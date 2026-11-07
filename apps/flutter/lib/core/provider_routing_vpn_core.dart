import 'dart:async';
import 'dart:io';

import 'harmoney_vpn_core.dart';
import 'firetunnel_vpn_core.dart';
import 'vpn_core.dart';
import 'vpn_debug_log_service.dart';
import 'windows_per_app_split_tunnel.dart';
import 'local_cache_service.dart';

class ProviderRoutingVpnCore implements VpnCore {
  ProviderRoutingVpnCore(
    this.existing,
    this.fireTunnel, [
    HarmoneyCore? harmoneyCore,
  ])  : harmoney = harmoneyCore ?? HarmoneyCore(),
        _disabledProvider = const UnsupportedVpnCore();

  final VpnCore existing;
  final FireTunnelVpnCore fireTunnel;
  final HarmoneyCore harmoney;
  final VpnCore _disabledProvider;
  VpnCore? _active;
  Future<void> _operations = Future<void>.value();
  Future<void>? _connectInFlight;
  String? _connectTargetKey;
  String? _activeProviderId;
  int _requestId = 0;

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _operations.then((_) => operation());
    _operations = next.catchError((Object _) {});
    return next;
  }

  final _controller = StreamController<VpnConnectionState>.broadcast();
  VpnConnectionState _lastState = const VpnConnectionState(
    status: VpnConnectionStatus.disconnected,
  );
  String? _lastLoggedState;
  StreamSubscription<VpnConnectionState>? _existingSubscription;
  StreamSubscription<VpnConnectionState>? _fireTunnelSubscription;
  StreamSubscription<VpnConnectionState>? _harmoneySubscription;

  void _emit(VpnConnectionState state) {
    _lastState = state;
    _controller.add(state);

    final provider = state.providerId ??
        _activeProviderId ??
        (_active == harmoney
            ? HarmoneyCore.providerId
            : _active == fireTunnel
                ? FireTunnelVpnCore.providerId
                : _active == existing
                    ? 'existing'
                    : 'unknown');
    final server = state.server;
    final message = <String>[
      'status=${state.status.name}',
      if (server != null && server.country.isNotEmpty)
        'location=${server.country}${server.city.isEmpty ? '' : ' / ${server.city}'}',
      if (state.protocol != null) 'protocol=${state.protocol}',
      if (state.endpoint != null) 'endpoint=${state.endpoint}',
      if (state.rawBackendState != null) state.rawBackendState!,
      if (state.errorMessage != null) 'error=${state.errorMessage}',
    ].join(' · ');
    final signature = '$provider|$message';
    if (signature == _lastLoggedState) return;
    _lastLoggedState = signature;
    final level = state.status == VpnConnectionStatus.error ||
            state.status == VpnConnectionStatus.failed
        ? 'ERROR'
        : state.status == VpnConnectionStatus.recovering ||
                state.status == VpnConnectionStatus.reconnecting
            ? 'WARNING'
            : 'INFO';
    VpnDebugLogService.instance.record(
      level: level,
      provider: provider,
      protocol: state.protocol ?? '-',
      message: message,
    );
  }

  VpnCore _for(String id) {
    final lower = id.toLowerCase();
    if (lower == HarmoneyCore.providerId) return harmoney;
    if (lower == FireTunnelVpnCore.providerId) return fireTunnel;
    return _disabledProvider;
  }

  @override
  Stream<VpnConnectionState> watchConnection() {
    _existingSubscription ??= existing.watchConnection().listen((state) {
      if (_active == null && state.isConnected) _active = existing;
      if (_active == null || _active == existing) _emit(state);
    });
    _fireTunnelSubscription ??= fireTunnel.watchConnection().listen((state) {
      if (state.status != VpnConnectionStatus.disconnected && _active == null) {
        _active = fireTunnel;
      }
      if (_active == fireTunnel) _emit(state);
    });
    _harmoneySubscription ??= harmoney.watchConnection().listen((state) {
      if (state.status != VpnConnectionStatus.disconnected && _active == null) {
        _active = harmoney;
      }
      if (_active == harmoney) _emit(state);
    });
    return Stream<VpnConnectionState>.multi((listener) {
      final subscription = _controller.stream.listen(listener.add);
      listener.add(_lastState);
      listener.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> connect({
    required String providerId,
    VpnServer? server,
    required String protocol,
  }) {
    final effectiveProvider = (server?.providerId.isNotEmpty == true)
        ? server!.providerId
        : providerId;
    // Protocol changes on the same location are new connection requests, not
    // duplicates of the in-flight handshake (e.g. Surfshark OpenVPN -> IKEv2).
    final targetKey =
        '$effectiveProvider|${server?.id ?? 'automatic'}|${protocol.trim().toLowerCase()}';
    final inFlight = _connectInFlight;
    if (inFlight != null) {
      if (_connectTargetKey == targetKey) return inFlight;
      // A different route cancels a slow handshake and takes priority.
      ++_requestId;
      final active = _active;
      if (active != null) {
        unawaited(active.cancelConnect().catchError((Object _) {}));
      }
    }
    VpnDebugLogService.instance.record(
      level: 'INFO',
      provider: effectiveProvider,
      protocol: protocol,
      message:
          'Connect requested${server == null ? '' : ' · ${server.country} / ${server.city}'}',
    );
    final request = ++_requestId;
    _connectTargetKey = targetKey;
    final operation = _enqueue(() async {
      if (request != _requestId) return;
      final target = _for(effectiveProvider);
      // A new location on the same provider also replaces the existing tunnel.
      // Serial teardown prevents late cleanup from deleting the new tunnel.
      final replaceInsideAndroidHarmoney =
          Platform.isAndroid && _active == harmoney && target == harmoney;
      if (_active != null && !replaceInsideAndroidHarmoney) {
        await _disconnectActive();
      }
      if (request != _requestId) return;
      _active = target;
      _activeProviderId = effectiveProvider;
      try {
        var effectiveServer = server;
        if (effectiveServer == null &&
            effectiveProvider == FireTunnelVpnCore.providerId) {
          final candidates = await target.listServers(
            providerId: effectiveProvider,
          );
          effectiveServer =
              candidates.where((item) => item.available).firstOrNull;
          if (effectiveServer == null) {
            throw StateError(
              'No available servers were found for $effectiveProvider. Refresh the server list and try again.',
            );
          }
          VpnDebugLogService.instance.record(
            level: 'INFO',
            provider: effectiveProvider,
            protocol: protocol,
            message:
                'No server was selected; automatically using ${effectiveServer.country} / ${effectiveServer.city}',
          );
        }
        if (Platform.isWindows) {
          await LocalCacheService.instance.init();
          try {
            await WindowsPerAppSplitTunnel.prepare();
          } catch (error) {
            VpnDebugLogService.instance.record(
              level: 'WARN',
              provider: effectiveProvider,
              protocol: protocol,
              message:
                  'Could not snapshot the physical interface for per-app bypass: $error',
            );
          }
          final perAppEnabled =
              LocalCacheService.instance.getWindowsPerAppEnabled();
          final perAppExecutables =
              LocalCacheService.instance.getWindowsPerAppExecutables();
          if (perAppEnabled && perAppExecutables.isNotEmpty) {
            await WindowsPerAppSplitTunnel.configure(
              enabled: true,
              executables: perAppExecutables,
            );
          }
        }
        await _active!.connect(
          providerId: effectiveProvider,
          server: effectiveServer,
          protocol: protocol,
        );
      } catch (error, stackTrace) {
        VpnDebugLogService.instance.record(
          level: 'ERROR',
          provider: effectiveProvider,
          protocol: protocol,
          message: 'Connect failed: $error\n$stackTrace',
        );
        rethrow;
      }
    });
    _connectInFlight = operation;
    unawaited(
      operation.then<void>(
        (_) {
          if (identical(_connectInFlight, operation)) {
            _connectInFlight = null;
            _connectTargetKey = null;
          }
        },
        onError: (Object _, StackTrace __) {
          if (identical(_connectInFlight, operation)) {
            _connectInFlight = null;
            _connectTargetKey = null;
          }
        },
      ),
    );
    return operation;
  }

  @override
  Future<void> disconnect() {
    ++_requestId;
    return _enqueue(_disconnectActive);
  }

  Future<void> _disconnectActive() async {
    _emit(const VpnConnectionState(status: VpnConnectionStatus.disconnecting));
    if (Platform.isWindows) {
      try {
        await WindowsPerAppSplitTunnel.configure(
          enabled: false,
          executables: const [],
        );
      } catch (error) {
        VpnDebugLogService.instance.record(
          level: 'WARN',
          provider: _activeProviderId ?? 'windows',
          protocol: '-',
          message: 'Per-app split cleanup failed: $error',
        );
      }
    }
    final activeCore = _active;
    if (activeCore != null) {
      await activeCore.disconnect();
      _active = null;
      _emit(const VpnConnectionState(status: VpnConnectionStatus.disconnected));
      return;
    }

    if (Platform.isLinux) {
      await fireTunnel.disconnect();
      await harmoney.disconnect();
      _active = null;
      _emit(const VpnConnectionState(status: VpnConnectionStatus.disconnected));
      return;
    }
    Object? firstError;
    for (final core in <VpnCore>[harmoney, fireTunnel, existing]) {
      try {
        await core.disconnect();
      } catch (error) {
        firstError ??= error;
      }
    }
    _active = null;
    _emit(const VpnConnectionState(status: VpnConnectionStatus.disconnected));
    if (firstError != null) throw firstError;
  }

  @override
  Future<void> cancelConnect() async {
    ++_requestId;
    // Interrupt the pending handshake before waiting for serialized cleanup.
    await _active?.cancelConnect();
    await _enqueue(_disconnectActive);
  }

  @override
  Future<List<VpnServer>> listServers({required String providerId}) =>
      _for(providerId).listServers(providerId: providerId);

  @override
  Future<void> refreshServers({required String providerId}) =>
      _for(providerId).refreshServers(providerId: providerId);

  @override
  Future<int?> probeServer({
    required String providerId,
    required String serverId,
    String? protocol,
  }) =>
      _for(
        providerId,
      ).probeServer(
          providerId: providerId, serverId: serverId, protocol: protocol);

  @override
  Future<void> setKillSwitch(bool enabled) async {
    await harmoney.setKillSwitch(enabled);
    await fireTunnel.setKillSwitch(enabled);
    if (_active != fireTunnel && _active != harmoney) {
      await existing.setKillSwitch(enabled);
    }
  }

  @override
  Future<void> setDnsProtection(bool enabled) async {
    await harmoney.setDnsProtection(enabled);
    if (_active != harmoney) await existing.setDnsProtection(enabled);
  }

  @override
  Future<void> setIpv6Protection(bool enabled) async {
    await harmoney.setIpv6Protection(enabled);
    if (_active != harmoney) await existing.setIpv6Protection(enabled);
  }

  @override
  Future<bool> credentialsSaved() async {
    if (_active != null) return _active!.credentialsSaved();
    final e = await existing.credentialsSaved();
    return e;
  }

  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await existing.saveCredentials(username: username, password: password);
  }

  @override
  Future<Map<String, Object?>> runDiagnostics() =>
      (_active ?? existing).runDiagnostics();
}
