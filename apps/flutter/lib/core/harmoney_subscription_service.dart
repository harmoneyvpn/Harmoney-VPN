import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'harmoney_subscription_refresh_scheduler.dart';
import 'vpn_notification_events.dart';
import 'secure_credentials_vault.dart';

class HarmoneySubscription {
  const HarmoneySubscription({
    required this.id,
    required this.name,
    required this.url,
    this.nodeCount = 0,
    this.lastUpdated,
    this.error,
    this.enabled = true,
    this.uploadBytes,
    this.downloadBytes,
    this.totalBytes,
    this.expiresAt,
    this.requiredAppVersion,
  });

  final String id;
  final String name;
  final String url;
  final int nodeCount;
  final DateTime? lastUpdated;
  final String? error;
  final bool enabled;
  final int? uploadBytes;
  final int? downloadBytes;
  final int? totalBytes;
  final DateTime? expiresAt;
  final String? requiredAppVersion;

  HarmoneySubscription copyWith({
    int? nodeCount,
    DateTime? lastUpdated,
    String? error,
    bool clearError = false,
    bool? enabled,
    int? uploadBytes,
    int? downloadBytes,
    int? totalBytes,
    DateTime? expiresAt,
    String? requiredAppVersion,
  }) =>
      HarmoneySubscription(
        id: id,
        name: name,
        url: url,
        nodeCount: nodeCount ?? this.nodeCount,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        error: clearError ? null : (error ?? this.error),
        enabled: enabled ?? this.enabled,
        uploadBytes: uploadBytes ?? this.uploadBytes,
        downloadBytes: downloadBytes ?? this.downloadBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        expiresAt: expiresAt ?? this.expiresAt,
        requiredAppVersion: requiredAppVersion ?? this.requiredAppVersion,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'nodeCount': nodeCount,
        'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
        'error': error,
        'enabled': enabled,
        'uploadBytes': uploadBytes,
        'downloadBytes': downloadBytes,
        'totalBytes': totalBytes,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
        'requiredAppVersion': requiredAppVersion,
      };

  factory HarmoneySubscription.fromJson(Map<String, dynamic> json) =>
      HarmoneySubscription(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Subscription',
        url: json['url']?.toString() ?? '',
        nodeCount: (json['nodeCount'] as num?)?.toInt() ?? 0,
        lastUpdated: json['lastUpdated'] is num
            ? DateTime.fromMillisecondsSinceEpoch(
                (json['lastUpdated'] as num).toInt(),
              )
            : null,
        error: json['error']?.toString(),
        enabled: json['enabled'] != false,
        uploadBytes: (json['uploadBytes'] as num?)?.toInt(),
        downloadBytes: (json['downloadBytes'] as num?)?.toInt(),
        totalBytes: (json['totalBytes'] as num?)?.toInt(),
        expiresAt: json['expiresAt'] is num
            ? DateTime.fromMillisecondsSinceEpoch(
                (json['expiresAt'] as num).toInt(),
              )
            : null,
        requiredAppVersion: json['requiredAppVersion']?.toString(),
      );
}

class HarmoneySubscriptionNode {
  const HarmoneySubscriptionNode({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.name,
    required this.protocol,
    required this.host,
    required this.port,
    required this.link,
    required this.compatible,
    this.compatibilityWarning,
  });

  final String id;
  final String subscriptionId;
  final String subscriptionName;
  final String name;
  final String protocol;
  final String host;
  final int port;
  final String link;
  final bool compatible;
  final String? compatibilityWarning;
}

/// User subscriptions are stored in the platform credential vault because a
/// subscription URL commonly grants access to the owner's VPN account.
class HarmoneySubscriptionService {
  HarmoneySubscriptionService._();
  static final instance = HarmoneySubscriptionService._();

  // Do not use DioClient here: its diagnostic interceptor logs request URLs,
  // and subscription URLs can contain bearer credentials.
  late final Dio _dio = _createSecureSubscriptionDio();

