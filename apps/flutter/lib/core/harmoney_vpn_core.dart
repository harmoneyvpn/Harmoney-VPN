import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'desktop_security_guard.dart';
import 'harmoney_native_service.dart';
import 'harmoney_windows_xray.dart';
import 'harmoney_source_updater.dart';
import 'harmoney_subscription_service.dart';
import 'harmoney_vpn_bridge.dart';
import 'mobile_vpn_bridge.dart';
import 'vpn_core.dart';

class HarmoneyCore implements VpnCore {
  HarmoneyCore({
    HarmoneyBridge? bridge,
    bool? useLinuxBackend,
    bool? useWindowsBackend,
  })  : _bridge = bridge ?? HarmoneyBridge(),
        _useLinuxBackend = useLinuxBackend ?? Platform.isLinux,
        _useWindowsBackend = useWindowsBackend ?? Platform.isWindows,
        _windowsXray = (useWindowsBackend ?? Platform.isWindows)
            ? HarmoneyWindowsXray()
            : null {
    _initListeners();
  }

  static const String providerId = 'harmoney';

  final HarmoneyBridge _bridge;
  final bool _useLinuxBackend;
  final bool _useWindowsBackend;
  final HarmoneyWindowsXray? _windowsXray;
  int _generation = 0;
  bool _disposed = false;
  Timer? _verificationTimer;
  bool _verifying = false;
  final StreamController<VpnConnectionState> _stateController =
      StreamController<VpnConnectionState>.broadcast();

  VpnConnectionState _currentState = const VpnConnectionState(
    status: VpnConnectionStatus.disconnected,
    providerId: providerId,
  );

  VpnServer? _activeServer;
  List<HarmoneySubscriptionNode> _subscriptionNodesCache = const [];
  StreamSubscription<String>? _statusSub;
  StreamSubscription<String>? _progressSub;
  StreamSubscription<VpnConnectionStatus>? _nativeStatusSub;
  StreamSubscription<String>? _nativeProgressSub;
  bool _killSwitch = true;
  bool _dnsProtection = true;
  bool _ipv6Protection = true;

  // These are the actual flowline groups, not fabricated geographic servers.
  static const List<VpnServer> _defaultServers = [
    VpnServer(
      id: 'harmoney-smart',
      providerId: providerId,
      country: 'Harmoney Smart Route',
      city: 'Automatic verified route',
      hostname: '',
      countryCode: 'AUTO',
      available: true,
    ),
    VpnServer(
      id: 'harmoney-fastlane',
      providerId: providerId,
      country: 'Fastlane',
      city: 'Automatic Xray selection',
      hostname: '',
      countryCode: 'AUTO',
      available: true,
    ),
    VpnServer(
      id: 'harmoney-xray',
      providerId: providerId,
      country: 'Xray',
      city: 'Xray routes from the bundled configuration',
      hostname: '',
      countryCode: 'AUTO',
      available: true,
    ),
    VpnServer(
      id: 'harmoney-masque',
      providerId: providerId,
      country: 'Cloudflare MASQUE',
      city: 'Cloudflare tunnel over HTTPS',
      hostname: '',
      countryCode: 'CF',
      available: true,
    ),
    VpnServer(
      id: 'harmoney-warp',
      providerId: providerId,
      country: 'Cloudflare WARP',
      city: 'Cloudflare WireGuard tunnel',
      hostname: '',
      countryCode: 'CF',
      available: true,
    ),
    VpnServer(
      id: 'harmoney-warp-in-warp',
      providerId: providerId,
      country: 'WARP in WARP',
      city: 'Gool double tunnel',
      hostname: '',
      countryCode: 'CF',
      available: true,
    ),
  ];

