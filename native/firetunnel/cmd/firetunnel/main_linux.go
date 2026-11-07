package main

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"firetunnel/internal/auth"
	"firetunnel/internal/dnsproxy"
	"firetunnel/internal/guardian"
	"firetunnel/internal/linuxnet"
	"firetunnel/internal/provider"
	"firetunnel/internal/serverlist"
	"firetunnel/internal/tunnel"
	"net"
)

const version = "0.4.0-alpha"

func usage() {
	fmt.Printf(`FireTunnel %s

Usage:
  firetunnel doctor
  firetunnel locations [--json]
  firetunnel app-state [--country DE]
  firetunnel refresh
  firetunnel bootstrap
  firetunnel probe
  firetunnel login [--email EMAIL]
  firetunnel logout
  firetunnel quota [--json]
  firetunnel connect [--country DE] [--listen 127.0.0.1:1080]
  firetunnel system-proxy [--country DE]
  firetunnel setup-linux
  firetunnel linux-tun [--country DE] [--killswitch]
  firetunnel version
`, version)
}

func main() {
	if len(os.Args) < 2 {
		usage()
		return
	}
	switch os.Args[1] {
	case "version":
		fmt.Println("FireTunnel", version)
	case "doctor":
		doctor()
	case "login":
		loginCmd(os.Args[2:])
	case "login-json":
		loginJSONCmd()
	case "logout":
		if err := auth.ClearTokens(); err != nil {
			fatal(err)
		}
		fmt.Println("Saved FireTunnel tokens cleared.")
	case "quota":
		quotaCmd(os.Args[2:])
	case "connect":
		connectCmd(os.Args[2:])
	case "system-proxy":
		systemProxyCmd(os.Args[2:])
	case "setup-linux":
		setupLinuxCmd()
	case "linux-tun":
		linuxTunCmd(os.Args[2:])
	case "locations":
		locationsCmd(os.Args[2:])
	case "app-state":
		appStateCmd(os.Args[2:])
	case "refresh":
		refreshCmd()
	case "bootstrap":
		c, err := serverlist.Bootstrap()
		if err != nil {
			fatal(err)
		}
		printLocations(c, "embedded-bootstrap")
	case "probe":
		probeCmd()
	default:
		usage()
	}
}

func loginJSONCmd() {
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
		Code     string `json:"code,omitempty"`
	}
	if err := json.NewDecoder(io.LimitReader(os.Stdin, 16<<10)).Decode(&req); err != nil {
		jsonError("invalid_request", err)
		return
	}
	req.Email = strings.TrimSpace(req.Email)
	if req.Email == "" || len(req.Email) > 320 || req.Password == "" || len(req.Password) > 2048 {
		jsonError("invalid_credentials", errors.New("email and password are required"))
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	lr, err := auth.Login(ctx, req.Email, req.Password)
	req.Password = ""
	if err != nil {
		jsonError("authentication_failed", err)
		return
	}
	if !lr.Verified {
		if strings.TrimSpace(req.Code) == "" {
			_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": "verification_required"})
			return
		}
		if err := auth.VerifyCode(ctx, lr.SessionToken, strings.TrimSpace(req.Code)); err != nil {
			jsonError("verification_failed", err)
			return
		}
	}
	tok, err := auth.OAuthFromSession(ctx, lr.SessionToken)
	if err != nil {
		jsonError("oauth_failed", err)
		return
	}
	if err := auth.SaveTokens(tok); err != nil {
		jsonError("token_store_failed", err)
		return
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		jsonError("guardian_failed", err)
		return
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{
		"ok": true, "logged_in": true,
		"quota": map[string]any{"limit": pass.QuotaLimit, "remaining": pass.QuotaRemaining, "reset": pass.QuotaReset},
	})
}

func jsonError(code string, err error) {
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": code, "error": err.Error()})
}

