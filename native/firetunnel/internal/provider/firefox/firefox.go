package firefox

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"firetunnel/internal/netutil"
	"firetunnel/internal/provider"
)

const ServerListURL = "https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/vpn-serverlist/records"

type Client struct{ http *http.Client }

func New() *Client             { return &Client{http: netutil.MozillaClient(15 * time.Second)} }
func (c *Client) Name() string { return "firefox-built-in-vpn" }

type envelope struct {
	Data []provider.Country `json:"data"`
}

func (c *Client) Locations(ctx context.Context) ([]provider.Country, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, ServerListURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "FireTunnel/0.1.1")
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetch Mozilla server list: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		return nil, fmt.Errorf("Mozilla server list HTTP %d: %s", resp.StatusCode, string(body))
	}
	var env envelope
	if err := json.NewDecoder(resp.Body).Decode(&env); err != nil {
		return nil, fmt.Errorf("decode server list: %w", err)
	}
	if len(env.Data) == 0 {
		return nil, fmt.Errorf("Mozilla server list was empty")
	}
	return env.Data, nil
}
