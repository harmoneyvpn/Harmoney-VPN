package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/netip"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"firetunnel/internal/auth"
	"firetunnel/internal/dnsproxy"
	"firetunnel/internal/guardian"
	"firetunnel/internal/serverlist"
	"firetunnel/internal/tunnel"
)

const windowsVersion = "0.5.0-windows"

type runtimeState struct {
	State           string `json:"state"`
	Provider        string `json:"provider"`
	CountryCode     string `json:"country_code,omitempty"`
	Country         string `json:"country,omitempty"`
	Location        string `json:"location,omitempty"`
	Endpoint        string `json:"endpoint,omitempty"`
	PublicIP        string `json:"public_ip,omitempty"`
	ExitCountryCode string `json:"exit_country_code,omitempty"`
	ExitColo        string `json:"exit_colo,omitempty"`
	Transport       string `json:"transport,omitempty"`
	ConnectedAt     int64  `json:"connected_at,omitempty"`
	Code            string `json:"code,omitempty"`
	Error           string `json:"error,omitempty"`
	PID             int    `json:"pid,omitempty"`
	ControlKey      string `json:"control_key,omitempty"`
	EgressVerified  bool   `json:"egress_verified,omitempty"`
}

var (
	stateMu   sync.Mutex
	stateFile = os.Getenv("FIRETUNNEL_STATE")
)

func main() {
	if len(os.Args) < 2 {
		usageWindows()
		return
	}
	switch os.Args[1] {
	case "version":
		fmt.Println("FireTunnel", windowsVersion)
	case "locations":
		locationsWindows()
	case "app-state":
		appStateWindows(os.Args[2:])
	case "login-json":
		loginJSONWindows()
	case "logout":
		if err := auth.ClearTokens(); err != nil {
			jsonErrorWindows("token_store_failed", err)
			return
		}
		_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": true})
	case "connect":
		connectWindows(os.Args[2:])
	case "connect-xray":
		connectXrayWindows(os.Args[2:])
	case "disconnect", "cancel":
		disconnectWindows()
	case "status", "diagnostics":
		writeCurrentState()
	default:
		usageWindows()
	}
}

func usageWindows() {
	fmt.Printf("FireTunnel %s (Windows)\n", windowsVersion)
	fmt.Println("Commands: app-state, locations, login-json, logout, connect, connect-xray, disconnect, status")
}

func jsonErrorWindows(code string, err error) {
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": code, "error": err.Error()})
}