  static Dio _createSecureSubscriptionDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 12),
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Anti-Proxy: Bypass local sniffing/intercepting proxies
        client.findProxy = (uri) => 'DIRECT';
        // Reject unverified/self-signed certs immediately
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => false;
        return client;
      },
      validateCertificate: (X509Certificate? cert, String host, int port) {
        if (cert == null) return false;
        final issuer = cert.issuer.toLowerCase();
        final subject = cert.subject.toLowerCase();
        const suspiciousCa = [
          'charles',
          'httptoolkit',
          'http toolkit',
          'mitmproxy',
          'portswigger',
          'burp',
          'fiddler',
          'proxyman',
          'whistle',
          'reqable',
        ];
        if (suspiciousCa.any((ca) => issuer.contains(ca) || subject.contains(ca))) {
          return false;
        }
        if (cert.issuer == cert.subject) {
          return false;
        }
        return true;
      },
    );

    return dio;
  }
  final Map<String,
          ({DateTime fetchedAt, List<HarmoneySubscriptionNode> nodes})>
      _nodeCache = {};
  final Map<String, ({DateTime checkedAt, int? latency})> _probeCache = {};
  final Map<String, Future<int?>> _probeInFlight = {};
  final Set<String> _notificationWarnings = {};
  static const _protocols = <String>[
    'vless://',
    'vmess://',
    'trojan://',
    'ss://',
    'tuic://',
    'hysteria2://',
    'hy2://',
    'wireguard://',
  ];
  static const _favoriteKey = 'vault_harmoney_favorite_nodes_v1';

  Future<List<HarmoneySubscription>> list() async {
    try {
      final raw =
          await SecureCredentialsVault.instance.getHarmoneySubscriptions();
      if (raw == null || raw.isEmpty) return const [];
      final entries = jsonDecode(raw) as List;
      final result = entries
          .whereType<Map>()
          .map(
            (entry) =>
                HarmoneySubscription.fromJson(Map<String, dynamic>.from(entry)),
          )
          .where((entry) => entry.id.isNotEmpty && entry.url.isNotEmpty)
          .fold<List<HarmoneySubscription>>([], (unique, entry) {
        if (unique.every(
          (item) => _canonicalUrl(item.url) != _canonicalUrl(entry.url),
        )) {
          unique.add(entry);
        }
        return unique;
      });
      unawaited(
        HarmoneySubscriptionRefreshScheduler.instance.sync(
          hasSubscriptions: result.isNotEmpty,
        ),
      );
      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(List<HarmoneySubscription> subscriptions) async {
    final unique = <String, HarmoneySubscription>{};
    for (final entry in subscriptions) {
      unique.putIfAbsent(_canonicalUrl(entry.url), () => entry);
    }
    await SecureCredentialsVault.instance.saveHarmoneySubscriptions(
      jsonEncode(unique.values.map((entry) => entry.toJson()).toList()),
    );
    unawaited(
      HarmoneySubscriptionRefreshScheduler.instance.sync(
        hasSubscriptions: unique.isNotEmpty,
      ),
    );
  }

  Future<HarmoneySubscription> add({required String url, String? name}) async {
    final normalized = url.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'https', 'http'}.contains(uri.scheme.toLowerCase())) {
      throw const FormatException(
        'Enter a valid HTTP or HTTPS subscription URL.',
      );
    }
    final existing = await list();
    if (existing.any(
      (entry) => _canonicalUrl(entry.url) == _canonicalUrl(normalized),
    )) {
      throw const FormatException('This subscription is already added.');
    }
    final fetched = await _fetch(normalized);
    if (fetched.count == 0) {
      throw const FormatException('No supported VPN servers were found.');
    }
    final label = name?.trim().isNotEmpty == true
        ? name!.trim()
        : (uri.host.isEmpty ? 'Subscription' : uri.host);
    final entry = HarmoneySubscription(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: label,
      url: normalized,
      nodeCount: fetched.count,
      lastUpdated: DateTime.now(),
      uploadBytes: fetched.uploadBytes,
      downloadBytes: fetched.downloadBytes,
      totalBytes: fetched.totalBytes,
      expiresAt: fetched.expiresAt,
      requiredAppVersion: fetched.requiredAppVersion,
    );
    await _save([...existing, entry]);
    _nodeCache.clear();
    _publishSubscriptionWarnings([entry]);
    return entry;
  }

  Future<List<HarmoneySubscription>> refreshAll() async {
    final entries = await list();
    final updated = <HarmoneySubscription>[];
    for (final entry in entries) {
      try {
        final fetched = await _fetch(entry.url);
        if (fetched.count == 0) {
          throw const FormatException('No supported VPN servers found.');
        }
        updated.add(
          entry.copyWith(
            nodeCount: fetched.count,
            lastUpdated: DateTime.now(),
            clearError: true,
            uploadBytes: fetched.uploadBytes,
            downloadBytes: fetched.downloadBytes,
            totalBytes: fetched.totalBytes,
            expiresAt: fetched.expiresAt,
            requiredAppVersion: fetched.requiredAppVersion,
          ),
        );
      } catch (error) {
        updated.add(entry.copyWith(error: _shortError(error)));
      }
    }
    await _save(updated);
    _nodeCache.clear();
    VpnNotificationEvents.publish(VpnNotificationEvent(
      VpnNotificationEventType.subscriptionUpdated,
      failed: updated.where((entry) => entry.error != null).length,
    ));
    _publishSubscriptionWarnings(updated.where((entry) => entry.error == null));
    return updated;
  }

  void _publishSubscriptionWarnings(Iterable<HarmoneySubscription> entries) {
    final now = DateTime.now();
    for (final entry in entries) {
      final expiry = entry.expiresAt;
      if (expiry != null) {
        final days = expiry.difference(now).inDays;
        if (days >= 0 &&
            days <= 3 &&
            _notificationWarnings.add('expiry:${entry.id}')) {
          VpnNotificationEvents.publish(VpnNotificationEvent(
            VpnNotificationEventType.subscriptionExpiry,
            value: days,
          ));
        }
      }
      final total = entry.totalBytes;
      if (total != null && total > 0) {
        final used = (entry.uploadBytes ?? 0) + (entry.downloadBytes ?? 0);
        final percent = ((used / total) * 100).round().clamp(0, 100).toInt();
        if (percent >= 90 && _notificationWarnings.add('quota:${entry.id}')) {
          VpnNotificationEvents.publish(VpnNotificationEvent(
            VpnNotificationEventType.subscriptionQuota,
            value: percent,
          ));
        }
      }
    }
  }

  Future<HarmoneySubscription?> refreshSubscription(String id) async {
    final entries = await list();
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return null;
    final entry = entries[index];
    HarmoneySubscription updated;
    try {
      final fetched = await _fetch(entry.url);
      if (fetched.count == 0) {
        throw const FormatException('No supported VPN servers found.');
      }
      updated = entry.copyWith(
        nodeCount: fetched.count,
        lastUpdated: DateTime.now(),
        clearError: true,
        uploadBytes: fetched.uploadBytes,
        downloadBytes: fetched.downloadBytes,
        totalBytes: fetched.totalBytes,
        expiresAt: fetched.expiresAt,
        requiredAppVersion: fetched.requiredAppVersion,
      );
    } catch (error) {
      updated = entry.copyWith(error: _shortError(error));
    }
    entries[index] = updated;
    await _save(entries);
    _nodeCache.clear();
    if (updated.error == null) {
      _publishSubscriptionWarnings([updated]);
    }
    return updated;
  }

  Future<void> remove(String id) async {
    final entries = await list();
    await _save(entries.where((entry) => entry.id != id).toList());
    _nodeCache.clear();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final entries = await list();
    await _save(
      entries
          .map(
            (entry) =>
                entry.id == id ? entry.copyWith(enabled: enabled) : entry,
          )
          .toList(),
    );
    _nodeCache.clear();
  }

  Future<List<String>> sourceUrls({
    String? subscriptionId,
    String? nodeId,
  }) async {
    if (nodeId != null) {
      final selected = (await nodes(subscriptionId: subscriptionId))
          .where((node) => node.id == nodeId && node.compatible)
          .toList(growable: false);
      return selected.isEmpty ? const [] : [selected.first.link];
    }
    return (await list())
        .where(
          (entry) =>
              entry.enabled &&
              (subscriptionId == null || entry.id == subscriptionId),
        )
        .map((entry) => entry.url)
        .toList(growable: false);
  }

  Future<Set<String>> favoriteNodeIds() async {
    try {
      final raw = await SecureCredentialsVault.instance.getSecret(_favoriteKey);
      if (raw == null || raw.isEmpty) return <String>{};
      return (jsonDecode(raw) as List).map((value) => value.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> setNodeFavorite(String id, bool favorite) async {
    final favorites = await favoriteNodeIds();
    if (favorite) {
      favorites.add(id);
    } else {
      favorites.remove(id);
    }
    await SecureCredentialsVault.instance.saveSecret(
      _favoriteKey,
      jsonEncode(favorites.toList()),
    );
  }

  Future<List<HarmoneySubscriptionNode>> nodes({
    String? subscriptionId,
    bool includeDisabled = false,
  }) async {
    final cacheKey = '${subscriptionId ?? '*'}:${includeDisabled ? 1 : 0}';
    final cached = _nodeCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) <
            const Duration(minutes: 5)) {
      return cached.nodes;
    }
    final entries = (await list())
        .where(
          (entry) =>
              (includeDisabled || entry.enabled) &&
              (subscriptionId == null || entry.id == subscriptionId),
        )
        .toList();
    final appVersion = (await PackageInfo.fromPlatform()).version;
    final bodies = List<String?>.filled(entries.length, null);
    var nextEntry = 0;
    Future<void> worker() async {
      while (nextEntry < entries.length) {
        final index = nextEntry++;
        try {
          final cancelToken = CancelToken();
          final response = await _dio.get<String>(
            entries[index].url,
            cancelToken: cancelToken,
            onReceiveProgress: (received, _) {
              if (received > 5 * 1024 * 1024) {
                cancelToken.cancel('Subscription content exceeds 5 MB.');
              }
            },
            options: Options(
              responseType: ResponseType.plain,
              validateStatus: (status) => status != null && status < 500,
            ),
          );
          if (response.statusCode == 200) bodies[index] = response.data;
        } catch (_) {}
      }
    }

    await Future.wait(
      List.generate(entries.length.clamp(1, 4), (_) => worker()),
    );
    final output = <HarmoneySubscriptionNode>[];
    for (var index = 0; index < entries.length; index++) {
      final body = bodies[index];
      if (body == null) continue;
      for (final line in _decodeLines(body)) {
        final node = _parseNode(entries[index], line, appVersion);
        if (node != null) output.add(node);
      }
    }
    final seen = <String>{};
    final unique =
        output.where((node) => seen.add(node.id)).toList(growable: false);
    _nodeCache[cacheKey] = (fetchedAt: DateTime.now(), nodes: unique);
    return unique;
  }

  Future<int?> testNode(HarmoneySubscriptionNode node) {
    final cached = _probeCache[node.id];
    if (cached != null &&
        DateTime.now().difference(cached.checkedAt) <
            const Duration(seconds: 30)) {
      return Future.value(cached.latency);
    }
    return _probeInFlight.putIfAbsent(node.id, () => _testNodeUncached(node));
  }

  int? cachedNodeLatency(String nodeId) {
    final cached = _probeCache[nodeId];
    if (cached == null ||
        DateTime.now().difference(cached.checkedAt) >=
            const Duration(seconds: 30)) {
      return null;
    }
    return cached.latency;
  }

  Future<int?> _testNodeUncached(HarmoneySubscriptionNode node) async {
    final watch = Stopwatch()..start();
    Socket? socket;
    int? latency;
    try {
      socket = await Socket.connect(
        node.host,
        node.port,
        timeout: const Duration(seconds: 4),
      );
      latency = watch.elapsedMilliseconds;
    } catch (_) {
      latency = null;
    } finally {
      socket?.destroy();
      _probeCache[node.id] = (checkedAt: DateTime.now(), latency: latency);
      _probeInFlight.remove(node.id);
    }
    return latency;
  }

  Future<
      ({
        int count,
        int? uploadBytes,
        int? downloadBytes,
        int? totalBytes,
        DateTime? expiresAt,
        String? requiredAppVersion,
      })> _fetch(String url) async {
    final cancelToken = CancelToken();
    final response = await _dio.get<String>(
      url,
      cancelToken: cancelToken,
      onReceiveProgress: (received, _) {
        if (received > 5 * 1024 * 1024) {
          cancelToken.cancel('Subscription content exceeds 5 MB.');
        }
      },
      options: Options(
        responseType: ResponseType.plain,
        sendTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode != 200) {
      throw FormatException('HTTP ${response.statusCode ?? 'error'}');
    }
    final body = response.data?.trim() ?? '';
    final info = _decodeLines(body);
    final header = response.headers.value('subscription-userinfo') ??
        response.headers.value('x-subscription-userinfo') ??
        '';
    final requiredAppVersion = response.headers.value('x-min-app-version') ??
        response.headers.value('min-app-version') ??
        response.headers.value('profile-min-app-version');
    final values = <String, int>{};
    for (final match in RegExp(
      r'([a-zA-Z_]+)\s*=\s*(\d+)',
    ).allMatches(header)) {
      values[match.group(1)!.toLowerCase()] = int.parse(match.group(2)!);
    }
    final expirySeconds = values['expire'];
    return (
      count: info.toSet().length,
      uploadBytes: values['upload'],
      downloadBytes: values['download'],
      totalBytes: values['total'],
      expiresAt: expirySeconds == null || expirySeconds == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expirySeconds * 1000),
      requiredAppVersion: requiredAppVersion?.trim().isEmpty == true
          ? null
          : requiredAppVersion?.trim(),
    );
  }

  List<String> _decodeLines(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed.startsWith('<')) return const [];
    var decoded = trimmed;
    if (!_protocols.any(decoded.contains)) {
      try {
        final compact = decoded.replaceAll(RegExp(r'\s+'), '');
        decoded = utf8.decode(
          base64.decode(base64.normalize(compact)),
          allowMalformed: true,
        );
      } catch (_) {
        return const [];
      }
    }
    return decoded
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => _protocols.any(line.startsWith))
        .toSet()
        .toList(growable: false);
  }

  HarmoneySubscriptionNode? _parseNode(
    HarmoneySubscription subscription,
    String link,
    String appVersion,
  ) {
    try {
      final protocol = link.substring(0, link.indexOf('://')).toLowerCase();
      String host;
      int port;
      String name;
      if (protocol == 'vmess') {
        final raw = link.substring(link.indexOf('://') + 3);
        final decoded = utf8.decode(
          base64.decode(
            base64.normalize(raw.replaceAll('-', '+').replaceAll('_', '/')),
          ),
        );
        final data = jsonDecode(decoded) as Map<String, dynamic>;
        host = data['add']?.toString() ?? '';
        port = int.tryParse(data['port']?.toString() ?? '') ?? 0;
        name = data['ps']?.toString() ?? host;
      } else {
        final uri = Uri.parse(link);
        host = uri.host;
        port = uri.hasPort ? uri.port : (protocol == 'ss' ? 8388 : 443);
        name = uri.fragment.isEmpty ? host : Uri.decodeComponent(uri.fragment);
      }
      if (host.isEmpty || port <= 0 || port > 65535) return null;
      final protocolSupported = Platform.isWindows
          ? const {'vless', 'vmess', 'trojan', 'ss'}.contains(protocol)
          : (Platform.isAndroid || Platform.isLinux) &&
              _protocols.any((prefix) => prefix.startsWith('$protocol://'));
      final versionSupported = subscription.requiredAppVersion == null ||
          !_isOlderVersion(appVersion, subscription.requiredAppVersion!);
      final warning = !protocolSupported
          ? 'Protocol $protocol is not supported on this device.'
          : !versionSupported
              ? 'Requires app version ${subscription.requiredAppVersion}.'
              : null;
      return HarmoneySubscriptionNode(
        id: sha256.convert(utf8.encode(link)).toString(),
        subscriptionId: subscription.id,
        subscriptionName: subscription.name,
        name: name,
        protocol: protocol,
        host: host,
        port: port,
        link: link,
        compatible: warning == null,
        compatibilityWarning: warning,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isOlderVersion(String current, String required) {
    List<int> parts(String value) => RegExp(r'\d+')
        .allMatches(value)
        .map((match) => int.tryParse(match.group(0)!) ?? 0)
        .toList();
    final currentParts = parts(current);
    final requiredParts = parts(required);
    for (var index = 0;
        index < currentParts.length || index < requiredParts.length;
        index++) {
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      final requiredPart =
          index < requiredParts.length ? requiredParts[index] : 0;
      if (currentPart != requiredPart) return currentPart < requiredPart;
    }
    return false;
  }

  String _shortError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == null ? 'Could not reach subscription.' : 'HTTP $status';
    }
    return error.toString().replaceFirst('FormatException: ', '');
  }

  String _canonicalUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return value.trim();
    return uri
        .replace(
          scheme: uri.scheme.toLowerCase(),
          host: uri.host.toLowerCase(),
          path: uri.normalizePath().path,
        )
        .toString();
  }
}
