# Resilient Bootstrap Mode

Goals:

1. Never require Mozilla Remote Settings to be reachable before FireTunnel can discover a known entry point.
2. Never overwrite a known-good list with an empty, malformed, or unusable response.
3. Automatically learn newly added countries/cities/servers without an application update.
4. Keep provider-specific server discovery out of the tunnel core.

Priority:

- live validated server list
- last validated local cache
- embedded bootstrap snapshot

The embedded snapshot is deliberately small. A huge hardcoded catalog becomes stale quickly and is less reliable than a few generic/known entry points plus a validated dynamic cache.

