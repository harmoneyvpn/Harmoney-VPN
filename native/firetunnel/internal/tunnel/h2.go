package tunnel

import (
	"context"
	"crypto/tls"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

type H2Proxy struct {
	addr      string
	host      string
	token     string
	transport *http.Transport
}

func NewH2Proxy(ctx context.Context, addr, token string, timeout time.Duration) (*H2Proxy, error) {
	if !strings.Contains(addr, ":") {
		addr += ":2499"
	}
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return nil, err
	}
	// Resolve the Fastly endpoint before system routes/DNS are changed. Keep a
	// concrete dial address so TUN mode never needs DNS to reach its own VPN
	// upstream (which would otherwise create a resolver/tunnel recursion).
	ips, err := net.DefaultResolver.LookupIP(ctx, "ip", host)
	if err != nil {
		return nil, fmt.Errorf("resolve proxy %s: %w", host, err)
	}
	if len(ips) == 0 {
		return nil, fmt.Errorf("resolve proxy %s: no addresses returned", host)
	}
	chosen := ips[0]
	for _, ip := range ips {
		if ip.To4() != nil {
			chosen = ip
			break
		}
	}
	dialAddr := net.JoinHostPort(chosen.String(), port)
	d := &net.Dialer{Timeout: timeout, KeepAlive: 30 * time.Second}
	tr := &http.Transport{
		ForceAttemptHTTP2: true,
		DialContext: func(dctx context.Context, network, _ string) (net.Conn, error) {
			return d.DialContext(dctx, network, dialAddr)
		},
		TLSClientConfig: &tls.Config{
			ServerName: host,
			MinVersion: tls.VersionTLS12,
			NextProtos: []string{"h2", "http/1.1"},
		},
		TLSHandshakeTimeout: timeout,
		IdleConnTimeout:     90 * time.Second,
		MaxIdleConns:        4,
		MaxIdleConnsPerHost: 4,
	}
	// Probe TLS/ALPN once so connect fails early instead of waiting for
	// the first SOCKS client request.
	raw, err := tls.DialWithDialer(d, "tcp", dialAddr, &tls.Config{
		ServerName: host,
		MinVersion: tls.VersionTLS12,
		NextProtos: []string{"h2"},
	})
	if err != nil {
		return nil, err
	}
	proto := raw.ConnectionState().NegotiatedProtocol
	_ = raw.Close()
	if proto != "h2" {
		return nil, fmt.Errorf("proxy did not negotiate HTTP/2")
	}
	return &H2Proxy{addr: addr, host: host, token: token, transport: tr}, nil
}

func (p *H2Proxy) Close() error {
	p.transport.CloseIdleConnections()
	return nil
}

func (p *H2Proxy) OpenTunnel(ctx context.Context, authority string) (net.Conn, error) {
	pr, pw := io.Pipe()
	req, err := http.NewRequestWithContext(ctx, http.MethodConnect, "https://"+p.addr+"/", pr)
	if err != nil {
		return nil, err
	}
	req.Host = authority
	req.Header.Set("Proxy-Authorization", "Bearer "+p.token)

	resp, err := p.transport.RoundTrip(req)
	if err != nil {
		_ = pr.CloseWithError(err)
		_ = pw.CloseWithError(err)
		return nil, err
	}
	if resp.ProtoMajor != 2 {
		resp.Body.Close()
		_ = pr.Close()
		_ = pw.Close()
		return nil, fmt.Errorf("proxy CONNECT used %s instead of HTTP/2", resp.Proto)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		resp.Body.Close()
		_ = pr.Close()
		_ = pw.Close()
		return nil, fmt.Errorf("proxy CONNECT failed: %s: %s", resp.Status, strings.TrimSpace(string(b)))
	}
	return &streamConn{
		reader:     resp.Body,
		writer:     pw,
		closeRead:  resp.Body,
		closeWrite: pw,
		local:      dummyAddr("firetunnel"),
		remote:     dummyAddr(authority),
	}, nil
}

type dummyAddr string

func (d dummyAddr) Network() string { return "firetunnel" }
func (d dummyAddr) String() string  { return string(d) }

type streamConn struct {
	reader     io.Reader
	writer     io.Writer
	closeRead  io.Closer
	closeWrite io.Closer
	local      net.Addr
	remote     net.Addr
	once       sync.Once
}

func (c *streamConn) Read(b []byte) (int, error)  { return c.reader.Read(b) }
func (c *streamConn) Write(b []byte) (int, error) { return c.writer.Write(b) }
func (c *streamConn) Close() error {
	var err error
	c.once.Do(func() {
		if c.closeWrite != nil {
			_ = c.closeWrite.Close()
		}
		if c.closeRead != nil {
			err = c.closeRead.Close()
		}
	})
	return err
}
func (c *streamConn) LocalAddr() net.Addr              { return c.local }
func (c *streamConn) RemoteAddr() net.Addr             { return c.remote }
func (c *streamConn) SetDeadline(time.Time) error      { return nil }
func (c *streamConn) SetReadDeadline(time.Time) error  { return nil }
func (c *streamConn) SetWriteDeadline(time.Time) error { return nil }

