import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app_talker.dart';
import 'dio_client.dart';
import 'local_cache_service.dart';
import 'harmoney_subscription_service.dart';

/// State of the Harmoney feed refresh process.
class HarmoneyRefreshState {
  final bool isRefreshing;
  final DateTime? lastSuccessfulUpdate;
  final String
      status; // 'idle', 'refreshing', 'success', 'partial', 'failed', 'offline', 'timeout'
  final String? errorMessage;
  final int activeFeeds;
  final int totalFeeds;
  final double progress;

  const HarmoneyRefreshState({
    this.isRefreshing = false,
    this.lastSuccessfulUpdate,
    this.status = 'idle',
    this.errorMessage,
    this.activeFeeds = 0,
    this.totalFeeds = 0,
    this.progress = 0.0,
  });

  HarmoneyRefreshState copyWith({
    bool? isRefreshing,
    DateTime? lastSuccessfulUpdate,
    String? status,
    String? errorMessage,
    int? activeFeeds,
    int? totalFeeds,
    double? progress,
  }) {
    return HarmoneyRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastSuccessfulUpdate: lastSuccessfulUpdate ?? this.lastSuccessfulUpdate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFeeds: activeFeeds ?? this.activeFeeds,
      totalFeeds: totalFeeds ?? this.totalFeeds,
      progress: progress ?? this.progress,
    );
  }
}

/// Result of a Harmoney sources refresh attempt.
class HarmoneyRefreshResult {
  final bool isSuccess;
  final int activeFeeds;
  final int totalFeeds;
  final String? errorMessage;
  final int durationMs;

  const HarmoneyRefreshResult({
    required this.isSuccess,
    required this.activeFeeds,
    required this.totalFeeds,
    this.errorMessage,
    required this.durationMs,
  });
}

/// Service managing reliable retrieval, validation, deduplication, and fallback
/// of upstream Harmoney proxy configuration feeds.
class HarmoneySourceUpdater {
  HarmoneySourceUpdater._();

  static final HarmoneySourceUpdater instance = HarmoneySourceUpdater._();

  final ValueNotifier<HarmoneyRefreshState> stateNotifier =
      ValueNotifier<HarmoneyRefreshState>(const HarmoneyRefreshState());

  Completer<HarmoneyRefreshResult>? _inFlightRefresh;

