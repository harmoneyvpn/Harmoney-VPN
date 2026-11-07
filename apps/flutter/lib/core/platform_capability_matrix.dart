import 'dart:io';

enum PlatformSupportState { supported, unavailable, degraded }

enum PlatformFeatureKey {
  coreConnection,
  locationCatalog,
  speedAndLatencyProbe,
  secureCredentials,
  trafficAccounting,
  baseDiagnostics,
  autoConnectLifecycle,
  killSwitch,
  dnsLeakProtection,
  ipv6LeakProtection,
  splitTunnelingApps,
  splitTunnelingCidr,
  hotspotTethering,
  guestHotspot,
  routerQuotaAndLimits,
  iranBypassAndCustomRouting,
  candidateAndWatchdogEngine,
  liveLogStream,
  alwaysOnVpnService,
  backgroundSubscriptionRefresh,
  systemNetworkExtension,
}

class PlatformCapability {
  const PlatformCapability({required this.state, required this.reason});

  final PlatformSupportState state;
  final String reason;

  bool get isSupported => state == PlatformSupportState.supported;
  bool get isUnavailable => state == PlatformSupportState.unavailable;
  bool get isDegraded => state == PlatformSupportState.degraded;
}

class PlatformCapabilityMatrix {
  PlatformCapabilityMatrix._();