func loginCmd(args []string) {
	fs := flag.NewFlagSet("login", flag.ExitOnError)
	email := fs.String("email", "", "Firefox Account email")
	_ = fs.Parse(args)
	r := bufio.NewReader(os.Stdin)
	if strings.TrimSpace(*email) == "" {
		fmt.Print("Firefox Account email: ")
		v, _ := r.ReadString('\n')
		*email = strings.TrimSpace(v)
	}
	fmt.Print("Password: ")
	pw, err := readPassword()
	fmt.Println()
	if err != nil {
		fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	lr, err := auth.Login(ctx, *email, string(pw))
	if err != nil {
		fatal(err)
	}
	if !lr.Verified {
		fmt.Print("Email verification code: ")
		code, _ := r.ReadString('\n')
		if err := auth.VerifyCode(ctx, lr.SessionToken, strings.TrimSpace(code)); err != nil {
			fatal(err)
		}
	}
	tok, err := auth.OAuthFromSession(ctx, lr.SessionToken)
	if err != nil {
		fatal(err)
	}
	if err := auth.SaveTokens(tok); err != nil {
		fatal(err)
	}
	p, _ := auth.TokenPath()
	fmt.Println("Login successful.")
	fmt.Println("Token store:", p)
	if _, err := guardian.Status(ctx, tok.AccessToken); err != nil {
		fmt.Println("Guardian status note:", err)
		fmt.Println("Trying Guardian activation...")
		if _, aerr := guardian.Activate(ctx, tok.AccessToken); aerr != nil {
			fmt.Println("Guardian activation note:", aerr)
		}
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		fatal(fmt.Errorf("login succeeded but ProxyPass failed: %w", err))
	}
	fmt.Printf("ProxyPass OK. Expires: %s\n", pass.ExpiresAt().Local().Format(time.RFC3339))
	printQuota(pass)
}

func quotaCmd(args []string) {
	fs := flag.NewFlagSet("quota", flag.ExitOnError)
	jsonOut := fs.Bool("json", false, "machine-readable JSON")
	_ = fs.Parse(args)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	tok, err := auth.ValidTokens(ctx)
	if err != nil {
		fatal(fmt.Errorf("not logged in: %w", err))
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		fatal(err)
	}
	if *jsonOut {
		_ = json.NewEncoder(os.Stdout).Encode(map[string]any{
			"quota_limit":     pass.QuotaLimit,
			"quota_remaining": pass.QuotaRemaining,
			"quota_reset":     pass.QuotaReset,
			"expires_at":      pass.ExpiresAt().Format(time.RFC3339),
		})
		return
	}
	printQuota(pass)
}

func printQuota(p *guardian.ProxyPass) {
	fmt.Println("Quota limit:    ", blank(p.QuotaLimit))
	fmt.Println("Quota remaining:", blank(p.QuotaRemaining))
	fmt.Println("Quota reset:    ", blank(p.QuotaReset))
}

func connectCmd(args []string) {
	fs := flag.NewFlagSet("connect", flag.ExitOnError)
	country := fs.String("country", "REC", "country code/name (default recommended)")
	listen := fs.String("listen", "127.0.0.1:1080", "local SOCKS5 listen address")
	timeout := fs.Duration("timeout", 15*time.Second, "upstream handshake timeout")
	_ = fs.Parse(args)

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	tok, err := auth.ValidTokens(ctx)
	if err != nil {
		fatal(fmt.Errorf("not logged in; run 'firetunnel login': %w", err))
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		fatal(err)
	}

	slctx, slcancel := context.WithTimeout(ctx, 12*time.Second)
	res := serverlist.Resolve(slctx)
	slcancel()
	if len(res.Countries) == 0 {
		fatal(res.Err)
	}
	cand, err := serverlist.Select(res.Countries, *country)
	if err != nil {
		fatal(err)
	}
	fmt.Printf("Upstream: %s / %s (%s) -> %s\n", cand.CountryName, cand.CityName, cand.CountryCode, cand.Addr)
	fmt.Println("Server-list source:", res.Source)

	up, err := tunnel.NewH2Proxy(ctx, cand.Addr, pass.Token, *timeout)
	if err != nil {
		fatal(fmt.Errorf("HTTP/2 upstream: %w", err))
	}
	defer up.Close()

	s := &tunnel.SOCKSServer{Listen: *listen, Upstream: up}
	fmt.Println("FireTunnel SOCKS5 is listening on", *listen)
	fmt.Println("Test in another terminal:")
	fmt.Printf("  curl --socks5-hostname %s https://www.cloudflare.com/cdn-cgi/trace\n", *listen)
	fmt.Println("Press Ctrl+C to disconnect.")
	if err := s.Serve(ctx); err != nil {
		fatal(err)
	}
}

func locationsCmd(args []string) {
	fs := flag.NewFlagSet("locations", flag.ExitOnError)
	jsonOut := fs.Bool("json", false, "machine-readable JSON")
	_ = fs.Parse(args)
	ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
	defer cancel()
	r := serverlist.Resolve(ctx)
	if len(r.Countries) == 0 {
		fatal(r.Err)
	}
	if *jsonOut {
		_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"source": r.Source, "locations": r.Countries})
		return
	}
	if r.Err != nil {
		fmt.Fprintln(os.Stderr, "note: fallback activated:", r.Err)
	}
	printLocations(r.Countries, r.Source)
}