func loginJSONWindows() {
	var req struct {
		Email        string `json:"email"`
		Password     string `json:"password,omitempty"`
		Code         string `json:"code,omitempty"`
		SessionToken string `json:"session_token,omitempty"`
	}
	if err := json.NewDecoder(io.LimitReader(os.Stdin, 16<<10)).Decode(&req); err != nil {
		jsonErrorWindows("invalid_request", err)
		return
	}
	req.Email = strings.TrimSpace(req.Email)
	if req.Email == "" || len(req.Email) > 320 || !strings.Contains(req.Email, "@") || len(req.Password) > 2048 {
		req.Password = ""
		jsonErrorWindows("invalid_credentials", errors.New("a valid email address is required"))
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	var sessionToken string
	if strings.TrimSpace(req.SessionToken) != "" {
		sessionToken = strings.TrimSpace(req.SessionToken)
		if strings.TrimSpace(req.Code) == "" {
			jsonErrorWindows("verification_required", errors.New("enter the email verification code"))
			return
		}
		if err := auth.VerifyCode(ctx, sessionToken, strings.TrimSpace(req.Code)); err != nil {
			jsonErrorWindows("verification_failed", err)
			return
		}
	} else {
		if req.Password == "" {
			jsonErrorWindows("invalid_credentials", errors.New("email and password are required"))
			return
		}
		lr, err := auth.Login(ctx, req.Email, req.Password)
		req.Password = ""
		if err != nil {
			jsonErrorWindows("authentication_failed", err)
			return
		}
		sessionToken = lr.SessionToken
		if !lr.Verified {
			if strings.TrimSpace(req.Code) == "" {
				_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": "verification_required", "session_token": sessionToken})
				return
			}
			if err := auth.VerifyCode(ctx, sessionToken, strings.TrimSpace(req.Code)); err != nil {
				jsonErrorWindows("verification_failed", err)
				return
			}
		}
	}
	tok, err := auth.OAuthFromSession(ctx, sessionToken)
	if err != nil {
		jsonErrorWindows("oauth_failed", err)
		return
	}
	if err := auth.SaveTokens(tok); err != nil {
		jsonErrorWindows("token_store_failed", err)
		return
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		jsonErrorWindows("guardian_failed", err)
		return
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{
		"ok": true, "logged_in": true,
		"quota": map[string]any{"limit": pass.QuotaLimit, "remaining": pass.QuotaRemaining, "reset": pass.QuotaReset},
	})
}

func locationsWindows() {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	r := serverlist.Resolve(ctx)
	if len(r.Countries) == 0 {
		_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": "locations_unavailable", "error": fmt.Sprint(r.Err)})
		return
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": true, "source": r.Source, "locations": r.Countries})
}

func appStateWindows(args []string) {
	fs := flag.NewFlagSet("app-state", flag.ContinueOnError)
	country := fs.String("country", "REC", "location code")
	_ = fs.Parse(args)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	loggedIn := false
	var quota any
	if tok, err := auth.ValidTokens(ctx); err == nil {
		loggedIn = true
		if pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken); err == nil {
			quota = map[string]any{"limit": pass.QuotaLimit, "remaining": pass.QuotaRemaining, "reset": pass.QuotaReset}
		}
	}
	r := serverlist.Resolve(ctx)
	var selected any
	if len(r.Countries) > 0 {
		selected, _ = serverlist.Select(r.Countries, *country)
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{
		"ok": true, "version": windowsVersion, "logged_in": loggedIn,
		"quota": quota, "locations": r.Countries, "selected": selected,
		"capabilities": map[string]bool{"windows_tun": true, "tcp_tunnel": true, "doh_dns": true, "udp_masque": false},
	})
}

func connectWindows(args []string) {
	fs := flag.NewFlagSet("connect", flag.ContinueOnError)
	country := fs.String("country", "REC", "country code/name")
	killswitch := fs.Bool("killswitch", true, "block physical uplink while connected")
	_ = fs.Parse(args)
	ctx, cancel := context.WithCancel(context.Background())
	controlKey := randomControlKey()
	controlDone := make(chan struct{})
	writeState(runtimeState{State: "connecting", Provider: "firetunnel", PID: os.Getpid(), ControlKey: controlKey})
	go serveControl(ctx, cancel, controlKey, controlDone)
	defer func() { cancel(); <-controlDone }()
	tok, err := auth.ValidTokens(ctx)
	if err != nil {
		failWindows("authentication_required", err)
		return
	}
	pass, err := guardian.FetchProxyPass(ctx, tok.AccessToken)
	if err != nil {
		failWindows("guardian_failed", err)
		return
	}
	ctxResolve, cancelResolve := context.WithTimeout(ctx, 15*time.Second)
	r := serverlist.Resolve(ctxResolve)
	cancelResolve()
	if len(r.Countries) == 0 {
		failWindows("locations_unavailable", r.Err)
		return
	}
	candidate, err := serverlist.Select(r.Countries, *country)
	if err != nil {
		failWindows("location_unavailable", err)
		return
	}
	host, _, err := net.SplitHostPort(candidate.Addr)
	if err != nil {
		failWindows("invalid_endpoint", err)
		return
	}
	ips, err := net.DefaultResolver.LookupIP(ctx, "ip4", host)
	if err != nil || len(ips) == 0 {
		failWindows("endpoint_dns_failed", fmt.Errorf("could not resolve IPv4 for %s: %v", host, err))
		return
	}
	endpointIP := ips[0].String()
	physical, err := physicalRoute(endpointIP)
	if err != nil {
		failWindows("physical_route_unavailable", err)
		return
	}
	proxy, err := tunnel.NewH2Proxy(ctx, candidate.Addr, pass.Token, 20*time.Second)
	if err != nil {
		failWindows("http2_connect_failed", err)
		return
	}
	defer proxy.Close()
	socks := &tunnel.SOCKSServer{Listen: "127.0.0.1:1080", Upstream: proxy}
	socksErr := make(chan error, 1)
	go func() { socksErr <- socks.Serve(ctx) }()
	if err := waitTCP("127.0.0.1:1080", 4*time.Second); err != nil {
		failWindows("socks_start_failed", err)
		return
	}
	tun, err := startTun2Socks(physical.Name)
	if err != nil {
		failWindows("tun_start_failed", err)
		return
	}
	tunDone := make(chan error, 1)
	go func() { tunDone <- tun.Wait() }()
	defer func() {
		if tun != nil && tun.Process != nil {
			_ = tun.Process.Kill()
		}
	}()
	if err := waitAdapter("wintun", 12*time.Second); err != nil {
		failWindows("wintun_unavailable", err)
		return
	}
	if err := prepareTunnelAdapter(physical, endpointIP); err != nil {
		_ = cleanupTunnel(physical, endpointIP, true)
		failWindows("network_setup_failed", err)
		return
	}
	dns := &dnsproxy.Proxy{Listen: "198.18.0.2:53", Upstream: proxy, Target: "cloudflare-dns.com:443", SNI: "cloudflare-dns.com", Path: "/dns-query"}
	dnsReady := make(chan struct{})
	dnsErr := make(chan error, 1)
	go func() {
		deadline := time.Now().Add(8 * time.Second)
		for {
			dns.Ready = dnsReady
			err := dns.Serve(ctx)
			if err == nil || ctx.Err() != nil {
				dnsErr <- err
				return
			}
			message := strings.ToLower(err.Error())
			addressNotReady := strings.Contains(message, "requested address is not valid in its context") ||
				strings.Contains(message, "cannot assign requested address")
			if !addressNotReady || time.Now().After(deadline) {
				dnsErr <- fmt.Errorf("start tunnel DNS listener: %w", err)
				return
			}
			select {
			case <-ctx.Done():
				dnsErr <- nil
				return
			case <-time.After(200 * time.Millisecond):
			}
		}
	}()
	select {
	case <-dnsReady:
	case err := <-dnsErr:
		if err != nil {
			_ = cleanupTunnel(physical, endpointIP, true)
			failWindows("dns_start_failed", err)
			return
		}
	case <-time.After(10 * time.Second):
		_ = cleanupTunnel(physical, endpointIP, true)
		failWindows("dns_start_timeout", errors.New("DNS-over-HTTPS proxy did not start"))
		return
	}
	if *killswitch {
		if err := enableTunnelWFP(physical, endpointIP); err != nil {
			failTunnelSetup("kill_switch_failed", err, physical, endpointIP, true)
			return
		}
	}
	if err := configureTunnel(physical, endpointIP); err != nil {
		failTunnelSetup("network_setup_failed", err, physical, endpointIP, true)
		return
	}
	egress, err := verifyTunnelEgress()
	if err != nil {
		failTunnelSetup("tunnel_egress_unverified", err, physical, endpointIP, true)
		return
	}
	connected := runtimeState{State: "connected", Provider: "firetunnel", CountryCode: candidate.CountryCode,
		Country: candidate.CountryName, Location: candidate.CityName, Endpoint: candidate.Addr,
		PublicIP: egress.PublicIP, ExitCountryCode: egress.CountryCode, ExitColo: egress.Colo,
		Transport: "h2-connect", ConnectedAt: time.Now().Unix(), PID: os.Getpid(), ControlKey: controlKey, EgressVerified: true}
	writeState(connected)
	fmt.Fprintln(os.Stdout, `{"ok":true,"state":"connected"}`)
	select {
	case <-ctx.Done():
	case err := <-tunDone:
		if err == nil {
			err = errors.New("tun2socks exited unexpectedly")
		}
		writeState(runtimeState{State: "error", Provider: "firetunnel", Error: err.Error(), PID: os.Getpid()})
		cancel()
	case err := <-socksErr:
		if err != nil {
			writeState(runtimeState{State: "error", Provider: "firetunnel", Error: err.Error(), PID: os.Getpid()})
		}
	case err := <-dnsErr:
		if err != nil {
			writeState(runtimeState{State: "error", Provider: "firetunnel", Error: err.Error(), PID: os.Getpid()})
			cancel()
		}
	}
	writeState(runtimeState{State: "disconnecting", Provider: "firetunnel", PID: os.Getpid()})
	cleanupErr := cleanupTunnel(physical, endpointIP, true)
	var firewallErr error
	if cleanupErr == nil {
		firewallErr = runWFP("disable")
	}
	cancel()
	if cleanupErr != nil || firewallErr != nil {
		writeState(runtimeState{State: "error", Provider: "firetunnel", Code: "network_restore_failed",
			Error: errors.Join(cleanupErr, firewallErr).Error(), PID: os.Getpid()})
		return
	}
	writeState(runtimeState{State: "disconnected", Provider: "firetunnel"})
}

// connectXrayWindows runs the open-source Xray engine behind the same Wintun
// full-tunnel data path used by FireTunnel. The config is created per-user by
// the Flutter client and contains the selected subscription node credentials.
func connectXrayWindows(args []string) {
	fs := flag.NewFlagSet("connect-xray", flag.ContinueOnError)
	configPath := fs.String("config", "", "Xray JSON configuration")
	killswitch := fs.Bool("killswitch", true, "block physical uplink while connected")
	_ = fs.Parse(args)
	if *configPath == "" {
		failWindows("xray_config_missing", errors.New("Xray config path is required"))
		return
	}
	localAppData := os.Getenv("LOCALAPPDATA")
	if localAppData == "" || !strings.EqualFold(filepath.Clean(filepath.Dir(*configPath)), filepath.Join(localAppData, "HarmoneyVPN")) {
		failWindows("xray_config_path_invalid", errors.New("Xray config must be inside the current user's HarmoneyVPN data folder"))
		return
	}
	b, err := os.ReadFile(*configPath)
	if err != nil {
		failWindows("xray_config_unreadable", errors.New("could not read Xray config"))
		return
	}
	var cfg struct {
		Outbounds []struct {
			Protocol string `json:"protocol"`
			Settings struct {
				VNext []struct {
					Address string `json:"address"`
				} `json:"vnext"`
				Servers []struct {
					Address string `json:"address"`
				} `json:"servers"`
			} `json:"settings"`
		} `json:"outbounds"`
	}
	if json.Unmarshal(b, &cfg) != nil || len(cfg.Outbounds) < 1 {
		failWindows("xray_config_invalid", errors.New("Xray config is invalid"))
		return
	}
	endpoint := ""
	first := cfg.Outbounds[0]
	if len(first.Settings.VNext) > 0 {
		endpoint = first.Settings.VNext[0].Address
	}
	if endpoint == "" && len(first.Settings.Servers) > 0 {
		endpoint = first.Settings.Servers[0].Address
	}
	if endpoint == "" || strings.ContainsAny(endpoint, "\\/\r\n") {
		failWindows("xray_endpoint_invalid", errors.New("Xray endpoint is invalid"))
		return
	}
	port := 443
	if strings.EqualFold(first.Protocol, "shadowsocks") && len(first.Settings.Servers) > 0 {
		// Shadowsocks server port is retained in the Xray config; read it below.
		var ss struct {
			Outbounds []struct {
				Settings struct {
					Servers []struct {
						Port int `json:"port"`
					} `json:"servers"`
				} `json:"settings"`
			} `json:"outbounds"`
		}
		if json.Unmarshal(b, &ss) == nil && len(ss.Outbounds) > 0 && len(ss.Outbounds[0].Settings.Servers) > 0 {
			port = ss.Outbounds[0].Settings.Servers[0].Port
		}
	} else {
		var generic struct {
			Outbounds []struct {
				Settings struct {
					VNext []struct {
						Users []any `json:"users"`
					} `json:"vnext"`
					Servers []struct {
						Port int `json:"port"`
					} `json:"servers"`
				} `json:"settings"`
			} `json:"outbounds"`
		}
		if json.Unmarshal(b, &generic) == nil && len(generic.Outbounds) > 0 {
			if len(generic.Outbounds[0].Settings.Servers) > 0 {
				port = generic.Outbounds[0].Settings.Servers[0].Port
			}
			// VLESS/VMess carry port beside address.
			var v struct {
				Outbounds []struct {
					Settings struct {
						VNext []struct {
							Port int `json:"port"`
						} `json:"vnext"`
					} `json:"settings"`
				} `json:"outbounds"`
			}
			if json.Unmarshal(b, &v) == nil && len(v.Outbounds) > 0 && len(v.Outbounds[0].Settings.VNext) > 0 {
				port = v.Outbounds[0].Settings.VNext[0].Port
			}
		}
	}
	if port < 1 || port > 65535 {
		failWindows("xray_endpoint_invalid", errors.New("Xray endpoint port is invalid"))
		return
	}
	ctx, cancel := context.WithCancel(context.Background())
	controlKey := randomControlKey()
	controlDone := make(chan struct{})
	writeState(runtimeState{State: "connecting", Provider: "harmoney", PID: os.Getpid(), ControlKey: controlKey})
	go serveControl(ctx, cancel, controlKey, controlDone)
	defer func() { cancel(); <-controlDone }()
	ips, err := net.DefaultResolver.LookupIP(ctx, "ip4", endpoint)
	if err != nil || len(ips) == 0 {
		failWindows("xray_endpoint_dns_failed", errors.New("could not resolve the selected Xray server"))
		return
	}
	endpointIP := ips[0].String()
	// Pin Xray's own server dial to the address already resolved over the
	// physical network. Otherwise its DNS lookup could recurse into its tunnel.
	var configMap map[string]any
	if json.Unmarshal(b, &configMap) != nil {
		failWindows("xray_config_invalid", errors.New("Xray config is invalid"))
		return
	}
	bypassCIDRs, err := xrayDirectIPv4CIDRs(configMap)
	if err != nil {
		failWindows("xray_bypass_invalid", err)
		return
	}
	outs, _ := configMap["outbounds"].([]any)
	if len(outs) == 0 {
		failWindows("xray_config_invalid", errors.New("Xray config has no outbound"))
		return
	}
	firstOut, _ := outs[0].(map[string]any)
	settings, _ := firstOut["settings"].(map[string]any)
	if vnext, ok := settings["vnext"].([]any); ok && len(vnext) > 0 {
		if node, ok := vnext[0].(map[string]any); ok {
			node["address"] = endpointIP
		}
	} else if servers, ok := settings["servers"].([]any); ok && len(servers) > 0 {
		if node, ok := servers[0].(map[string]any); ok {
			node["address"] = endpointIP
		}
	}
	pinnedConfig, err := os.CreateTemp(filepath.Dir(*configPath), "xray-session-*.json")
	if err != nil {
		failWindows("xray_config_unreadable", errors.New("could not prepare Xray session config"))
		return
	}
	pinnedConfigPath := pinnedConfig.Name()
	defer os.Remove(pinnedConfigPath)
	if err = json.NewEncoder(pinnedConfig).Encode(configMap); err != nil {
		_ = pinnedConfig.Close()
		failWindows("xray_config_invalid", errors.New("could not prepare Xray session config"))
		return
	}
	if err = pinnedConfig.Close(); err != nil {
		failWindows("xray_config_unreadable", errors.New("could not write Xray session config"))
		return
	}
	physical, err := physicalRoute(endpointIP)
	if err != nil {
		failWindows("physical_route_unavailable", err)
		return
	}
	addedBypassCIDRs, err := installPhysicalBypassRoutes(physical, bypassCIDRs)
	if err != nil {
		failWindows("bypass_route_failed", err)
		return
	}
	defer removePhysicalBypassRoutes(physical, addedBypassCIDRs)
	exe, err := os.Executable()
	if err != nil {
		failWindows("xray_runtime_missing", errors.New("could not locate Xray runtime"))
		return
	}
	xrayPath := filepath.Join(filepath.Dir(exe), "xray.exe")
	if _, err = os.Stat(xrayPath); err != nil {
		failWindows("xray_runtime_missing", errors.New("Xray runtime is missing from the Windows package"))
		return
	}
	xray := exec.CommandContext(ctx, xrayPath, "run", "-c", pinnedConfigPath)
	xray.Stdout, xray.Stderr = io.Discard, io.Discard
	if err = xray.Start(); err != nil {
		failWindows("xray_start_failed", errors.New("Xray could not start"))
		return
	}
	xrayDone := make(chan error, 1)
	go func() { xrayDone <- xray.Wait() }()
	defer func() {
		if xray.Process != nil {
			_ = xray.Process.Kill()
		}
	}()
	if err = waitTCP("127.0.0.1:10808", 12*time.Second); err != nil {
		failWindows("xray_socks_unavailable", errors.New("Xray did not start its local proxy"))
		return
	}
	tun, err := startTun2SocksPort(physical.Name, 10808)
	if err != nil {
		failWindows("tun_start_failed", err)
		return
	}
	tunDone := make(chan error, 1)
	go func() { tunDone <- tun.Wait() }()
	defer func() {
		if tun.Process != nil {
			_ = tun.Process.Kill()
		}
	}()
	if err = waitAdapter("wintun", 12*time.Second); err != nil {
		failWindows("wintun_unavailable", err)
		return
	}
	if err = prepareTunnelAdapter(physical, endpointIP); err != nil {
		_ = cleanupTunnel(physical, endpointIP, true, addedBypassCIDRs...)
		failWindows("network_setup_failed", err)
		return
	}
	dnsReady := make(chan struct{})
	dnsErr := make(chan error, 1)
	dns := &dnsproxy.Proxy{
		Listen: "198.18.0.2:53",
		SOCKS:  "127.0.0.1:10808",
		Target: "1.1.1.1:443",
		SNI:    "cloudflare-dns.com",
		Path:   "/dns-query",
	}
	go func() {
		deadline := time.Now().Add(8 * time.Second)
		for {
			dns.Ready = dnsReady
			err := dns.Serve(ctx)
			if err == nil || ctx.Err() != nil {
				dnsErr <- err
				return
			}
			message := strings.ToLower(err.Error())
			addressNotReady := strings.Contains(message, "requested address is not valid in its context") ||
				strings.Contains(message, "cannot assign requested address")
			if !addressNotReady || time.Now().After(deadline) {
				dnsErr <- fmt.Errorf("start tunnel DNS listener: %w", err)
				return
			}
			select {
			case <-ctx.Done():
				dnsErr <- nil
				return
			case <-time.After(200 * time.Millisecond):
			}
		}
	}()
	select {
	case <-dnsReady:
	case dnsStartErr := <-dnsErr:
		_ = cleanupTunnel(physical, endpointIP, true, addedBypassCIDRs...)
		failWindows("dns_start_failed", dnsStartErr)
		return
	case <-time.After(10 * time.Second):
		_ = cleanupTunnel(physical, endpointIP, true, addedBypassCIDRs...)
		failWindows("dns_start_timeout", errors.New("DNS-over-HTTPS proxy did not start"))
		return
	}
	if *killswitch {
		if err = enableTunnelWFP(physical, endpointIP, bypassCIDRs...); err != nil {
			failTunnelSetup("kill_switch_failed", err, physical, endpointIP, true, addedBypassCIDRs...)
			return
		}
	}
	if err = configureXrayTunnel(physical, endpointIP); err != nil {
		failTunnelSetup("network_setup_failed", err, physical, endpointIP, true, addedBypassCIDRs...)
		return
	}
	egress, err := verifyTunnelEgress()
	if err != nil {
		failTunnelSetup("tunnel_egress_unverified", err, physical, endpointIP, true, addedBypassCIDRs...)
		return
	}
	writeState(runtimeState{State: "connected", Provider: "harmoney", Endpoint: net.JoinHostPort(endpoint, fmt.Sprint(port)), PublicIP: egress.PublicIP, ExitCountryCode: egress.CountryCode, ExitColo: egress.Colo, Transport: strings.ToUpper(first.Protocol), ConnectedAt: time.Now().Unix(), PID: os.Getpid(), ControlKey: controlKey, EgressVerified: true})
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": true, "state": "connected"})
	select {
	case <-ctx.Done():
	case err = <-tunDone:
		if err == nil {
			err = errors.New("tun2socks exited unexpectedly")
		}
		writeState(runtimeState{State: "error", Provider: "harmoney", Error: err.Error()})
		cancel()
	case <-xrayDone:
		writeState(runtimeState{State: "error", Provider: "harmoney", Error: "Xray exited unexpectedly"})
		cancel()
	case err = <-dnsErr:
		if err != nil {
			writeState(runtimeState{State: "error", Provider: "harmoney", Error: "DNS proxy exited: " + err.Error()})
			cancel()
		}
	}
	writeState(runtimeState{State: "disconnecting", Provider: "harmoney"})
	cleanupErr := cleanupTunnel(physical, endpointIP, true, addedBypassCIDRs...)
	var firewallErr error
	if cleanupErr == nil {
		firewallErr = runWFP("disable")
	}
	cancel()
	if cleanupErr != nil || firewallErr != nil {
		writeState(runtimeState{State: "error", Provider: "harmoney", Code: "network_restore_failed",
			Error: errors.Join(cleanupErr, firewallErr).Error(), PID: os.Getpid()})
		return
	}
	writeState(runtimeState{State: "disconnected", Provider: "harmoney"})
}

const maxXrayBypassCIDRs = 700

func xrayDirectIPv4CIDRs(config map[string]any) ([]string, error) {
	routing, _ := config["routing"].(map[string]any)
	rules, _ := routing["rules"].([]any)
	seen := make(map[string]struct{})
	var cidrs []string
	for _, rawRule := range rules {
		rule, _ := rawRule.(map[string]any)
		if rule["outboundTag"] != "direct" {
			continue
		}
		values, _ := rule["ip"].([]any)
		for _, raw := range values {
			text, ok := raw.(string)
			if !ok {
				return nil, errors.New("country bypass rule contains a non-string CIDR")
			}
			prefix, err := netip.ParsePrefix(text)
			if err != nil || !prefix.Addr().Is4() || prefix.Bits() < 8 {
				return nil, fmt.Errorf("invalid or overly broad Windows bypass CIDR: %q", text)
			}
			canonical := prefix.Masked().String()
			if _, exists := seen[canonical]; exists {
				continue
			}
			seen[canonical] = struct{}{}
			cidrs = append(cidrs, canonical)
			if len(cidrs) > maxXrayBypassCIDRs {
				return nil, fmt.Errorf("Windows bypass is limited to %d IPv4 ranges", maxXrayBypassCIDRs)
			}
		}
	}
	sort.Strings(cidrs)
	return cidrs, nil
}

func installPhysicalBypassRoutes(physical routeInfo, cidrs []string) ([]string, error) {
	if len(cidrs) == 0 {
		return nil, nil
	}
	quoted := make([]string, 0, len(cidrs))
	for _, value := range cidrs {
		prefix, err := netip.ParsePrefix(value)
		if err != nil || !prefix.Addr().Is4() || prefix.Bits() < 8 {
			return nil, fmt.Errorf("invalid Windows bypass CIDR: %q", value)
		}
		quoted = append(quoted, "'"+prefix.Masked().String()+"'")
	}
	list := strings.Join(quoted, ",")
	script := fmt.Sprintf(`$ErrorActionPreference='Stop'; $added=[System.Collections.Generic.List[string]]::new(); try { foreach($prefix in @(%s)) { $routes=@(Get-NetRoute -DestinationPrefix $prefix -PolicyStore ActiveStore -ErrorAction SilentlyContinue); $matching=@($routes | Where-Object { $_.InterfaceIndex -eq %d -and $_.NextHop -eq '%s' }); if($matching.Count -gt 0){continue}; if($routes.Count -gt 0){throw "A conflicting route already exists for $prefix"}; New-NetRoute -DestinationPrefix $prefix -InterfaceIndex %d -NextHop '%s' -PolicyStore ActiveStore -RouteMetric 1 -ErrorAction Stop | Out-Null; $added.Add($prefix) } } catch { foreach($prefix in $added){Remove-NetRoute -DestinationPrefix $prefix -InterfaceIndex %d -Confirm:$false -ErrorAction SilentlyContinue}; throw }; ConvertTo-Json -InputObject @($added.ToArray()) -Compress`, list, physical.Index, physical.Gateway, physical.Index, physical.Gateway, physical.Index)
	out, err := powershell(script)
	if err != nil {
		return nil, fmt.Errorf("install selected-country physical routes: %w", err)
	}
	var added []string
	if strings.TrimSpace(string(out)) != "" {
		if err := json.Unmarshal(out, &added); err != nil {
			return nil, fmt.Errorf("read installed bypass routes: %w", err)
		}
	}
	return added, nil
}

func removePhysicalBypassRoutes(physical routeInfo, cidrs []string) {
	if len(cidrs) == 0 {
		return
	}
	var commands strings.Builder
	for _, value := range cidrs {
		prefix, err := netip.ParsePrefix(value)
		if err != nil || !prefix.Addr().Is4() {
			continue
		}
		fmt.Fprintf(&commands, "Remove-NetRoute -DestinationPrefix '%s' -InterfaceIndex %d -Confirm:$false -ErrorAction SilentlyContinue; ", prefix.Masked(), physical.Index)
	}
	if commands.Len() > 0 {
		_, _ = powershell("$ErrorActionPreference='SilentlyContinue'; " + commands.String())
	}
}

type routeInfo struct {
	Index        int      `json:"index"`
	Name         string   `json:"name"`
	Gateway      string   `json:"gateway"`
	Dns          []string `json:"dns"`
	DnsAutomatic bool     `json:"dns_automatic"`
}

func physicalRoute(endpoint string) (routeInfo, error) {
	script := "$r=Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop | Sort-Object RouteMetric | Select-Object -First 1; $a=Get-NetAdapter -InterfaceIndex $r.InterfaceIndex -ErrorAction Stop; $d=@((Get-DnsClientServerAddress -InterfaceIndex $r.InterfaceIndex -AddressFamily IPv4).ServerAddresses); $g=$a.InterfaceGuid.ToString('B'); $k=Get-ItemProperty -LiteralPath ('HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\Interfaces\\'+$g) -Name NameServer -ErrorAction SilentlyContinue; $auto=[string]::IsNullOrWhiteSpace([string]$k.NameServer) -or ($d -contains '198.18.0.2'); @{index=$r.InterfaceIndex;name=$a.Name;gateway=$r.NextHop;dns=$d;dns_automatic=$auto} | ConvertTo-Json -Compress"
	b, err := powershell(script)
	if err != nil {
		return routeInfo{}, err
	}
	var value struct {
		Index   int      `json:"index"`
		Name    string   `json:"name"`
		Gateway string   `json:"gateway"`
		DNS     []string `json:"dns"`
		DNSAuto bool     `json:"dns_automatic"`
	}
	if err := json.Unmarshal(b, &value); err != nil {
		return routeInfo{}, err
	}
	if value.Index < 1 || value.Name == "" || value.Gateway == "" {
		return routeInfo{}, errors.New("could not identify the active physical adapter and gateway")
	}
	return routeInfo{Index: value.Index, Name: value.Name, Gateway: value.Gateway, Dns: value.DNS, DnsAutomatic: value.DNSAuto}, nil
}

func prepareTunnelAdapter(physical routeInfo, endpoint string) error {
	pin := endpoint + "/32"
	script := fmt.Sprintf(`$ErrorActionPreference='Stop'; $p=Get-NetAdapter -Name 'wintun' -ErrorAction Stop; $i=$p.ifIndex; $existing=@(Get-NetRoute -DestinationPrefix '%s' -PolicyStore ActiveStore -ErrorAction SilentlyContinue); $matching=@($existing | Where-Object { $_.InterfaceIndex -eq %d -and $_.NextHop -eq '%s' }); if($matching.Count -eq 0){if($existing.Count -gt 0){throw 'A conflicting route already exists for the Xray endpoint'}; New-NetRoute -DestinationPrefix '%s' -InterfaceIndex %d -NextHop '%s' -PolicyStore ActiveStore -RouteMetric 1 | Out-Null}; if(-not (Get-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.1' -ErrorAction SilentlyContinue)){New-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.1' -PrefixLength 15 -PolicyStore ActiveStore | Out-Null}; if(-not (Get-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.2' -ErrorAction SilentlyContinue)){New-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.2' -PrefixLength 32 -PolicyStore ActiveStore | Out-Null}; if(-not (Get-NetIPAddress -InterfaceIndex $i -IPAddress 'fd42:4242::1' -ErrorAction SilentlyContinue)){New-NetIPAddress -InterfaceIndex $i -IPAddress 'fd42:4242::1' -PrefixLength 126 -AddressFamily IPv6 -PolicyStore ActiveStore | Out-Null}`, pin, physical.Index, physical.Gateway, pin, physical.Index, physical.Gateway)
	if _, err := powershell(script); err != nil {
		return fmt.Errorf("configure Wintun interface: %w", err)
	}
	return nil
}

func configureTunnel(physical routeInfo, endpoint string) error {
	_ = endpoint
	if err := configureSystemTunnelRoutes("198.18.0.2"); err != nil {
		return err
	}
	if err := verifyTunnelDNS(); err != nil {
		return err
	}
	return nil
}

func configureXrayTunnel(physical routeInfo, endpoint string) error {
	_ = endpoint
	if err := configureSystemTunnelRoutes("198.18.0.2"); err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	if _, err := net.DialTimeout("udp", "198.18.0.2:53", 2*time.Second); err != nil {
		return fmt.Errorf("tunneled DNS-over-HTTPS proxy unavailable: %w", err)
	}
	if _, err := net.DefaultResolver.LookupIPAddr(ctx, "www.cloudflare.com"); err != nil {
		return fmt.Errorf("DNS-over-HTTPS through Xray failed: %w", err)
	}
	return nil
}

// configureSystemTunnelRoutes applies idempotent split-default routes to the
// Wintun interface. A previous interrupted connection may leave an identical
// route behind; reuse it, but reject a route owned by a different interface.
func configureSystemTunnelRoutes(dnsServer string) error {
	if err := removeStaleTapSplitRoutes(); err != nil {
		return fmt.Errorf("remove stale split routes: %w", err)
	}
	script := fmt.Sprintf(`$ErrorActionPreference='Stop'; $p=Get-NetAdapter -Name 'wintun' -ErrorAction Stop; $i=$p.ifIndex; Set-DnsClientServerAddress -InterfaceIndex $i -ServerAddresses '%s' -ErrorAction Stop; function Ensure-TunnelRoute([string]$prefix,[int]$index,[string]$nextHop){$routes=@(Get-NetRoute -DestinationPrefix $prefix -PolicyStore ActiveStore -ErrorAction SilentlyContinue); $matching=@($routes | Where-Object { $_.InterfaceIndex -eq $index -and $_.NextHop -eq $nextHop }); if($matching.Count -gt 0){return}; if($routes.Count -gt 0){throw "A conflicting route already exists for $prefix"}; New-NetRoute -DestinationPrefix $prefix -InterfaceIndex $index -NextHop $nextHop -PolicyStore ActiveStore -RouteMetric 1 | Out-Null}; Ensure-TunnelRoute '0.0.0.0/1' $i '198.18.0.1'; Ensure-TunnelRoute '128.0.0.0/1' $i '198.18.0.1'; Ensure-TunnelRoute '::/1' $i '::'; Ensure-TunnelRoute '8000::/1' $i '::'`, dnsServer)
	if _, err := powershell(script); err != nil {
		return fmt.Errorf("configure Wintun routes and DNS: %w", err)
	}
	return nil
}

// An interrupted OpenVPN/NordVPN session can leave /1 routes attached to a
// disconnected TAP adapter. They conflict with FireTunnel's full-tunnel routes
// but are unusable while the TAP interface is down. Prune only those stale
// IPv4 split routes; routes on active adapters and other prefixes are preserved.
func removeStaleTapSplitRoutes() error {
	script := `$ErrorActionPreference='Stop'; foreach($prefix in @('0.0.0.0/1','128.0.0.0/1')){$routes=@(Get-NetRoute -DestinationPrefix $prefix -PolicyStore ActiveStore -ErrorAction SilentlyContinue); foreach($route in $routes){$adapter=Get-NetAdapter -InterfaceIndex $route.InterfaceIndex -ErrorAction SilentlyContinue; if($adapter -and $adapter.Status -ne 'Up' -and $adapter.InterfaceDescription -like '*TAP*'){Remove-NetRoute -InputObject $route -Confirm:$false -ErrorAction Stop}}}`
	if _, err := powershell(script); err != nil {
		return fmt.Errorf("PowerShell failed to prune routes on disconnected TAP adapters: %w", err)
	}
	return nil
}

func verifyTunnelDNS() error {
	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	conn, err := net.DialTimeout("udp", "198.18.0.2:53", 2*time.Second)
	if err != nil {
		return fmt.Errorf("tunneled DNS endpoint unavailable: %w", err)
	}
	_ = conn.Close()
	_, err = net.DefaultResolver.LookupIPAddr(ctx, "www.cloudflare.com")
	if err != nil {
		return fmt.Errorf("DNS verification failed: %w", err)
	}
	return nil
}

func cleanupTunnel(physical routeInfo, endpoint string, restoreDNS bool, bypassCIDRs ...string) error {
	dns, _ := json.Marshal(physical.Dns)
	restoreDNSCondition := "$false"
	if restoreDNS {
		restoreDNSCondition = "$true"
	}
	dnsAutomaticCondition := "$false"
	if physical.DnsAutomatic {
		dnsAutomaticCondition = "$true"
	}
	var bypassCleanup strings.Builder
	for _, value := range bypassCIDRs {
		prefix, err := netip.ParsePrefix(value)
		if err != nil || !prefix.Addr().Is4() || prefix.Bits() < 8 {
			continue
		}
		fmt.Fprintf(&bypassCleanup, "Remove-NetRoute -DestinationPrefix '%s' -InterfaceIndex %d -Confirm:$false -ErrorAction SilentlyContinue; ", prefix.Masked(), physical.Index)
	}
	script := fmt.Sprintf(`$ErrorActionPreference='Stop'
$p=Get-NetAdapter -Name 'wintun' -ErrorAction SilentlyContinue
if($p){$i=$p.ifIndex; Set-DnsClientServerAddress -InterfaceIndex $i -ResetServerAddresses -ErrorAction SilentlyContinue; Remove-NetRoute -DestinationPrefix '0.0.0.0/1' -InterfaceIndex $i -Confirm:$false -ErrorAction SilentlyContinue; Remove-NetRoute -DestinationPrefix '128.0.0.0/1' -InterfaceIndex $i -Confirm:$false -ErrorAction SilentlyContinue; Remove-NetRoute -DestinationPrefix '::/1' -InterfaceIndex $i -Confirm:$false -ErrorAction SilentlyContinue; Remove-NetRoute -DestinationPrefix '8000::/1' -InterfaceIndex $i -Confirm:$false -ErrorAction SilentlyContinue; Remove-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.1' -Confirm:$false -ErrorAction SilentlyContinue; Remove-NetIPAddress -InterfaceIndex $i -IPAddress '198.18.0.2' -Confirm:$false -ErrorAction SilentlyContinue}
%s Remove-NetRoute -DestinationPrefix '%s' -InterfaceIndex %d -Confirm:$false -ErrorAction SilentlyContinue
if(%s){$d=ConvertFrom-Json '%s'; if(%s -or -not $d -or @($d).Count -eq 0){Set-DnsClientServerAddress -InterfaceIndex %d -ResetServerAddresses -ErrorAction Stop}else{Set-DnsClientServerAddress -InterfaceIndex %d -ServerAddresses $d -ErrorAction Stop}}
$adapters=Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {$_.Name -ne 'wintun'}
foreach($a in $adapters){$s=@((Get-DnsClientServerAddress -InterfaceIndex $a.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses); if($s -contains '198.18.0.2'){Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop}}
Clear-DnsClientCache -ErrorAction Stop
if($p){$left=@(Get-NetRoute -InterfaceIndex $p.ifIndex -ErrorAction SilentlyContinue | Where-Object {$_.DestinationPrefix -in @('0.0.0.0/1','128.0.0.0/1','::/1','8000::/1')}); if($left.Count -gt 0){throw 'Tunnel routes remain installed after cleanup'}}`, bypassCleanup.String(), endpoint+"/32", physical.Index, restoreDNSCondition, strings.ReplaceAll(string(dns), "'", "''"), dnsAutomaticCondition, physical.Index, physical.Index)
	_, err := powershell(script)
	return err
}

func startTun2Socks(interfaceName string) (*exec.Cmd, error) {
	return startTun2SocksPort(interfaceName, 1080)
}

func startTun2SocksPort(interfaceName string, port int) (*exec.Cmd, error) {
	exe, err := os.Executable()
	if err != nil {
		return nil, err
	}
	bin := filepath.Join(filepath.Dir(exe), "tun2socks.exe")
	if _, err := os.Stat(bin); err != nil {
		return nil, fmt.Errorf("tun2socks runtime is missing: %w", err)
	}
	cmd := exec.Command(bin, "--device", "tun://wintun?guid={A24376CC-541A-4A1D-8247-1BE78D5F26F8}", "--proxy", fmt.Sprintf("socks5://127.0.0.1:%d", port), "--interface", interfaceName, "--loglevel", "warn")
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Start(); err != nil {
		return nil, err
	}
	return cmd, nil
}

func waitAdapter(name string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		_, err := powershell("Get-NetAdapter -Name '" + name + "' -ErrorAction Stop | Out-Null")
		if err == nil {
			return nil
		}
		time.Sleep(250 * time.Millisecond)
	}
	return fmt.Errorf("Wintun adapter %q did not appear", name)
}