  void _initListeners() {
    if (_useLinuxBackend) {
      HarmoneyNativeService.instance.initialize();
      _nativeStatusSub = HarmoneyNativeService.instance.statusStream.listen((
        status,
      ) {
        final flag = HarmoneyNativeService.instance.getFlag();
        final base = _activeServer ?? _defaultServers.first;
        final effective = (status == VpnConnectionStatus.connected)
            ? (flag.isNotEmpty
                ? base.copyWith(
                    countryCode: flag.toUpperCase(),
                    country: _countryNameFromCode(flag) ?? flag.toUpperCase(),
                  )
                : base.copyWith(countryCode: 'UNKNOWN', country: 'Unknown'))
            : base;
        _emitState(
          VpnConnectionState(
            status: status,
            providerId: providerId,
            server: effective,
            connectedAt: status == VpnConnectionStatus.connected
                ? (_currentState.connectedAt ?? DateTime.now())
                : null,
            errorMessage: HarmoneyNativeService.instance.lastError,
          ),
        );
      });

      _nativeProgressSub = HarmoneyNativeService.instance.progressStream.listen(
        (progress) {
          if (_currentState.status == VpnConnectionStatus.connecting ||
              _currentState.status == VpnConnectionStatus.authenticating ||
              _currentState.status == VpnConnectionStatus.preparing) {
            _emitState(_currentState.copyWith(rawBackendState: progress));
          }
        },
      );
    } else {
      _statusSub = _bridge.statusUpdates.listen((status) {
        _mapStatusUpdate(status);
      });

      _progressSub = _bridge.progressUpdates.listen((progress) {
        if (_currentState.status == VpnConnectionStatus.connecting ||
            _currentState.status == VpnConnectionStatus.authenticating ||
            _currentState.status == VpnConnectionStatus.preparing) {
          _emitState(_currentState.copyWith(rawBackendState: progress));
        }
      });
    }

    // Initial check
    unawaited(_checkInitialState());
  }

  Future<void> _checkInitialState() async {
    final generation = _generation;
    try {
      if (_useLinuxBackend) {
        final service = HarmoneyNativeService.instance;
        await service.refreshStatus();
        if (generation != _generation || _disposed) return;
        _emitState(
          VpnConnectionState(
            status: service.currentStatus,
            providerId: providerId,
            server: service.currentStatus == VpnConnectionStatus.connected
                ? _defaultServers.first
                : null,
            connectedAt: service.currentStatus == VpnConnectionStatus.connected
                ? DateTime.now()
                : null,
            errorMessage: service.lastError,
          ),
        );
        return;
      }
      if (_useWindowsBackend && _windowsXray != null) {
        final state = await _windowsXray.readState();
        if (generation != _generation || _disposed) return;
        if (state?['state'] == 'connected') {
          final connectedServer = _windowsConnectedServer(state);
          _activeServer = connectedServer;
          _emitState(
            VpnConnectionState(
              status: VpnConnectionStatus.connected,
              providerId: providerId,
              server: connectedServer,
              protocol: state?['transport']?.toString(),
              endpoint: state?['endpoint']?.toString(),
              publicIp: state?['public_ip']?.toString(),
              connectedAt: state?['connected_at'] is num
                  ? DateTime.fromMillisecondsSinceEpoch(
                      (state!['connected_at'] as num).toInt() * 1000,
                    )
                  : DateTime.now(),
            ),
          );
          _startVerificationMonitoring();
        }
        return;
      }
      final capabilities = await _bridge.capabilities();
      if (capabilities['system_tunnel'] == true &&
          capabilities['traffic_verification'] == true &&
          await _bridge.isTunnelRunning() &&
          await _bridge.verifyGateway() &&
          generation == _generation &&
          !_disposed) {
        _emitState(
          VpnConnectionState(
            status: VpnConnectionStatus.connected,
            providerId: providerId,
            server: _activeServer,
            connectedAt: DateTime.now(),
          ),
        );
        _startVerificationMonitoring();
      }
    } catch (_) {}
  }

