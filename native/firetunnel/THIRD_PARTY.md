# Third-party component

FireTunnel Phase 3.2 can download and execute `tun2socks` by xjasonlyu as the Linux userspace TCP/IP packet engine.

- Project: https://github.com/xjasonlyu/tun2socks
- Version pinned by FireTunnel: v2.7.0
- License: MIT
- Linux amd64 release archive SHA-256: `a612baa287a3b6de6221f74fd02b442a50888508227ecf51e1288a5ccbb77381`

The tun2socks binary is not embedded in this source archive. `firetunnel setup-linux` downloads it from the upstream GitHub release and verifies the pinned checksum before installation.

Windows full-tunnel runtime:

- `tun2socks-windows-amd64.zip` v2.7.0, MIT, SHA-256 `c5d46e9452f6c9cc7c15ab9158d6d6a0169ceecd6bca019ce476b49337d2be43`.
- Wintun 0.14.1 signed amd64 DLL, SHA-256 `07c256185d6ee3652e09fa55c0b673e2624b565e02c4b9091c79ca7d2f24ef51`. The official prebuilt DLL is distributed under the permissive binary terms included in the Wintun archive; the package script preserves that license file.
- The Windows package build verifies both hashes before extraction. The connection process requests elevation because it creates a Wintun adapter, changes DNS and routes, and installs the WFP kill switch.
- The Firefox/Fastly HTTP/2 CONNECT transport carries TCP and DoH. UDP/MASQUE is not implemented, so generic UDP traffic is not tunneled.

