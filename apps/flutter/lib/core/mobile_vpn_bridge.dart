import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'platform_features_contracts.dart';

class VpnStateEvent {
  const VpnStateEvent({
    required this.eventId,
    required this.state,
    required this.phase,
    required this.protocol,
    required this.provider,
    required this.serverId,
    required this.hostname,
    required this.message,
    this.nativeError,
    required this.timestamp,
    this.endpoint,
    this.retryCount = 0,
  });

  final String eventId;
  final String state;
  final String phase;
  final String protocol;
  final String provider;
  final String serverId;
  final String hostname;
  final String message;
  final String? nativeError;
  final String timestamp;
  final String? endpoint;
  final int retryCount;
}

class MobileVpnStatus {
  const MobileVpnStatus({
    required this.state,
    this.protocol,
    this.transport,
    this.message,
    this.provider,
    this.serverId,
    this.hostname,
    this.retryCount = 0,
    this.systemVpnActive = false,
  });

  final String state;
  final String? protocol;
  final String? transport;
  final String? message;
  final String? provider;
  final String? serverId;
  final String? hostname;
  final int retryCount;
  final bool systemVpnActive;

  bool get isConnected => state == 'connected' || systemVpnActive;
  bool get isTerminalError =>
      state == 'error' || state == 'failed' || state.endsWith('_failed');
}

class MobileVpnBridge {
  MobileVpnBridge._();

  static const MethodChannel _android = MethodChannel(
    'io.harmoney.client/android',
  );
  static const EventChannel _androidEvents = EventChannel(
    'io.harmoney.client/android_events',
  );
  static const MethodChannel _ios = MethodChannel('io.harmoney.client/ios');

  static MethodChannel get _channel {
    if (Platform.isAndroid) return _android;
    if (Platform.isIOS) return _ios;
    throw UnsupportedError(
      'Mobile VPN bridge is only available on Android/iOS',
    );
  }

  static Future<List<String>> supportedProtocols() async {
    if (!Platform.isAndroid && !Platform.isIOS) return const [];
    final values = await _channel.invokeListMethod<String>(
      'supportedProtocols',
    );
    return List<String>.unmodifiable(values ?? const <String>[]);
  }

  static Future<int?> probeVpnDataPath() async {
    final reply = await _android.invokeMapMethod<String, Object?>(
      'probeVpnDataPath',
    );
    return (reply?['latencyMs'] as num?)?.toInt();
  }

  static Future<int?> probeFirefox(String hostname, int port) async {
    final reply = await _android.invokeMapMethod<String, Object?>(
      'probeFirefox',
      {'hostname': hostname, 'port': port},
    );
    return (reply?['latencyMs'] as num?)?.toInt();
  }

  static Future<int?> probeFirefoxDataPath() async {
    final reply = await _android.invokeMapMethod<String, Object?>(
      'probeFirefoxDataPath',
    );
    return (reply?['latencyMs'] as num?)?.toInt();
  }

