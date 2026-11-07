enum VpnConnectionStatus {
  idle,
  preparing,
  discovering,
  connecting,
  authenticating,
  verifying,
  connected,
  cancelling,
  disconnecting,
  disconnected,
  recovering,
  failed,
  authRequired,
  reconnecting,
  error,
}

class VpnServer {
  const VpnServer({
    required this.id,
    required this.providerId,
    required this.country,
    required this.city,
    required this.hostname,
    this.countryCode,
    this.latencyMs,
    this.fingerprint = '',
    this.available = true,
    this.subscriptionNodeId,
    this.subscriptionId,
  });

  final String id;
  final String providerId;
  final String country;
  final String city;
  final String hostname;
  final String? countryCode;
  final int? latencyMs;
  final String fingerprint;
  final bool available;
  final String? subscriptionNodeId;
  final String? subscriptionId;

  VpnServer copyWith({
    String? id,
    String? providerId,
    String? country,
    String? city,
    String? hostname,
    String? countryCode,
    int? latencyMs,
    String? fingerprint,
    bool? available,
    String? subscriptionNodeId,
    String? subscriptionId,
  }) {
    return VpnServer(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      country: country ?? this.country,
      city: city ?? this.city,
      hostname: hostname ?? this.hostname,
      countryCode: countryCode ?? this.countryCode,
      latencyMs: latencyMs ?? this.latencyMs,
      fingerprint: fingerprint ?? this.fingerprint,
      available: available ?? this.available,
      subscriptionNodeId: subscriptionNodeId ?? this.subscriptionNodeId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}

class VpnConnectionState {
  const VpnConnectionState({
    required this.status,
    this.server,
    this.protocol,
    this.errorMessage,
    this.providerId,
    this.endpoint,
    this.publicIp,
    this.connectedAt,
    this.transport,
    this.quota,
    this.rawBackendState,
  });

  final VpnConnectionStatus status;
  final VpnServer? server;
  final String? protocol;
  final String? errorMessage;
  final String? providerId;
  final String? endpoint;
  final String? publicIp;
  final DateTime? connectedAt;
  final String? transport;
  final Map<String, Object?>? quota;
  final String? rawBackendState;

  bool get isConnected => status == VpnConnectionStatus.connected;
  bool get isTransitioning =>
      status == VpnConnectionStatus.preparing ||
      status == VpnConnectionStatus.discovering ||
      status == VpnConnectionStatus.connecting ||
      status == VpnConnectionStatus.authenticating ||
      status == VpnConnectionStatus.verifying ||
      status == VpnConnectionStatus.cancelling ||
      status == VpnConnectionStatus.disconnecting ||
      status == VpnConnectionStatus.recovering ||
      status == VpnConnectionStatus.reconnecting;

  VpnConnectionState copyWith({
    VpnConnectionStatus? status,
    VpnServer? server,
    String? protocol,
    String? errorMessage,
    String? providerId,
    String? endpoint,
    String? publicIp,
    DateTime? connectedAt,
    String? transport,
    Map<String, Object?>? quota,
    String? rawBackendState,
  }) {
    return VpnConnectionState(
      status: status ?? this.status,
      server: server ?? this.server,
      protocol: protocol ?? this.protocol,
      errorMessage: errorMessage ?? this.errorMessage,
      providerId: providerId ?? this.providerId,
      endpoint: endpoint ?? this.endpoint,
      publicIp: publicIp ?? this.publicIp,
      connectedAt: connectedAt ?? this.connectedAt,
      transport: transport ?? this.transport,
      quota: quota ?? this.quota,
      rawBackendState: rawBackendState ?? this.rawBackendState,
    );
  }
}

abstract interface class VpnCore {
  Stream<VpnConnectionState> watchConnection();
  Future<List<VpnServer>> listServers({required String providerId});
  Future<void> refreshServers({required String providerId});
  Future<int?> probeServer({
    required String providerId,
    required String serverId,
    String? protocol,
  });
  Future<void> connect({
    required String providerId,
    VpnServer? server,
    required String protocol,
  });
  Future<void> disconnect();
  Future<void> cancelConnect();
  Future<void> setKillSwitch(bool enabled);
  Future<void> setDnsProtection(bool enabled);
  Future<void> setIpv6Protection(bool enabled);
  Future<bool> credentialsSaved();
  Future<void> saveCredentials({
    required String username,
    required String password,
  });
  Future<Map<String, Object?>> runDiagnostics();
}

class UnsupportedVpnCore implements VpnCore {
  const UnsupportedVpnCore();

  @override
  Stream<VpnConnectionState> watchConnection() => Stream.value(
    const VpnConnectionState(status: VpnConnectionStatus.disconnected),
  );

  @override
  Future<List<VpnServer>> listServers({required String providerId}) async =>
      const [];

  @override
  Future<void> refreshServers({required String providerId}) async {}

  @override
  Future<int?> probeServer({
    required String providerId,
    required String serverId,
    String? protocol,
  }) async => null;

  @override
  Future<void> connect({
    required String providerId,
    VpnServer? server,
    required String protocol,
  }) async {
    throw UnsupportedError('Native VPN core is not connected yet.');
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> cancelConnect() async {}

  @override
  Future<void> setKillSwitch(bool enabled) async {}

  @override
  Future<void> setDnsProtection(bool enabled) async {}

  @override
  Future<void> setIpv6Protection(bool enabled) async {}

  @override
  Future<bool> credentialsSaved() async => false;

  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    throw UnsupportedError(
      'Secure credential storage is not available on this platform yet.',
    );
  }

  @override
  Future<Map<String, Object?>> runDiagnostics() async => {
    'core': 'unavailable',
    'message': 'Flutter contract is ready for the Rust/native adapter.',
  };
}
