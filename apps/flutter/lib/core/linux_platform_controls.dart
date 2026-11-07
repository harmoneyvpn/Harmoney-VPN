import 'dart:convert';
import 'dart:io';

import 'mobile_vpn_bridge.dart';
import 'platform_features_contracts.dart';

class LinuxPlatformControls implements LinuxPlatformFeatures {
  static const _helper = '/usr/libexec/harmoney-vpn-platform-helper';

  bool get supported => Platform.isLinux;

  Future<Map<String, dynamic>> _run(
    String action, [
    List<String> args = const [],
  ]) async {
    if (!Platform.isLinux) {
      throw UnsupportedError(
        'Linux platform controls are only available on Linux.',
      );
    }
    final result = await Process.run('pkexec', [_helper, action, ...args]);
    final output = '${result.stdout}'.trim().isNotEmpty
        ? '${result.stdout}'.trim()
        : '${result.stderr}'.trim();
    Map<String, dynamic> decoded;
    try {
      decoded = Map<String, dynamic>.from(jsonDecode(output) as Map);
    } catch (_) {
      throw StateError(
        output.isEmpty ? 'Platform helper returned no response.' : output,
      );
    }
    if (result.exitCode != 0 || decoded['ok'] != true) {
      throw StateError(
        (decoded['error'] as String?) ?? 'Linux platform operation failed.',
      );
    }
    return decoded;
  }

  // --- Split Tunneling ---
  Future<void> setDnsProtection(bool enabled) =>
      _run('dns-set', [enabled ? '1' : '0']);
  Future<void> setIpv6Protection(bool enabled) =>
      _run('ipv6-set', [enabled ? '1' : '0']);
  @override
  Future<Map<String, dynamic>> splitStatus() async {
    try {
      final file = File('/var/lib/harmoney-vpn/platform/split-tunnel.json');
      if (file.existsSync()) {
        final text = await file.readAsString();
        return Map<String, dynamic>.from(jsonDecode(text) as Map);
      }
    } catch (_) {}
    return _run('split-status');
  }

  @override
  Future<Map<String, dynamic>> setSplitEnabled(bool enabled) =>
      _run('split-enable', [enabled ? '1' : '0']);
  @override
  Future<Map<String, dynamic>> addSplitRule(String target, String mode) =>
      _run('split-add', [target, mode]);
  @override
  Future<Map<String, dynamic>> removeSplitRule(String target) =>
      _run('split-remove', [target]);

  @override
  Future<Map<String, dynamic>> addSplitAppRule(
    String desktopId,
    String mode, [
    String? name,
  ]) =>
      _run('split-app-add', [desktopId, mode, name ?? desktopId]);

  @override
  Future<Map<String, dynamic>> removeSplitAppRule(String desktopId) =>
      _run('split-app-remove', [desktopId]);

