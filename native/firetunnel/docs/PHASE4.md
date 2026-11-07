# Phase 4 - Core/API boundary before Flutter

Implemented in 0.4.0-alpha:

- Stable JSON app-state for Flutter/native clients.
- JSON location and quota output.
- Capability advertisement (`udp_masque=false` until the H3 transport lands).
- Clean SOCKS5 RFC 1928 rejection for UDP ASSOCIATE instead of connection reset.
- Existing working Linux TUN TCP + tunneled DoH path retained.

Transport note:
Mozilla's current CONNECT-UDP design is HTTP/3-only. The existing FireTunnel
upstream is HTTP/2 CONNECT, so pretending UDP works through it would be wrong.
The H3/MASQUE transport belongs behind the same core interface and will be
wired to the platform packet path independently of the Flutter UI.