  static Future<bool> prepare(String protocol) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    return (await _channel.invokeMethod<bool>('prepare', <String, Object?>{
          'protocol': protocol.toLowerCase(),
        })) ??
        false;
  }

  static Future<void> connect({
    required String providerId,
    required String serverId,
    required String hostname,
    required String protocol,
  }) async {
    await _channel.invokeMethod<void>('connect', <String, Object?>{
      'providerId': providerId,
      'serverId': serverId,
      'hostname': hostname,
      'protocol': protocol.toLowerCase(),
    });
  }

  static Future<void> disconnect() async {
    await _channel.invokeMethod<void>('disconnect');
  }

  static Future<void> cancelConnect() async {
    await _channel.invokeMethod<void>('cancelConnect');
  }

  static Future<void> setAutoConnect(bool enabled) async {
    await _channel.invokeMethod<void>('setAutoConnect', {'enabled': enabled});
  }

  static Future<MobileVpnStatus> status() async {
    final value =
        await _channel.invokeMapMethod<String, Object?>('status') ?? const {};
    return MobileVpnStatus(
      state: (value['state'] as String?) ?? 'disconnected',
      protocol: value['protocol'] as String?,
      transport: value['transport'] as String?,
      message: value['message'] as String?,
      provider: value['provider'] as String?,
      serverId: value['serverId'] as String?,
      hostname: value['hostname'] as String?,
      retryCount: (value['retryCount'] as num?)?.toInt() ?? 0,
      systemVpnActive: value['systemVpnActive'] == true,
    );
  }

  static Future<bool> credentialsSaved() async {
    return (await _channel.invokeMethod<bool>('credentialsSaved')) ?? false;
  }

  static Future<Map<String, Object?>> diagnostics() async =>
      Map<String, Object?>.from(
        await _channel.invokeMapMethod<String, Object?>('diagnostics') ??
            const {},
      );

  static Future<Map<String, dynamic>> trafficSnapshot() async =>
      Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, Object?>('trafficSnapshot') ??
            const {},
      );

  static Future<Map<String, dynamic>> protectionState() async =>
      Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, Object?>('protectionState') ??
            const {},
      );

  static Future<Map<String, dynamic>> runtimeSecurityStatus() async {
    if (!Platform.isAndroid) return const {};
    return Map<String, dynamic>.from(
      await _android.invokeMapMethod<String, Object?>(
            'runtimeSecurityStatus',
          ) ??
          const {},
    );
  }

  static Future<Map<String, dynamic>> setDnsProtection(bool enabled) async =>
      Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, Object?>('setDnsProtection', {
              'enabled': enabled,
            }) ??
            const {},
      );

  static Future<Map<String, dynamic>> setIpv6Protection(bool enabled) async =>
      Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, Object?>('setIpv6Protection', {
              'enabled': enabled,
            }) ??
            const {},
      );

  static Future<void> openVpnSettings() =>
      _channel.invokeMethod<void>('openVpnSettings');

  static Future<void> openTetherSettings() =>
      _channel.invokeMethod<void>('openTetherSettings');

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _channel.invokeMethod<void>('saveCredentials', <String, Object?>{
      'username': username,
      'password': password,
    });
  }

  static Future<bool> isAlwaysOnVpnActive() async {
    final state = await protectionState();
    return state['always_on'] == true;
  }

  static Future<bool> isLockdownActive() async {
    final state = await protectionState();
    return state['lockdown'] == true;
  }

  static Future<List<String>> listInstalledAppPackages() async {
    if (!Platform.isAndroid) return const [];
    final res = await _channel.invokeListMethod<String>('listInstalledApps');
    return res ?? const [];
  }

  static Future<void> setAppSplitTunneling({
    required List<String> allowedPackages,
    required List<String> disallowedPackages,
  }) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('setAppSplitTunneling', {
      'allowedPackages': allowedPackages,
      'disallowedPackages': disallowedPackages,
    });
  }

  static Future<Map<String, dynamic>> getSplitCidrBypass() async {
    if (!Platform.isAndroid) return const {};
    return Map<String, dynamic>.from(
      await _android.invokeMapMethod<String, Object?>('getSplitCidrBypass') ??
          const {},
    );
  }

  static Future<Map<String, dynamic>> setSplitCidrBypass({
    required bool enabled,
    required List<String> cidrs,
  }) async {
    if (!Platform.isAndroid) return const {};
    return Map<String, dynamic>.from(
      await _android.invokeMapMethod<String, Object?>('setSplitCidrBypass', {
            'enabled': enabled,
            'cidrs': cidrs,
          }) ??
          const {},
    );
  }

  // --- Real-time Event Stream and Live Debugging ---

  static final StreamController<VpnStateEvent> _stateEvents =
      StreamController<VpnStateEvent>.broadcast();
  static bool _initializedMethodHandler = false;

  static void _ensureMethodHandler() {
    if (_initializedMethodHandler) return;
    _initializedMethodHandler = true;
    if (Platform.isAndroid) {
      _android.setMethodCallHandler((call) async {
        if (call.method == 'onVpnStateChanged') {
          final args = call.arguments;
          if (args is Map) {
            final map = Map<String, dynamic>.from(args);
            final event = VpnStateEvent(
              eventId: (map['eventId'] as String?) ?? '',
              state: (map['state'] as String?) ?? '',
              phase: (map['phase'] as String?) ?? '',
              protocol: (map['protocol'] as String?) ?? '',
              provider: (map['provider'] as String?) ?? '',
              serverId: (map['serverId'] as String?) ?? '',
              hostname: (map['hostname'] as String?) ?? '',
              message: (map['message'] as String?) ?? '',
              nativeError: map['nativeError'] as String?,
              timestamp: (map['timestamp'] as String?) ?? '',
            );
            if (!_stateEvents.isClosed) {
              _stateEvents.add(event);
            }
          }
        }
      });
    }
  }

  static Stream<VpnStateEvent> watchVpnStateEvents() {
    _ensureMethodHandler();
    return _stateEvents.stream;
  }

  static Stream<String> watchEventLogStream() {
    if (!Platform.isAndroid) {
      return const Stream.empty();
    }
    return _androidEvents
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .handleError((dynamic error) => '[ERROR] Stream error: $error');
  }

  static Future<List<String>> getLogs() async {
    if (!Platform.isAndroid) return const [];
    final list = await _channel.invokeListMethod<String>('getLogs');
    return list ?? const [];
  }

  static Future<void> clearLogs() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('clearLogs');
  }

  static Future<String> exportSupportBundle() async {
    if (!Platform.isAndroid) {
      return 'Platform does not support Android support bundle.';
    }
    return (await _channel.invokeMethod<String>('exportSupportBundle')) ??
        'Failed to export bundle';
  }

  // --- Android Diagnostic Test Actions ---

  static Future<Map<String, dynamic>> testVpnPermission() async {
    if (!Platform.isAndroid) {
      return {'granted': false, 'message': 'Not on Android'};
    }
    return Map<String, dynamic>.from(
      await _channel.invokeMapMethod<String, Object?>('testVpnPermission') ??
          {},
    );
  }

  static Future<Map<String, dynamic>> testInternet() async {
    if (!Platform.isAndroid) {
      return {'success': false, 'message': 'Not on Android'};
    }
    return Map<String, dynamic>.from(
      await _channel.invokeMapMethod<String, Object?>('testInternet') ?? {},
    );
  }

  static Future<Map<String, dynamic>> testDns() async {
    if (!Platform.isAndroid) {
      return {'success': false, 'message': 'Not on Android'};
    }
    return Map<String, dynamic>.from(
      await _channel.invokeMapMethod<String, Object?>('testDns') ?? {},
    );
  }

  static Future<Map<String, dynamic>> testServer(String hostname) async {
    if (!Platform.isAndroid) {
      return {'success': false, 'message': 'Not on Android'};
    }
    return Map<String, dynamic>.from(
      await _channel.invokeMapMethod<String, Object?>('testServer', {
            'hostname': hostname,
          }) ??
          {},
    );
  }

  static Future<Map<String, dynamic>> testCredentials() async {
    if (!Platform.isAndroid) {
      return {'saved': false, 'message': 'Not on Android'};
    }
    return Map<String, dynamic>.from(
      await _channel.invokeMapMethod<String, Object?>('testCredentials') ?? {},
    );
  }
}

