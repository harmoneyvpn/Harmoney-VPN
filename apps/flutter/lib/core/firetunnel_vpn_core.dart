import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'vpn_core.dart';
import 'mobile_vpn_bridge.dart';
import '../shared/country_flag.dart';

class FireTunnelAccountState {
  const FireTunnelAccountState({
    required this.loggedIn,
    this.quota,
    this.version,
    this.warning,
  });
  final bool loggedIn;
  final Map<String, dynamic>? quota;
  final String? version;
  final String? warning;
}

class FireTunnelLocationSnapshot {
  const FireTunnelLocationSnapshot({required this.servers, this.source});
  final List<VpnServer> servers;
  final String? source;
}

class FireTunnelVpnCore implements VpnCore {
  FireTunnelVpnCore();

  static const providerId = 'firetunnel';
  static const _helper = '/usr/libexec/harmoney-firetunnel-helper';
  static const _runtimeState = '/run/harmoney-firetunnel/state.json';
  static const _windowsHelperName = 'harmoney-firetunnel.exe';
  static const _android = MethodChannel('io.harmoney.client/android');
  final _controller = StreamController<VpnConnectionState>.broadcast();
  Timer? _poller;
  VpnServer? _activeServer;
  VpnConnectionState _last = const VpnConnectionState(
    status: VpnConnectionStatus.disconnected,
  );
  bool _killSwitch = true;
  final Map<String, ({String host, int port})> _probeTargets = {};
  final Map<String, int> _latencies = {};
  final Map<String, String> _cityCodes = {};
  bool _polling = false;
  String? _pendingWindowsLoginSession;

  static String get _windowsRuntimeDirectory =>
      File(Platform.resolvedExecutable).parent.path;

  static String get windowsRuntimeStatePath =>
      '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}${Platform.pathSeparator}HarmoneyVPN${Platform.pathSeparator}firetunnel-state.json';

  static String get _windowsConfigRoot =>
      '${Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.systemTemp.path}${Platform.pathSeparator}.config';

  static String get _windowsLegacyConfigRoot =>
      '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}${Platform.pathSeparator}HarmoneyVPN';

  static String get windowsHelperPath =>
      '$_windowsRuntimeDirectory${Platform.pathSeparator}$_windowsHelperName';

  static bool get hasWindowsRuntime =>
      Platform.isWindows &&
      <String>[
        windowsHelperPath,
        '$_windowsRuntimeDirectory${Platform.pathSeparator}tun2socks.exe',
        '$_windowsRuntimeDirectory${Platform.pathSeparator}wintun.dll',
        '$_windowsRuntimeDirectory${Platform.pathSeparator}wfp-helper.exe',
        '$_windowsRuntimeDirectory${Platform.pathSeparator}xray.exe',
      ].every((path) => File(path).existsSync());

  bool get supported =>
      Platform.isAndroid ||
      (Platform.isLinux && File(_helper).existsSync()) ||
      hasWindowsRuntime;

