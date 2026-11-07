# FireTunnel Flutter bridge contract (Phase 4)

Phase 4 freezes a machine-readable CLI contract so the Flutter app does not
need to parse human terminal text.

## Read state

```bash
firetunnel app-state --country DE
```

Returns one JSON object with version, login state, tun2socks readiness,
locations, selected location, quota and capabilities.

## Locations

```bash
firetunnel locations --json
```

## Quota

```bash
firetunnel quota --json
```

## Connection lifecycle

Phase 5 Flutter shell will call the native core through a platform service:

- Linux desktop: privileged helper/systemd service + local IPC.
- Windows: Windows service + named pipe.
- Android: VpnService + native core bridge.
- iOS/macOS: NetworkExtension/PacketTunnelProvider + native core bridge.

The Flutter layer owns screens/state/UI. Credentials, Guardian tokens,
routing, TUN and transport stay native/core-side.