class AndroidPlatformControls implements AndroidPlatformFeatures {
  const AndroidPlatformControls();

  @override
  Future<void> openVpnSettings() => MobileVpnBridge.openVpnSettings();

  @override
  Future<bool> isAlwaysOnVpnActive() => MobileVpnBridge.isAlwaysOnVpnActive();

  @override
  Future<bool> isLockdownActive() => MobileVpnBridge.isLockdownActive();

  @override
  Future<List<String>> listInstalledAppPackages() =>
      MobileVpnBridge.listInstalledAppPackages();

  @override
  Future<void> setAppSplitTunneling({
    required List<String> allowedPackages,
    required List<String> disallowedPackages,
  }) => MobileVpnBridge.setAppSplitTunneling(
    allowedPackages: allowedPackages,
    disallowedPackages: disallowedPackages,
  );

  @override
  Stream<String> watchConnectionLogEventStream() =>
      MobileVpnBridge.watchEventLogStream();

  @override
  Future<List<String>> getLogs() => MobileVpnBridge.getLogs();
  @override
  Future<void> clearLogs() => MobileVpnBridge.clearLogs();
  @override
  Future<String> exportSupportBundle() => MobileVpnBridge.exportSupportBundle();
  @override
  Future<Map<String, dynamic>> testVpnPermission() =>
      MobileVpnBridge.testVpnPermission();
  @override
  Future<Map<String, dynamic>> testInternet() => MobileVpnBridge.testInternet();
  @override
  Future<Map<String, dynamic>> testDns() => MobileVpnBridge.testDns();
  @override
  Future<Map<String, dynamic>> testServer(String hostname) =>
      MobileVpnBridge.testServer(hostname);
  @override
  Future<Map<String, dynamic>> testCredentials() =>
      MobileVpnBridge.testCredentials();
}