func appStateCmd(args []string) {
	fs := flag.NewFlagSet("app-state", flag.ExitOnError)
	country := fs.String("country", "REC", "country code/name")
	_ = fs.Parse(args)

	type state struct {
		Version          string          `json:"version"`
		LoggedIn         bool            `json:"logged_in"`
		Tun2SocksReady   bool            `json:"tun2socks_ready"`
		Tun2SocksPath    string          `json:"tun2socks_path,omitempty"`
		ServerListSource string          `json:"server_list_source,omitempty"`
		Selected         any             `json:"selected,omitempty"`
		Locations        any             `json:"locations,omitempty"`
		Quota            any             `json:"quota,omitempty"`
		Capabilities     map[string]bool `json:"capabilities"`
		Warnings         []string        `json:"warnings,omitempty"`
	}
	out := state{Version: version, Capabilities: map[string]bool{
		"tcp_tun": true, "dns_doh": true, "udp_masque": false, "linux_tun": true,
	}}
	if p, err := linuxnet.FindTun2Socks(); err == nil {
		out.Tun2SocksReady = true
		out.Tun2SocksPath = p
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	if tok, err := auth.ValidTokens(ctx); err == nil {
		out.LoggedIn = true
		if pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken); err == nil {
			out.Quota = map[string]any{"limit": pass.QuotaLimit, "remaining": pass.QuotaRemaining, "reset": pass.QuotaReset}
		} else {
			out.Warnings = append(out.Warnings, "quota unavailable: "+err.Error())
		}
	}
	r := serverlist.Resolve(ctx)
	if len(r.Countries) > 0 {
		out.ServerListSource = r.Source
		out.Locations = r.Countries
		if c, err := serverlist.Select(r.Countries, *country); err == nil {
			out.Selected = c
		}
	} else if r.Err != nil {
		out.Warnings = append(out.Warnings, "server list unavailable: "+r.Err.Error())
	}
	_ = json.NewEncoder(os.Stdout).Encode(out)
}