  Future<Map<String, dynamic>> _run(
    String action, [
    List<String> args = const [],
    Map<String, dynamic>? stdin,
  ]) async {
    if (Platform.isAndroid) {
      final method = switch (action) {
        'app-state' => 'firefoxAccountState',
        'login' => 'firefoxLogin',
        'logout' => 'firefoxLogout',
        'locations' => 'firefoxLocations',
        'disconnect' || 'cancel' => 'firefoxDisconnect',
        'diagnostics' => 'firefoxStatus',
        _ => throw UnsupportedError(
          'Unsupported Android Firefox action: $action',
        ),
      };
      try {
        final response = await _android.invokeMethod<Object?>(method, stdin);
        if (response == null) return <String, dynamic>{'ok': true};
        return Map<String, dynamic>.from(response as Map);
      } on PlatformException catch (error) {
        throw FireTunnelException(
          error.message ?? error.code,
          verificationRequired: error.code == 'verification_required',
        );
      }
    }
    if (Platform.isWindows) {
      await _migrateWindowsTokenStore();
      final command = switch (action) {
        'app-state' => <String>['app-state', '--country', ...args],
        'login' => <String>['login-json'],
        'logout' => <String>['logout'],
        'locations' => <String>['locations'],
        'disconnect' || 'cancel' => <String>['disconnect'],
        'diagnostics' => <String>['status'],
        _ => throw UnsupportedError(
          'Unsupported Windows Firefox action: $action',
        ),
      };
      final env = <String, String>{
        ...Platform.environment,
        'FIRETUNNEL_STATE': windowsRuntimeStatePath,
        'XDG_CONFIG_HOME': _windowsConfigRoot,
      };
      final process = await Process.start(
        windowsHelperPath,
        command,
        environment: env,
        runInShell: false,
      );
      if (stdin != null) process.stdin.writeln(jsonEncode(stdin));
      await process.stdin.close();
      final values = await Future.wait([
        utf8.decoder.bind(process.stdout).join(),
        utf8.decoder.bind(process.stderr).join(),
        process.exitCode,
      ]);
      final output = (values[0] as String).trim();
      final errorOutput = (values[1] as String).trim();
      final exitCode = values[2] as int;
      final responseText = output.isNotEmpty ? output : errorOutput;
      Map<String, dynamic> decoded;
      try {
        decoded = Map<String, dynamic>.from(jsonDecode(responseText) as Map);
      } catch (_) {
        throw StateError(
          responseText.isEmpty
              ? 'FireTunnel Windows engine returned no response.'
              : responseText,
        );
      }
      if (exitCode != 0 || decoded['ok'] == false) {
        final code = '${decoded['code'] ?? decoded['error'] ?? action}';
        final detail = decoded['error']?.toString();
        throw FireTunnelException(
          detail == null || detail == code ? code : '$code: $detail',
          verificationRequired: decoded['code'] == 'verification_required',
          sessionToken: decoded['session_token'] as String?,
        );
      }
      return decoded;
    }
    if (!Platform.isLinux) {
      throw UnsupportedError(
        'FireTunnel system tunnel is currently available on Linux.',
      );
    }
    final process = await Process.start('pkexec', [_helper, action, ...args]);
    if (stdin != null) process.stdin.writeln(jsonEncode(stdin));
    await process.stdin.close();
    final values = await Future.wait([
      utf8.decoder.bind(process.stdout).join(),
      utf8.decoder.bind(process.stderr).join(),
    ]);
    final exitCode = await process.exitCode;
    final text = values[0].trim().isNotEmpty
        ? values[0].trim()
        : values[1].trim();
    Map<String, dynamic> decoded;
    try {
      decoded = Map<String, dynamic>.from(jsonDecode(text) as Map);
    } catch (_) {
      throw StateError(
        text.isEmpty ? 'FireTunnel returned no JSON response.' : text,
      );
    }
    if (exitCode != 0 || decoded['ok'] == false) {
      final code = '${decoded['code'] ?? decoded['error'] ?? action}';
      final detail = decoded['error']?.toString();
      throw FireTunnelException(
        detail == null || detail == code ? code : '$code: $detail',
        verificationRequired: decoded['code'] == 'verification_required',
      );
    }
    return decoded;
  }

  Future<void> _migrateWindowsTokenStore() async {
    final oldTokens = File(
      '$_windowsLegacyConfigRoot${Platform.pathSeparator}firetunnel${Platform.pathSeparator}tokens.json',
    );
    final newTokens = File(
      '$_windowsConfigRoot${Platform.pathSeparator}firetunnel${Platform.pathSeparator}tokens.json',
    );
    if (await newTokens.exists() || !await oldTokens.exists()) return;
    await newTokens.parent.create(recursive: true);
    await oldTokens.copy(newTokens.path);
    if (await oldTokens.length() == await newTokens.length()) {
      await oldTokens.delete();
    }
  }

  Future<FireTunnelAccountState> accountState({
    String countryCode = 'REC',
  }) async {
    final value = await _run('app-state', [countryCode]);
    return FireTunnelAccountState(
      loggedIn: value['logged_in'] == true,
      quota: value['quota'] is Map
          ? Map<String, dynamic>.from(value['quota'] as Map)
          : null,
      version: value['version'] as String?,
      warning: (value['warnings'] as List?)?.join('\n'),
    );
  }

  Future<void> login({
    required String email,
    required String password,
    String? code,
  }) async {
    final pendingSession = Platform.isWindows
        ? _pendingWindowsLoginSession
        : null;
    final payload = <String, dynamic>{'email': email};
    if (pendingSession != null && code != null) {
      payload['session_token'] = pendingSession;
      payload['code'] = code;
    } else {
      payload['password'] = password;
      if (code != null) payload['code'] = code;
    }
    try {
      await _run('login', const [], payload);
      _pendingWindowsLoginSession = null;
    } on FireTunnelException catch (error) {
      if (Platform.isWindows &&
          error.verificationRequired &&
          error.sessionToken != null) {
        _pendingWindowsLoginSession = error.sessionToken;
      }
      rethrow;
    }
  }