  void _mapStatusUpdate(String raw) {
    final lower = raw.toLowerCase().trim();
    if (_activeServer == null && lower != 'disconnected') return;
    if (lower == 'connected' && _currentState.isConnected) return;
    final status = switch (lower) {
      'connected' => VpnConnectionStatus.verifying,
      'connecting' => VpnConnectionStatus.connecting,
      'analyzing' || 'authenticating' => VpnConnectionStatus.authenticating,
      'loading' || 'preparing' => VpnConnectionStatus.preparing,
      'disconnecting' => VpnConnectionStatus.disconnecting,
      'recovering' => VpnConnectionStatus.recovering,
      'disconnected' => VpnConnectionStatus.disconnected,
      'error' || 'failed' => VpnConnectionStatus.error,
      _ => _currentState.status,
    };

    _emitState(
      VpnConnectionState(
        status: status,
        providerId: providerId,
        server: _activeServer ?? _defaultServers.first,
        connectedAt: status == VpnConnectionStatus.connected
            ? (_currentState.connectedAt ?? DateTime.now())
            : null,
        rawBackendState: raw,
      ),
    );
  }

  void _emitState(VpnConnectionState newState) {
    if (_disposed) return;
    _currentState = newState;
    _stateController.add(newState);
  }

  VpnServer _windowsConnectedServer(Map<String, dynamic>? state) {
    final base = _activeServer ?? _defaultServers.first;
    final code = (state?['exit_country_code'] ?? state?['country_code'])
        ?.toString()
        .trim()
        .toUpperCase();
    if (code == null || code.length != 2) return base;
    final colo = state?['exit_colo']?.toString().trim();
    return base.copyWith(
      countryCode: code,
      country: _countryNameFromCode(code) ?? code,
      city: colo == null || colo.isEmpty ? base.city : 'Exit · $colo',
    );
  }

  @override
  Stream<VpnConnectionState> watchConnection() async* {
    yield _currentState;
    yield* _stateController.stream;
  }

  @override
  Future<List<VpnServer>> listServers({required String providerId}) async {
    if (providerId != HarmoneyCore.providerId) return _defaultServers;
    try {
      final nodes = await HarmoneySubscriptionService.instance.nodes();
      _subscriptionNodesCache = nodes;
      return [
        ..._defaultServers,
        for (final node in nodes)
          VpnServer(
            id: 'harmoney-sub-${node.id}',
            providerId: providerId,
            country: node.subscriptionName,
            city: '${node.name} · ${node.protocol.toUpperCase()}',
            hostname: '${node.host}:${node.port}',
            countryCode: 'SUB',
            available: node.compatible,
            subscriptionNodeId: node.id,
            subscriptionId: node.subscriptionId,
          ),
      ];
    } catch (_) {
      return _defaultServers;
    }
  }

  @override
  Future<void> refreshServers({required String providerId}) async {
    await HarmoneySubscriptionService.instance.refreshAll();
    await HarmoneySourceUpdater.instance.refresh();
  }

  @override
  Future<int?> probeServer({
    required String providerId,
    required String serverId,
    String? protocol,
  }) async {
    HarmoneySubscriptionNode? nodeId;
    for (final node in _subscriptionNodesCache) {
      if ('harmoney-sub-${node.id}' == serverId) {
        nodeId = node;
        break;
      }
    }
    if (nodeId != null) {
      return HarmoneySubscriptionService.instance.testNode(nodeId);
    }
    if (_useLinuxBackend &&
        _currentState.status == VpnConnectionStatus.connected &&
        _activeServer?.id == serverId) {
      final p = HarmoneyNativeService.instance.measurePing();
      if (p > 0) return p;
    }

    // Catalog entries are routing preferences, not probeable server endpoints.
    // Never display fabricated latency after a failed probe.
    return null;
  }

