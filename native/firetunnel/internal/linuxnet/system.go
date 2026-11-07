package linuxnet

import (
	"bytes"
	"context"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

func run(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	var out, errb bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &errb
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("%s %s: %w: %s", name, strings.Join(args, " "), err, strings.TrimSpace(errb.String()))
	}
	return strings.TrimSpace(out.String()), nil
}

func WaitForInterface(ctx context.Context, ifname string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if _, err := run(ctx, "ip", "link", "show", "dev", ifname); err == nil {
			return nil
		}
		time.Sleep(100 * time.Millisecond)
	}
	return fmt.Errorf("TUN interface %s did not appear", ifname)
}

func BringUp(ctx context.Context, ifname string) error {
	if _, err := run(ctx, "ip", "link", "set", "dev", ifname, "mtu", "1500", "up"); err != nil {
		return err
	}
	if _, err := run(ctx, "ip", "addr", "replace", "198.18.0.1/15", "dev", ifname); err != nil {
		return err
	}
	_, _ = run(ctx, "ip", "-6", "addr", "replace", "fd42:4242::1/126", "dev", ifname)
	return nil
}

type RouteInfo struct {
	IP      string
	Gateway string
	Device  string
	IPv6    bool
}

func RouteTo(ctx context.Context, ip string) (RouteInfo, error) {
	ri := RouteInfo{IP: ip, IPv6: strings.Contains(ip, ":")}
	args := []string{"route", "get", ip}
	if ri.IPv6 {
		args = append([]string{"-6"}, args...)
	}
	out, err := run(ctx, "ip", args...)
	if err != nil {
		return ri, err
	}
	f := strings.Fields(out)
	for i := 0; i+1 < len(f); i++ {
		switch f[i] {
		case "via":
			ri.Gateway = f[i+1]
		case "dev":
			ri.Device = f[i+1]
		}
	}
	if ri.Device == "" {
		return ri, fmt.Errorf("could not determine physical interface for %s from: %s", ip, out)
	}
	return ri, nil
}

func ResolveHost(host string) (string, string) {
	ips, _ := net.LookupIP(host)
	var v4, v6 string
	for _, ip := range ips {
		if ip4 := ip.To4(); ip4 != nil && v4 == "" {
			v4 = ip4.String()
		} else if ip.To4() == nil && v6 == "" {
			v6 = ip.String()
		}
	}
	return v4, v6
}

func PinRoute(ctx context.Context, ri RouteInfo) error {
	if ri.IP == "" || ri.Device == "" {
		return nil
	}
	prefix := "/32"
	args := []string{"route", "replace", ri.IP + prefix}
	if ri.IPv6 {
		prefix = "/128"
		args = []string{"-6", "route", "replace", ri.IP + prefix}
	}
	if ri.Gateway != "" {
		args = append(args, "via", ri.Gateway)
	}
	args = append(args, "dev", ri.Device)
	_, err := run(ctx, "ip", args...)
	return err
}

func UnpinRoute(ctx context.Context, ri RouteInfo) {
	if ri.IP == "" {
		return
	}
	if ri.IPv6 {
		_, _ = run(ctx, "ip", "-6", "route", "del", ri.IP+"/128")
	} else {
		_, _ = run(ctx, "ip", "route", "del", ri.IP+"/32")
	}
}

func RouteAllThroughTUN(ctx context.Context, ifname string, ipv6 bool) error {
	if _, err := run(ctx, "ip", "route", "replace", "0.0.0.0/1", "dev", ifname); err != nil {
		return err
	}
	if _, err := run(ctx, "ip", "route", "replace", "128.0.0.0/1", "dev", ifname); err != nil {
		return err
	}
	if ipv6 {
		if _, err := run(ctx, "ip", "-6", "route", "replace", "::/1", "dev", ifname); err != nil {
			return err
		}
		if _, err := run(ctx, "ip", "-6", "route", "replace", "8000::/1", "dev", ifname); err != nil {
			return err
		}
	}
	return nil
}

func RemoveTunRoutes(ctx context.Context, ifname string) {
	_, _ = run(ctx, "ip", "route", "del", "0.0.0.0/1", "dev", ifname)
	_, _ = run(ctx, "ip", "route", "del", "128.0.0.0/1", "dev", ifname)
	_, _ = run(ctx, "ip", "-6", "route", "del", "::/1", "dev", ifname)
	_, _ = run(ctx, "ip", "-6", "route", "del", "8000::/1", "dev", ifname)
}

func LoadIPv4CIDRs(path string) ([]string, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var result []string
	for _, line := range strings.Split(string(raw), "\n") {
		line = strings.TrimSpace(strings.SplitN(line, "#", 2)[0])
		if line == "" {
			continue
		}
		ip, network, err := net.ParseCIDR(line)
		if err != nil || ip.To4() == nil {
			continue
		}
		result = append(result, network.String())
	}
	if len(result) == 0 {
		return nil, fmt.Errorf("Iran bypass CIDR file is empty")
	}
	return result, nil
}

func SetDirectRoutes(ctx context.Context, cidrs []string, route RouteInfo, add bool) error {
	if len(cidrs) == 0 || route.Device == "" {
		return nil
	}
	var batch strings.Builder
	for _, cidr := range cidrs {
		if add {
			fmt.Fprintf(&batch, "route replace %s ", cidr)
			if route.Gateway != "" {
				fmt.Fprintf(&batch, "via %s ", route.Gateway)
			}
			fmt.Fprintf(&batch, "dev %s metric 5\n", route.Device)
		} else {
			fmt.Fprintf(&batch, "route del %s dev %s\n", cidr, route.Device)
		}
	}
	cmd := exec.CommandContext(ctx, "ip", "-force", "-batch", "-")
	cmd.Stdin = strings.NewReader(batch.String())
	var errb bytes.Buffer
	cmd.Stderr = &errb
	if err := cmd.Run(); err != nil && add {
		return fmt.Errorf("install Iran bypass routes: %w: %s", err, strings.TrimSpace(errb.String()))
	}
	return nil
}

