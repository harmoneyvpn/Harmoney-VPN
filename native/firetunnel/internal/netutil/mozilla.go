package netutil

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// Mozilla endpoints are served by Fastly. These bootstrap addresses are only
// used when the local system resolver returns SERVFAIL/misbehaving; TLS still
// uses the original hostname from the URL, so certificate and SNI validation
// are unchanged.
var mozillaBootstrapIPv4 = map[string][]string{
	"vpn.mozilla.org": {
		"151.101.1.91", "151.101.65.91", "151.101.129.91", "151.101.193.91",
	},
	"firefox.settings.services.mozilla.com": {
		"151.101.1.91", "151.101.65.91", "151.101.129.91", "151.101.193.91",
	},
}

// MozillaClient returns an HTTP client that survives a broken local
// systemd-resolved stub during Firefox account/server-list bootstrap.
func MozillaClient(timeout time.Duration) *http.Client {
	dialer := &net.Dialer{Timeout: 8 * time.Second, KeepAlive: 30 * time.Second}
	transport := &http.Transport{
		Proxy:                 http.ProxyFromEnvironment,
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          8,
		IdleConnTimeout:       30 * time.Second,
		TLSHandshakeTimeout:   8 * time.Second,
		ResponseHeaderTimeout: 15 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	}
	transport.DialContext = func(ctx context.Context, network, address string) (net.Conn, error) {
		host, port, err := net.SplitHostPort(address)
		if err != nil {
			return nil, err
		}

		ips, lookupErr := net.DefaultResolver.LookupIPAddr(ctx, host)
		var candidates []string
		for _, ip := range ips {
			if v4 := ip.IP.To4(); v4 != nil {
				candidates = append(candidates, v4.String())
			}
		}
		if len(candidates) == 0 {
			candidates = append(candidates, mozillaBootstrapIPv4[strings.ToLower(host)]...)
		}
		if len(candidates) == 0 {
			if lookupErr != nil {
				return nil, lookupErr
			}
			return nil, fmt.Errorf("no IPv4 address for %s", host)
		}

		var lastErr error
		for _, ip := range candidates {
			conn, dialErr := dialer.DialContext(ctx, network, net.JoinHostPort(ip, port))
			if dialErr == nil {
				return conn, nil
			}
			lastErr = dialErr
		}
		return nil, fmt.Errorf("dial %s via %s: %w", host, strconv.Itoa(len(candidates)), lastErr)
	}
	return &http.Client{Transport: transport, Timeout: timeout}
}