  Future<bool> _isRuntimeCompromised() async {
    if (kDebugMode) return false;
    try {
      if (Platform.isAndroid) {
        final posture = await MobileVpnBridge.runtimeSecurityStatus();
        return posture['debugger_attached'] == true ||
            posture['debuggable_build'] == true ||
            posture['virtual_environment'] == true ||
            posture['signature_compromised'] == true;
      }
      if (Platform.isLinux || Platform.isWindows) {
        return await DesktopSecurityGuard.isDebuggerAttached();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> connect({
    required String providerId,
    VpnServer? server,
    required String protocol,
  }) async {
    final generation = ++_generation;
    _activeServer = server ?? _defaultServers.first;

    if (await _isRuntimeCompromised()) {
      _emitState(
        VpnConnectionState(
          status: VpnConnectionStatus.error,
          providerId: providerId,
          server: _activeServer,
          errorMessage: 'اتصال به دلیل مسائل امنیتی دستگاه متوقف شد.',
        ),
      );
      return;
    }

    _emitState(
      VpnConnectionState(
        status: VpnConnectionStatus.preparing,
        providerId: providerId,
        server: _activeServer,
      ),
    );

    _emitState(
      VpnConnectionState(
        status: VpnConnectionStatus.connecting,
        providerId: providerId,
        server: _activeServer,
      ),
    );

    try {
      final pattern = _activeServer?.subscriptionId != null
          ? 'xray'
          : switch (_activeServer?.id) {
              'harmoney-fastlane' => 'fastlane',
              'harmoney-xray' => 'xray',
              'harmoney-masque' => 'masque',
              'harmoney-warp' => 'warp',
              'harmoney-warp-in-warp' => 'gool',
              _ => 'auto',
            };

      if (_useLinuxBackend) {
        final ok = await HarmoneyNativeService.instance.startVPN(
          pattern: pattern,
          subscriptionUrls:
              await HarmoneySubscriptionService.instance.sourceUrls(
            subscriptionId: _activeServer?.subscriptionId,
            nodeId: _activeServer?.subscriptionNodeId,
          ),
          deepScan: false,
          healthCheck: true,
          killSwitch: _killSwitch,
          dnsProtection: _dnsProtection,
          ipv6Protection: _ipv6Protection,
        );

        if (generation != _generation) return;
        if (!ok) {
          final err = HarmoneyNativeService.instance.lastError ??
              'Failed to connect to ${_activeServer?.country ?? pattern}';
          _emitState(
            VpnConnectionState(
              status: VpnConnectionStatus.error,
              providerId: providerId,
              server: _activeServer,
              errorMessage: err,
            ),
          );
          throw Exception(err);
        }

        _emitState(
          VpnConnectionState(
            status: VpnConnectionStatus.connected,
            providerId: providerId,
            server: _activeServer,
            connectedAt: DateTime.now(),
          ),
        );
      } else if (_useWindowsBackend && _windowsXray != null) {
        if (!{'auto', 'fastlane', 'xray'}.contains(pattern)) {
          throw UnsupportedError(
            'این مسیر در ویندوز هنوز موتور ندارد؛ فعلاً Fastlane و Xray قابل اتصال هستند.',
          );
        }
        await _windowsXray.connect(
          pattern: pattern,
          preferredNodeId: _activeServer?.subscriptionNodeId,
          selectedSubscriptionId: _activeServer?.subscriptionId,
          killSwitch: _killSwitch,
          onProgress: (progress) {
            if (generation == _generation && !_disposed) {
              _emitState(_currentState.copyWith(rawBackendState: progress));
            }
          },
        );
        if (generation != _generation) return;
        final state = await _windowsXray.readState();
        final connectedServer = _windowsConnectedServer(state);
        _activeServer = connectedServer;
        _emitState(
          VpnConnectionState(
            status: VpnConnectionStatus.connected,
            providerId: providerId,
            server: connectedServer,
            protocol: state?['transport']?.toString() ?? 'Xray',
            endpoint: state?['endpoint']?.toString(),
            publicIp: state?['public_ip']?.toString(),
            connectedAt: DateTime.now(),
          ),
        );
        _startVerificationMonitoring();
      } else {
        final capabilities = await _bridge.capabilities();
        if (generation != _generation) return;
        if (capabilities['system_tunnel'] != true ||
            capabilities['traffic_verification'] != true) {
          throw UnsupportedError(
            capabilities['reason']?.toString() ??
                'Harmoney system VPN engine is not installed for ${Platform.operatingSystem}.',
          );
        }
        final prepared = await _bridge.prepareVpn();
        if (generation != _generation) return;
        if (!prepared) {
          throw StateError('VPN permission was denied.');
        }
        final flowline =
            await HarmoneySourceUpdater.instance.flowlineWithSubscriptions(
          subscriptionId: _activeServer?.subscriptionId,
          preferredNodeId: _activeServer?.subscriptionNodeId,
        );
        final accepted = await _bridge.startVPN(
          pattern: pattern,
          healthCheck: true,
          flowline: flowline,
        );
        if (generation != _generation) {
          await _bridge.stopVPN();
          return;
        }
        if (!accepted) {
          throw StateError(
            'Harmoney native engine rejected the connection request.',
          );
        }
        final deadline = DateTime.now().add(
          Duration(
            seconds: Platform.isAndroid && pattern == 'auto' ? 180 : 110,
          ),
        );
        while (generation == _generation && DateTime.now().isBefore(deadline)) {
          if (await _bridge.getVpnStatus() == 'failed') {
            throw StateError(
              await _bridge.getLastError() ??
                  'Harmoney native connection failed.',
            );
          }
          final running = await _bridge.isTunnelRunning();
          if (running && await _bridge.verifyGateway()) {
            if (generation != _generation) return;
            final flag = await _bridge.getFlag();
            final base = _activeServer ?? _defaultServers.first;
            var effective = flag.isNotEmpty
                ? base.copyWith(
                    countryCode: flag.toUpperCase(),
                    country: _countryNameFromCode(flag) ?? flag.toUpperCase(),
                  )
                : base.copyWith(countryCode: 'UNKNOWN', country: 'Unknown');
            _activeServer = effective;
            _emitState(
              VpnConnectionState(
                status: VpnConnectionStatus.connected,
                providerId: providerId,
                server: effective,
                connectedAt: DateTime.now(),
              ),
            );
            _startVerificationMonitoring();
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        if (generation != _generation) return;
        await _bridge.stopVPN();
        throw StateError(
          'Harmoney system tunnel did not pass traffic verification.',
        );
      }
    } catch (e) {
      if (generation != _generation) return;
      _emitState(
        VpnConnectionState(
          status: VpnConnectionStatus.error,
          providerId: providerId,
          server: _activeServer,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    ++_generation;
    _verificationTimer?.cancel();
    _activeServer = null;
    _emitState(
      VpnConnectionState(
        status: VpnConnectionStatus.disconnecting,
        providerId: providerId,
        server: _activeServer,
      ),
    );
    try {
      if (_useLinuxBackend) {
        await HarmoneyNativeService.instance.stopVPN();
      } else if (_useWindowsBackend && _windowsXray != null) {
        await _windowsXray.disconnect();
        try {
          final config = File(
            '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}${Platform.pathSeparator}HarmoneyVPN${Platform.pathSeparator}harmoney-xray.json',
          );
          if (await config.exists()) await config.delete();
        } catch (_) {}
      } else {
        await _bridge.stopVPN();
      }
      _emitState(
        const VpnConnectionState(
          status: VpnConnectionStatus.disconnected,
          providerId: providerId,
        ),
      );
    } catch (error) {
      _emitState(
        VpnConnectionState(
          status: VpnConnectionStatus.error,
          providerId: providerId,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> cancelConnect() async {
    await disconnect();
  }

  @override
  Future<void> setKillSwitch(bool enabled) async {
    _killSwitch = enabled;
  }

  @override
  Future<void> setDnsProtection(bool enabled) async {
    _dnsProtection = enabled;
  }

  @override
  Future<void> setIpv6Protection(bool enabled) async {
    _ipv6Protection = enabled;
  }

  @override
  Future<bool> credentialsSaved() async {
    return true; // Harmoney uses automatic / zero-config token auth
  }

  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {}

  @override
  Future<Map<String, Object?>> runDiagnostics() async {
    if (_useLinuxBackend) {
      return HarmoneyNativeService.instance.diagnostics();
    }
    if (_useWindowsBackend && _windowsXray != null) {
      final state = await _windowsXray.readState();
      return {
        'core': 'Xray + Wintun',
        'tunnel_state': state?['state'] ?? 'disconnected',
        'endpoint': state?['endpoint'],
        'transport': state?['transport'],
        'kill_switch': _killSwitch,
      };
    }
    final gateway = await _bridge.verifyGateway();
    final isRunning = await _bridge.isTunnelRunning();
    final ping = await _bridge.calculatePing();

    return {
      'core': 'DXcore / Harmoney Engine',
      'gateway_verified': gateway,
      'tunnel_running': isRunning,
      'ping_ms': ping,
      'kill_switch': _killSwitch,
      'dns_protection': _dnsProtection,
      'ipv6_protection': _ipv6Protection,
    };
  }

  void _startVerificationMonitoring() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_verifying ||
          _disposed ||
          !{
            VpnConnectionStatus.connected,
            VpnConnectionStatus.recovering,
            VpnConnectionStatus.verifying,
          }.contains(_currentState.status)) {
        return;
      }
      _verifying = true;
      final generation = _generation;
      try {
        bool verified;
        if (_useWindowsBackend && _windowsXray != null) {
          verified = (await _windowsXray.readState())?['state'] == 'connected';
        } else {
          verified =
              await _bridge.isTunnelRunning() && await _bridge.verifyGateway();
        }
        if (generation == _generation &&
            verified &&
            !_currentState.isConnected) {
          final flag = _useWindowsBackend ? '' : await _bridge.getFlag();
          final base = _activeServer ?? _defaultServers.first;
          final effective = flag.isNotEmpty
              ? base.copyWith(
                  countryCode: flag.toUpperCase(),
                  country: _countryNameFromCode(flag) ?? flag.toUpperCase(),
                )
              : base.copyWith(countryCode: 'UNKNOWN', country: 'Unknown');
          _activeServer = effective;
          _emitState(
            VpnConnectionState(
              status: VpnConnectionStatus.connected,
              providerId: providerId,
              server: effective,
              connectedAt: _currentState.connectedAt ?? DateTime.now(),
            ),
          );
        } else if (generation == _generation &&
            !verified &&
            (_useWindowsBackend ||
                await _bridge.getVpnStatus() != 'recovering')) {
          _emitState(
            const VpnConnectionState(
              status: VpnConnectionStatus.failed,
              providerId: providerId,
              errorMessage: 'Harmoney VPN traffic verification failed.',
            ),
          );
          _verificationTimer?.cancel();
        }
      } finally {
        _verifying = false;
      }
    });
  }

  void dispose() {
    if (_useLinuxBackend) HarmoneyNativeService.instance.dispose();
    _verificationTimer?.cancel();
    _disposed = true;
    ++_generation;
    _statusSub?.cancel();
    _progressSub?.cancel();
    _nativeStatusSub?.cancel();
    _nativeProgressSub?.cancel();
    _stateController.close();
  }

  static String? _countryNameFromCode(String code) {
    const map = {
      'de': 'Germany',
      'us': 'United States',
      'gb': 'United Kingdom',
      'nl': 'Netherlands',
      'fr': 'France',
      'fi': 'Finland',
      'se': 'Sweden',
      'tr': 'Turkey',
      'ir': 'Iran',
      'ca': 'Canada',
      'at': 'Austria',
      'ch': 'Switzerland',
      'es': 'Spain',
      'it': 'Italy',
      'pl': 'Poland',
      'no': 'Norway',
      'sg': 'Singapore',
      'jp': 'Japan',
    };
    return map[code.toLowerCase()];
  }
}