func AddLocalDNSAlias(ctx context.Context, ip string) error {
	if ip == "" {
		return fmt.Errorf("empty local DNS IP")
	}
	_, err := run(ctx, "ip", "addr", "replace", ip+"/32", "dev", "lo")
	return err
}

func RemoveLocalDNSAlias(ctx context.Context, ip string) {
	if ip != "" {
		_, _ = run(ctx, "ip", "addr", "del", ip+"/32", "dev", "lo")
	}
}

func VerifyDNS(ctx context.Context, name string) error {
	if name == "" {
		name = "www.cloudflare.com"
	}
	vctx, cancel := context.WithTimeout(ctx, 8*time.Second)
	defer cancel()
	if _, err := exec.LookPath("resolvectl"); err == nil {
		if _, err := run(vctx, "resolvectl", "query", name); err != nil {
			return fmt.Errorf("tunneled DNS verification failed for %s: %w", name, err)
		}
		return nil
	}
	if _, err := run(vctx, "getent", "ahosts", name); err != nil {
		return fmt.Errorf("tunneled DNS verification failed for %s: %w", name, err)
	}
	return nil
}

func SetDNS(ctx context.Context, ifname, dnsIP string) error {
	if _, err := exec.LookPath("resolvectl"); err != nil {
		return fmt.Errorf("resolvectl is required for TUN DNS mode")
	}
	if _, err := run(ctx, "resolvectl", "dns", ifname, dnsIP); err != nil {
		return err
	}
	if _, err := run(ctx, "resolvectl", "domain", ifname, "~."); err != nil {
		return err
	}
	_, _ = run(ctx, "resolvectl", "default-route", ifname, "yes")
	return nil
}

func RestoreDNS(ctx context.Context, ifname string) {
	if _, err := exec.LookPath("resolvectl"); err == nil {
		_, _ = run(ctx, "resolvectl", "revert", ifname)
	}
}

type RPFilterState struct {
	All string
	Dev string
	If  string
}

func DisableRPFilter(ctx context.Context, physicalIf string) RPFilterState {
	s := RPFilterState{If: physicalIf}
	s.All, _ = run(ctx, "sysctl", "-n", "net.ipv4.conf.all.rp_filter")
	if physicalIf != "" {
		s.Dev, _ = run(ctx, "sysctl", "-n", "net.ipv4.conf."+physicalIf+".rp_filter")
	}
	_, _ = run(ctx, "sysctl", "-q", "-w", "net.ipv4.conf.all.rp_filter=0")
	if physicalIf != "" {
		_, _ = run(ctx, "sysctl", "-q", "-w", "net.ipv4.conf."+physicalIf+".rp_filter=0")
	}
	return s
}

func RestoreRPFilter(ctx context.Context, s RPFilterState) {
	if _, err := strconv.Atoi(strings.TrimSpace(s.All)); err == nil {
		_, _ = run(ctx, "sysctl", "-q", "-w", "net.ipv4.conf.all.rp_filter="+strings.TrimSpace(s.All))
	}
	if s.If != "" {
		if _, err := strconv.Atoi(strings.TrimSpace(s.Dev)); err == nil {
			_, _ = run(ctx, "sysctl", "-q", "-w", "net.ipv4.conf."+s.If+".rp_filter="+strings.TrimSpace(s.Dev))
		}
	}
}

func EnableKillSwitch(ctx context.Context, ifname, physicalIf, upstream4, upstream6 string, bypassCIDRs []string) error {
	if _, err := exec.LookPath("nft"); err != nil {
		return fmt.Errorf("nft not installed")
	}
	var allow4, allow6 string
	if upstream4 != "" {
		allow4 = fmt.Sprintf("ip daddr %s oifname \"%s\" accept", upstream4, physicalIf)
	}
	if upstream6 != "" {
		allow6 = fmt.Sprintf("ip6 daddr %s oifname \"%s\" accept", upstream6, physicalIf)
	}
	bypassSet, bypassRule := "", ""
	if len(bypassCIDRs) > 0 {
		bypassSet = "set iran_bypass { type ipv4_addr; flags interval; elements = { " + strings.Join(bypassCIDRs, ", ") + " } }"
		bypassRule = fmt.Sprintf("ip daddr @iran_bypass oifname \"%s\" accept", physicalIf)
	}
	script := fmt.Sprintf(`table inet firetunnel {
 %s
 chain output {
  type filter hook output priority 0; policy drop;
  oifname "lo" accept
  ct state established,related accept
  oifname "%s" accept
  %s
  %s
  %s
 }
}`, bypassSet, ifname, allow4, allow6, bypassRule)
	cmd := exec.CommandContext(ctx, "nft", "-f", "-")
	cmd.Stdin = strings.NewReader(script)
	var errb bytes.Buffer
	cmd.Stderr = &errb
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("nft: %w: %s", err, strings.TrimSpace(errb.String()))
	}
	return nil
}

func DisableKillSwitch(ctx context.Context) {
	_, _ = run(ctx, "nft", "delete", "table", "inet", "firetunnel")
}