func waitTCP(addr string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		c, err := net.DialTimeout("tcp", addr, 200*time.Millisecond)
		if err == nil {
			_ = c.Close()
			return nil
		}
		time.Sleep(100 * time.Millisecond)
	}
	return fmt.Errorf("local service did not start on %s", addr)
}

func powershell(script string) ([]byte, error) {
	cmd := exec.Command("powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", script)
	var out, stderr strings.Builder
	cmd.Stdout, cmd.Stderr = &out, &stderr
	if err := cmd.Run(); err != nil {
		return nil, fmt.Errorf("PowerShell failed: %w: %s", err, strings.TrimSpace(stderr.String()))
	}
	return []byte(strings.TrimSpace(out.String())), nil
}

func runWFP(args ...string) error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	helper := filepath.Join(filepath.Dir(exe), "wfp-helper.exe")
	cmd := exec.Command(helper, args...)
	b, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("WFP kill switch: %w: %s", err, strings.TrimSpace(string(b)))
	}
	return nil
}

func failTunnelSetup(code string, cause error, physical routeInfo, endpoint string, restoreDNS bool, bypassCIDRs ...string) {
	cleanupErr := cleanupTunnel(physical, endpoint, restoreDNS, bypassCIDRs...)
	if cleanupErr != nil {
		// Keep the WFP policy active when routes or DNS could not be restored.
		// That leaves the machine offline rather than silently sending traffic
		// outside the VPN after a failed setup.
		failWindows("network_restore_failed", errors.Join(cause, cleanupErr))
		return
	}
	if firewallErr := runWFP("disable"); firewallErr != nil {
		failWindows("network_restore_failed", errors.Join(cause, firewallErr))
		return
	}
	failWindows(code, cause)
}

