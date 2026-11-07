import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge communicating with native Harmoney / DXcore implementations
/// across Android, Linux, Windows, macOS, and iOS.
class HarmoneyBridge {
  HarmoneyBridge._internal();
  static final HarmoneyBridge _instance = HarmoneyBridge._internal();
  factory HarmoneyBridge() => _instance;

  static const String channelName = 'com.harmoney.vpn';
  static const String progressChannelName = 'com.harmoney.progress_events';
  static const String statusChannelName = 'com.harmoney.vpn_events';
  static const String crashChannelName = 'com.harmoney.crash_events';

  final MethodChannel _methodChannel = const MethodChannel(channelName);
  final EventChannel _progressEventChannel =
      const EventChannel(progressChannelName);
  final EventChannel _statusEventChannel =
      const EventChannel(statusChannelName);

  Stream<String>? _progressStream;
  Stream<String>? _statusStream;

  Future<void> setNativeActionHandler(
    Future<dynamic> Function(MethodCall call) handler,
  ) async {
    _methodChannel.setMethodCallHandler(handler);
  }

  Future<void> updateTrayLabels(Map<String, String> labels) async {
    try {
      await _methodChannel.invokeMethod<void>('updateTrayLabels', labels);
    } on MissingPluginException {
      // The native tray is only available in the Linux desktop runner.
    } on PlatformException {
      // Tray localization must never affect VPN operation.
    }
  }

  Future<void> quitApplication() async {
    await _methodChannel.invokeMethod<void>('quitApplication');
  }

  Stream<String> get progressUpdates {
    if (_progressStream == null) {
      if (Platform.isAndroid || Platform.isIOS) {
        _progressStream = _progressEventChannel
            .receiveBroadcastStream()
            .map((event) => event.toString())
            .handleError((dynamic error) {
          debugPrint('[HarmoneyBridge] Progress stream error: $error');
          return '';
        });
      } else {
        _progressStream = const Stream<String>.empty().asBroadcastStream();
      }
    }
    return _progressStream!;
  }

  Stream<String> get statusUpdates {
    if (_statusStream == null) {
      if (Platform.isAndroid || Platform.isIOS) {
        _statusStream = _statusEventChannel
            .receiveBroadcastStream()
            .map((event) => event is Map
                ? '${event['status'] ?? event['state'] ?? 'disconnected'}'
                : event.toString())
            .handleError((dynamic error) {
          debugPrint('[HarmoneyBridge] Status stream error: $error');
          return 'disconnected';
        });
      } else {
        _statusStream = const Stream<String>.empty().asBroadcastStream();
      }
    }
    return _statusStream!;
  }

  Future<Map<String, dynamic>> capabilities() async {
    try {
      return await _methodChannel
              .invokeMapMethod<String, dynamic>('capabilities') ??
          {};
    } catch (_) {
      return {};
    }
  }

  Future<String?> getVpnStatus() async {
    try {
      return await _methodChannel.invokeMethod<String>('getVpnStatus');
    } catch (e) {
      debugPrint('[HarmoneyBridge] getVpnStatus error: $e');
      return 'disconnected';
    }
  }

  Future<String?> getLastError() async {
    try {
      return await _methodChannel.invokeMethod<String>('getLastError');
    } catch (_) {
      return null;
    }
  }

  Future<int> calculatePing() async {
    try {
      final res = await _methodChannel.invokeMethod<dynamic>('calculatePing');
      if (res is num) return res.toInt();
      return int.tryParse(res?.toString() ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> isTunnelRunning() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isTunnelRunning') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> prepareVpn() async {
    try {
      return await _methodChannel.invokeMethod<bool>('prepareVPN') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> grantVpnPermission() async {
    try {
      return await _methodChannel.invokeMethod<bool>('grantVpnPermission') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startVPN({
    String flowline = '',
    String pattern = '',
    bool deepScan = false,
    bool healthCheck = true,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<Object?>('startVPN', {
        'flowLine': flowline,
        'pattern': pattern,
        'deepScan': deepScan.toString(),
        'healthCheck': healthCheck.toString(),
      });
      return result == true;
    } catch (e) {
      debugPrint('[HarmoneyBridge] startVPN failed: $e');
      return false;
    }
  }

  Future<bool> connect() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('connect');
      return res ?? false;
    } catch (e) {
      debugPrint('[HarmoneyBridge] connect failed: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod('disconnect');
    } catch (e) {
      if (e is MissingPluginException) return;
      rethrow;
    }
  }

  Future<void> stopVPN() async {
    try {
      await _methodChannel.invokeMethod('stopVPN');
    } catch (e) {
      if (e is MissingPluginException) return;
      rethrow;
    }
  }

  Future<String> getFlowLine(String token) async {
    try {
      final res = await _methodChannel.invokeMethod<String>('getFlowLine', {
        'token': token,
        'isTest': 'false',
      });
      return res ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> getCachedFlowLine() async {
    try {
      final res =
          await _methodChannel.invokeMethod<String>('getCachedFlowLine');
      return res ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> decodeAndVerifyFlowline(String flowLine) async {
    try {
      final res = await _methodChannel.invokeMethod<String>(
          'decodeAndVerifyFlowline', {'flowLine': flowLine});
      return res ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> getSharedDirectory() async {
    try {
      return await _methodChannel.invokeMethod<String>('getSharedDirectory') ??
          '';
    } catch (_) {
      return '';
    }
  }

  Future<void> setCacheDir(String cacheDir) async {
    try {
      await _methodChannel.invokeMethod('setCacheDir', {'cacheDir': cacheDir});
    } catch (_) {}
  }

  Future<void> setTimezone(String timezone) async {
    try {
      await _methodChannel.invokeMethod('setTimezone', {'timezone': timezone});
    } catch (_) {}
  }

  Future<String> getFlag() async {
    try {
      return await _methodChannel.invokeMethod<String>('getFlag') ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<bool> verifyGateway() async {
    try {
      return await _methodChannel.invokeMethod<bool>('verifyGateway') ?? false;
    } catch (_) {
      return false;
    }
  }
}
