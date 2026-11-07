import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'app_talker.dart';

class NetworkMonitorService {
  NetworkMonitorService._();

  static final NetworkMonitorService instance = NetworkMonitorService._();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<String>? _physicalSub;
  String? _physicalIdentity;
  Stream<String>? _physicalChanges;
  Stream<String> get physicalNetworkChanges =>
      _physicalChanges ??= Platform.isAndroid
      ? const EventChannel('io.harmoney.client/physical_network')
            .receiveBroadcastStream()
            .map((event) => event.toString())
            .distinct()
            .asBroadcastStream()
      : const Stream<String>.empty();
  List<ConnectivityResult> _lastResults = const [];
  bool _isReconnecting = false;

  /// Callback invoked when a network switch (e.g. WiFi -> Cellular) occurs during an active VPN session.
  Future<void> Function()? onReconnectionRequested;

  /// Function to verify if VPN is currently connected
  bool Function()? isVpnConnected;

  /// Whether smart reconnection on network switch is enabled
  bool autoReconnectOnNetworkSwitch = true;

  void start() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
    _physicalSub?.cancel();
    _physicalSub = physicalNetworkChanges.listen(
      (identity) {
        final previous = _physicalIdentity;
        _physicalIdentity = identity;
        if (previous == null ||
            previous == identity ||
            identity == 'unavailable') {
          return;
        }
        AppTalker.networkEvent('Physical Internet network changed');
        unawaited(_requestReconnect());
      },
      onError: (Object error) {
        AppTalker.warning('Physical network monitor unavailable: $error');
      },
    );
    AppTalker.networkEvent('NetworkMonitorService started');
  }

  void stop() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _physicalSub?.cancel();
    _physicalSub = null;
    AppTalker.networkEvent('NetworkMonitorService stopped');
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    final prev = _lastResults;
    _lastResults = results;

    if (prev.isEmpty) return; // Initial event

    final isSame =
        prev.length == results.length &&
        prev.every((item) => results.contains(item));
    if (isSame) return;

    AppTalker.networkEvent('Network changed from $prev to $results');

    // Android's native stream distinguishes SIMs and excludes VPN transport.
    // connectivity_plus can report the same cellular type for both SIMs.
    if (Platform.isAndroid) return;

    final isNone = results.contains(ConnectivityResult.none) || results.isEmpty;
    if (isNone) return;
    await _requestReconnect();
  }

  Future<void> _requestReconnect() async {
    final isConnected = isVpnConnected?.call() ?? false;
    if (!isConnected || !autoReconnectOnNetworkSwitch || _isReconnecting) {
      return;
    }

    // Verify internet access
    try {
      _isReconnecting = true;
      final hasInternet = await _internetConnection.hasInternetAccess;
      if (hasInternet) {
        AppTalker.info(
          'New network interface verified with internet access. Triggering smart VPN reconnect...',
        );
        await onReconnectionRequested?.call();
      } else {
        AppTalker.warning(
          'New network has no internet access yet. Reconnect deferred.',
        );
      }
    } catch (e) {
      AppTalker.error('Error during smart reconnect evaluation', e);
    } finally {
      _isReconnecting = false;
    }
  }

  Future<bool> checkHasInternet() async {
    try {
      return await _internetConnection.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }
}
