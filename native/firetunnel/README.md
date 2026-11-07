# FireTunnel 0.4.0-alpha — Linux TUN data plane

Phase 3.2 connects Linux TUN traffic to the Firefox/Fastly HTTP/2 tunnel that was proven in Phase 2.

## What changed

```text
Linux applications
      ↓
firetun0
      ↓
tun2socks userspace TCP/IP stack
      ↓
127.0.0.1:1080 (FireTunnel SOCKS5)
      ↓
HTTP/2 CONNECT + Guardian ProxyPass
      ↓
Firefox/Fastly VPN exit
```

DNS is handled separately so it does not leak over the normal network:

```text
systemd-resolved
      ↓
127.0.0.2:53 UDP
      ↓
FireTunnel DNS proxy
      ↓
DNS-over-TCP through HTTP/2 CONNECT
      ↓
1.1.1.1:53
```

## 1. Build

```bash
cd FireTunnel-phase3.2
go build -o firetunnel ./cmd/firetunnel
./firetunnel version
./firetunnel doctor
```

## 2. Install the packet engine once

Run this **without sudo**:

```bash
./firetunnel setup-linux
```

It downloads `tun2socks v2.7.0` for Linux amd64 from the upstream GitHub release and verifies this pinned SHA-256 before installing it into your user profile:

```text
a612baa287a3b6de6221f74fd02b442a50888508227ecf51e1288a5ccbb77381
```

If GitHub is unavailable, place a compatible tun2socks binary anywhere and set:

```bash
export FIRETUNNEL_TUN2SOCKS=/path/to/tun2socks
```

## 3. Connect the whole Linux TCP stack

```bash
sudo ./firetunnel linux-tun --country DE
```

Then, in a second terminal, test **without any SOCKS flag**:

```bash
curl https://www.cloudflare.com/cdn-cgi/trace
```

Expected fields for Germany include:

```text
loc=DE
colo=MUC
```

Stop with `Ctrl+C`. FireTunnel restores its DNS settings, TUN routes, upstream pin routes and rp_filter changes during normal shutdown and handled errors.

## Kill switch

After the basic TUN test succeeds:

```bash
sudo ./firetunnel linux-tun --country DE --killswitch
```

The kill switch permits loopback, TUN traffic and the pinned Fastly upstream while blocking other output.

## Current transport limitation

The current Mozilla/Fastly path used by FireTunnel is HTTP/2 CONNECT, which is TCP-only. Therefore:

- TCP: routed through the VPN.
- DNS: tunneled over TCP through the VPN.
- Generic UDP/QUIC: not yet supported in TUN mode.

Browsers and curl can use TCP normally. Full generic UDP requires the later HTTP/3/MASQUE CONNECT-UDP transport.

## Routing-loop protection

Before installing the two half-default routes, FireTunnel resolves the selected Fastly endpoint and pins its IP to the original physical route. The H2 transport also caches a concrete upstream IP before DNS is switched, preventing the VPN from trying to reach its own server through the TUN.

## Important

FireTunnel is an unofficial project and is not affiliated with Mozilla.


## 0.3.3 DNS fix

- local DNS moved from 127.0.0.2 to 198.18.0.2 to avoid systemd-resolved loopback-link issues
- DNS is now DNS-over-HTTPS to cloudflare-dns.com:443 through FireTunnel
- UDP and TCP DNS listeners are supported locally
- DNS is verified before system-wide TUN routes are installed
- failed DNS setup now exits before taking system routing offline


## 0.3.4 DNS bind-order fix

The local DNS alias (`198.18.0.2/32`) is now added to loopback **before** the DNS proxy binds to `198.18.0.2:53`. This fixes Linux `bind: cannot assign requested address` (`EADDRNOTAVAIL`). Cleanup still removes the alias on exit or error.


## Phase 4 / Flutter boundary

`firetunnel app-state`, `locations --json`, and `quota --json` are the stable
machine-readable surface for the upcoming Flutter client. See
`docs/FLUTTER_BRIDGE.md`. UDP ASSOCIATE is rejected cleanly until the native
HTTP/3 MASQUE CONNECT-UDP transport is implemented.