  static final Map<PlatformFeatureKey, PlatformCapability>
  _linuxCapabilities = {
    PlatformFeatureKey.coreConnection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason:
          'Native route and tunnel lifecycle through the privileged helper.',
    ),
    PlatformFeatureKey.locationCatalog: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Remote signed & bundled location provider catalog.',
    ),
    PlatformFeatureKey.speedAndLatencyProbe: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Firefox tunnel and HTTP/2 transport probes.',
    ),
    PlatformFeatureKey.secureCredentials: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Privileged credentials store with zero-memory exposure.',
    ),
    PlatformFeatureKey.trafficAccounting: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Live sysfs & daily/monthly usage accounting.',
    ),
    PlatformFeatureKey.baseDiagnostics: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Full network stack, route table, and ip rule diagnostics.',
    ),
    PlatformFeatureKey.autoConnectLifecycle: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Watchdog auto-reconnect and system startup integration.',
    ),
    PlatformFeatureKey.killSwitch: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'System-wide iptables/nftables lockdown filter chains.',
    ),
    PlatformFeatureKey.dnsLeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Systemd-resolved & resolvconf DNS locking.',
    ),
    PlatformFeatureKey.ipv6LeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Sysctl disable_ipv6 and blackhole route rules.',
    ),
    PlatformFeatureKey.splitTunnelingApps: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Direct-launch isolation is available; saved app selections do not reroute existing processes. CIDR bypass is supported separately.',
    ),
    PlatformFeatureKey.splitTunnelingCidr: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Linux ip rule & custom routing tables.',
    ),
    PlatformFeatureKey.hotspotTethering: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Hostapd / NetworkManager AP with iptables NAT masquerading.',
    ),
    PlatformFeatureKey.guestHotspot: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Isolated guest SSID with client isolation and timer expiry.',
    ),
    PlatformFeatureKey.routerQuotaAndLimits: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Tc traffic shaping & iptables quota accounting.',
    ),
    PlatformFeatureKey.iranBypassAndCustomRouting: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'GeoIP / CIDR Iran bypass routes and domain rules.',
    ),
    PlatformFeatureKey.candidateAndWatchdogEngine: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Engine-v3 candidate rotation & health watchdog.',
    ),
    PlatformFeatureKey.liveLogStream: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Real-time JSON event stream with redaction.',
    ),
    PlatformFeatureKey.alwaysOnVpnService: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Persistent systemd watchdog & autoconnect services with auto-reconnect across sleep/resume and crash recovery.',
    ),
    PlatformFeatureKey.backgroundSubscriptionRefresh: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Runs with systemd user timers. Tasks need an active user service manager; after logout they continue only when systemd linger is enabled.',
    ),
    PlatformFeatureKey.systemNetworkExtension: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Apple-specific NetworkExtension framework.',
    ),
  };

  static final Map<PlatformFeatureKey, PlatformCapability>
  _androidCapabilities = {
    PlatformFeatureKey.coreConnection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Android VpnService & tun fd packet routing.',
    ),
    PlatformFeatureKey.locationCatalog: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Remote signed & bundled location provider catalog.',
    ),
    PlatformFeatureKey.speedAndLatencyProbe: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'HTTP/HTTPS socket latency probes.',
    ),
    PlatformFeatureKey.secureCredentials: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Android EncryptedSharedPreferences / KeyStore.',
    ),
    PlatformFeatureKey.trafficAccounting: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Android NetworkStatsManager and VpnService statistics.',
    ),
    PlatformFeatureKey.baseDiagnostics: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Android ConnectivityManager network link properties.',
    ),
    PlatformFeatureKey.autoConnectLifecycle: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'BootCompletedReceiver and network state callbacks.',
    ),
    PlatformFeatureKey.killSwitch: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Managed via Android System "Block connections without VPN".',
    ),
    PlatformFeatureKey.dnsLeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Enforced by VpnService.Builder.addDnsServer.',
    ),
    PlatformFeatureKey.ipv6LeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Enforced by VpnService IPv6 route filtering.',
    ),
    PlatformFeatureKey.splitTunnelingApps: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'VpnService.Builder.addAllowedApplication & addDisallowedApplication.',
    ),
    PlatformFeatureKey.splitTunnelingCidr: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'IPv4/IPv6 bypass CIDRs are supported by the VPN backends; Android 13+ uses excluded routes directly and older versions build complementary routes. Reconnect to apply.',
    ),
    PlatformFeatureKey.hotspotTethering: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on Android (Android OS isolates Wi-Fi hotspot from VpnService).',
    ),
    PlatformFeatureKey.guestHotspot: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on Android (requires hostapd root access).',
    ),
    PlatformFeatureKey.routerQuotaAndLimits: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on Android (Linux router/tc policy only).',
    ),
    PlatformFeatureKey.iranBypassAndCustomRouting: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Country bypass rules follow the route behavior of each active tunnel.',
    ),
    PlatformFeatureKey.candidateAndWatchdogEngine: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason:
          'Handled via Android Foreground Service lifecycle and ping retries.',
    ),
    PlatformFeatureKey.liveLogStream: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Application in-memory log buffer.',
    ),
    PlatformFeatureKey.alwaysOnVpnService: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'System Always-On VPN supported natively.',
    ),
    PlatformFeatureKey.backgroundSubscriptionRefresh: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'WorkManager schedules network-constrained refreshes; Android may defer execution to meet battery and background limits.',
    ),
    PlatformFeatureKey.systemNetworkExtension: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Apple-specific NetworkExtension framework.',
    ),
  };

  static final Map<PlatformFeatureKey, PlatformCapability>
  _appleCapabilities = {
    PlatformFeatureKey.coreConnection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Apple NetworkExtension NEPacketTunnelProvider / NEVPNManager.',
    ),
    PlatformFeatureKey.locationCatalog: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Remote signed & bundled location provider catalog.',
    ),
    PlatformFeatureKey.speedAndLatencyProbe: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NWConnection TCP/UDP latency probes.',
    ),
    PlatformFeatureKey.secureCredentials: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Apple Keychain Services with secure access groups.',
    ),
    PlatformFeatureKey.trafficAccounting: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NEPacketTunnelFlow packet count & bytes.',
    ),
    PlatformFeatureKey.baseDiagnostics: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NWPathMonitor path and interface status.',
    ),
    PlatformFeatureKey.autoConnectLifecycle: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NetworkExtension On-Demand rules (NEOnDemandRuleConnect).',
    ),
    PlatformFeatureKey.killSwitch: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NEVPNProtocol includeAllNetworks / on-demand locking.',
    ),
    PlatformFeatureKey.dnsLeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NEDNSSettings tunnel-scoped DNS enforcement.',
    ),
    PlatformFeatureKey.ipv6LeakProtection: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'NEIPv6Settings tunnel encapsulation or drop.',
    ),
    PlatformFeatureKey.splitTunnelingApps: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on iOS/macOS sandbox without enterprise MDM per-app VPN.',
    ),
    PlatformFeatureKey.splitTunnelingCidr: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Supported via NEIPv4Settings included/excluded routes.',
    ),
    PlatformFeatureKey.hotspotTethering: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on iOS/macOS (Apple sandbox isolates personal hotspot).',
    ),
    PlatformFeatureKey.guestHotspot: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on iOS/macOS.',
    ),
    PlatformFeatureKey.routerQuotaAndLimits: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on iOS/macOS.',
    ),
    PlatformFeatureKey.iranBypassAndCustomRouting: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Not supported on iOS/macOS sandbox.',
    ),
    PlatformFeatureKey.candidateAndWatchdogEngine: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Managed via NEPacketTunnelProvider reconnection lifecycle.',
    ),
    PlatformFeatureKey.liveLogStream: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'os_log / app group shared notification buffer.',
    ),
    PlatformFeatureKey.alwaysOnVpnService: const PlatformCapability(
      state: PlatformSupportState.unavailable,
      reason: 'Handled via Apple On-Demand VPN rules instead of Android VpnService.',
    ),
    PlatformFeatureKey.backgroundSubscriptionRefresh: const PlatformCapability(
      state: PlatformSupportState.degraded,
      reason: 'Background refresh is scheduled by the system and may be deferred by iOS power policy.',
    ),
    PlatformFeatureKey.systemNetworkExtension: const PlatformCapability(
      state: PlatformSupportState.supported,
      reason: 'Full Apple NetworkExtension integration.',
    ),
  };

  // Windows exposes full-system tunnel orchestration, Xray, hotspot sharing, and route controls.
  static final Map<PlatformFeatureKey, PlatformCapability>
  _windowsCapabilities =
      {
          for (final feature in PlatformFeatureKey.values)
            feature: const PlatformCapability(
              state: PlatformSupportState.unavailable,
              reason:
                  'No Windows implementation is configured for this feature.',
            ),
        }
        ..[PlatformFeatureKey.coreConnection] = const PlatformCapability(
          state: PlatformSupportState.supported,
          reason: 'Full-system tunnel and route orchestration.',
        )
        ..[PlatformFeatureKey.iranBypassAndCustomRouting] =
            const PlatformCapability(
              state: PlatformSupportState.degraded,
              reason: 'Xray applies selected-country IPv4/IPv6 ranges and curated Iranian domains. Domain bypass is limited to the bundled Iranian domain list.',
            )
        ..[PlatformFeatureKey.splitTunnelingCidr] = const PlatformCapability(
          state: PlatformSupportState.supported,
          reason: 'Destination IP subnet routing directly through the physical gateway.',
        )
        ..[PlatformFeatureKey.hotspotTethering] = const PlatformCapability(
          state: PlatformSupportState.supported,
          reason: 'Windows ICS (Internet Connection Sharing) with automatic virtual Wi-Fi MTU 1350 clamping for Latitude 7210 and portable devices.',
        )
        ..[PlatformFeatureKey.splitTunnelingApps] = const PlatformCapability(
          state: PlatformSupportState.degraded,
          reason: 'Uses the native Windows process-aware connection policy to bypass the VPN over the physical interface for TCP and UDP/IPv4 and IPv6; requires a compatible Windows build and the privileged Harmoney service.',
        )
        ..[PlatformFeatureKey.backgroundSubscriptionRefresh] =
            const PlatformCapability(
              state: PlatformSupportState.degraded,
              reason: 'Task Scheduler refresh runs while the user is signed in; it does not run after the user signs out.',
            );

  static final Map<PlatformFeatureKey, PlatformCapability>
  _unsupportedPlatform = {
    for (final feature in PlatformFeatureKey.values)
      feature: const PlatformCapability(
        state: PlatformSupportState.unavailable,
        reason: 'This platform has no configured Harmoney VPN adapter.',
      ),
  };

  static Map<PlatformFeatureKey, PlatformCapability> currentCapabilities() {
    return capabilitiesForPlatform(Platform.operatingSystem);
  }

  static Map<PlatformFeatureKey, PlatformCapability> capabilitiesForPlatform(
    String platform,
  ) {
    return switch (platform.toLowerCase()) {
      'linux' => _linuxCapabilities,
      'android' => _androidCapabilities,
      'ios' || 'macos' => _appleCapabilities,
      'windows' => _windowsCapabilities,
      _ => _unsupportedPlatform,
    };
  }

  static PlatformCapability getCapability(PlatformFeatureKey key) {
    final map = currentCapabilities();
    return map[key] ??
        const PlatformCapability(
          state: PlatformSupportState.unavailable,
          reason: 'Feature not configured for this operating system.',
        );
  }

  static bool isSupported(PlatformFeatureKey key) =>
      getCapability(key).state == PlatformSupportState.supported;

  static String currentPlatformName() {
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
}
