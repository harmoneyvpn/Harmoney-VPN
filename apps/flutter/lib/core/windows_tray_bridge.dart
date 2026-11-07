import 'package:flutter/services.dart';

import 'vpn_core.dart';

/// Connects the Windows native notification-area menu to the Flutter VPN core.
class WindowsTrayBridge {
  WindowsTrayBridge._();

  static const _channel = MethodChannel('io.harmoney.client/windows_tray');
  static bool _installed = false;
  static Future<void> Function()? _toggle;
  static void Function()? _openApp;
  static void Function()? _openServers;
  static void Function()? _openSettings;
  static void Function()? _openLogs;
  static Future<void> Function()? _toggleAutoConnect;
  static Future<void> Function()? _toggleLaunchOnStartup;
  static Future<void> Function()? _toggleStartMinimized;
  static Future<void> Function()? _quit;
  static String? _lastState;

  static Future<void> quitApplication() async {
    await _channel.invokeMethod<void>('quitApplication');
  }

  static Future<void> configure({
    required Future<void> Function() onToggle,
    required void Function() onOpenApp,
    required void Function() onOpenServers,
    required void Function() onOpenSettings,
    required void Function() onOpenLogs,
    required Future<void> Function() onToggleAutoConnect,
    required Future<void> Function() onToggleLaunchOnStartup,
    required Future<void> Function() onToggleStartMinimized,
    required Future<void> Function() onQuit,
  }) async {
    _toggle = onToggle;
    _openApp = onOpenApp;
    _openServers = onOpenServers;
    _openSettings = onOpenSettings;
    _openLogs = onOpenLogs;
    _toggleAutoConnect = onToggleAutoConnect;
    _toggleLaunchOnStartup = onToggleLaunchOnStartup;
    _toggleStartMinimized = onToggleStartMinimized;
    _quit = onQuit;
    if (_installed) return;
    _installed = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'toggleConnection':
          await _toggle?.call();
          break;
        case 'openServers':
          _openServers?.call();
          break;
        case 'openApp':
          _openApp?.call();
          break;
        case 'openSettings':
          _openSettings?.call();
          break;
        case 'openLogs':
          _openLogs?.call();
          break;
        case 'toggleAutoConnect':
          await _toggleAutoConnect?.call();
          break;
        case 'toggleLaunchOnStartup':
          await _toggleLaunchOnStartup?.call();
          break;
        case 'toggleStartMinimized':
          await _toggleStartMinimized?.call();
          break;
        case 'quitApplication':
          await _quit?.call();
          break;
      }
    });
  }

  static Future<void> update(
    VpnConnectionState? state, {
    required Map<String, String> labels,
    required bool autoConnect,
    required bool launchOnStartup,
    required bool startMinimized,
  }) async {
    if (state == null) return;
    final server = state.server?.city.isNotEmpty == true
        ? state.server!.city
        : state.server?.country ?? labels['automatic'] ?? 'Automatic';
    final status = state.isTransitioning
        ? (state.status.name.toLowerCase().contains('disconnect')
            ? 'disconnecting'
            : 'connecting')
        : state.isConnected
            ? 'connected'
            : state.status.name.toLowerCase().contains('error')
                ? 'error'
                : 'disconnected';
    final localizedLabels = Map<String, String>.unmodifiable(labels);
    final value =
        '$status|$server|$autoConnect|$launchOnStartup|$startMinimized|${localizedLabels.entries.map((e) => '${e.key}=${e.value}').join(';')}';
    if (value == _lastState) return;
    _lastState = value;
    try {
      await _channel.invokeMethod<void>('updateState', {
        'status': status,
        'server': server,
        'autoConnect': autoConnect,
        'launchOnStartup': launchOnStartup,
        'startMinimized': startMinimized,
        'labels': localizedLabels,
      });
    } on MissingPluginException {
      // The bridge is only implemented by the Windows runner.
    } on PlatformException {
      // The VPN remains usable if the tray is unavailable.
    }
  }
}