func enableTunnelWFP(physical routeInfo, endpoint string, bypassCIDRs ...string) error {
	indexes, err := protectedNetworkInterfaceIndexes(uint32(physical.Index))
	if err != nil {
		return fmt.Errorf("enumerate physical interfaces for leak protection: %w", err)
	}
	args := []string{"enable", fmt.Sprint(physical.Index), endpoint}
	for _, index := range indexes {
		if index == uint32(physical.Index) {
			continue
		}
		args = append(args, fmt.Sprintf("--block-ifindex=%d", index))
	}
	args = append(args, bypassCIDRs...)
	return runWFP(args...)
}

func protectedNetworkInterfaceIndexes(primary uint32) ([]uint32, error) {
	output, err := powershell("Get-NetAdapter -ErrorAction Stop | Where-Object {$_.Name -ne 'wintun'} | ForEach-Object {[int]$_.ifIndex}")
	if err != nil {
		return nil, err
	}
	indexes := map[uint32]struct{}{primary: {}}
	for _, line := range strings.Split(string(output), "\n") {
		index, parseErr := strconv.ParseUint(strings.TrimSpace(line), 10, 32)
		if parseErr == nil && index > 0 {
			indexes[uint32(index)] = struct{}{}
		}
	}
	result := make([]uint32, 0, len(indexes))
	for index := range indexes {
		result = append(result, index)
	}
	sort.Slice(result, func(i, j int) bool { return result[i] < result[j] })
	return result, nil
}

