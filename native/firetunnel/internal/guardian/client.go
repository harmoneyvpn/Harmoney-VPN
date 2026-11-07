package guardian

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"firetunnel/internal/netutil"
)

const Endpoint = "https://vpn.mozilla.org"

var ErrQuotaExceeded = errors.New("monthly quota exceeded")

type Claims struct {
	Sub string `json:"sub"`
	Aud string `json:"aud"`
	Iat int64  `json:"iat"`
	Nbf int64  `json:"nbf"`
	Exp int64  `json:"exp"`
	Iss string `json:"iss"`
}

type ProxyPass struct {
	Token          string
	Claims         Claims
	QuotaLimit     string
	QuotaRemaining string
	QuotaReset     string
}

type Entitlement struct {
	Subscribed       bool   `json:"subscribed"`
	UID              int    `json:"uid"`
	MaxBytes         string `json:"maxBytes"`
	LimitedBandwidth bool   `json:"limited_bandwidth"`
}

func headers(req *http.Request) {
	req.Header.Set("Authorization", req.Header.Get("Authorization"))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "MozillaVPN/2.35.0 (sys:linux; iap:true)")
}

func FetchProxyPass(ctx context.Context, accessToken string) (*ProxyPass, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, Endpoint+"/api/v1/fpn/token", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	headers(req)
	resp, err := netutil.MozillaClient(20 * time.Second).Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode == http.StatusTooManyRequests {
		return nil, fmt.Errorf("%w: %s", ErrQuotaExceeded, strings.TrimSpace(string(data)))
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Guardian token HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var body struct {
		Token string `json:"token"`
	}
	if err := json.Unmarshal(data, &body); err != nil {
		return nil, err
	}
	if body.Token == "" {
		return nil, fmt.Errorf("Guardian returned an empty ProxyPass")
	}
	claims, err := parseClaims(body.Token)
	if err != nil {
		return nil, err
	}
	return &ProxyPass{
		Token: body.Token, Claims: claims,
		QuotaLimit:     resp.Header.Get("X-Quota-Limit"),
		QuotaRemaining: resp.Header.Get("X-Quota-Remaining"),
		QuotaReset:     resp.Header.Get("X-Quota-Reset"),
	}, nil
}

func Status(ctx context.Context, accessToken string) (*Entitlement, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, Endpoint+"/api/v1/fpn/status", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	headers(req)
	resp, err := netutil.MozillaClient(20 * time.Second).Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Guardian status HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var e Entitlement
	if err := json.Unmarshal(data, &e); err != nil {
		return nil, err
	}
	return &e, nil
}

func Activate(ctx context.Context, accessToken string) (*Entitlement, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, Endpoint+"/api/v1/fpn/activate", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	headers(req)
	resp, err := netutil.MozillaClient(20 * time.Second).Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Guardian activate HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(data)))
	}
	var e Entitlement
	if err := json.Unmarshal(data, &e); err != nil {
		return nil, err
	}
	return &e, nil
}

func parseClaims(token string) (Claims, error) {
	var c Claims
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return c, fmt.Errorf("invalid ProxyPass JWT")
	}
	b, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return c, err
	}
	if err := json.Unmarshal(b, &c); err != nil {
		return c, err
	}
	return c, nil
}

func (p *ProxyPass) ExpiresAt() time.Time {
	return time.Unix(p.Claims.Exp, 0)
}