  static const String bundledFlowlinePath =
      'assets/config/harmoney_flowline.json';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final meta = LocalCacheService.instance.getHarmoneyUpdateMetadata();
    stateNotifier.value = HarmoneyRefreshState(
      isRefreshing: false,
      lastSuccessfulUpdate: meta['lastUpdate'] as DateTime?,
      status: (meta['status'] as String?) ?? 'idle',
      errorMessage: meta['error'] as String?,
      activeFeeds: (meta['activeFeeds'] as int?) ?? 0,
      totalFeeds: (meta['totalFeeds'] as int?) ?? 0,
    );
    _initialized = true;
  }

  /// Returns the current feed configuration with the user's private feeds
  /// appended in memory. Personal subscription URLs are not written into the
  /// shared Hive feed cache.
  Future<String> flowlineWithSubscriptions({
    String? subscriptionId,
    String? preferredNodeId,
  }) async {
    await init();
    Map<String, dynamic>? flowline;
    try {
      final cached = LocalCacheService.instance.getCachedHarmoneyFlowline();
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        if (_isValidFlowlineStructure(decoded)) flowline = decoded;
      }
    } catch (_) {}
    flowline ??= await _loadMotherFlowline();
    if (flowline == null) {
      throw StateError('Harmoney feed configuration is unavailable.');
    }
    final urls = await HarmoneySubscriptionService.instance.sourceUrls(
      subscriptionId: subscriptionId,
      nodeId: preferredNodeId,
    );
    if (urls.isNotEmpty) {
      final effective =
          jsonDecode(jsonEncode(flowline)) as Map<String, dynamic>;
      final groups = effective['flowLine'] as List;
      Map<String, dynamic>? xrayGroup;
      for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
        final rawGroup = groups[groupIndex];
        if (rawGroup is Map &&
            rawGroup['label']?.toString().toLowerCase() == 'xray') {
          xrayGroup = Map<String, dynamic>.from(rawGroup);
          groups[groupIndex] = xrayGroup;
          break;
        }
      }
      xrayGroup ??= {'label': 'xray', 'core': 'xray', 'steps': <dynamic>[]};
      final steps = subscriptionId != null
          ? <dynamic>[]
          : xrayGroup['steps'] as List? ?? <dynamic>[];
      for (var index = 0; index < urls.length; index++) {
        steps.add({
          'key': 'personal-sub-$index',
          'provider': 'all',
          'device': 'all',
          'url': urls[index],
          'enabled': true,
          'requireIp': 'ipv4,ipv6',
          'pick_mode': 'LOADBALANCE',
          'max_items': 30,
          'probe_timeout': 10,
          'dnsAddress': '',
          'tunnelDomain': '',
          'publicKey': '',
        });
      }
      xrayGroup['enabled'] = true;
      xrayGroup['steps'] = steps;
      if (!groups.any(
        (raw) => raw is Map && raw['label']?.toString().toLowerCase() == 'xray',
      )) {
        groups.add(xrayGroup);
      }
      return jsonEncode(effective);
    }
    return jsonEncode(flowline);
  }

  /// Triggers a controlled update and validation of upstream proxy feeds.
  /// Deduplicates concurrent calls via an in-flight lock.
  /// Never disrupts an active VPN connection and never overwrites a healthy
  /// config with broken or empty downloads.
  Future<HarmoneyRefreshResult> refresh({
    Duration timeoutPerFeed = const Duration(seconds: 8),
    int maxConcurrency = 4,
    Dio? dioClient,
    bool checkInternet = true,
    Future<bool> Function()? checkConnectivity,
  }) async {
    await init();

    if (_inFlightRefresh != null) {
      AppTalker.debug(
        '[HarmoneyUpdater] Refresh already in-flight; joining existing task.',
      );
      return _inFlightRefresh!.future;
    }

    final completer = Completer<HarmoneyRefreshResult>();
    _inFlightRefresh = completer;

    final stopwatch = Stopwatch()..start();

    try {
      stateNotifier.value = stateNotifier.value.copyWith(
        isRefreshing: true,
        status: 'refreshing',
        errorMessage: null,
        progress: 0.05,
      );

      // Pre-check network connectivity
      if (checkInternet) {
        final hasConnection = checkConnectivity != null
            ? await checkConnectivity()
            : await _checkConnectivity();
        if (!hasConnection) {
          const error = 'عدم اتصال به شبکه اینترنت / No internet connection';
          stateNotifier.value = stateNotifier.value.copyWith(
            isRefreshing: false,
            status: 'offline',
            errorMessage: error,
            progress: 1.0,
          );
          final res = HarmoneyRefreshResult(
            isSuccess: false,
            activeFeeds: stateNotifier.value.activeFeeds,
            totalFeeds: stateNotifier.value.totalFeeds,
            errorMessage: error,
            durationMs: stopwatch.elapsedMilliseconds,
          );
          completer.complete(res);
          return res;
        }
      }

      // 1. Load baseline mother flowline (cached or bundled asset)
      final baselineFlowline = await _loadMotherFlowline();
      if (baselineFlowline == null) {
        const error =
            'فایل مادر یافت نشد یا معتبر نیست / Mother flowline invalid';
        stateNotifier.value = stateNotifier.value.copyWith(
          isRefreshing: false,
          status: 'failed',
          errorMessage: error,
          progress: 1.0,
        );
        final res = HarmoneyRefreshResult(
          isSuccess: false,
          activeFeeds: 0,
          totalFeeds: 0,
          errorMessage: error,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        completer.complete(res);
        return res;
      }

      // 2. Extract candidate remote feeds
      final candidateFeeds = _extractFeeds(baselineFlowline);
      if (candidateFeeds.isEmpty) {
        const error = 'هیچ فید فعالی پیکربندی نشده است / No active feeds';
        stateNotifier.value = stateNotifier.value.copyWith(
          isRefreshing: false,
          status: 'failed',
          errorMessage: error,
          progress: 1.0,
        );
        final res = HarmoneyRefreshResult(
          isSuccess: false,
          activeFeeds: 0,
          totalFeeds: 0,
          errorMessage: error,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        completer.complete(res);
        return res;
      }

      final totalFeeds = candidateFeeds.length;
      stateNotifier.value = stateNotifier.value.copyWith(
        totalFeeds: totalFeeds,
        progress: 0.1,
      );

      // 3. Download & Validate feeds with concurrency control and per-feed timeout
      final client = dioClient ?? DioClient.instance.dio;
      final results = await _downloadAndValidateFeeds(
        candidateFeeds,
        client: client,
        timeout: timeoutPerFeed,
        concurrency: maxConcurrency,
        onProgress: (done, total) {
          final p = 0.1 + (done / total) * 0.8;
          stateNotifier.value = stateNotifier.value.copyWith(progress: p);
        },
      );

      final verifiedFeeds = <String, _FeedValidationResult>{};
      for (final entry in results.entries) {
        if (entry.value.isValid) {
          verifiedFeeds[entry.key] = entry.value;
        }
      }

      final activeFeedsCount = verifiedFeeds.length;

      // 4. Decision: Keep healthy config if zero feeds succeeded
      if (activeFeedsCount == 0) {
        const error =
            'دریافت منابع با خطا مواجه شد؛ کانفیگ سالم قبلی حفظ شد / All feeds failed, preserved healthy config';
        AppTalker.warning(
          '[HarmoneyUpdater] All feeds failed validation; retaining previous healthy config.',
        );
        stateNotifier.value = stateNotifier.value.copyWith(
          isRefreshing: false,
          status: 'failed',
          errorMessage: error,
          progress: 1.0,
        );
        final res = HarmoneyRefreshResult(
          isSuccess: false,
          activeFeeds: 0,
          totalFeeds: totalFeeds,
          errorMessage: error,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        completer.complete(res);
        return res;
      }

      // 5. Update flowline with verified feeds while deactivating dead ones
      final updatedFlowlineJson = _generateUpdatedFlowline(
        baselineFlowline,
        verifiedFeeds: verifiedFeeds.keys.toSet(),
      );

      // Persist healthy verified flowline
      await LocalCacheService.instance.saveCachedHarmoneyFlowline(
        updatedFlowlineJson,
      );
      await _writeActiveFlowlineFile(updatedFlowlineJson);

      final now = DateTime.now();
      final isFullSuccess = activeFeedsCount == totalFeeds;
      final finalStatus = isFullSuccess ? 'success' : 'partial';
      final statusMessage = isFullSuccess
          ? 'تمام منابع با موفقیت دریافت و تأیید شدند'
          : '$activeFeedsCount از $totalFeeds منبع تأیید شد';

      await LocalCacheService.instance.saveHarmoneyUpdateMetadata(
        timestamp: now,
        status: finalStatus,
        errorMessage: isFullSuccess ? null : statusMessage,
        activeFeeds: activeFeedsCount,
        totalFeeds: totalFeeds,
      );

      stateNotifier.value = stateNotifier.value.copyWith(
        isRefreshing: false,
        lastSuccessfulUpdate: now,
        status: finalStatus,
        errorMessage: isFullSuccess ? null : statusMessage,
        activeFeeds: activeFeedsCount,
        totalFeeds: totalFeeds,
        progress: 1.0,
      );

      AppTalker.info(
        '[HarmoneyUpdater] Refreshed successfully: $activeFeedsCount/$totalFeeds feeds valid in ${stopwatch.elapsedMilliseconds}ms.',
      );

      final finalResult = HarmoneyRefreshResult(
        isSuccess: true,
        activeFeeds: activeFeedsCount,
        totalFeeds: totalFeeds,
        errorMessage: isFullSuccess ? null : statusMessage,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      completer.complete(finalResult);
      return finalResult;
    } catch (e, stack) {
      AppTalker.error(
        '[HarmoneyUpdater] Unexpected refresh failure: $e',
        e,
        stack,
      );
      final errorStr = 'خطا در به‌روزرسانی: $e';
      stateNotifier.value = stateNotifier.value.copyWith(
        isRefreshing: false,
        status: 'failed',
        errorMessage: errorStr,
        progress: 1.0,
      );
      final res = HarmoneyRefreshResult(
        isSuccess: false,
        activeFeeds: stateNotifier.value.activeFeeds,
        totalFeeds: stateNotifier.value.totalFeeds,
        errorMessage: errorStr,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      completer.complete(res);
      return res;
    } finally {
      _inFlightRefresh = null;
    }
  }

  /// Checks internet connectivity safely
  Future<bool> _checkConnectivity() async {
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (_) {
      // Fallback: if checker fails, assume network might be up and attempt probe
      return true;
    }
  }

  /// Loads the mother flowline JSON map, checking cache first then bundled asset.
  Future<Map<String, dynamic>?> _loadMotherFlowline() async {
    try {
      final cached = LocalCacheService.instance.getCachedHarmoneyFlowline();
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        if (_isValidFlowlineStructure(decoded)) {
          return decoded;
        }
      }
    } catch (_) {}

    try {
      final assetStr = await rootBundle.loadString(bundledFlowlinePath);
      final decoded = jsonDecode(assetStr) as Map<String, dynamic>;
      if (_isValidFlowlineStructure(decoded)) {
        return decoded;
      }
    } catch (_) {}

    return null;
  }

  /// Verifies flowline schema integrity.
  static bool _isValidFlowlineStructure(Map<String, dynamic> map) {
    if (!map.containsKey('flowLine')) return false;
    final groups = map['flowLine'];
    if (groups is! List || groups.isEmpty) return false;
    for (final group in groups) {
      if (group is! Map || !group.containsKey('label')) return false;
    }
    return true;
  }

  /// Extracts enabled HTTP steps from flowline.
  static List<_FeedCandidate> _extractFeeds(Map<String, dynamic> flowline) {
    final list = <_FeedCandidate>[];
    final groups = flowline['flowLine'] as List;
    for (final group in groups) {
      if (group is! Map) continue;
      final steps = group['steps'];
      if (steps is! List) continue;
      for (final step in steps) {
        if (step is! Map) continue;
        final enabled = step['enabled'] == true;
        final key = step['key']?.toString() ?? '';
        final url = step['url']?.toString() ?? '';
        if (enabled && url.startsWith('http')) {
          list.add(_FeedCandidate(key: key, url: url));
        }
      }
    }
    return list;
  }

  /// Concurrently downloads and validates feeds with max worker limit.
  Future<Map<String, _FeedValidationResult>> _downloadAndValidateFeeds(
    List<_FeedCandidate> feeds, {
    required Dio client,
    required Duration timeout,
    required int concurrency,
    required void Function(int completed, int total) onProgress,
  }) async {
    final results = <String, _FeedValidationResult>{};
    var nextIndex = 0;
    var completedCount = 0;

    Future<void> worker() async {
      while (true) {
        int index;
        if (nextIndex >= feeds.length) break;
        index = nextIndex++;
        final feed = feeds[index];

        final result = await _validateFeed(client, feed, timeout: timeout);
        results[feed.key] = result;

        completedCount++;
        onProgress(completedCount, feeds.length);
      }
    }

    final workers = List.generate(
      concurrency.clamp(1, feeds.length),
      (_) => worker(),
    );

    await Future.wait(workers);
    return results;
  }

  /// Fetches an individual feed and strictly validates proxy content.
  /// Redacts all sensitive credentials from logs.
  Future<_FeedValidationResult> _validateFeed(
    Dio client,
    _FeedCandidate feed, {
    required Duration timeout,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final response = await client.get<String>(
        feed.url,
        options: Options(
          responseType: ResponseType.plain,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        AppTalker.warning(
          '[HarmoneyUpdater] Feed ${feed.key} returned HTTP ${response.statusCode}',
        );
        return _FeedValidationResult(
          isValid: false,
          statusCode: response.statusCode ?? 0,
          proxyCount: 0,
          latencyMs: sw.elapsedMilliseconds,
          error: 'HTTP ${response.statusCode}',
        );
      }

      final body = response.data;
      if (body == null || body.trim().isEmpty) {
        return _FeedValidationResult(
          isValid: false,
          statusCode: 200,
          proxyCount: 0,
          latencyMs: sw.elapsedMilliseconds,
          error: 'Empty response',
        );
      }

      // Reject HTML error pages
      if (body.contains('<!DOCTYPE html>') ||
          body.contains('<html') ||
          body.contains('404: Not Found')) {
        return _FeedValidationResult(
          isValid: false,
          statusCode: 200,
          proxyCount: 0,
          latencyMs: sw.elapsedMilliseconds,
          error: 'HTML error page',
        );
      }

      // Validate proxy content (raw or base64 subscription)
      final validCount = _countValidProxies(body);
      if (validCount > 0) {
        // Redaction: Never log actual config strings or keys!
        AppTalker.info(
          '[HarmoneyUpdater] Feed "${feed.key}" validated ($validCount proxy items in ${sw.elapsedMilliseconds}ms)',
        );
        return _FeedValidationResult(
          isValid: true,
          statusCode: 200,
          proxyCount: validCount,
          latencyMs: sw.elapsedMilliseconds,
        );
      }

      return _FeedValidationResult(
        isValid: false,
        statusCode: 200,
        proxyCount: 0,
        latencyMs: sw.elapsedMilliseconds,
        error: 'No valid proxy entries found',
      );
    } catch (e) {
      AppTalker.warning('[HarmoneyUpdater] Feed ${feed.key} probe error: $e');
      return _FeedValidationResult(
        isValid: false,
        statusCode: 0,
        proxyCount: 0,
        latencyMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  /// Counts the number of valid proxy protocol configurations in text.
  /// Supports direct protocol links and Base64 encoded subscription data.
  static int _countValidProxies(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;

    int countDirect(String content) {
      var valid = 0;
      final lines = content.split('\n');
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;
        if (line.startsWith('vless://') ||
            line.startsWith('vmess://') ||
            line.startsWith('ss://') ||
            line.startsWith('trojan://') ||
            line.startsWith('tuic://') ||
            line.startsWith('hysteria2://') ||
            line.startsWith('hy2://') ||
            line.startsWith('wireguard://')) {
          valid++;
        }
      }
      return valid;
    }

    final directCount = countDirect(trimmed);
    if (directCount > 0) return directCount;

    // Check if body is Base64 encoded
    try {
      final sanitizedBase64 = trimmed.replaceAll(RegExp(r'\s+'), '');
      final normalized = base64.normalize(sanitizedBase64);
      final decodedBytes = base64.decode(normalized);
      final decodedText = utf8.decode(decodedBytes, allowMalformed: true);
      return countDirect(decodedText);
    } catch (_) {
      return 0;
    }
  }

  /// Produces updated flowline JSON disabling any step that failed validation.
  static String _generateUpdatedFlowline(
    Map<String, dynamic> baseline, {
    required Set<String> verifiedFeeds,
  }) {
    final cloned = jsonDecode(jsonEncode(baseline)) as Map<String, dynamic>;
    final groups = cloned['flowLine'] as List;
    for (final group in groups) {
      if (group is! Map) continue;
      final steps = group['steps'];
      if (steps is! List) continue;
      for (final step in steps) {
        if (step is! Map) continue;
        final key = step['key']?.toString() ?? '';
        final url = step['url']?.toString() ?? '';
        if (url.startsWith('http')) {
          // If this feed failed or was not verified, disable it
          step['enabled'] = verifiedFeeds.contains(key);
        }
      }
    }
    return jsonEncode(cloned);
  }

  /// Safely writes updated active flowline to platform file system if available.
  Future<void> _writeActiveFlowlineFile(String flowlineJson) async {
    try {
      if (Platform.isAndroid) {
        // App-specific internal storage
        final dir = await getApplicationSupportDirectory();
        if (await dir.exists()) {
          final file = File('${dir.path}/harmoney_flowline_active.json');
          await file.writeAsString(flowlineJson, flush: true);
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '';
        if (home.isNotEmpty) {
          final userCache = Directory('$home/.cache/harmoney-vpn');
          await userCache.create(recursive: true);
          final file = File('${userCache.path}/flowline_active.json');
          await file.writeAsString(flowlineJson, flush: true);
        }
      }
    } catch (_) {}
  }
}

class _FeedCandidate {
  final String key;
  final String url;
  const _FeedCandidate({required this.key, required this.url});
}

class _FeedValidationResult {
  final bool isValid;
  final int statusCode;
  final int proxyCount;
  final int latencyMs;
  final String? error;

  const _FeedValidationResult({
    required this.isValid,
    required this.statusCode,
    required this.proxyCount,
    required this.latencyMs,
    this.error,
  });
}
