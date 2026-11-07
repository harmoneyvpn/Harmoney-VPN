package serverlist

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"os/user"
	"path/filepath"
	"sort"
	"time"

	"firetunnel/internal/provider"
	"firetunnel/internal/provider/firefox"
)

//go:embed bootstrap.json
var bootstrapBytes []byte

type Snapshot struct {
	FetchedAt time.Time          `json:"fetched_at"`
	Source    string             `json:"source"`
	Countries []provider.Country `json:"countries"`
}

type Result struct {
	Countries []provider.Country
	Source    string
	Err       error
}

func Bootstrap() ([]provider.Country, error) {
	var v []provider.Country
	if err := json.Unmarshal(bootstrapBytes, &v); err != nil {
		return nil, err
	}
	return v, nil
}

func ConfigDir() (string, error) {
	if x := os.Getenv("XDG_CONFIG_HOME"); x != "" {
		return filepath.Join(x, "firetunnel"), nil
	}
	if os.Geteuid() == 0 {
		if sudoUser := os.Getenv("SUDO_USER"); sudoUser != "" && sudoUser != "root" {
			if u, err := user.Lookup(sudoUser); err == nil && u.HomeDir != "" {
				return filepath.Join(u.HomeDir, ".config", "firetunnel"), nil
			}
		}
	}
	h, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(h, ".config", "firetunnel"), nil
}

func CachePath() (string, error) {
	d, err := ConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(d, "serverlist.json"), nil
}

func LoadCache() (*Snapshot, error) {
	p, err := CachePath()
	if err != nil {
		return nil, err
	}
	b, err := os.ReadFile(p)
	if err != nil {
		return nil, err
	}
	var s Snapshot
	if err := json.Unmarshal(b, &s); err != nil {
		return nil, err
	}
	if len(s.Countries) == 0 {
		return nil, errors.New("cache contains no countries")
	}
	return &s, nil
}

func SaveCache(countries []provider.Country, source string) error {
	if len(countries) == 0 {
		return errors.New("refusing to overwrite cache with empty server list")
	}
	d, err := ConfigDir()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(d, 0700); err != nil {
		return err
	}
	p := filepath.Join(d, "serverlist.json")
	tmp, err := os.CreateTemp(d, "serverlist-*.tmp")
	if err != nil {
		return err
	}
	name := tmp.Name()
	defer os.Remove(name)
	enc := json.NewEncoder(tmp)
	enc.SetIndent("", "  ")
	if err := enc.Encode(Snapshot{FetchedAt: time.Now().UTC(), Source: source, Countries: countries}); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Chmod(0600); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(name, p)
}

// Resolve prefers live data, then a previously validated cache, then the embedded
// bootstrap. This gives normal networks fresh data while still allowing startup
// when Mozilla Remote Settings is unreachable.
func Resolve(ctx context.Context) Result {
	live, err := firefox.New().Locations(ctx)
	if err == nil && validate(live) == nil {
		_ = SaveCache(live, "mozilla-remote-settings")
		return Result{Countries: live, Source: "live"}
	}
	if cache, cacheErr := LoadCache(); cacheErr == nil && validate(cache.Countries) == nil {
		return Result{Countries: cache.Countries, Source: "cache", Err: err}
	}
	boot, bootErr := Bootstrap()
	if bootErr == nil && validate(boot) == nil {
		return Result{Countries: boot, Source: "embedded-bootstrap", Err: err}
	}
	return Result{Err: fmt.Errorf("live: %v; bootstrap: %v", err, bootErr)}
}

func Refresh(ctx context.Context) (int, error) {
	live, err := firefox.New().Locations(ctx)
	if err != nil {
		return 0, err
	}
	if err := validate(live); err != nil {
		return 0, err
	}
	if err := SaveCache(live, "mozilla-remote-settings"); err != nil {
		return 0, err
	}
	return len(live), nil
}

func validate(c []provider.Country) error {
	if len(c) == 0 {
		return errors.New("empty list")
	}
	servers := 0
	for _, country := range c {
		for _, city := range country.Cities {
			for _, s := range city.Servers {
				if s.Hostname == "" || s.Port <= 0 || s.Port > 65535 {
					continue
				}
				servers++
			}
		}
	}
	if servers == 0 {
		return errors.New("list has no usable servers")
	}
	return nil
}

type ProbeResult struct {
	Host      string
	Port      int
	Reachable bool
	Latency   time.Duration
	Err       error
}

func Probe(ctx context.Context, countries []provider.Country, limit int) []ProbeResult {
	seen := map[string]bool{}
	var targets []provider.Server
	for _, c := range countries {
		for _, city := range c.Cities {
			for _, s := range city.Servers {
				if s.Quarantined {
					continue
				}
				key := fmt.Sprintf("%s:%d", s.Hostname, s.Port)
				if !seen[key] {
					seen[key] = true
					targets = append(targets, s)
				}
			}
		}
	}
	if limit > 0 && len(targets) > limit {
		targets = targets[:limit]
	}
	out := make([]ProbeResult, 0, len(targets))
	for _, s := range targets {
		start := time.Now()
		d := net.Dialer{Timeout: 2500 * time.Millisecond}
		conn, err := d.DialContext(ctx, "tcp", fmt.Sprintf("%s:%d", s.Hostname, s.Port))
		lat := time.Since(start)
		if err == nil {
			conn.Close()
		}
		out = append(out, ProbeResult{Host: s.Hostname, Port: s.Port, Reachable: err == nil, Latency: lat, Err: err})
	}
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].Reachable != out[j].Reachable {
			return out[i].Reachable
		}
		return out[i].Latency < out[j].Latency
	})
	return out
}

