package auth

import (
	"encoding/json"
	"errors"
	"os"
	"os/user"
	"path/filepath"
	"time"
)

type Tokens struct {
	AccessToken   string `json:"access_token"`
	RefreshToken  string `json:"refresh_token,omitempty"`
	ExpiresAtUnix int64  `json:"expires_at_unix"`
}

func (t Tokens) ExpiredSoon() bool {
	return t.AccessToken == "" || time.Now().Add(2*time.Minute).Unix() >= t.ExpiresAtUnix
}

func configDir() (string, error) {
	// TUN mode normally runs under sudo. In that case, credentials belong to
	// the invoking desktop user, not to root. Respect an explicit
	// XDG_CONFIG_HOME first, then SUDO_USER, then the current user's home.
	if x := os.Getenv("XDG_CONFIG_HOME"); x != "" {
		return filepath.Join(x, "firetunnel"), nil
	}
	if isRoot() {
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

func TokenPath() (string, error) {
	d, err := configDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(d, "tokens.json"), nil
}

func SaveTokens(t Tokens) error {
	if t.AccessToken == "" {
		return errors.New("refusing to save empty access token")
	}
	d, err := configDir()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(d, 0700); err != nil {
		return err
	}
	p := filepath.Join(d, "tokens.json")
	tmp, err := os.CreateTemp(d, "tokens-*.tmp")
	if err != nil {
		return err
	}
	name := tmp.Name()
	defer os.Remove(name)
	if err := tmp.Chmod(0600); err != nil {
		tmp.Close()
		return err
	}
	enc := json.NewEncoder(tmp)
	enc.SetIndent("", "  ")
	if err := enc.Encode(t); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(name, p)
}

func LoadTokens() (Tokens, error) {
	p, err := TokenPath()
	if err != nil {
		return Tokens{}, err
	}
	b, err := os.ReadFile(p)
	if err != nil {
		return Tokens{}, err
	}
	var t Tokens
	if err := json.Unmarshal(b, &t); err != nil {
		return Tokens{}, err
	}
	if t.AccessToken == "" {
		return Tokens{}, errors.New("saved token file contains no access token")
	}
	return t, nil
}

func ClearTokens() error {
	p, err := TokenPath()
	if err != nil {
		return err
	}
	if err := os.Remove(p); err != nil && !os.IsNotExist(err) {
		return err
	}
	return nil
}