type tunnelEgressInfo struct {
	PublicIP    string
	CountryCode string
	Colo        string
}

// verifyTunnelEgress performs a normal system HTTPS request after the system
// routes and kill switch are active, and returns the public exit details seen
// by the remote endpoint.
func verifyTunnelEgress() (tunnelEgressInfo, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
	defer cancel()
	transport := &http.Transport{
		Proxy:                 nil,
		DisableKeepAlives:     true,
		TLSHandshakeTimeout:   5 * time.Second,
		ResponseHeaderTimeout: 5 * time.Second,
	}
	defer transport.CloseIdleConnections()
	client := &http.Client{Transport: transport}
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, "https://www.cloudflare.com/cdn-cgi/trace", nil)
	if err != nil {
		return tunnelEgressInfo{}, err
	}
	response, err := client.Do(request)
	if err != nil {
		return tunnelEgressInfo{}, fmt.Errorf("system HTTPS egress through VPN failed: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return tunnelEgressInfo{}, fmt.Errorf("system HTTPS egress through VPN returned HTTP %d", response.StatusCode)
	}
	body, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return tunnelEgressInfo{}, fmt.Errorf("read VPN egress verification response: %w", err)
	}
	info := tunnelEgressInfo{}
	for _, line := range strings.Split(string(body), "\n") {
		key, value, ok := strings.Cut(strings.TrimSpace(line), "=")
		if !ok {
			continue
		}
		switch key {
		case "ip":
			ip := net.ParseIP(value)
			if ip == nil || !ip.IsGlobalUnicast() || ip.IsPrivate() {
				return tunnelEgressInfo{}, errors.New("VPN egress verification did not return a public IP")
			}
			info.PublicIP = ip.String()
		case "loc":
			if len(value) == 2 && value[0] >= 'A' && value[0] <= 'Z' && value[1] >= 'A' && value[1] <= 'Z' {
				info.CountryCode = value
			}
		case "colo":
			info.Colo = value
		}
	}
	if info.PublicIP == "" {
		return tunnelEgressInfo{}, errors.New("VPN egress verification response did not include a public IP")
	}
	return info, nil
}