func refreshCmd() {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	n, err := serverlist.Refresh(ctx)
	if err != nil {
		fatal(err)
	}
	p, _ := serverlist.CachePath()
	fmt.Printf("Updated cache atomically: %d countries\n%s\n", n, p)
}
func probeCmd() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	r := serverlist.Resolve(ctx)
	if len(r.Countries) == 0 {
		fatal(r.Err)
	}
	fmt.Println("Server source:", r.Source)
	for _, p := range serverlist.Probe(ctx, r.Countries, 12) {
		if p.Reachable {
			fmt.Printf("OK   %-36s %4d %s\n", p.Host, p.Port, p.Latency.Round(time.Millisecond))
		} else {
			fmt.Printf("FAIL %-36s %4d %v\n", p.Host, p.Port, p.Err)
		}
	}
}
func printLocations(countries []provider.Country, source string) {
	fmt.Println("Source:", source)
	for _, c := range countries {
		fmt.Printf("%s (%s)\n", c.Name, c.Code)
		for _, city := range c.Cities {
			fmt.Printf("  - %s (%s): %d server(s)\n", city.Name, city.Code, len(city.Servers))
		}
	}
}
func doctor() {
	tp, _ := auth.TokenPath()
	sp, _ := serverlist.CachePath()
	fmt.Println("FireTunnel doctor")
	fmt.Println("  version:            ", version)
	fmt.Println("  dynamic server list: OK")
	fmt.Println("  embedded bootstrap:  OK")
	fmt.Println("  server cache:       ", sp)
	fmt.Println("  FxA auth:            implemented")
	fmt.Println("  refresh tokens:      implemented")
	fmt.Println("  Guardian ProxyPass:  implemented")
	fmt.Println("  quota headers:       implemented")
	fmt.Println("  HTTP/2 CONNECT:      implemented")
	fmt.Println("  local SOCKS5:        implemented")
	fmt.Println("  token store:        ", tp)
	fmt.Println("  Linux TUN plumbing:  implemented")
	fmt.Println("  DNS/routes:          implemented")
	fmt.Println("  kill switch:         implemented")
	fmt.Println("  packet TCP/IP engine: tun2socks integration")
	if p, err := linuxnet.FindTun2Socks(); err == nil {
		fmt.Println("  tun2socks:           ", p)
	} else {
		fmt.Println("  tun2socks:            not installed (run setup-linux)")
	}
	fmt.Println("  HTTP/3 MASQUE:       later transport")
}
func fatal(err error) { fmt.Fprintln(os.Stderr, "error:", err); os.Exit(1) }
func blank(s string) string {
	if strings.TrimSpace(s) == "" {
		return "(not supplied)"
	}
	return s
}

func readPassword() ([]byte, error) {
	// Ubuntu/Linux alpha: hide terminal echo using the standard stty utility.
	// If stty is unavailable (for example redirected stdin), fall back to a
	// normal line read instead of failing the whole login flow.
	cmd := exec.Command("stty", "-echo")
	cmd.Stdin = os.Stdin
	hidden := cmd.Run() == nil
	if hidden {
		defer func() {
			restore := exec.Command("stty", "echo")
			restore.Stdin = os.Stdin
			_ = restore.Run()
		}()
	}
	r := bufio.NewReader(os.Stdin)
	line, err := r.ReadString('\n')
	if err != nil && len(line) == 0 {
		return nil, err
	}
	return []byte(strings.TrimRight(line, "\r\n")), nil
}

