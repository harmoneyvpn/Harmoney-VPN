package linuxnet

import (
	"archive/zip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"runtime"
	"strings"
	"time"
)

const (
	Tun2SocksVersion = "2.7.0"
	Tun2SocksURL     = "https://github.com/xjasonlyu/tun2socks/releases/download/v2.7.0/tun2socks-linux-amd64.zip"
	Tun2SocksSHA256  = "a612baa287a3b6de6221f74fd02b442a50888508227ecf51e1288a5ccbb77381"
)

func invokingHome() (string, error) {
	if os.Geteuid() == 0 {
		if su := os.Getenv("SUDO_USER"); su != "" && su != "root" {
			if u, err := user.Lookup(su); err == nil && u.HomeDir != "" {
				return u.HomeDir, nil
			}
		}
	}
	return os.UserHomeDir()
}

func ManagedTun2SocksPath() (string, error) {
	h, err := invokingHome()
	if err != nil {
		return "", err
	}
	return filepath.Join(h, ".local", "share", "firetunnel", "bin", "tun2socks"), nil
}

func FindTun2Socks() (string, error) {
	if p := strings.TrimSpace(os.Getenv("FIRETUNNEL_TUN2SOCKS")); p != "" {
		if st, err := os.Stat(p); err == nil && !st.IsDir() {
			return p, nil
		}
	}
	if p, err := ManagedTun2SocksPath(); err == nil {
		if st, err := os.Stat(p); err == nil && !st.IsDir() {
			return p, nil
		}
	}
	for _, name := range []string{"tun2socks", "tun2socks-linux-amd64"} {
		if p, err := exec.LookPath(name); err == nil {
			return p, nil
		}
	}
	return "", fmt.Errorf("tun2socks not found; run './firetunnel setup-linux' first")
}

func InstallTun2Socks(ctx context.Context) (string, error) {
	if runtime.GOOS != "linux" || runtime.GOARCH != "amd64" {
		return "", fmt.Errorf("automatic tun2socks install currently supports linux/amd64 only; set FIRETUNNEL_TUN2SOCKS for another build")
	}
	dest, err := ManagedTun2SocksPath()
	if err != nil {
		return "", err
	}
	if err := os.MkdirAll(filepath.Dir(dest), 0755); err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, Tun2SocksURL, nil)
	if err != nil {
		return "", err
	}
	client := &http.Client{Timeout: 2 * time.Minute}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("download tun2socks: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("download tun2socks: HTTP %s", resp.Status)
	}

	tmpZip, err := os.CreateTemp("", "firetunnel-tun2socks-*.zip")
	if err != nil {
		return "", err
	}
	zipName := tmpZip.Name()
	defer os.Remove(zipName)
	h := sha256.New()
	if _, err := io.Copy(io.MultiWriter(tmpZip, h), resp.Body); err != nil {
		tmpZip.Close()
		return "", err
	}
	if err := tmpZip.Close(); err != nil {
		return "", err
	}
	got := hex.EncodeToString(h.Sum(nil))
	if got != Tun2SocksSHA256 {
		return "", fmt.Errorf("tun2socks SHA256 mismatch: got %s", got)
	}

	zr, err := zip.OpenReader(zipName)
	if err != nil {
		return "", err
	}
	defer zr.Close()
	var src *zip.File
	for _, f := range zr.File {
		base := filepath.Base(f.Name)
		if strings.HasPrefix(base, "tun2socks-linux-amd64") && !f.FileInfo().IsDir() {
			src = f
			break
		}
	}
	if src == nil {
		return "", fmt.Errorf("tun2socks binary not found in downloaded archive")
	}
	in, err := src.Open()
	if err != nil {
		return "", err
	}
	defer in.Close()
	tmp, err := os.CreateTemp(filepath.Dir(dest), ".tun2socks-*")
	if err != nil {
		return "", err
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName)
	if _, err := io.Copy(tmp, in); err != nil {
		tmp.Close()
		return "", err
	}
	if err := tmp.Chmod(0755); err != nil {
		tmp.Close()
		return "", err
	}
	if err := tmp.Close(); err != nil {
		return "", err
	}
	if err := os.Rename(tmpName, dest); err != nil {
		return "", err
	}
	return dest, nil
}

type Tun2SocksProcess struct {
	cmd *exec.Cmd
}

func StartTun2Socks(ctx context.Context, binary, ifname, proxy, physicalIf string) (*Tun2SocksProcess, error) {
	args := []string{"--device", "tun://" + ifname, "--proxy", proxy, "--loglevel", "info"}
	if physicalIf != "" {
		args = append(args, "--interface", physicalIf)
	}
	cmd := exec.CommandContext(ctx, binary, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Start(); err != nil {
		return nil, err
	}
	p := &Tun2SocksProcess{cmd: cmd}
	go func() { _ = cmd.Wait() }()
	return p, nil
}

func (p *Tun2SocksProcess) Stop() {
	if p == nil || p.cmd == nil || p.cmd.Process == nil {
		return
	}
	_ = p.cmd.Process.Signal(os.Interrupt)
	done := make(chan struct{})
	go func() { _, _ = p.cmd.Process.Wait(); close(done) }()
	select {
	case <-done:
	case <-time.After(2 * time.Second):
		_ = p.cmd.Process.Kill()
	}
}

