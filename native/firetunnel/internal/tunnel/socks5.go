package tunnel

import (
	"context"
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"strconv"
	"sync"
	"time"
)

type SOCKSServer struct {
	Listen   string
	Upstream *H2Proxy
}

func (s *SOCKSServer) Serve(ctx context.Context) error {
	ln, err := net.Listen("tcp", s.Listen)
	if err != nil {
		return err
	}
	defer ln.Close()
	go func() { <-ctx.Done(); _ = ln.Close() }()
	for {
		c, err := ln.Accept()
		if err != nil {
			if ctx.Err() != nil {
				return nil
			}
			return err
		}
		go s.handle(ctx, c)
	}
}

func (s *SOCKSServer) handle(ctx context.Context, c net.Conn) {
	defer c.Close()
	target, cmd, err := socksHandshake(c)
	if err != nil {
		return
	}
	if cmd != 1 {
		// RFC 1928 reply 0x07 = command not supported. This makes UDP/QUIC
		// failure explicit to tun2socks instead of resetting the TCP control
		// connection. Native MASQUE CONNECT-UDP will replace this in the
		// dedicated UDP transport.
		_, _ = c.Write([]byte{5, 7, 0, 1, 0, 0, 0, 0, 0, 0})
		return
	}
	up, err := s.Upstream.OpenTunnel(ctx, target)
	if err != nil {
		_, _ = c.Write([]byte{5, 1, 0, 1, 0, 0, 0, 0, 0, 0})
		return
	}
	defer up.Close()
	_, _ = c.Write([]byte{5, 0, 0, 1, 0, 0, 0, 0, 0, 0})
	var wg sync.WaitGroup
	wg.Add(2)
	go func() { defer wg.Done(); _, _ = io.Copy(up, c) }()
	go func() { defer wg.Done(); _, _ = io.Copy(c, up) }()
	wg.Wait()
}

func socksHandshake(c net.Conn) (string, byte, error) {
	_ = c.SetDeadline(time.Now().Add(15 * time.Second))
	defer c.SetDeadline(time.Time{})
	h := make([]byte, 2)
	if _, err := io.ReadFull(c, h); err != nil {
		return "", 0, err
	}
	if h[0] != 5 {
		return "", 0, fmt.Errorf("SOCKS version %d unsupported", h[0])
	}
	methods := make([]byte, int(h[1]))
	if _, err := io.ReadFull(c, methods); err != nil {
		return "", 0, err
	}
	if _, err := c.Write([]byte{5, 0}); err != nil {
		return "", 0, err
	}
	req := make([]byte, 4)
	if _, err := io.ReadFull(c, req); err != nil {
		return "", 0, err
	}
	if req[0] != 5 {
		return "", 0, fmt.Errorf("SOCKS version %d unsupported", req[0])
	}
	cmd := req[1]
	var host string
	switch req[3] {
	case 1:
		b := make([]byte, 4)
		if _, err := io.ReadFull(c, b); err != nil {
			return "", 0, err
		}
		host = net.IP(b).String()
	case 3:
		l := make([]byte, 1)
		if _, err := io.ReadFull(c, l); err != nil {
			return "", 0, err
		}
		b := make([]byte, int(l[0]))
		if _, err := io.ReadFull(c, b); err != nil {
			return "", 0, err
		}
		host = string(b)
	case 4:
		b := make([]byte, 16)
		if _, err := io.ReadFull(c, b); err != nil {
			return "", 0, err
		}
		host = net.IP(b).String()
	default:
		return "", 0, fmt.Errorf("unsupported address type")
	}
	p := make([]byte, 2)
	if _, err := io.ReadFull(c, p); err != nil {
		return "", 0, err
	}
	port := binary.BigEndian.Uint16(p)
	return net.JoinHostPort(host, strconv.Itoa(int(port))), cmd, nil
}

