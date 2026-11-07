package dnsproxy

import (
	"bufio"
	"bytes"
	"context"
	"crypto/tls"
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"net/http"
	"time"

	"firetunnel/internal/tunnel"
)

type Proxy struct {
	Listen   string
	Upstream *tunnel.H2Proxy
	SOCKS    string
	Target   string
	SNI      string
	Path     string
	Ready    chan<- struct{}
}

func (p *Proxy) defaults() {
	if p.Listen == "" {
		p.Listen = "198.18.0.2:53"
	}
	if p.Target == "" {
		p.Target = "cloudflare-dns.com:443"
	}
	if p.SNI == "" {
		p.SNI = "cloudflare-dns.com"
	}
	if p.Path == "" {
		p.Path = "/dns-query"
	}
}

func (p *Proxy) Serve(ctx context.Context) error {
	p.defaults()
	ua, err := net.ResolveUDPAddr("udp", p.Listen)
	if err != nil {
		return err
	}
	udp, err := net.ListenUDP("udp", ua)
	if err != nil {
		return fmt.Errorf("DNS UDP listen %s: %w", p.Listen, err)
	}
	tcp, err := net.Listen("tcp", p.Listen)
	if err != nil {
		_ = udp.Close()
		return fmt.Errorf("DNS TCP listen %s: %w", p.Listen, err)
	}
	if p.Ready != nil {
		close(p.Ready)
	}

	errc := make(chan error, 2)
	go func() {
		defer udp.Close()
		buf := make([]byte, 65535)
		for {
			n, client, err := udp.ReadFromUDP(buf)
			if err != nil {
				if ctx.Err() != nil {
					errc <- nil
					return
				}
				errc <- err
				return
			}
			q := append([]byte(nil), buf[:n]...)
			go func() {
				resp, err := p.exchange(ctx, q)
				if err == nil && len(resp) > 0 {
					_, _ = udp.WriteToUDP(resp, client)
				}
			}()
		}
	}()

	go func() {
		defer tcp.Close()
		for {
			c, err := tcp.Accept()
			if err != nil {
				if ctx.Err() != nil {
					errc <- nil
					return
				}
				errc <- err
				return
			}
			go p.handleTCP(ctx, c)
		}
	}()

	go func() { <-ctx.Done(); _ = udp.Close(); _ = tcp.Close() }()
	select {
	case <-ctx.Done():
		return nil
	case err := <-errc:
		return err
	}
}

func (p *Proxy) handleTCP(parent context.Context, c net.Conn) {
	defer c.Close()
	_ = c.SetDeadline(time.Now().Add(15 * time.Second))
	var hdr [2]byte
	if _, err := io.ReadFull(c, hdr[:]); err != nil {
		return
	}
	n := int(binary.BigEndian.Uint16(hdr[:]))
	if n <= 0 || n > 65535 {
		return
	}
	q := make([]byte, n)
	if _, err := io.ReadFull(c, q); err != nil {
		return
	}
	resp, err := p.exchange(parent, q)
	if err != nil || len(resp) == 0 || len(resp) > 65535 {
		return
	}
	binary.BigEndian.PutUint16(hdr[:], uint16(len(resp)))
	_, _ = c.Write(hdr[:])
	_, _ = c.Write(resp)
}

