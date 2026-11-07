import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native anti-debug check for desktop VPN connection attempts.
class DesktopSecurityGuard {
  DesktopSecurityGuard._();

  static const _linuxChannel = MethodChannel('com.harmoney.vpn');
  static const _windowsChannel =
      MethodChannel('io.harmoney.client/windows_tray');

  static Future<bool> isDebuggerAttached() async {
    if (!Platform.isLinux && !Platform.isWindows) return false;
    // A debug build is expected to run under a debugger. Treating that as a
    // compromised runtime prevents developers from exercising VPN flows and
    // makes diagnostics impossible. Release builds retain the native check.
    if (kDebugMode) return false;
    final channel = Platform.isWindows ? _windowsChannel : _linuxChannel;
    try {
      final nativeResult =
          await channel.invokeMethod<bool>('isDebuggerAttached');
      if (nativeResult != null) return nativeResult;
    } on PlatformException {
      // Linux has an equivalent kernel-provided check in procfs. Use it if
      // the Flutter channel is unavailable, so a channel registration issue
      // is not mistaken for an attached debugger.
      if (!Platform.isLinux) rethrow;
    } on MissingPluginException {
      if (!Platform.isLinux) rethrow;
    }

    if (Platform.isLinux) return _linuxProcfsDebuggerCheck();
    // Keep Windows fail-closed when the native guard is unavailable.
    return true;
  }

  static Future<bool> _linuxProcfsDebuggerCheck() async {
    try {
      final status = await File('/proc/self/status').readAsLines();
      final tracerLine = status.where((line) => line.startsWith('TracerPid:'));
      if (tracerLine.length != 1) return true;
      final tracerPid = int.tryParse(tracerLine.single.substring(10).trim());
      // Unknown state remains unsafe; a positive PID means a tracer is attached.
      return tracerPid == null || tracerPid > 0;
    } on FileSystemException {
      return true;
    }
  }
}
