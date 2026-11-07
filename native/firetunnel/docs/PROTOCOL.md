# FireTunnel protocol notes — phase 2

Implemented path:

1. Firefox Accounts login against `https://api.accounts.firefox.com/v1`.
2. Derive FxA `authPW` using the documented PICL quick-stretch/HKDF flow.
3. Request an OAuth token with client id `5882386c6d801776` and scope:
   `profile https://identity.mozilla.com/apps/vpn`.
4. Persist access/refresh tokens locally with 0600 permissions.
5. Fetch Guardian ProxyPass from:
   `https://vpn.mozilla.org/api/v1/fpn/token`.
6. Read `X-Quota-Limit`, `X-Quota-Remaining`, and `X-Quota-Reset`.
7. Select a `connect` endpoint from Mozilla Remote Settings, cache, or embedded bootstrap.
8. TLS connect to the proxy with ALPN `h2`.
9. Open HTTP CONNECT streams with:
   `Proxy-Authorization: Bearer <ProxyPass>`.
10. Expose those streams through a local SOCKS5 listener.

Phase 3 will add Linux TUN, DNS, routes, kill switch, reconnect, and
post-connect server-list refresh through the tunnel.

