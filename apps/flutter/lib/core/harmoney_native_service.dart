import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'vpn_core.dart';

/// The installed Linux helper owns the core, TUN, DNS and routes.
/// A SOCKS listener or core progress message alone is never a VPN connection.
class HarmoneyNativeService {
  HarmoneyNativeService._internal();
  static final instance = HarmoneyNativeService._internal();
  static const helperPath = '/usr/libexec/harmoney-vpn-helper';
  static const statePath = '/run/harmoney-vpn/state.json';

  final _statusController = StreamController<VpnConnectionStatus>.broadcast();
  final _progressController = StreamController<String>.broadcast();
  Stream<VpnConnectionStatus> get statusStream => _statusController.stream;
  Stream<String> get progressStream => _progressController.stream;
  VpnConnectionStatus _currentStatus = VpnConnectionStatus.disconnected;
  VpnConnectionStatus get currentStatus => _currentStatus;
  String? _lastError;
  String? get lastError => _lastError;
  int _currentPing = 0;
  String _currentFlag = '';
  Map<String, dynamic> _details = {};
  Timer? _timer;
  bool _reading = false;
  int _generation = 0;
  String? _expectedSession;

  bool initialize() {
    if (!Platform.isLinux) return false;
    if (!File(helperPath).existsSync()) return false;
    _timer ??= Timer.periodic(
      const Duration(seconds: 2),
      (_) => refreshStatus(),
    );
    return true;
  }

  Future<Map<String, dynamic>> _run(
    String action, [
    List<String> args = const [],
    String? stdinPayload,
  ]) async {
    if (!initialize()) {
      throw StateError(
        'Harmoney system VPN helper is not installed. '
        'Run scripts/install-harmoney.sh as administrator.',
      );
    }
    final process = await Process.start('pkexec', [
      helperPath,
      action,
      ...args,
    ]);
    if (stdinPayload != null) process.stdin.write(stdinPayload);
    await process.stdin.close();
    final stdoutResult = process.stdout.transform(utf8.decoder).join();
    final stderrResult = process.stderr.transform(utf8.decoder).join();
    int code;
    try {
      code = await process.exitCode.timeout(const Duration(seconds: 30));
    } on TimeoutException {
      process.kill();
      rethrow;
    }
    final output = (await stdoutResult).trim();
    final error = (await stderrResult).trim();
    if (code != 0) throw StateError(error.isEmpty ? output : error);
    final data = Map<String, dynamic>.from(jsonDecode(output) as Map);
    if (data['ok'] != true) throw StateError('${data['error']}');
    return data;
  }

  Future<void> refreshStatus() async {
    if (_reading || !Platform.isLinux) return;
    _reading = true;
    try {
      final file = File(statePath);
      if (!await file.exists()) {
        if (_currentStatus == VpnConnectionStatus.connected) {
          _lastError = 'Harmoney VPN service state was lost.';
          _updateStatus(VpnConnectionStatus.failed);
        }
        return;
      }
      final data = Map<String, dynamic>.from(
        jsonDecode(await file.readAsString()) as Map,
      );
      if (_expectedSession != null && data['session_id'] != _expectedSession) {
        return;
      }
      _details = data;
      final updated = (data['updated_at'] as num?)?.toInt() ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch ~/ 1000 - updated;
      final fresh = age >= 0 && age < 45;
      final status = switch (data['state']) {
        'connected' when data['verified'] == true && fresh =>
          VpnConnectionStatus.connected,
        'connected' => VpnConnectionStatus.failed,
        'preparing' => VpnConnectionStatus.preparing,
        'connecting' => VpnConnectionStatus.connecting,
        'verifying' => VpnConnectionStatus.verifying,
        'recovering' => VpnConnectionStatus.recovering,
        'disconnecting' => VpnConnectionStatus.disconnecting,
        'error' || 'failed' => VpnConnectionStatus.failed,
        _ => VpnConnectionStatus.disconnected,
      };
      _lastError = data['error'] as String?;
      if (!fresh && data['state'] == 'connected') {
        _lastError = 'Harmoney VPN verification expired.';
      }
      _currentPing = (data['ping_ms'] as num?)?.toInt() ?? 0;
      _currentFlag = data['country'] as String? ?? '';
      if (data['message'] case final String message) {
        _progressController.add(message);
      }
      _updateStatus(status);
    } on FileSystemException {
      // Atomic state replacement can briefly race a read.
    } on FormatException {
      _lastError = 'Invalid Harmoney VPN service state.';
      _updateStatus(VpnConnectionStatus.failed);
    } finally {
      _reading = false;
    }
  }

  void _updateStatus(VpnConnectionStatus status) {
    if (_currentStatus == status) return;
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<bool> startVPN({
    required String pattern,
    required List<String> subscriptionUrls,
    bool deepScan = false,
    bool healthCheck = true,
    bool killSwitch = true,
    bool dnsProtection = true,
    bool ipv6Protection = true,
  }) async {
    final generation = ++_generation;
    _lastError = null;
    _expectedSession = 'pending';
    _updateStatus(VpnConnectionStatus.preparing);
    try {
      final response = await _run('connect', [
        pattern,
        killSwitch ? '1' : '0',
      ], jsonEncode(subscriptionUrls));
      _expectedSession = response['session_id'] as String?;
      if (_expectedSession == null) {
        throw StateError(
          'Harmoney helper did not identify the new VPN session.',
        );
      }
      if (generation != _generation) {
        await _run('disconnect');
        return false;
      }
      final deadline = DateTime.now().add(const Duration(seconds: 120));
      while (generation == _generation && DateTime.now().isBefore(deadline)) {
        await refreshStatus();
        if (_currentStatus == VpnConnectionStatus.connected) return true;
        if (_currentStatus == VpnConnectionStatus.failed) return false;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (generation != _generation) return false;
      await _run('disconnect');
      throw StateError(
        'Harmoney VPN connection timed out before traffic was verified.',
      );
    } catch (error) {
      if (generation != _generation) return false;
      _lastError = error.toString();
      _updateStatus(VpnConnectionStatus.failed);
      return false;
    }
  }

  Future<void> stopVPN() async {
    ++_generation;
    _expectedSession = null;
    _updateStatus(VpnConnectionStatus.disconnecting);
    try {
      if (File(helperPath).existsSync()) await _run('disconnect');
      _updateStatus(VpnConnectionStatus.disconnected);
    } catch (error) {
      _lastError = error.toString();
      _updateStatus(VpnConnectionStatus.failed);
      rethrow;
    }
  }

  int measurePing() =>
      _currentStatus == VpnConnectionStatus.connected ? _currentPing : 0;
  String getFlag() => _currentFlag;
  String getVpnStatus() => _currentStatus.name;
  Future<Map<String, Object?>> diagnostics() async {
    await refreshStatus();
    return {
      'helper_installed': File(helperPath).existsSync(),
      'tunnel_running': _currentStatus == VpnConnectionStatus.connected,
      'traffic_verified': _currentStatus == VpnConnectionStatus.connected,
      'ping_ms': _currentPing,
      'kill_switch': _details['kill_switch_active'] == true,
      'dns_protection': _details['dns_protection'] == true,
      'ipv6_protection': _details['ipv6_protection'] == true,
      'country': _currentFlag,
      'error': _lastError,
    };
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