  @override
  Future<List<Map<String, dynamic>>> listDesktopApps() async {
    if (!Platform.isLinux) return const [];
    try {
      final direct = await _scanDesktopAppsDirect();
      if (direct.isNotEmpty) return direct;
    } catch (_) {}
    try {
      final result = await _run('apps-list');
      return (result['apps'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<List<Map<String, dynamic>>> _scanDesktopAppsDirect() async {
    final home = Platform.environment['HOME'] ?? '';
    final dirs = <String>[
      '/usr/share/applications',
      '/usr/local/share/applications',
      if (home.isNotEmpty) '$home/.local/share/applications',
      '/var/lib/flatpak/exports/share/applications',
      '/var/lib/snapd/desktop/applications',
    ];

    final apps = <String, Map<String, dynamic>>{};

    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      try {
        final entries = dir.listSync();
        for (final entry in entries) {
          if (entry is! File || !entry.path.endsWith('.desktop')) continue;
          final filename = entry.uri.pathSegments.last;
          if (apps.containsKey(filename)) continue;

          try {
            final lines = entry.readAsLinesSync();
            String name = '';
            String exec = '';
            String icon = '';
            bool noDisplay = false;
            bool isApplication = false;

            for (final rawLine in lines) {
              final line = rawLine.trim();
              if (line.startsWith('[') && line != '[Desktop Entry]') {
                if (isApplication) break;
              }
              if (line == 'Type=Application') isApplication = true;
              if (line == 'NoDisplay=true') noDisplay = true;
              if (line.startsWith('Name=') && name.isEmpty) {
                name = line.substring(5).trim();
              }
              if (line.startsWith('Exec=') && exec.isEmpty) {
                exec = line.substring(5).trim();
              }
              if (line.startsWith('Icon=') && icon.isEmpty) {
                icon = line.substring(5).trim();
              }
            }

            if (noDisplay || !isApplication || name.isEmpty) continue;

            apps[filename] = {
              'desktop_id': filename,
              'name': name,
              'exec': exec.split(' ').first,
              'icon': icon,
              'package': filename,
            };
          } catch (_) {}
        }
      } catch (_) {}
    }

    final list = apps.values.toList();
    list.sort(
      (a, b) => (a['name'] as String).toLowerCase().compareTo(
            (b['name'] as String).toLowerCase(),
          ),
    );
    return list;
  }

  @override
  Future<Map<String, dynamic>> launchAppDirect(String desktopId) =>
      _run('app-direct-launch', [desktopId]);

  // --- General VPN helper runner ---
  Future<Map<String, dynamic>> runVpnAction(
    String action, [
    List<String> args = const [],
  ]) async {
    if (!Platform.isLinux) {
      throw UnsupportedError('This system feature is only available on Linux.');
    }
    final result = await Process.run('pkexec', [_helper, action, ...args]);
    final output = '${result.stdout}'.trim().isNotEmpty
        ? '${result.stdout}'.trim()
        : '${result.stderr}'.trim();
    if (result.exitCode != 0) {
      throw StateError(output.isEmpty ? '$action failed.' : output);
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(output) as Map);
    } catch (_) {
      return {'ok': true, 'message': output};
    }
  }

  // --- Router & Hotspot Management ---
  @override
  Future<Map<String, dynamic>> routerStatus() => runVpnAction('router-status');

  Future<Map<String, dynamic>> deviceSet({
    required String mac,
    String policy = 'default',
    int speedKbit = 0,
    int quotaMb = 0,
    String quotaAction = 'notify',
    bool paused = false,
  }) =>
      runVpnAction('device-set', [
        mac,
        policy,
        '$speedKbit',
        '$quotaMb',
        quotaAction,
        paused ? '1' : '0',
      ]);

  Future<Map<String, dynamic>> routerOptions({
    bool? forceDns,
    bool? blockQuic,
    bool? clientIsolation,
    String? ipv6Policy,
  }) =>
      runVpnAction('router-options', [
        forceDns == null ? '1' : (forceDns ? '1' : '0'),
        blockQuic == null ? '0' : (blockQuic ? '1' : '0'),
        clientIsolation == null ? '0' : (clientIsolation ? '1' : '0'),
        ipv6Policy ?? 'block',
      ]);

  @override
  Future<Map<String, dynamic>> guestStart({
    int minutes = 60,
    String ssid = 'Harmoney Guest',
  }) =>
      runVpnAction('guest-start', ['$minutes', ssid]);

  @override
  Future<Map<String, dynamic>> guestStop() => runVpnAction('guest-stop');
  @override
  Future<Map<String, dynamic>> guestStatus() => runVpnAction('guest-status');
  Future<Map<String, dynamic>> hotspotDoctor() =>
      runVpnAction('hotspot-doctor');
  Future<Map<String, dynamic>> hotspotRepair() =>
      runVpnAction('hotspot-repair');
  Future<Map<String, dynamic>> quotaEnforce() => runVpnAction('quota-enforce');

  // --- Advanced Routing & Policies ---
  Future<Map<String, dynamic>> policyAdd(
    String target,
    String policy, {
    String scope = 'both',
  }) =>
      runVpnAction('policy-add', [target, policy, scope]);

  Future<Map<String, dynamic>> policyRemove(
    String target, {
    String scope = 'both',
  }) =>
      runVpnAction('policy-remove', [target, scope]);

  Future<Map<String, dynamic>> routeExplain(String target) =>
      runVpnAction('route-explain', [target]);

  Future<Map<String, dynamic>> routeTest(String target) =>
      runVpnAction('route-test', [target]);

  Future<Map<String, dynamic>> applySafe() => runVpnAction('apply-safe');
  Future<Map<String, dynamic>> fullLiveTest() => runVpnAction('full-live-test');
  Future<Map<String, dynamic>> getCandidates() => runVpnAction('candidates');
  @override
  Future<Map<String, dynamic>> candidateStatus() => getCandidates();
  Future<Map<String, dynamic>> candidateAction(String address, String action) =>
      runVpnAction('candidate-action', [address, action]);

  @override
  Future<Map<String, dynamic>> setDevicePolicy({
    required String mac,
    required String policy,
    int? speedLimitKbit,
    int? quotaMb,
    String? quotaAction,
    bool? paused,
  }) =>
      deviceSet(
        mac: mac,
        policy: policy,
        speedKbit: speedLimitKbit ?? 0,
        quotaMb: quotaMb ?? 0,
        quotaAction: quotaAction ?? 'notify',
        paused: paused ?? false,
      );

  @override
  Future<Map<String, dynamic>> removeDevicePolicy(String mac) =>
      runVpnAction('device-remove', [mac]);

  Future<Map<String, dynamic>> customRulesGet() =>
      runVpnAction('custom-rules-get');
  Future<Map<String, dynamic>> customRulesAdd(String target) =>
      runVpnAction('custom-rules-add', [target]);
  Future<Map<String, dynamic>> customRulesRemove(String target) =>
      runVpnAction('custom-rules-remove', [target]);

  @override
  Future<Map<String, dynamic>> routingModeStatus() =>
      runVpnAction('routing-mode-status');
  @override
  Future<Map<String, dynamic>> setRoutingMode(String mode) =>
      runVpnAction('set-routing-mode', [mode]);
  @override
  Future<Map<String, dynamic>> rulesUpdate() => runVpnAction('rules-update');
  @override
  Future<Map<String, dynamic>> rulesStatus() => runVpnAction('rules-status');
  Future<Map<String, dynamic>> desktopStatus() =>
      runVpnAction('desktop-status');

  Future<Map<String, dynamic>> setLockdown(bool enabled) =>
      runVpnAction('lockdown', [enabled ? '1' : '0']);
  Future<Map<String, dynamic>> setLockdownAllowIran(bool enabled) =>
      runVpnAction('lockdown-allow-iran', [enabled ? '1' : '0']);
  Future<Map<String, dynamic>> lockdownApply() =>
      runVpnAction('lockdown-apply');

  // --- Credential Management (Zero Secrets Logged, Stdin-Based) ---
  Future<void> saveCredentialsSecure(String username, String password) async {
    if (!Platform.isLinux) {
      throw UnsupportedError('Only available on Linux.');
    }
    if (username.isEmpty ||
        username.length > 128 ||
        username.contains('\n') ||
        username.contains('\r')) {
      throw ArgumentError('Invalid service username.');
    }
    if (password.isEmpty ||
        password.length > 512 ||
        password.contains('\n') ||
        password.contains('\r')) {
      throw ArgumentError('Invalid or empty service password.');
    }

    final process = await Process.start('pkexec', [
      _helper,
      'credentials-save',
      username,
    ]);
    process.stdin.writeln(password);
    await process.stdin.flush();
    await process.stdin.close();

    final exitCode = await process.exitCode;
    await process.stdout.drain();
    final stderr = await utf8.decoder.bind(process.stderr).join();
    if (exitCode != 0) {
      final sanitized = stderr.replaceAll(password, '[REDACTED]');
      throw StateError(
        sanitized.isEmpty ? 'Failed to save credentials' : sanitized,
      );
    }
  }

  Future<bool> credentialsStatus() async {
    if (!Platform.isLinux) return false;
    try {
      final result = await runVpnAction('credentials-status');
      return result['saved'] == true;
    } catch (_) {
      return false;
    }
  }

  // --- Disconnect, Cancel & Emergency Stop ---
  Future<void> disconnectClean() async {
    if (!Platform.isLinux) return;
    // Stop the proxy tunnel before restoring the physical DNS/routes.
    final firefox = File('/usr/libexec/harmoney-firetunnel-helper');
    if (await firefox.exists()) {
      final result = await Process.run('pkexec', [firefox.path, 'disconnect']);
      if (result.exitCode != 0) {
        throw StateError('Firefox disconnect failed: ${result.stderr}');
      }
    }
    await runVpnAction('disconnect');
  }

  Future<void> cancelConnectClean() async {
    if (!Platform.isLinux) return;
    await disconnectClean();
  }

  Future<void> emergencyStop() async {
    if (!Platform.isLinux) return;
    await runVpnAction('emergency-stop');
    await runVpnAction('disconnect');
  }

  // --- Engine & Watchdog Status ---
  @override
  Future<Map<String, dynamic>> engineStatus() async {
    final stateFile = File('/run/harmoney-vpn/engine.json');
    if (await stateFile.exists()) {
      try {
        final content = await stateFile.readAsString();
        return Map<String, dynamic>.from(jsonDecode(content) as Map);
      } catch (_) {}
    }
    return runVpnAction('engine-status');
  }

  @override
  Future<Map<String, String>> watchdogStatus() async {
    return _readState('/run/harmoney-vpn/live.state');
  }

  // --- Startup & Auto-Connect ---
  Future<void> setAutoConnect(bool enabled) async {
    await runVpnAction('auto-connect', [enabled ? '1' : '0']);
  }

  @override
  Future<void> setAlwaysOnVpn(bool enabled) async {
    try {
      await _run('alwayson-set', [enabled ? '1' : '0']);
    } catch (_) {}
    await setAutoConnect(enabled);
  }

  @override
  Future<bool> isAlwaysOnVpnActive() async {
    try {
      final res = await _run('alwayson-status');
      return res['enabled'] == true || res['active'] == true;
    } catch (_) {
      return false;
    }
  }

  File get _autostartFile {
    final home = Platform.environment['HOME'] ?? '.';
    return File('$home/.config/autostart/harmoney-secure.desktop');
  }

  Future<bool> launchAtStartupEnabled() async {
    return _autostartFile.existsSync();
  }

  Future<void> setLaunchAtStartup(bool enabled) async {
    final file = _autostartFile;
    if (!enabled) {
      if (file.existsSync()) await file.delete();
      return;
    }
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    final exe = Platform.resolvedExecutable;
    final content = '[Desktop Entry]\n'
        'Type=Application\n'
        'Name=Harmoney Secure\n'
        'Exec="$exe"\n'
        'X-GNOME-Autostart-enabled=true\n'
        'NoDisplay=true\n';
    await file.writeAsString(content);
  }

  // --- Custom Location Lists ---
  File get _locationListsFile {
    final home = Platform.environment['HOME'] ?? '.';
    return File('$home/.config/harmoney-secure/location-lists.json');
  }

  Future<List<Map<String, dynamic>>> getLocationLists() async {
    try {
      final file = _locationListsFile;
      if (!file.existsSync()) return [];
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLocationLists(List<Map<String, dynamic>> lists) async {
    final file = _locationListsFile;
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(lists));
  }

  // --- Live Terminal Logs with Event Stream & Secret Redaction ---
  @override
  Stream<String> watchConnectionLogEventStream() async* {
    if (!Platform.isLinux) return;
    final eventsFile = File('/run/harmoney-vpn/engine.events');
    var lastOffset = 0;

    // Yield initial history if file already exists
    if (eventsFile.existsSync()) {
      try {
        final content = await eventsFile.readAsString();
        lastOffset = content.length;
        for (final raw in content.split('\n')) {
          if (raw.trim().isNotEmpty) {
            yield _formatEventLine(raw);
          }
        }
      } catch (_) {}
    }

    // Actively watch file changes or poll periodically
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!eventsFile.existsSync()) continue;
      try {
        final currentLen = await eventsFile.length();
        if (currentLen < lastOffset) {
          // File was truncated or restarted
          lastOffset = 0;
        }
        if (currentLen > lastOffset) {
          final stream = eventsFile.openRead(lastOffset);
          final text = await stream.transform(utf8.decoder).join();
          lastOffset = currentLen;
          for (final raw in text.split('\n')) {
            if (raw.trim().isNotEmpty) {
              yield _formatEventLine(raw);
            }
          }
        }
      } catch (_) {}
    }
  }

  Stream<VpnStateEvent> watchVpnStateEvents() async* {
    if (!Platform.isLinux) return;
    final eventsFile = File('/run/harmoney-vpn/engine.events');
    var lastOffset = 0;
    var eventCounter = 0;
    String? lastPhase;

    VpnStateEvent parseEvent(String raw) {
      eventCounter++;
      try {
        final v = jsonDecode(raw) as Map;
        final phase = (v['phase'] ?? 'ENGINE').toString().toUpperCase();
        final rawMsg = (v['message'] ?? '').toString();
        final proto = (v['protocol'] ?? 'unknown').toString().toLowerCase();
        final endpoint = (v['endpoint'] ?? '').toString();
        final hostname = (v['hostname'] ?? v['target'] ?? '').toString();
        final server = (v['server'] ?? v['location_id'] ?? '').toString();
        final retry = (v['retry'] as num?)?.toInt() ?? 0;
        final ts = (v['time'] ?? DateTime.now().toIso8601String()).toString();

        final state = switch (phase) {
          'PREPARING' => 'preparing',
          'DISCOVERING' => 'discovering',
          'IKE' || 'CONNECTING' => 'connecting',
          'AUTHENTICATING' => 'authenticating',
          'TUNNEL_ESTABLISHED' || 'VERIFYING_DATA' => 'verifying',
          'CONNECTED' => 'connected',
          'DISCONNECTING' || 'CANCELLING' => 'disconnecting',
          'DISCONNECTED' => 'disconnected',
          'TIMEOUT' => 'timeout',
          'FAILED' || 'BLOCKED' || 'ERROR' => 'failed',
          _ => phase.toLowerCase(),
        };

        final nativeError =
            (phase == 'FAILED' || phase == 'BLOCKED' || phase == 'ERROR')
                ? sanitizeLog(rawMsg)
                : null;

        return VpnStateEvent(
          eventId: 'lnx_${DateTime.now().millisecondsSinceEpoch}_$eventCounter',
          state: state,
          phase: phase,
          protocol: proto,
          provider: (v['provider'] ?? '').toString(),
          serverId: server,
          hostname: hostname,
          endpoint: endpoint.isNotEmpty ? endpoint : null,
          message: sanitizeLog(rawMsg),
          nativeError: nativeError,
          timestamp: ts,
          retryCount: retry,
        );
      } catch (_) {
        return VpnStateEvent(
          eventId: 'lnx_${DateTime.now().millisecondsSinceEpoch}_$eventCounter',
          state: 'info',
          phase: 'ENGINE',
          protocol: 'unknown',
          provider: '',
          serverId: '',
          hostname: '',
          message: sanitizeLog(raw),
          timestamp: DateTime.now().toIso8601String(),
        );
      }
    }

    if (eventsFile.existsSync()) {
      try {
        final content = await eventsFile.readAsString();
        lastOffset = content.length;
        for (final raw in content.split('\n')) {
          if (raw.trim().isNotEmpty) {
            final ev = parseEvent(raw);
            if (ev.phase != lastPhase) {
              lastPhase = ev.phase;
              yield ev;
            }
          }
        }
      } catch (_) {}
    }

    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!eventsFile.existsSync()) continue;
      try {
        final currentLen = await eventsFile.length();
        if (currentLen < lastOffset) {
          lastOffset = 0;
        }
        if (currentLen > lastOffset) {
          final stream = eventsFile.openRead(lastOffset);
          final text = await stream.transform(utf8.decoder).join();
          lastOffset = currentLen;
          for (final raw in text.split('\n')) {
            if (raw.trim().isNotEmpty) {
              final ev = parseEvent(raw);
              if (ev.phase != lastPhase || ev.state == 'failed') {
                lastPhase = ev.phase;
                yield ev;
              }
            }
          }
        }
      } catch (_) {}
    }
  }

  static String _formatEventLine(String raw) => formatLogLine(raw);

  String formatLog(String raw) => formatLogLine(raw);

  static String formatLogLine(String raw) {
    try {
      final v = jsonDecode(raw) as Map;
      final phase = (v['phase'] ?? 'ENGINE').toString().toUpperCase();
      final msg = v['message'] ?? '';
      final proto = v['protocol'] ?? '';
      final endpoint = v['endpoint'] ?? '';
      final level = switch (phase) {
        'FAILED' || 'ERROR' || 'BLOCKED' => 'ERROR',
        'CANCELLING' || 'RECOVERING' || 'FALLBACK' => 'WARNING',
        _ => (v['level'] ?? 'INFO').toString().toUpperCase(),
      };
      final protoStr = proto.toString().isNotEmpty ? ' protocol=$proto' : '';
      final endStr =
          endpoint.toString().isNotEmpty ? ' endpoint=$endpoint' : '';
      return '[$level] ENGINE [$phase] $msg$protoStr$endStr';
    } catch (_) {
      return '[INFO] ${sanitizeLog(raw)}';
    }
  }

  Future<String> connectionAttemptLog() async {
    if (!Platform.isLinux) return '';
    final lines = <String>[];
    final eventsFile = File('/run/harmoney-vpn/engine.events');
    if (eventsFile.existsSync()) {
      try {
        final content = await eventsFile.readAsString();
        for (final raw in content.split('\n')) {
          if (raw.trim().isEmpty) continue;
          lines.add(formatLogLine(raw));
        }
      } catch (_) {}
    }

    final liveState = await _readState('/run/harmoney-vpn/live.state');
    if (liveState.isNotEmpty) {
      final state = liveState['STATE'] ?? liveState['HEALTH'] ?? '';
      if (state.isNotEmpty) {
        lines.add('[INFO] STATUS: $state');
      }
    }
    return lines.join('\n');
  }

  static String sanitizeLog(String text) {
    var out = text;
    out = out.replaceAll(
      RegExp(
        r'(service_pass|service_user|password|secret|PrivateKey|private_key|token|auth_token)([:=]\s*)("[^"]+"|[^\s,]+)',
        caseSensitive: false,
      ),
      r'$1$2"[REDACTED]"',
    );
    out = out.replaceAll(
      RegExp(r'\beap_id:\s*".+"', caseSensitive: false),
      'eap_id: "[REDACTED]"',
    );
    out = out.replaceAll(
      RegExp(
        r'-----BEGIN[ A-Z0-9_-]+KEY-----[^-]+-----END[ A-Z0-9_-]+KEY-----',
        caseSensitive: false,
        multiLine: true,
      ),
      '[REDACTED_KEY_BLOCK]',
    );
    return out;
  }

  String humanizeError(String error) {
    return error;
  }

  // --- Diagnostics ---
  Future<Map<String, dynamic>> chatGptTest() => runVpnAction('chatgpt-test');
  Future<Map<String, dynamic>> dnsTest() => runVpnAction('dns-test');
  Future<Map<String, dynamic>> dnsRepair() => runVpnAction('dns-repair');
  Future<Map<String, dynamic>> mtuTest() => runVpnAction('mtu-test');
  Future<Map<String, dynamic>> speedTest() => runVpnAction('speed-test');
  Future<Map<String, dynamic>> supportBundle() =>
      runVpnAction('support-bundle');

  @override
  Future<String> exportSupportBundle() async {
    final result = await supportBundle();
    return (result['path'] as String?) ??
        (result['bundle'] as String?) ??
        result.toString();
  }

  @override
  Future<Map<String, dynamic>> preflightCheck({String? protocol}) async {
    if (!Platform.isLinux) {
      return {
        'ok': false,
        'all_ready': false,
        'dependencies': <String, dynamic>{},
        'missing': <String>[],
        'error': 'Not on Linux',
      };
    }
    try {
      final res = await runVpnAction('preflight');
      return res;
    } catch (_) {
      final pkexecOk = File('/usr/bin/pkexec').existsSync();
      final systemdOk = File('/usr/bin/systemctl').existsSync();
      final ipOk =
          File('/usr/bin/ip').existsSync() || File('/sbin/ip').existsSync();
      final nftOk = File('/usr/sbin/nft').existsSync() ||
          File('/usr/bin/nft').existsSync();
      final iptOk = File('/usr/sbin/iptables').existsSync() ||
          File('/usr/bin/iptables').existsSync();
      final firewallOk = nftOk || iptOk;
      final missing = <String>[];
      if (!pkexecOk) missing.add('pkexec');
      if (!systemdOk) missing.add('systemd');
      if (!ipOk) missing.add('iproute2');
      if (!firewallOk) missing.add('firewall');
      return {
        'ok': true,
        'all_ready': missing.isEmpty,
        'missing': missing,
        'dependencies': {
          'pkexec': {'available': pkexecOk},
          'systemd': {'available': systemdOk},
          'iproute2': {'available': ipOk},
          'firewall': {'available': firewallOk},
        },
      };
    }
  }

  @override
  Future<Map<String, dynamic>> testVpnPermission() async {
    final preflight = await preflightCheck();
    final pkexecPath = File('/usr/bin/pkexec').existsSync();
    final helperPath = File(_helper).existsSync();
    final vpnHelperPath = helperPath;
    final granted = pkexecPath && helperPath;
    return {
      'ok': granted,
      'granted': granted,
      'pkexec': pkexecPath,
      'platform_helper': helperPath,
      'vpn_helper': vpnHelperPath,
      'preflight': preflight,
      'message': granted
          ? 'Linux privileged helper and elevation permission verified'
          : 'Privileged helper or pkexec is missing',
    };
  }

  @override
  Future<Map<String, dynamic>> testInternet() async {
    try {
      return await runVpnAction('test-internet');
    } catch (_) {
      final res = await Process.run('ping', [
        '-n',
        '-c',
        '2',
        '-W',
        '2',
        '1.1.1.1',
      ]);
      final ok = res.exitCode == 0;
      return {
        'ok': ok,
        'success': ok,
        'target': '1.1.1.1',
        'message': ok ? 'Internet reachable' : 'Internet ping failed',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> testDns() async {
    try {
      return await runVpnAction('dns-test');
    } catch (_) {
      try {
        final lookup = await InternetAddress.lookup('cloudflare.com');
        return {
          'ok': lookup.isNotEmpty,
          'success': lookup.isNotEmpty,
          'message': lookup.isNotEmpty
              ? 'DNS resolution succeeded'
              : 'No records returned',
        };
      } catch (e) {
        return {'ok': false, 'success': false, 'error': e.toString()};
      }
    }
  }

  @override
  Future<Map<String, dynamic>> testServer(String hostname) async {
    try {
      return await runVpnAction('test-server', [hostname]);
    } catch (_) {
      try {
        final lookup = await InternetAddress.lookup(hostname);
        return {
          'ok': lookup.isNotEmpty,
          'success': lookup.isNotEmpty,
          'hostname': hostname,
          'resolved_ips': lookup.map((a) => a.address).toList(),
        };
      } catch (e) {
        return {
          'ok': false,
          'success': false,
          'hostname': hostname,
          'error': e.toString(),
        };
      }
    }
  }

  @override
  Future<Map<String, dynamic>> testCredentials() async {
    try {
      return await runVpnAction('test-credentials');
    } catch (_) {
      final saved = await credentialsStatus();
      return {
        'ok': saved,
        'saved': saved,
        'message': saved ? 'Credentials configured' : 'Credentials missing',
      };
    }
  }

  Future<String> pingReport(String kind, [String? host]) async {
    final target = switch (kind) {
      'internet' => '1.1.1.1',
      'location' || 'vpn' => host ?? '1.1.1.1',
      _ => '1.1.1.1',
    };
    final res = await Process.run('ping', ['-n', '-c', '6', '-W', '2', target]);
    final raw = '${res.stdout}\n${res.stderr}'.trim();
    return 'Target: $target\n$raw';
  }

  Future<Map<String, int?>> pingLocationsBatch(
    List<Map<String, String>> targets, {
    int concurrency = 6,
  }) async {
    final results = <String, int?>{};
    final queue = List<Map<String, String>>.from(targets);
    var index = 0;

    Future<void> worker() async {
      while (true) {
        if (index >= queue.length) break;
        final current = queue[index++];
        final id = current['id'] ?? '';
        final host = current['host'] ?? '';
        if (id.isEmpty || host.isEmpty) continue;
        try {
          final res = await Process.run('ping', [
            '-n',
            '-c',
            '2',
            '-W',
            '1',
            host,
          ]);
          if (res.exitCode == 0) {
            final stdout = '${res.stdout}';
            final match = RegExp(r'min/avg/max[^=]*=\s*[\d.]+/([\d.]+)/')
                .firstMatch(stdout);
            if (match != null) {
              results[id] = double.tryParse(match.group(1) ?? '')?.round();
            } else {
              results[id] = null;
            }
          } else {
            results[id] = null;
          }
        } catch (_) {
          results[id] = null;
        }
      }
    }

    final workers = List.generate(concurrency.clamp(1, 16), (_) => worker());
    await Future.wait(workers);
    return results;
  }

  Future<Map<String, dynamic>> networkDiagnostics() async {
    final links = await Process.run('ip', ['-br', 'link']);
    final routes = await Process.run('ip', ['-4', 'route']);
    final dns = await Process.run('resolvectl', ['status']);
    final v6 = await Process.run('ip', ['-6', 'route']);

    final linksText = '${links.stdout}'.trim();
    final vpnIface = linksText
        .split('\n')
        .where((l) => l.contains('harmoney') || l.contains('xfrm'))
        .map((l) => l.split(RegExp(r'\s+')).first)
        .firstOrNull;

    return {
      'interfaces': linksText.split('\n'),
      'vpn_interface': vpnIface,
      'default_route': '${routes.stdout}'.split('\n').firstWhere(
            (l) => l.startsWith('default'),
            orElse: () => 'not found',
          ),
      'dns_status': '${dns.stdout}'.trim(),
      'ipv6_status': '${v6.stdout}'.trim(),
    };
  }

  Future<Map<String, dynamic>> trafficSnapshot() async {
    if (!Platform.isLinux) {
      throw UnsupportedError('Live traffic is not available on this platform.');
    }
    final restricted = await _readState('/run/harmoney-vpn/restricted.state');
    final live = await _readState('/run/harmoney-vpn/live.state');
    final usage = await _readState('/var/lib/harmoney-vpn/traffic-usage.state');
    final iface = restricted['TUNNEL_IF'] ?? 'tun0';
    return {
      'connected': File('/sys/class/net/$iface').existsSync(),
      'rx_bytes': await _readInt('/sys/class/net/$iface/statistics/rx_bytes'),
      'tx_bytes': await _readInt('/sys/class/net/$iface/statistics/tx_bytes'),
      'rx_bps': int.tryParse(live['RX_BPS'] ?? '') ?? 0,
      'tx_bps': int.tryParse(live['TX_BPS'] ?? '') ?? 0,
      'day_rx_bytes': int.tryParse(usage['DAY_RX_BYTES'] ?? '') ?? 0,
      'day_tx_bytes': int.tryParse(usage['DAY_TX_BYTES'] ?? '') ?? 0,
      'month_rx_bytes': int.tryParse(usage['MONTH_RX_BYTES'] ?? '') ?? 0,
      'month_tx_bytes': int.tryParse(usage['MONTH_TX_BYTES'] ?? '') ?? 0,
      'all_rx_bytes': int.tryParse(usage['ALL_RX_BYTES'] ?? '') ?? 0,
      'all_tx_bytes': int.tryParse(usage['ALL_TX_BYTES'] ?? '') ?? 0,
    };
  }

  Future<Map<String, String>> _readState(String path) async {
    final file = File(path);
    if (!await file.exists()) return {};
    final values = <String, String>{};
    for (final line in await file.readAsLines()) {
      final separator = line.indexOf('=');
      if (separator > 0) {
        values[line.substring(0, separator)] = line.substring(separator + 1);
      }
    }
    return values;
  }

  Future<int> _readInt(String path) async {
    try {
      return int.tryParse((await File(path).readAsString()).trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