func systemProxyCmd(args []string) {
	fs := flag.NewFlagSet("system-proxy", flag.ExitOnError)
	country := fs.String("country", "REC", "country code/name")
	listen := fs.String("listen", "127.0.0.1:1080", "local SOCKS5 address")
	_ = fs.Parse(args)

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	tok, err := auth.ValidTokens(ctx)
	if err != nil {
		fatal(fmt.Errorf("not logged in; run 'firetunnel login': %w", err))
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		fatal(err)
	}

	slctx, slcancel := context.WithTimeout(ctx, 12*time.Second)
	res := serverlist.Resolve(slctx)
	slcancel()
	if len(res.Countries) == 0 {
		fatal(res.Err)
	}
	cand, err := serverlist.Select(res.Countries, *country)
	if err != nil {
		fatal(err)
	}

	up, err := tunnel.NewH2Proxy(ctx, cand.Addr, pass.Token, 15*time.Second)
	if err != nil {
		fatal(err)
	}
	defer up.Close()

	s := &tunnel.SOCKSServer{Listen: *listen, Upstream: up}
	go func() {
		if err := s.Serve(ctx); err != nil && ctx.Err() == nil {
			fmt.Fprintln(os.Stderr, "SOCKS error:", err)
			cancel()
		}
	}()

	host, port, _ := net.SplitHostPort(*listen)
	if host == "" {
		host = "127.0.0.1"
	}

	fmt.Println("FireTunnel connected:", cand.CountryName, cand.CityName, cand.Addr)
	fmt.Println("SOCKS5:", *listen)

	if _, err := exec.LookPath("gsettings"); err == nil {
		_ = exec.Command("gsettings", "set", "org.gnome.system.proxy", "mode", "manual").Run()
		_ = exec.Command("gsettings", "set", "org.gnome.system.proxy.socks", "host", host).Run()
		_ = exec.Command("gsettings", "set", "org.gnome.system.proxy.socks", "port", port).Run()
		fmt.Println("GNOME system SOCKS proxy enabled.")
		defer func() {
			_ = exec.Command("gsettings", "set", "org.gnome.system.proxy", "mode", "none").Run()
			fmt.Println("GNOME system proxy restored.")
		}()
	} else {
		fmt.Println("gsettings not found; use SOCKS5:", *listen)
	}

	<-ctx.Done()
}

func setupLinuxCmd() {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	fmt.Printf("Installing tun2socks %s for linux/amd64...\n", linuxnet.Tun2SocksVersion)
	p, err := linuxnet.InstallTun2Socks(ctx)
	if err != nil {
		fatal(err)
	}
	fmt.Println("tun2socks installed:", p)
	fmt.Println("SHA256 verified.")
}

func waitTCP(addr string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		c, err := net.DialTimeout("tcp", addr, 150*time.Millisecond)
		if err == nil {
			_ = c.Close()
			return nil
		}
		time.Sleep(50 * time.Millisecond)
	}
	return fmt.Errorf("local SOCKS5 did not become ready on %s", addr)
}

func linuxTunCmd(args []string) {
	writeRuntimeState(map[string]any{"state": "connecting", "provider": "firetunnel", "transport": "h2-connect"})
	if err := runLinuxTun(args); err != nil {
		writeRuntimeState(map[string]any{"state": "error", "provider": "firetunnel", "error": err.Error()})
		fatal(err)
	}
	writeRuntimeState(map[string]any{"state": "disconnected", "provider": "firetunnel"})
}

func writeRuntimeState(value map[string]any) {
	path := strings.TrimSpace(os.Getenv("FIRETUNNEL_STATE"))
	if path == "" {
		return
	}
	value["updated_at"] = time.Now().Unix()
	b, err := json.Marshal(value)
	if err != nil {
		return
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, append(b, '\n'), 0644); err == nil {
		_ = os.Chmod(tmp, 0644)
		_ = os.Rename(tmp, path)
	}
}

