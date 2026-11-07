import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:crypto/crypto.dart';

import 'country_bypass_bridge.dart';
import 'firetunnel_vpn_core.dart';
import 'local_cache_service.dart';
import 'harmoney_subscription_service.dart';

/// Windows Harmoney backend: Xray nodes carried through the packaged Wintun
/// full-system tunnel. Proprietary WARP/MASQUE flowline groups are not handled.
class HarmoneyWindowsXray {
  HarmoneyWindowsXray();

  static String get _runtime => File(Platform.resolvedExecutable).parent.path;
  static String get statePath => FireTunnelVpnCore.windowsRuntimeStatePath;
  static String get _configRoot =>
      '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}${Platform.pathSeparator}HarmoneyVPN';
  static List<String> get _statePaths => <String>{
        statePath,
        if ((Platform.environment['APPDATA'] ?? '').isNotEmpty)
          '${Platform.environment['APPDATA']}${Platform.pathSeparator}HarmoneyVPN${Platform.pathSeparator}firetunnel-state.json',
      }.toList(growable: false);
  static String get _helper =>
      '$_runtime${Platform.pathSeparator}harmoney-firetunnel.exe';
  static String get _xray => '$_runtime${Platform.pathSeparator}xray.exe';
  static String get _configPath =>
      '$_configRoot${Platform.pathSeparator}harmoney-xray.json';