func (p *Proxy) exchange(parent context.Context, query []byte) ([]byte, error) {
	if len(query) == 0 || len(query) > 65535 {
		return nil, fmt.Errorf("invalid DNS message size")
	}
	ctx, cancel := context.WithTimeout(parent, 12*time.Second)
	defer cancel()

	var raw net.Conn
	var err error
	if p.Upstream != nil {
		raw, err = p.Upstream.OpenTunnel(ctx, p.Target)
	} else if p.SOCKS != "" {
		raw, err = socksConnect(ctx, p.SOCKS, p.Target)
	} else {
		err = fmt.Errorf("DNS proxy has no upstream transport")
	}
	if err != nil {
		return nil, fmt.Errorf("open DoH tunnel: %w", err)
	}
	defer raw.Close()

	tc := tls.Client(raw, &tls.Config{ServerName: p.SNI, MinVersion: tls.VersionTLS12, NextProtos: []string{"http/1.1"}})
	if err := tc.HandshakeContext(ctx); err != nil {
		return nil, fmt.Errorf("DoH TLS: %w", err)
	}
	defer tc.Close()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://"+p.SNI+p.Path, bytes.NewReader(query))
	if err != nil {
		return nil, err
	}
	req.Host = p.SNI
	req.Header.Set("Content-Type", "application/dns-message")
	req.Header.Set("Accept", "application/dns-message")
	req.Header.Set("Connection", "close")
	req.ContentLength = int64(len(query))
	if err := req.Write(tc); err != nil {
		return nil, fmt.Errorf("DoH request: %w", err)
	}

	resp, err := http.ReadResponse(bufio.NewReader(tc), req)
	if err != nil {
		return nil, fmt.Errorf("DoH response: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("DoH HTTP %s", resp.Status)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 65536))
	if err != nil {
		return nil, err
	}
	if len(body) == 0 || len(body) > 65535 {
		return nil, fmt.Errorf("invalid DoH response size")
	}
	return body, nil
}

// socksConnect opens a TCP stream through the local Xray SOCKS5 inbound.
func socksConnect(ctx context.Context, proxyAddress, target string) (net.Conn, error) {
	conn, err := (&net.Dialer{}).DialContext(ctx, "tcp", proxyAddress)
	if err != nil {
		return nil, err
	}
	failed := true
	defer func() {
		if failed {
			_ = conn.Close()
		}
	}()
	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	}
	if _, err = conn.Write([]byte{0x05, 0x01, 0x00}); err != nil {
		return nil, err
	}
	var greeting [2]byte
	if _, err = io.ReadFull(conn, greeting[:]); err != nil {
		return nil, err
	}
	if greeting != [2]byte{0x05, 0x00} {
		return nil, fmt.Errorf("local SOCKS proxy rejected no-auth method")
	}
	host, portText, err := net.SplitHostPort(target)
	if err != nil {
		return nil, err
	}
	port, err := net.LookupPort("tcp", portText)
	if err != nil || port < 1 || port > 65535 {
		return nil, fmt.Errorf("invalid DoH target port")
	}
	request := []byte{0x05, 0x01, 0x00}
	if ip := net.ParseIP(host); ip != nil {
		if ip4 := ip.To4(); ip4 != nil {
			request = append(request, 0x01)
			request = append(request, ip4...)
		} else {
			request = append(request, 0x04)
			request = append(request, ip.To16()...)
		}
	} else {
		if len(host) == 0 || len(host) > 255 {
			return nil, fmt.Errorf("invalid DoH target host")
		}
		request = append(request, 0x03, byte(len(host)))
		request = append(request, host...)
	}
	request = append(request, byte(port>>8), byte(port))
	if _, err = conn.Write(request); err != nil {
		return nil, err
	}
	var response [4]byte
	if _, err = io.ReadFull(conn, response[:]); err != nil {
		return nil, err
	}
	if response[0] != 0x05 || response[1] != 0x00 {
		return nil, fmt.Errorf("local SOCKS proxy failed to connect to DoH endpoint (code %d)", response[1])
	}
	addressLength := 0
	switch response[3] {
	case 0x01:
		addressLength = 4
	case 0x04:
		addressLength = 16
	case 0x03:
		var n [1]byte
		if _, err = io.ReadFull(conn, n[:]); err != nil {
			return nil, err
		}
		addressLength = int(n[0])
	default:
		return nil, fmt.Errorf("local SOCKS proxy returned an invalid address type")
	}
	if _, err = io.CopyN(io.Discard, conn, int64(addressLength+2)); err != nil {
		return nil, err
	}
	_ = conn.SetDeadline(time.Time{})
	failed = false
	return conn, nil
}