func randomControlKey() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	return hex.EncodeToString(b)
}

func serveControl(ctx context.Context, cancel context.CancelFunc, key string, done chan<- struct{}) {
	defer close(done)
	mux := http.NewServeMux()
	mux.HandleFunc("/disconnect", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.Header.Get("X-FireTunnel-Control") != key {
			http.Error(w, "forbidden", http.StatusForbidden)
			return
		}
		w.WriteHeader(http.StatusAccepted)
		go cancel()
	})
	server := &http.Server{Addr: "127.0.0.1:47642", Handler: mux, ReadHeaderTimeout: 2 * time.Second}
	go func() { <-ctx.Done(); _ = server.Shutdown(context.Background()) }()
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		fmt.Fprintln(os.Stderr, "FireTunnel control listener:", err)
		cancel()
	}
}

func disconnectWindows() {
	state, err := readState()
	if err != nil || (state.State != "connected" && state.State != "connecting") || state.ControlKey == "" {
		// Clear terminal error state so polling and the next connection attempt
		// do not keep surfacing a stale failure from the previous run.
		writeState(runtimeState{State: "disconnected", Provider: "firetunnel"})
		_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": true, "state": "disconnected"})
		return
	}
	req, _ := http.NewRequest(http.MethodPost, "http://127.0.0.1:47642/disconnect", nil)
	req.Header.Set("X-FireTunnel-Control", state.ControlKey)
	resp, err := (&http.Client{Timeout: 3 * time.Second}).Do(req)
	if err != nil {
		jsonErrorWindows("disconnect_failed", err)
		return
	}
	_ = resp.Body.Close()
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": true, "state": "disconnecting"})
}