  /// Starts Firefox's official in-app browser sign-in on Android. The native
  /// Firefox engine captures the WebChannel session and exchanges it for VPN
  /// tokens; the password never passes through the Flutter bridge.
  Future<void> loginWithBrowser() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Firefox browser sign-in is available on Android.',
      );
    }
    final response = await _run('login', const [], const <String, dynamic>{
      'browser': true,
    });
    if (response['ok'] != true) {
      throw const FireTunnelException('login_cancelled');
    }
  }

  Future<void> logout() => _run('logout').then((_) {});

  String _countryCode(VpnServer server) {
    final raw = (server.countryCode ?? server.id.split(RegExp('[-_:]')).first)
        .toUpperCase();
    return raw == 'UK' ? 'GB' : raw;
  }

  String? _countryNameFromCode(String code) => const <String, String>{
    'CA': 'Canada',
    'DE': 'Germany',
    'ES': 'Spain',
    'FI': 'Finland',
    'FR': 'France',
    'GB': 'United Kingdom',
    'IR': 'Iran',
    'IT': 'Italy',
    'JP': 'Japan',
    'NL': 'Netherlands',
    'NO': 'Norway',
    'PL': 'Poland',
    'SE': 'Sweden',
    'SG': 'Singapore',
    'TR': 'Turkey',
    'US': 'United States',
  }[code.toUpperCase()];

  @override
  Stream<VpnConnectionState> watchConnection() {
    _poller ??= Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    scheduleMicrotask(_poll);
    return _controller.stream;
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      if (Platform.isWindows) await _migrateWindowsTokenStore();
      Map<String, dynamic> value;
      final stateFile = File(_runtimeState);
      if (Platform.isAndroid) {
        value = Map<String, dynamic>.from(
          await _android.invokeMethod<Map<Object?, Object?>>('firefoxStatus') ??
              const {},
        );
      } else if (Platform.isWindows &&
          await File(windowsRuntimeStatePath).exists()) {
        value = Map<String, dynamic>.from(
          jsonDecode(await File(windowsRuntimeStatePath).readAsString()) as Map,
        );
      } else if (await stateFile.exists()) {
        value = Map<String, dynamic>.from(
          jsonDecode(await stateFile.readAsString()) as Map,
        );
      } else {
        value = {'state': 'disconnected'};
      }
      if (Platform.isWindows &&
          value['state'] == 'error' &&
          value['code'] == 'authentication_required' &&
          await File(
            '$_windowsConfigRoot${Platform.pathSeparator}firetunnel${Platform.pathSeparator}tokens.json',
          ).exists()) {
        final staleState = File(windowsRuntimeStatePath);
        if (await staleState.exists()) await staleState.delete();
        value = {'state': 'disconnected'};
      }
      final status = switch (value['state']) {
        'connected' => VpnConnectionStatus.connected,
        'connecting' => VpnConnectionStatus.connecting,
        'disconnecting' => VpnConnectionStatus.disconnecting,
        'error' => VpnConnectionStatus.error,
        _ => VpnConnectionStatus.disconnected,
      };
      if (_activeServer == null &&
          status != VpnConnectionStatus.disconnected &&
          value['country_code'] is String) {
        _activeServer = VpnServer(
          id: '${value['country_code']}_${value['location'] ?? ''}_${(value['endpoint'] as String? ?? '').split(':').first}',
          providerId: providerId,
          countryCode: value['country_code'] as String,
          country:
              value['country'] as String? ?? value['country_code'] as String,
          city: value['location'] as String? ?? '',
          hostname: (value['endpoint'] as String? ?? '').split(':').first,
        );
      }
      final exitCode = value['exit_country_code']?.toString().toUpperCase();
      if (status == VpnConnectionStatus.connected &&
          exitCode != null &&
          RegExp(r'^[A-Z]{2}$').hasMatch(exitCode)) {
        final base =
            _activeServer ??
            VpnServer(
              id: 'exit-$exitCode',
              providerId: providerId,
              country: exitCode,
              city: '',
              hostname: '',
              countryCode: exitCode,
            );
        final colo = value['exit_colo']?.toString().trim();
        _activeServer = base.copyWith(
          countryCode: exitCode,
          country: _countryNameFromCode(exitCode) ?? exitCode,
          city: colo == null || colo.isEmpty ? base.city : 'Exit · $colo',
        );
      }
      _last = VpnConnectionState(
        status: status,
        server: status == VpnConnectionStatus.disconnected
            ? null
            : _activeServer,
        protocol: status == VpnConnectionStatus.disconnected
            ? null
            : 'HTTP/2 CONNECT',
        errorMessage: (value['error'] ?? value['message']) as String?,
        providerId: providerId,
        endpoint: value['endpoint'] as String?,
        publicIp: value['public_ip'] as String?,
        connectedAt: value['connected_at'] is num
            ? DateTime.fromMillisecondsSinceEpoch(
                (value['connected_at'] as num).toInt() * 1000,
              )
            : null,
        transport: value['transport'] as String?,
      );
      _controller.add(_last);
    } catch (error) {
      _controller.add(
        VpnConnectionState(
          status: VpnConnectionStatus.error,
          server: _activeServer,
          protocol: 'HTTP/2 CONNECT',
          errorMessage: error.toString(),
        ),
      );
    } finally {
      _polling = false;
    }
  }

  @override
  Future<void> connect({
    required String providerId,
    VpnServer? server,
    required String protocol,
  }) async {
    if (server == null) {
      throw ArgumentError('A location is required for FireTunnel.');
    }
    final loggedIn = Platform.isAndroid
        ? ((await _android.invokeMapMethod<String, Object?>(
                'firefoxSessionState',
              ))?['logged_in'] ==
              true)
        : (await accountState(countryCode: _countryCode(server))).loggedIn;
    if (!loggedIn) {
      _controller.add(
        VpnConnectionState(
          status: VpnConnectionStatus.authRequired,
          server: server,
          providerId: providerId,
          errorMessage: 'Sign in to Firefox Account from Settings.',
        ),
      );
      throw const FireTunnelException('authentication_required');
    }
    _activeServer = server;
    _controller.add(
      VpnConnectionState(
        status: VpnConnectionStatus.connecting,
        server: server,
        protocol: 'HTTP/2 CONNECT',
      ),
    );
    if (Platform.isWindows) {
      if (!hasWindowsRuntime) {
        throw const FireTunnelException(
          'windows_runtime_missing: reinstall the complete Windows package',
        );
      }
      final countryCode = _countryCode(server);
      if (!RegExp(r'^[A-Z0-9_-]{2,8}$').hasMatch(countryCode)) {
        throw const FireTunnelException('invalid_location_code');
      }
      final escapedExe = windowsHelperPath.replaceAll("'", "''");
      final escapedState = windowsRuntimeStatePath.replaceAll("'", "''");
      final environment = <String, String>{
        ...Platform.environment,
        'FIRETUNNEL_STATE': windowsRuntimeStatePath,
        'XDG_CONFIG_HOME': _windowsConfigRoot,
      };
      try {
        final oldState = File(windowsRuntimeStatePath);
        if (await oldState.exists()) await oldState.delete();
      } catch (_) {}
      final started = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          "\$env:FIRETUNNEL_STATE='$escapedState'; Start-Process -FilePath '$escapedExe' -ArgumentList @('connect','--country','$countryCode','--killswitch=${_killSwitch ? 'true' : 'false'}') -Verb RunAs -WindowStyle Hidden",
        ],
        environment: environment,
        runInShell: false,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      if (started.exitCode != 0) {
        final message = (started.stderr as String).trim();
        throw FireTunnelException(
          message.isEmpty ? 'windows_elevation_failed' : message,
        );
      }
      final until = DateTime.now().add(const Duration(seconds: 60));
      while (DateTime.now().isBefore(until)) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        final stateFile = File(windowsRuntimeStatePath);
        if (!await stateFile.exists()) continue;
        final state = Map<String, dynamic>.from(
          jsonDecode(await stateFile.readAsString()) as Map,
        );
        if (state['state'] == 'connected') {
          await _poll();
          return;
        }
        if (state['state'] == 'error') {
          throw FireTunnelException(
            state['error']?.toString() ?? 'windows_connect_failed',
          );
        }
      }
      throw TimeoutException(
        'Firefox VPN did not complete Windows tunnel setup within 60 seconds.',
      );
    } else if (Platform.isAndroid) {
      final permitted =
          await _android.invokeMethod<bool>('prepare', {
            'protocol': 'firefox',
          }) ??
          false;
      if (!permitted) throw const FireTunnelException('permission_denied');
      final parts = server.id.split('_');
      await _android.invokeMethod<void>('firefoxConnect', {
        'countryCode': _countryCode(server),
        'country': server.country,
        'cityCode':
            _cityCodes[server.id] ??
            (parts.length > 1 ? parts[1] : server.city),
        'hostname': server.hostname,
        'port': _probeTargets[server.id]?.port ?? 2499,
      });
    } else {
      await _run('connect', [
        _countryCode(server),
        '--killswitch=${_killSwitch ? 'true' : 'false'}',
      ]);
    }
  }

  @override
  Future<void> disconnect() async {
    await _run('disconnect');
    _activeServer = null;
    await _poll();
  }

  @override
  Future<void> cancelConnect() async {
    await _run('cancel');
    _activeServer = null;
    await _poll();
  }

  @override
  Future<List<VpnServer>> listServers({required String providerId}) async {
    return (await locationSnapshot()).servers;
  }

  static const List<Map<String, dynamic>> _bundledLocations = [
    {
      'name': 'Recommended Location',
      'code': 'REC',
      'cities': [
        {
          'name': 'Optimal Anycast Edge',
          'code': 'REC',
          'servers': [
            {
              'hostname': 'p.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'United States',
      'code': 'US',
      'cities': [
        {
          'name': 'Anycast US',
          'code': 'US',
          'servers': [
            {
              'hostname': 'us.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
        {
          'name': 'Chicago',
          'code': 'Q30',
          'servers': [
            {
              'hostname': 'p.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Germany',
      'code': 'DE',
      'cities': [
        {
          'name': 'Munich',
          'code': 'MUC',
          'servers': [
            {
              'hostname': 'muc139.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Netherlands',
      'code': 'NL',
      'cities': [
        {
          'name': 'Amsterdam / Rotterdam',
          'code': 'EHRD',
          'servers': [
            {
              'hostname': 'ehrd229.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'United Kingdom',
      'code': 'GB',
      'cities': [
        {
          'name': 'London',
          'code': 'EGLC',
          'servers': [
            {
              'hostname': 'eglc860.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'France',
      'code': 'FR',
      'cities': [
        {
          'name': 'Paris',
          'code': 'LFPB',
          'servers': [
            {
              'hostname': 'lfpb115.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Canada',
      'code': 'CA',
      'cities': [
        {
          'name': 'Toronto',
          'code': 'CA',
          'servers': [
            {
              'hostname': 'ca.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Singapore',
      'code': 'SG',
      'cities': [
        {
          'name': 'Singapore',
          'code': 'WSAT',
          'servers': [
            {
              'hostname': 'wsat188.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Japan',
      'code': 'JP',
      'cities': [
        {
          'name': 'Tokyo',
          'code': 'RJTF',
          'servers': [
            {
              'hostname': 'rjtf770.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Finland',
      'code': 'FI',
      'cities': [
        {
          'name': 'Helsinki',
          'code': 'HEL',
          'servers': [
            {
              'hostname': 'hel141.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Sweden',
      'code': 'SE',
      'cities': [
        {
          'name': 'Stockholm',
          'code': 'ESSB',
          'servers': [
            {
              'hostname': 'essb127.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Norway',
      'code': 'NO',
      'cities': [
        {
          'name': 'Oslo',
          'code': 'OSL',
          'servers': [
            {
              'hostname': 'osl65.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Denmark',
      'code': 'DK',
      'cities': [
        {
          'name': 'Copenhagen',
          'code': 'CPH',
          'servers': [
            {
              'hostname': 'cph232.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Belgium',
      'code': 'BE',
      'cities': [
        {
          'name': 'Brussels',
          'code': 'BRU',
          'servers': [
            {
              'hostname': 'bru148.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Austria',
      'code': 'AT',
      'cities': [
        {
          'name': 'Vienna',
          'code': 'VIE',
          'servers': [
            {
              'hostname': 'vie63.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Australia',
      'code': 'AU',
      'cities': [
        {
          'name': 'Sydney',
          'code': 'YSBK',
          'servers': [
            {
              'hostname': 'ysbk106.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'New Zealand',
      'code': 'NZ',
      'cities': [
        {
          'name': 'Auckland',
          'code': 'AKL',
          'servers': [
            {
              'hostname': 'akl103.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Spain',
      'code': 'ES',
      'cities': [
        {
          'name': 'Madrid',
          'code': 'LETO',
          'servers': [
            {
              'hostname': 'leto235.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Portugal',
      'code': 'PT',
      'cities': [
        {
          'name': 'Lisbon',
          'code': 'LIS',
          'servers': [
            {
              'hostname': 'lis149.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Italy',
      'code': 'IT',
      'cities': [
        {
          'name': 'Milan',
          'code': 'MXP',
          'servers': [
            {
              'hostname': 'mxp69.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Ireland',
      'code': 'IE',
      'cities': [
        {
          'name': 'Dublin',
          'code': 'DUB',
          'servers': [
            {
              'hostname': 'dub43.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Korea',
      'code': 'KR',
      'cities': [
        {
          'name': 'Seoul',
          'code': 'ICN',
          'servers': [
            {
              'hostname': 'icn145.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Brazil',
      'code': 'BR',
      'cities': [
        {
          'name': 'Sao Paulo',
          'code': 'SBSP',
          'servers': [
            {
              'hostname': 'sbsp209.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Argentina',
      'code': 'AR',
      'cities': [
        {
          'name': 'Buenos Aires',
          'code': 'EZE',
          'servers': [
            {
              'hostname': 'eze223.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Chile',
      'code': 'CL',
      'cities': [
        {
          'name': 'Santiago',
          'code': 'SCL',
          'servers': [
            {
              'hostname': 'scl222.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Colombia',
      'code': 'CO',
      'cities': [
        {
          'name': 'Bogota',
          'code': 'SKBO',
          'servers': [
            {
              'hostname': 'skbo234.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Peru',
      'code': 'PE',
      'cities': [
        {
          'name': 'Lima',
          'code': 'SPJC',
          'servers': [
            {
              'hostname': 'spjc128.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Mexico',
      'code': 'MX',
      'cities': [
        {
          'name': 'Queretaro',
          'code': 'MMQT',
          'servers': [
            {
              'hostname': 'mmqt107.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Malaysia',
      'code': 'MY',
      'cities': [
        {
          'name': 'Kuala Lumpur',
          'code': 'KUL',
          'servers': [
            {
              'hostname': 'kul98.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Philippines',
      'code': 'PH',
      'cities': [
        {
          'name': 'Manila',
          'code': 'MNL',
          'servers': [
            {
              'hostname': 'mnl215.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Thailand',
      'code': 'TH',
      'cities': [
        {
          'name': 'Bangkok',
          'code': 'BKK',
          'servers': [
            {
              'hostname': 'bkk228.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Bulgaria',
      'code': 'BG',
      'cities': [
        {
          'name': 'Sofia',
          'code': 'SOF',
          'servers': [
            {
              'hostname': 'sof151.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'Ghana',
      'code': 'GH',
      'cities': [
        {
          'name': 'Accra',
          'code': 'ACC',
          'servers': [
            {
              'hostname': 'acc96.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
    {
      'name': 'South Africa',
      'code': 'ZA',
      'cities': [
        {
          'name': 'Johannesburg',
          'code': 'JNB',
          'servers': [
            {
              'hostname': 'jnb70.m1.fastly-masque.net',
              'port': 2499,
              'quarantined': false,
            },
          ],
        },
      ],
    },
  ];

  Future<FireTunnelLocationSnapshot> locationSnapshot() async {
    Map<String, dynamic>? response;
    try {
      response = await _run('locations');
    } catch (_) {}

    final rawList = (response?['locations'] as List?) ?? const [];
    final locationData = rawList.isNotEmpty ? rawList : _bundledLocations;
    final locations = parseLocations(locationData);
    _probeTargets
      ..clear()
      ..addEntries(
        locations.map(
          (e) => MapEntry(e.server.id, (host: e.server.hostname, port: e.port)),
        ),
      );
    _cityCodes
      ..clear()
      ..addEntries(locations.map((e) => MapEntry(e.server.id, e.cityCode)));
    return FireTunnelLocationSnapshot(
      servers: List.unmodifiable(
        locations.map(
          (e) => e.server.copyWith(latencyMs: _latencies[e.server.id]),
        ),
      ),
      source: response?['source']?.toString() ?? 'bundled-catalog',
    );
  }

  static List<({VpnServer server, int port, String cityCode})> parseLocations(
    List<dynamic> locationData,
  ) {
    final entries = <String, ({VpnServer server, int port, String cityCode})>{};

    for (final locationRaw in locationData) {
      if (locationRaw is! Map) continue;
      final location = Map<String, dynamic>.from(locationRaw);
      final rawCode = location['code']?.toString().trim().toUpperCase() ?? '';
      final countryCode = rawCode == 'REC'
          ? rawCode
          : CountryFlags.normalize(rawCode);
      final country = location['name']?.toString().trim() ?? countryCode;
      for (final cityRaw in location['cities'] as List? ?? const []) {
        if (cityRaw is! Map) continue;
        final city = Map<String, dynamic>.from(cityRaw);
        final cityName = city['name']?.toString().trim() ?? '';
        final cityCode = (city['code']?.toString() ?? cityName)
            .trim()
            .toUpperCase();
        for (final serverRaw in city['servers'] as List? ?? const []) {
          if (serverRaw is! Map) continue;
          final server = Map<String, dynamic>.from(serverRaw);
          final hostname =
              server['hostname']?.toString().trim().toLowerCase() ?? '';
          if (countryCode.isEmpty || hostname.isEmpty) continue;
          final port = int.tryParse(server['port']?.toString() ?? '2499');
          if (port == null || port < 1 || port > 65535) continue;
          final id =
              '${countryCode}_${cityCode}_$hostname${port == 2499 ? '' : ':$port'}';
          if (entries[id]?.server.available == true) continue;
          entries[id] = (
            server: VpnServer(
              id: id,
              providerId: providerId,
              country: country,
              city: cityName,
              hostname: hostname,
              countryCode: countryCode,
              available: server['quarantined'] != true,
            ),
            port: port,
            cityCode: cityCode,
          );
        }
      }
    }
    return List.unmodifiable(entries.values);
  }

  @override
  Future<void> refreshServers({required String providerId}) async {
    await _run('locations');
  }

  @override
  Future<int?> probeServer({
    required String providerId,
    required String serverId,
    String? protocol,
  }) async {
    var target = _probeTargets[serverId];
    if (target == null) {
      await locationSnapshot();
      target = _probeTargets[serverId];
    }
    if (target == null) throw StateError('FireTunnel endpoint not found.');
    if (Platform.isAndroid) {
      final state = await _android.invokeMapMethod<String, Object?>(
        'firefoxStatus',
      );
      final active =
          state?['state'] == 'connected' && _activeServer?.id == serverId;
      final latency = active
          ? await MobileVpnBridge.probeFirefoxDataPath()
          : await MobileVpnBridge.probeFirefox(target.host, target.port);
      if (latency != null) _latencies[serverId] = latency;
      return latency;
    }
    // A plain TCP connect is not a valid Firefox VPN probe: captive portals,
    // carrier middleboxes, or a filtered proxy can accept TCP while blocking
    // the actual TLS/HTTP2 transport.  Verify the same endpoint and ALPN that
    // the Firefox tunnel uses, on the device's current network.  This is
    // intentionally transport-only (no VPN is started and no traffic is
    // routed through another provider), so scanning locations remains safe.
    final watch = Stopwatch()..start();
    SecureSocket? socket;
    try {
      socket = await SecureSocket.connect(
        target.host,
        target.port,
        timeout: const Duration(seconds: 5),
        supportedProtocols: const ['h2'],
      );
      if (socket.selectedProtocol != 'h2') return null;
      final latency = watch.elapsedMilliseconds.clamp(1, 60000);
      _latencies[serverId] = latency;
      return latency;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on HandshakeException {
      return null;
    } finally {
      socket?.destroy();
    }
  }

  @override
  Future<void> setKillSwitch(bool enabled) async {
    _killSwitch = enabled;
  }

  @override
  Future<void> setDnsProtection(bool enabled) async {}
  @override
  Future<void> setIpv6Protection(bool enabled) async {}
  @override
  Future<bool> credentialsSaved() async => (await accountState()).loggedIn;
  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) => login(email: username, password: password);
  @override
  Future<Map<String, Object?>> runDiagnostics() async =>
      Map<String, Object?>.from(await _run('diagnostics'));
}

class FireTunnelException implements Exception {
  const FireTunnelException(
    this.message, {
    this.verificationRequired = false,
    this.sessionToken,
  });
  final String message;
  final bool verificationRequired;
  final String? sessionToken;
  @override
  String toString() => 'FireTunnel: $message';
}