func runLinuxTun(args []string) error {
	fs := flag.NewFlagSet("linux-tun", flag.ExitOnError)
	country := fs.String("country", "REC", "country code/name")
	ifname := fs.String("ifname", "firetun0", "TUN interface name")
	killswitch := fs.Bool("killswitch", false, "enable nftables kill switch")
	ipv6 := fs.Bool("ipv6", true, "install IPv6 routes")
	iranBypassFile := fs.String("iran-bypass-file", "", "route listed Iranian IPv4 CIDRs through the physical ISP")
	socksListen := fs.String("socks", "127.0.0.1:1080", "internal SOCKS5 listen address")
	dnsListen := fs.String("dns-listen", "198.18.0.2:53", "local tunneled DNS listener")
	dnsTarget := fs.String("dns-target", "cloudflare-dns.com:443", "DNS-over-HTTPS target through VPN")
	_ = fs.Parse(args)

	if os.Geteuid() != 0 {
		return fmt.Errorf("linux-tun needs root; run it with sudo")
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	t2s, err := linuxnet.FindTun2Socks()
	if err != nil {
		return err
	}

	// Finish auth/discovery before touching network state.
	tok, err := auth.ValidTokens(ctx)
	if err != nil {
		return fmt.Errorf("not logged in: %w", err)
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		return err
	}

	slctx, slcancel := context.WithTimeout(ctx, 12*time.Second)
	res := serverlist.Resolve(slctx)
	slcancel()
	if len(res.Countries) == 0 {
		return res.Err
	}
	cand, err := serverlist.Select(res.Countries, *country)
	if err != nil {
		return err
	}

	host, _, err := net.SplitHostPort(cand.Addr)
	if err != nil {
		return err
	}
	up4, up6 := linuxnet.ResolveHost(host)
	if up4 == "" && up6 == "" {
		return fmt.Errorf("could not resolve upstream %s", host)
	}

	var r4, r6 linuxnet.RouteInfo
	var physicalIf string
	if up4 != "" {
		r4, err = linuxnet.RouteTo(ctx, up4)
		if err != nil {
			return err
		}
		physicalIf = r4.Device
	}
	if up6 != "" {
		r6, _ = linuxnet.RouteTo(ctx, up6)
		if physicalIf == "" {
			physicalIf = r6.Device
		}
	}
	if physicalIf == "" {
		return fmt.Errorf("could not determine physical network interface")
	}

	// This resolves the Fastly endpoint to a concrete IP internally, before DNS
	// is changed, so later H2 dials cannot recurse through the tunneled resolver.
	up, err := tunnel.NewH2Proxy(ctx, cand.Addr, pass.Token, 15*time.Second)
	if err != nil {
		return fmt.Errorf("HTTP/2 upstream: %w", err)
	}
	defer up.Close()

	socks := &tunnel.SOCKSServer{Listen: *socksListen, Upstream: up}
	socksErr := make(chan error, 1)
	go func() { socksErr <- socks.Serve(ctx) }()
	if err := waitTCP(*socksListen, 3*time.Second); err != nil {
		return err
	}

	// Parse and install the local DNS address BEFORE starting the DNS listener.
	// Binding directly to 198.18.0.2 fails with EADDRNOTAVAIL unless that
	// address already exists on a local interface. Keep it on loopback so the
	// resolver can reach it without sending DNS packets into firetun0.
	dnsHost, _, err := net.SplitHostPort(*dnsListen)
	if err != nil {
		return err
	}
	if err := linuxnet.AddLocalDNSAlias(ctx, dnsHost); err != nil {
		return fmt.Errorf("add local DNS address: %w", err)
	}
	defer linuxnet.RemoveLocalDNSAlias(context.Background(), dnsHost)
	// DNS is translated to DoH over HTTPS/443 inside the same Firefox/Fastly H2 tunnel.
	dns := &dnsproxy.Proxy{Listen: *dnsListen, Upstream: up, Target: *dnsTarget, SNI: "cloudflare-dns.com", Path: "/dns-query"}
	dnsErr := make(chan error, 1)
	go func() { dnsErr <- dns.Serve(ctx) }()
	time.Sleep(100 * time.Millisecond)
	select {
	case err := <-dnsErr:
		if err != nil {
			return fmt.Errorf("DNS proxy: %w", err)
		}
	default:
	}

	// From this point onward every mutation has a matching defer. Returning an
	// error (instead of os.Exit) guarantees cleanup is executed.
	if r4.IP != "" {
		if err := linuxnet.PinRoute(ctx, r4); err != nil {
			return err
		}
		defer linuxnet.UnpinRoute(context.Background(), r4)
	}
	if r6.IP != "" {
		if err := linuxnet.PinRoute(ctx, r6); err != nil {
			fmt.Fprintln(os.Stderr, "note: IPv6 upstream pin failed:", err)
		} else {
			defer linuxnet.UnpinRoute(context.Background(), r6)
		}
	}

	rpf := linuxnet.DisableRPFilter(ctx, physicalIf)
	defer linuxnet.RestoreRPFilter(context.Background(), rpf)

	engine, err := linuxnet.StartTun2Socks(ctx, t2s, *ifname, "socks5://"+*socksListen, "")
	if err != nil {
		return fmt.Errorf("start tun2socks: %w", err)
	}
	defer engine.Stop()

	if err := linuxnet.WaitForInterface(ctx, *ifname, 5*time.Second); err != nil {
		return err
	}
	if err := linuxnet.BringUp(ctx, *ifname); err != nil {
		return err
	}
	defer linuxnet.RemoveTunRoutes(context.Background(), *ifname)

	if err := linuxnet.SetDNS(ctx, *ifname, dnsHost); err != nil {
		return fmt.Errorf("set tunneled DNS: %w", err)
	}
	defer linuxnet.RestoreDNS(context.Background(), *ifname)

	if err := linuxnet.VerifyDNS(ctx, "www.cloudflare.com"); err != nil {
		return err
	}

	if err := linuxnet.RouteAllThroughTUN(ctx, *ifname, *ipv6); err != nil {
		return err
	}
	var iranCIDRs []string
	if *iranBypassFile != "" {
		iranCIDRs, err = linuxnet.LoadIPv4CIDRs(*iranBypassFile)
		if err != nil {
			return fmt.Errorf("load Iran bypass: %w", err)
		}
		if err := linuxnet.SetDirectRoutes(ctx, iranCIDRs, r4, true); err != nil {
			return err
		}
		defer linuxnet.SetDirectRoutes(context.Background(), iranCIDRs, r4, false)
	}

	if *killswitch {
		if err := linuxnet.EnableKillSwitch(ctx, *ifname, physicalIf, up4, up6, iranCIDRs); err != nil {
			return err
		}
		defer linuxnet.DisableKillSwitch(context.Background())
	}

	fmt.Printf("FireTunnel TUN connected: %s / %s (%s) -> %s\n", cand.CountryName, cand.CityName, cand.CountryCode, cand.Addr)
	writeRuntimeState(map[string]any{
		"state": "connected", "provider": "firetunnel", "country_code": cand.CountryCode,
		"country": cand.CountryName, "location": cand.CityName, "endpoint": cand.Addr,
		"transport": "h2-connect", "connected_at": time.Now().Unix(),
	})
	fmt.Println("Server-list source:", res.Source)
	fmt.Println("TUN interface:", *ifname)
	fmt.Println("Physical interface:", physicalIf)
	fmt.Println("Internal SOCKS5:", *socksListen)
	fmt.Printf("DNS: %s -> DoH %s through FireTunnel\n", *dnsListen, *dnsTarget)
	fmt.Println("Pinned upstream IPv4:", up4)
	if up6 != "" {
		fmt.Println("Pinned upstream IPv6:", up6)
	}
	fmt.Println()
	fmt.Println("TCP system traffic is now routed through FireTunnel.")
	fmt.Println("DNS is tunneled through FireTunnel. Generic UDP/QUIC is not supported by the current H2 transport yet.")
	fmt.Println("Test WITHOUT --socks5:")
	fmt.Println("  curl https://www.cloudflare.com/cdn-cgi/trace")
	fmt.Println("Press Ctrl+C to disconnect and restore routes/DNS.")

	select {
	case <-ctx.Done():
		return nil
	case err := <-socksErr:
		if err != nil {
			return fmt.Errorf("SOCKS5: %w", err)
		}
		return nil
	case err := <-dnsErr:
		if err != nil {
			return fmt.Errorf("DNS proxy: %w", err)
		}
		return nil
	}
}