func failWindows(code string, err error) {
	if err == nil {
		err = errors.New(code)
	}
	writeState(runtimeState{State: "error", Provider: "firetunnel", Code: code, Error: err.Error()})
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"ok": false, "code": code, "error": err.Error()})
}

func runtimeStatePath() string {
	if strings.TrimSpace(stateFile) != "" {
		return stateFile
	}
	if runtime.GOOS == "windows" {
		if localAppData := os.Getenv("LOCALAPPDATA"); localAppData != "" {
			return filepath.Join(localAppData, "HarmoneyVPN", "firetunnel-state.json")
		}
	}
	base, _ := os.UserConfigDir()
	return filepath.Join(base, "HarmoneyVPN", "firetunnel-state.json")
}

func writeState(state runtimeState) {
	path := runtimeStatePath()
	stateMu.Lock()
	defer stateMu.Unlock()
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return
	}
	b, err := json.Marshal(state)
	if err != nil {
		return
	}
	tmp := path + ".tmp"
	if os.WriteFile(tmp, append(b, '\n'), 0600) == nil {
		_ = os.Rename(tmp, path)
	}
}

func readState() (runtimeState, error) {
	path := runtimeStatePath()
	b, err := os.ReadFile(path)
	if err != nil {
		return runtimeState{}, err
	}
	var v runtimeState
	err = json.Unmarshal(b, &v)
	return v, err
}

func writeCurrentState() {
	state, err := readState()
	if err != nil {
		state = runtimeState{State: "disconnected", Provider: "firetunnel"}
	}
	_ = json.NewEncoder(os.Stdout).Encode(state)
}