  Future<void> connect({
    required String pattern,
    required bool killSwitch,
    String? preferredNodeId,
    String? selectedSubscriptionId,
    required void Function(String) onProgress,
  }) async {
    if (!Platform.isWindows || !FireTunnelVpnCore.hasWindowsRuntime) {
      throw const HarmoneyWindowsXrayException(
        'موتور تونل Windows در کنار برنامه پیدا نشد. بستهٔ کامل را دوباره بسازید.',
      );
    }
    onProgress('دریافت فهرست سرورها');
    final nodes = await _loadNodes(
      pattern,
      preferredNodeId: preferredNodeId,
      selectedSubscriptionId: selectedSubscriptionId,
    );
    if (nodes.isEmpty) {
      throw const HarmoneyWindowsXrayException(
        'از منابع Harmoney سرور سازگار با Xray دریافت نشد. اینترنت و منابع فهرست را بررسی کنید.',
      );
    }

    final protocols = nodes.map((node) => node.protocol.toUpperCase()).toSet();
    onProgress(
      'Found ${nodes.length} routes · protocols: ${protocols.join(', ')}',
    );
    final bypassState = await CountryBypassBridge.instance.getState();
    final bypassCidrs = selectedCountryIpCidrs(bypassState);
    final bypassDomains = bypassState.enabled &&
            bypassState.selectedCountries
                .map((code) => code.toUpperCase())
                .contains('IR')
        ? await _iranDomainBypassRules()
        : const <String>[];
    final dir = Directory(_configRoot);
    await dir.create(recursive: true);
    // The feed is already bounded to 36 unique nodes. A hard-coded limit of
    // 12 can miss every usable route when the first entries are stale or do
    // not carry UDP, so check the complete fetched list before reporting that
    // no route is available.
    final maxAttempts = nodes.length;
    _XrayNode? selectedNode;
    String? lastPreflightFailure;
    for (var i = 0; i < maxAttempts; i++) {
      final candidate = nodes[i];
      onProgress(
        'Checking route ${i + 1}/$maxAttempts · ${candidate.protocol.toUpperCase()} · ${candidate.displayName} · ${candidate.endpoint}',
      );
      final failure = await _preflightNode(
        candidate,
        i,
        onProgress: onProgress,
      );
      if (failure == null) {
        selectedNode = candidate;
        break;
      }
      lastPreflightFailure = '${candidate.displayName}: $failure';
      onProgress('Skipping route ${candidate.endpoint}: $failure');
    }
    if (selectedNode == null) {
      throw HarmoneyWindowsXrayException(
        'No server passed the connection check. Last check: $lastPreflightFailure. No administrator prompt was opened.',
      );
    }
    final node = selectedNode;
    final config = applyCountryBypassToConfig(
      node.config,
      bypassCidrs,
      domains: bypassDomains,
    );
    onProgress(
      'Starting full-system tunnel via ${node.protocol.toUpperCase()} · ${node.displayName} · ${node.endpoint}',
    );
    await File(_configPath).writeAsString(jsonEncode(config), flush: true);
    try {
      await _startElevated(killSwitch: killSwitch);
      final deadline = DateTime.now().add(const Duration(seconds: 35));
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        final state = await readState();
        if (state?['state'] == 'connected') return;
        if (state?['state'] == 'error') {
          final code = state?['code']?.toString();
          final detail = state?['error']?.toString();
          throw HarmoneyWindowsXrayException(
            _safeError(
              [code, detail]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(': '),
            ),
          );
        }
      }
      throw const HarmoneyWindowsXrayException(
        'Windows tunnel helper did not report connected or error within 35 seconds.',
      );
    } catch (error) {
      final detail = _safeError(error.toString());
      onProgress('Tunnel startup failed: $detail');
      await disconnect();
      try {
        final failedConfig = File(_configPath);
        if (await failedConfig.exists()) await failedConfig.delete();
      } catch (_) {}
      throw HarmoneyWindowsXrayException('Tunnel startup failed: $detail');
    }
  }

  Future<String?> _preflightNode(
    _XrayNode node,
    int index, {
    required void Function(String) onProgress,
  }) async {
    final configFile = File(
      '$_configRoot${Platform.pathSeparator}xray-preflight-$index.json',
    );
    Process? process;
    Future<String>? xrayStdout;
    Future<String>? xrayStderr;
    String? failure;
    int? processExitCode;
    var passed = false;
    try {
      final reservation = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final probePort = reservation.port;
      await reservation.close();
      final config = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(node.config)) as Map,
      );
      final inbounds = (config['inbounds'] as List).cast<Map>();
      inbounds.first['port'] = probePort;
      await configFile.writeAsString(jsonEncode(config), flush: true);
      onProgress('Validating Xray configuration for ${node.endpoint}');
      final validation = await Process.run(
        _xray,
        ['run', '-test', '-c', configFile.path],
        runInShell: false,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ).timeout(const Duration(seconds: 6));
      if (validation.exitCode != 0) {
        final output = <String>[
          (validation.stderr as String).trim(),
          (validation.stdout as String).trim(),
        ].where((line) => line.isNotEmpty).join(' ');
        failure =
            'Xray rejected this route configuration${output.isEmpty ? '' : ': $output'}';
        return failure;
      }
      process = await Process.start(
          _xray,
          [
            'run',
            '-c',
            configFile.path,
          ],
          runInShell: false);
      xrayStdout = utf8.decoder.bind(process.stdout).join();
      xrayStderr = utf8.decoder.bind(process.stderr).join();
      onProgress('Waiting for local Xray proxy on port $probePort');
      if (!await _waitForLocalSocks(
        process,
        probePort,
        const Duration(seconds: 8),
      )) {
        failure = 'Xray did not open its local SOCKS port';
      } else {
        const probeUrls = <String>[
          'https://www.cloudflare.com/cdn-cgi/trace',
          'https://www.google.com/generate_204',
          'https://example.com/',
        ];
        final probeErrors = <String>[];
        for (final url in probeUrls) {
          onProgress('Testing TCP through ${node.endpoint} to $url');
          final probe = await Process.run(
            'curl.exe',
            [
              '--silent',
              '--show-error',
              '--location',
              '--fail',
              '--connect-timeout',
              '3',
              '--max-time',
              '5',
              '--socks5-hostname',
              '127.0.0.1:$probePort',
              url,
            ],
            runInShell: false,
            stdoutEncoding: utf8,
            stderrEncoding: utf8,
          ).timeout(const Duration(seconds: 7));
          if (probe.exitCode == 0) {
            passed = true;
            break;
          }
          final message = (probe.stderr as String).trim();
          if (message.isNotEmpty) probeErrors.add(message);
        }
        if (!passed) {
          failure = probeErrors.isEmpty
              ? 'SOCKS egress probe failed for all test sites'
              : probeErrors.last;
        }
      }
    } on Object catch (error) {
      failure = error.toString();
    } finally {
      if (process != null) {
        process.kill();
        try {
          processExitCode = await process.exitCode.timeout(
            const Duration(seconds: 2),
          );
        } catch (_) {}
      }
      final stdout = await _readCompleted(xrayStdout);
      final stderr = await _readCompleted(xrayStderr);
      if (!passed && failure?.contains('did not open') == true) {
        final output = <String>[
          stdout,
          stderr,
        ].where((line) => line.isNotEmpty).join(' ');
        if (output.isNotEmpty) {
          failure = 'Xray did not open its local SOCKS port'
              '${processExitCode == null ? '' : ' (exit $processExitCode)'}: $output';
        } else if (processExitCode != null) {
          failure =
              'Xray did not open its local SOCKS port (exit $processExitCode)';
        }
      }
      try {
        if (await configFile.exists()) await configFile.delete();
      } catch (_) {}
    }
    return passed ? null : failure ?? 'Connection check failed';
  }

  Future<String> _readCompleted(Future<String>? output) async {
    if (output == null) return '';
    try {
      return (await output.timeout(const Duration(seconds: 2))).trim();
    } catch (_) {
      return '';
    }
  }

  Future<bool> _waitForLocalSocks(
    Process process,
    int port,
    Duration timeout,
  ) async {
    var exited = false;
    unawaited(process.exitCode.then((_) => exited = true));
    final deadline = DateTime.now().add(timeout);
    while (!exited && DateTime.now().isBefore(deadline)) {
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          port,
          timeout: const Duration(milliseconds: 250),
        );
        await socket.close();
        return true;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
    return false;
  }

  Future<void> _startElevated({required bool killSwitch}) async {
    for (final path in _statePaths) {
      try {
        final old = File(path);
        if (await old.exists()) await old.delete();
      } catch (_) {}
    }
    final escapedExe = _helper.replaceAll("'", "''");
    final escapedConfig = '"${_configPath.replaceAll("'", "''")}"';
    final escapedState = statePath.replaceAll("'", "''");
    final command =
        "\$env:FIRETUNNEL_STATE='$escapedState'; Start-Process -FilePath '$escapedExe' -ArgumentList @('connect-xray','--config','$escapedConfig','--killswitch=${killSwitch ? 'true' : 'false'}') -Verb RunAs -WindowStyle Hidden";
    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        command,
      ],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw const HarmoneyWindowsXrayException('admin_cancelled');
    }
  }

  Future<void> disconnect() async {
    try {
      final stateFile = await _latestStateFile();
      final env = <String, String>{
        ...Platform.environment,
        'FIRETUNNEL_STATE': stateFile?.path ?? statePath,
      };
      final result = await Process.run(
        _helper,
        ['disconnect'],
        environment: env,
        runInShell: false,
      );
      if (result.exitCode != 0) {
        throw HarmoneyWindowsXrayException(
          'Could not request Windows tunnel shutdown: ${_safeError([
            result.stderr,
            result.stdout
          ].join(' '))}',
        );
      }
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        final state = await readState();
        if (state == null || state['state'] == 'disconnected') return;
        if (state['state'] == 'error') {
          final detail = state['error']?.toString();
          final code = state['code']?.toString();
          throw HarmoneyWindowsXrayException(
            'Windows tunnel cleanup failed${code == null ? '' : ' ($code)'}${detail == null ? '' : ': $detail'}',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      throw const HarmoneyWindowsXrayException(
        'Windows tunnel cleanup did not finish within 20 seconds.',
      );
    } finally {
      // Securely wipe and remove config file from disk to prevent credential/node theft
      try {
        final file = File(_configPath);
        if (await file.exists()) {
          await file.writeAsString('{}', flush: true);
          await file.delete();
        }
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> readState() async {
    final stateFiles = <({File file, DateTime modified})>[];
    for (final path in _statePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          stateFiles.add((file: file, modified: await file.lastModified()));
        }
      } catch (_) {}
    }
    stateFiles.sort((a, b) => b.modified.compareTo(a.modified));
    for (final candidate in stateFiles) {
      try {
        return Map<String, dynamic>.from(
          jsonDecode(await candidate.file.readAsString()) as Map,
        );
      } catch (_) {}
    }
    return null;
  }

  Future<File?> _latestStateFile() async {
    File? latest;
    DateTime? latestModified;
    for (final path in _statePaths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final modified = await file.lastModified();
        if (latestModified == null || modified.isAfter(latestModified)) {
          latest = file;
          latestModified = modified;
        }
      } catch (_) {}
    }
    return latest;
  }

  Future<List<_XrayNode>> _loadNodes(
    String pattern, {
    String? preferredNodeId,
    String? selectedSubscriptionId,
  }) async {
    String? flowline;
    try {
      flowline = LocalCacheService.instance.getCachedHarmoneyFlowline();
    } catch (_) {}
    flowline ??= await rootBundle.loadString(
      'assets/config/harmoney_flowline.json',
    );
    final data = jsonDecode(flowline) as Map<String, dynamic>;
    final groups = data['flowLine'] as List? ?? const [];
    final selected = <Map<String, dynamic>>[];
    for (final groupRaw in groups) {
      if (groupRaw is! Map) continue;
      final group = Map<String, dynamic>.from(groupRaw);
      final core = group['core']?.toString().toLowerCase();
      final label = group['label']?.toString().toLowerCase() ?? '';
      if (core != 'xray') continue;
      if (pattern == 'fastlane' && !label.contains('fastlane')) continue;
      final steps = group['steps'] as List? ?? const [];
      for (final stepRaw in steps) {
        if (stepRaw is Map && stepRaw['enabled'] == true) {
          final step = Map<String, dynamic>.from(stepRaw);
          if ((step['url']?.toString() ?? '').startsWith('http')) {
            selected.add(step);
          }
        }
      }
    }
    final personalUrls = await HarmoneySubscriptionService.instance.sourceUrls(
      subscriptionId: selectedSubscriptionId,
    );
    final personalFeeds = <Map<String, dynamic>>[];
    for (var index = 0; index < personalUrls.length; index++) {
      personalFeeds.add({
        'key': 'personal-sub-$index',
        'url': personalUrls[index],
        'enabled': true,
      });
    }
    // Auto tries the curated Fastlane feed first, then the wider Xray pool.
    if (pattern == 'auto') {
      selected.sort((a, b) {
        final af = a['key']?.toString().contains('vpnHub') == true ? 0 : 1;
        final bf = b['key']?.toString().contains('vpnHub') == true ? 0 : 1;
        return af.compareTo(bf);
      });
    }
    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 8),
        responseType: ResponseType.plain,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    client.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final http = HttpClient();
        http.findProxy = (uri) => 'DIRECT';
        http.badCertificateCallback = (cert, host, port) => false;
        return http;
      },
    );
    final output = <_XrayNode>[];
    final seen = <String>{};
    final feeds = selectedSubscriptionId != null
        ? personalFeeds
        : [...personalFeeds, ...selected].take(32).toList(growable: false);
    final bodies = List<String?>.filled(feeds.length, null);
    var nextFeed = 0;
    Future<void> fetchWorker() async {
      while (nextFeed < feeds.length) {
        final index = nextFeed++;
        try {
          final response = await client.get<String>(
            feeds[index]['url'].toString(),
          );
          if (response.statusCode == 200) bodies[index] = response.data;
        } catch (_) {}
      }
    }

    await Future.wait(
      List.generate(feeds.length.clamp(1, 4), (_) => fetchWorker()),
    );
    for (final body in bodies) {
      if (body == null) continue;
      for (final link in _decodeSubscription(body)) {
        final node = _parseNode(link);
        if (node != null && preferredNodeId == node.id) {
          client.close(force: true);
          return [node];
        }
        if (node != null && preferredNodeId == null && seen.add(node.id)) {
          output.add(node);
        }
        if (preferredNodeId == null && output.length >= 36) break;
      }
      if (preferredNodeId == null && output.length >= 36) break;
    }
    client.close(force: true);
    if (preferredNodeId != null) {
      final preferred = output.where((node) => node.id == preferredNodeId);
      return preferred.isEmpty ? const [] : [preferred.first];
    }
    output.sort(
      (a, b) => _udpPriority(a.protocol).compareTo(_udpPriority(b.protocol)),
    );
    return output;
  }

  static int _udpPriority(String protocol) => switch (protocol) {
        'vless' => 0,
        'trojan' => 1,
        'vmess' => 2,
        'shadowsocks' => 3,
        _ => 4,
      };

  static Iterable<String> _decodeSubscription(String body) sync* {
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed.startsWith('<')) return;
    var decoded = trimmed;
    if (!RegExp(
      r'^(vless|vmess|trojan|ss)://',
      multiLine: true,
    ).hasMatch(decoded)) {
      try {
        final compact = trimmed.replaceAll(RegExp(r'\s+'), '');
        decoded = utf8.decode(
          base64.decode(base64.normalize(compact)),
          allowMalformed: true,
        );
      } catch (_) {
        return;
      }
    }
    for (final line in decoded.split(RegExp(r'[\r\n]+'))) {
      final value = line.trim();
      if (value.startsWith('vless://') ||
          value.startsWith('vmess://') ||
          value.startsWith('trojan://') ||
          value.startsWith('ss://')) {
        yield value;
      }
    }
  }

  static String _stableNodeId(String link) =>
      sha256.convert(utf8.encode(link)).toString();

  static _XrayNode? _parseNode(String link) {
    try {
      final type = link.substring(0, link.indexOf('://')).toLowerCase();
      if (type == 'vmess') return _parseVmess(link);
      if (type == 'ss') return _parseShadowsocks(link);
      final uri = Uri.parse(link);
      final host = uri.host;
      final port = uri.port;
      if (host.isEmpty || port < 1 || uri.userInfo.isEmpty) return null;
      final q = uri.queryParameters;
      final network = (q['type'] ?? 'tcp').toLowerCase();
      final security = (q['security'] ?? 'none').toLowerCase();
      final stream = <String, dynamic>{
        'network': network,
        'security': security,
      };
      if (security == 'tls' || security == 'reality') {
        final tls = <String, dynamic>{
          'serverName': q['sni'] ?? q['host'] ?? host,
          'allowInsecure': false,
          'fingerprint': q['fp'] ?? 'chrome',
        };
        if (security == 'reality') {
          tls.remove('allowInsecure');
          stream['realitySettings'] = {
            'serverName': q['sni'] ?? host,
            'fingerprint': q['fp'] ?? 'chrome',
            'publicKey': q['pbk'] ?? '',
            'shortId': q['sid'] ?? '',
            'spiderX': q['spx'] ?? '/',
          };
        } else {
          stream['tlsSettings'] = tls;
        }
      }
      if (network == 'ws') {
        stream['wsSettings'] = {
          'path': q['path'] ?? '/',
          'headers': (q['host'] ?? '').isNotEmpty ? {'Host': q['host']} : {},
        };
      } else if (network == 'grpc') {
        stream['grpcSettings'] = {
          'serviceName': q['serviceName'] ?? q['service'] ?? '',
          'authority': q['authority'] ?? q['host'] ?? '',
        };
      } else if (network != 'tcp') {
        return null;
      }
      final user = Uri.decodeComponent(uri.userInfo);
      final protocol = switch (type) {
        'vless' => 'vless',
        'trojan' => 'trojan',
        _ => null,
      };
      if (protocol == null) return null;
      final settings = protocol == 'vless'
          ? {
              'vnext': [
                {
                  'address': host,
                  'port': port,
                  'users': [
                    {
                      'id': user,
                      'encryption': q['encryption'] ?? 'none',
                      if ((q['flow'] ?? '').isNotEmpty) 'flow': q['flow'],
                    },
                  ],
                },
              ],
            }
          : {
              'servers': [
                {'address': host, 'port': port, 'password': user},
              ],
            };
      final config = _config(protocol, settings, stream);
      return _XrayNode(
        _stableNodeId(link),
        config,
        protocol: type,
        host: host,
        port: port,
        displayName: _safeNodeName(uri.fragment),
      );
    } catch (_) {
      return null;
    }
  }

  static _XrayNode? _parseVmess(String link) {
    try {
      final raw = utf8.decode(
        base64.decode(base64.normalize(link.substring(8).split('#').first)),
      );
      final value = jsonDecode(raw) as Map<String, dynamic>;
      final host = value['add']?.toString() ?? '';
      final port = int.tryParse(value['port']?.toString() ?? '') ?? 0;
      final id = value['id']?.toString() ?? '';
      if (host.isEmpty || id.isEmpty || port < 1 || port > 65535) return null;
      final network = (value['net']?.toString() ?? 'tcp').toLowerCase();
      final security =
          (value['tls']?.toString() ?? '').isEmpty ? 'none' : 'tls';
      final stream = <String, dynamic>{
        'network': network,
        'security': security,
      };
      if (security == 'tls') {
        stream['tlsSettings'] = {
          'serverName': value['sni']?.toString().isNotEmpty == true
              ? value['sni']
              : value['host'] ?? host,
          'allowInsecure':
              value['allowInsecure'] == '1' || value['allowInsecure'] == true,
          'fingerprint': value['fp'] ?? 'chrome',
        };
      }
      if (network == 'ws') {
        stream['wsSettings'] = {
          'path': value['path'] ?? '/',
          'headers': (value['host']?.toString() ?? '').isNotEmpty
              ? {'Host': value['host']}
              : {},
        };
      }
      if (network == 'grpc') {
        stream['grpcSettings'] = {'serviceName': value['path'] ?? ''};
      }
      if (network != 'tcp' && network != 'ws' && network != 'grpc') return null;
      final config = _config(
          'vmess',
          {
            'vnext': [
              {
                'address': host,
                'port': port,
                'users': [
                  {
                    'id': id,
                    'alterId':
                        int.tryParse(value['aid']?.toString() ?? '') ?? 0,
                    'security': value['scy'] ?? 'auto',
                  },
                ],
              },
            ],
          },
          stream);
      return _XrayNode(
        _stableNodeId(link),
        config,
        protocol: 'vmess',
        host: host,
        port: port,
        displayName: _safeNodeName(value['ps']?.toString()),
      );
    } catch (_) {
      return null;
    }
  }

  static _XrayNode? _parseShadowsocks(String link) {
    try {
      final uri = Uri.parse(link);
      String? method;
      String? password;
      var host = uri.host;
      var port = uri.port;
      if (uri.userInfo.isNotEmpty) {
        final credentials = utf8.decode(
          base64.decode(base64.normalize(uri.userInfo)),
        );
        final split = credentials.indexOf(':');
        if (split < 1) return null;
        method = credentials.substring(0, split);
        password = credentials.substring(split + 1);
      } else {
        final authority = link.substring(5).split('#').first;
        final encoded = authority.split('@').first;
        final credentials = utf8.decode(
          base64.decode(base64.normalize(encoded)),
        );
        final split = credentials.indexOf(':');
        final at = credentials.lastIndexOf('@');
        if (split < 1 || at < split) return null;
        method = credentials.substring(0, split);
        password = credentials.substring(split + 1, at);
        final endpoint = Uri.parse('ss://${credentials.substring(at + 1)}');
        host = endpoint.host;
        port = endpoint.port;
      }
      if (host.isEmpty || port < 1) return null;
      final config = _config(
        'shadowsocks',
        {
          'servers': [
            {
              'address': host,
              'port': port,
              'method': method,
              'password': password,
              // Xray's stream transport is TCP; UDP is carried by Shadowsocks
              // UOT and must not be declared as a "tcp,udp" transport.
              'uot': true,
            },
          ],
        },
        {'network': 'tcp', 'security': 'none'},
      );
      return _XrayNode(
        _stableNodeId(link),
        config,
        protocol: 'shadowsocks',
        host: host,
        port: port,
        displayName: _safeNodeName(uri.fragment),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _config(
    String protocol,
    Map<String, dynamic> settings,
    Map<String, dynamic> stream,
  ) =>
      {
        'log': {'loglevel': 'warning'},
        'inbounds': [
          {
            'tag': 'socks-in',
            'listen': '127.0.0.1',
            'port': 10808,
            'protocol': 'socks',
            'settings': {'auth': 'noauth', 'udp': true, 'userLevel': 0},
            'sniffing': {
              'enabled': true,
              'destOverride': ['http', 'tls', 'quic'],
            },
          },
        ],
        'outbounds': [
          {
            'tag': 'proxy',
            'protocol': protocol,
            'settings': settings,
            'streamSettings': stream,
          },
          {
            'tag': 'direct',
            'protocol': 'freedom',
            'settings': {'domainStrategy': 'UseIP'},
          },
        ],
        'routing': {
          'domainStrategy': 'AsIs',
          'rules': [
            {
              'type': 'field',
              'inboundTag': ['socks-in'],
              'outboundTag': 'proxy',
            },
          ],
        },
      };

  static String _safeNodeName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Location not supplied';
    var name = raw.trim();
    try {
      name = Uri.decodeComponent(name);
    } catch (_) {}
    name = name.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    if (name.isEmpty) return 'Location not supplied';
    return name.length > 48 ? '${name.substring(0, 48)}…' : name;
  }

  static List<String> selectedCountryIpCidrs(CountryBypassState state) {
    if (!state.enabled || state.selectedCountries.isEmpty) return const [];
    final selected =
        state.selectedCountries.map((code) => code.toUpperCase()).toSet();
    final cidrs = <String>{};
    for (final country in state.availableCountries) {
      if (!selected.contains(country.code.toUpperCase())) continue;
      for (final cidr in [...country.ipv4Cidrs, ...country.ipv6Cidrs]) {
        final parts = cidr.split('/');
        if (parts.length != 2) continue;
        final address = InternetAddress.tryParse(parts.first);
        if (address == null) continue;
        final prefix = int.tryParse(parts.last);
        final maxPrefix = address.type == InternetAddressType.IPv4 ? 32 : 128;
        if (prefix == null || prefix < 8 || prefix > maxPrefix) continue;
        cidrs.add('${parts.first}/$prefix');
      }
    }
    final sorted = cidrs.toList()..sort();
    if (sorted.length > maxCountryBypassCidrs) {
      throw const HarmoneyWindowsXrayException(
        'Windows country bypass is limited to $maxCountryBypassCidrs IPv4/IPv6 ranges.',
      );
    }
    return sorted;
  }

  /// Kept for callers that only need the IPv4 subset.
  static List<String> selectedCountryIPv4Cidrs(CountryBypassState state) =>
      selectedCountryIpCidrs(state)
          .where((cidr) => cidr.split('/').first.contains('.'))
          .toList(growable: false);

  static const int maxCountryBypassCidrs = 1400;

  static Future<List<String>> _iranDomainBypassRules() async {
    try {
      final content = await rootBundle.loadString(
        'assets/rules/iran_domains.txt',
      );
      return content
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim().toLowerCase())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .where((domain) => RegExp(r'^[a-z0-9.-]+$').hasMatch(domain))
          .map((domain) => 'domain:$domain')
          .toSet()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Map<String, dynamic> applyCountryBypassToConfig(
    Map<String, dynamic> source,
    List<String> cidrs, {
    List<String> domains = const [],
  }) {
    if (cidrs.isEmpty && domains.isEmpty) return source;
    final config = Map<String, dynamic>.from(source);
    final routing = Map<String, dynamic>.from(config['routing'] as Map);
    final rules = (routing['rules'] as List? ?? const [])
        .map((rule) => Map<String, dynamic>.from(rule as Map))
        .toList();
    if (domains.isNotEmpty) {
      rules.insert(0, {
        'type': 'field',
        'inboundTag': ['socks-in'],
        'domain': domains,
        'outboundTag': 'direct',
      });
    }
    if (cidrs.isNotEmpty) {
      rules.insert(0, {
        'type': 'field',
        'inboundTag': ['socks-in'],
        'ip': cidrs,
        'outboundTag': 'direct',
      });
    }
    routing['rules'] = rules;
    config['routing'] = routing;
    return config;
  }

  static String _safeError(String? error) {
    if (error == null || error.trim().isEmpty) {
      return 'The selected servers did not respond.';
    }
    if (error.contains('admin_cancelled')) {
      return 'Administrator permission for the system tunnel was not granted.';
    }
    if (error.contains('permission_denied') || error.contains('canceled')) {
      return 'Administrator permission for the tunnel was not granted.';
    }
    final detail = error.replaceAll(RegExp(r'\s+'), ' ').trim();
    return detail.length > 700 ? '${detail.substring(0, 700)}…' : detail;
  }
}

class HarmoneyWindowsXrayException implements Exception {
  const HarmoneyWindowsXrayException(this.message);
  final String message;
  @override
  String toString() => message;
}

class _XrayNode {
  const _XrayNode(
    this.id,
    this.config, {
    required this.protocol,
    required this.host,
    required this.port,
    required this.displayName,
  });

  final String id;
  final Map<String, dynamic> config;
  final String protocol;
  final String host;
  final int port;
  final String displayName;

  String get endpoint => '$host:$port';
}
