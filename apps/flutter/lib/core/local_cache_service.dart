import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  LocalCacheService._();

  static final LocalCacheService instance = LocalCacheService._();

  static const String _boxServers = 'server_cache_v1';
  static const String _boxIcons = 'app_icons_cache_v1';
  static const String _boxTraffic = 'daily_traffic_stats_v1';
  static const String _boxSettings = 'settings_store_v1';

  late Box<String> _serversBox;
  late Box<List<int>> _iconsBox;
  late Box<dynamic> _trafficBox;
  late Box<dynamic> _settingsBox;

  bool _initialized = false;
  Future<void>? _initialization;

  Future<void> init([String? subDir]) {
    if (_initialized) return Future<void>.value();
    return _initialization ??= _init(subDir).whenComplete(() {
      if (!_initialized) _initialization = null;
    });
  }

  Future<void> _init(String? subDir) async {
    try {
      if (subDir != null) {
        Hive.init(subDir);
      } else {
        await Hive.initFlutter();
      }
      _serversBox = await Hive.openBox<String>(_boxServers);
      _iconsBox = await Hive.openBox<List<int>>(_boxIcons);
      _trafficBox = await Hive.openBox<dynamic>(_boxTraffic);
      _settingsBox = await Hive.openBox<dynamic>(_boxSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('LocalCacheService init error: $e');
    }
  }

  // --- Servers Cache ---
  Future<void> cacheServers(
    String provider,
    List<Map<String, dynamic>> servers,
  ) async {
    if (!_initialized) await init();
    try {
      final jsonStr = jsonEncode(servers);
      await _serversBox.put('servers_$provider', jsonStr);
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>?> getCachedServers(String provider) async {
    if (!_initialized) await init();
    try {
      final raw = _serversBox.get('servers_$provider');
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  // --- App Icons Cache ---
  Future<void> cacheAppIcon(String packageName, List<int> bytes) async {
    if (!_initialized) await init();
    try {
      await _iconsBox.put(packageName, bytes);
    } catch (_) {}
  }

  Uint8List? getCachedAppIcon(String packageName) {
    if (!_initialized) return null;
    try {
      final raw = _iconsBox.get(packageName);
      if (raw == null) return null;
      return Uint8List.fromList(raw);
    } catch (_) {
      return null;
    }
  }

  // --- Daily Traffic Stats ---
  Future<void> recordTrafficSample({
    required int bytesIn,
    required int bytesOut,
  }) async {
    if (!_initialized) await init();
    try {
      final now = DateTime.now();
      final dateKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final currentIn =
          (_trafficBox.get('${dateKey}_in', defaultValue: 0) as num).toInt();
      final currentOut =
          (_trafficBox.get('${dateKey}_out', defaultValue: 0) as num).toInt();

      await _trafficBox.put('${dateKey}_in', currentIn + bytesIn);
      await _trafficBox.put('${dateKey}_out', currentOut + bytesOut);
    } catch (_) {}
  }

  Map<String, int> getTodayTraffic() {
    if (!_initialized) return {'in': 0, 'out': 0};
    try {
      final now = DateTime.now();
      final dateKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final totalIn = (_trafficBox.get('${dateKey}_in', defaultValue: 0) as num)
          .toInt();
      final totalOut =
          (_trafficBox.get('${dateKey}_out', defaultValue: 0) as num).toInt();
      return {'in': totalIn, 'out': totalOut};
    } catch (_) {
      return {'in': 0, 'out': 0};
    }
  }

  // --- Split Tunneling & Settings Store ---
  Future<void> saveSplitTunnelPackages(List<String> packages) async {
    if (!_initialized) await init();
    try {
      await _settingsBox.put('split_tunnel_packages', packages);
    } catch (_) {}
  }

  List<String> getSplitTunnelPackages() {
    if (!_initialized) return const [];
    try {
      final raw = _settingsBox.get('split_tunnel_packages');
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveWindowsPerAppExecutables(List<String> paths) async {
    if (!_initialized) await init();
    try {
      await _settingsBox.put(
        'windows_per_app_executables_v1',
        paths.toSet().toList(),
      );
    } catch (_) {}
  }

  List<String> getWindowsPerAppExecutables() {
    if (!_initialized) return const [];
    try {
      final raw = _settingsBox.get('windows_per_app_executables_v1');
      if (raw is List) return raw.map((value) => value.toString()).toList();
    } catch (_) {}
    return const [];
  }

  Future<void> saveWindowsPerAppEnabled(bool value) async {
    if (!_initialized) await init();
    try {
      await _settingsBox.put('windows_per_app_enabled_v1', value);
    } catch (_) {}
  }

  bool getWindowsPerAppEnabled() {
    if (!_initialized) return false;
    try {
      return _settingsBox.get('windows_per_app_enabled_v1') == true;
    } catch (_) {
      return false;
    }
  }

  // --- Harmoney Flowline & Source Update Metadata ---
  Future<void> saveHarmoneyUpdateMetadata({
    required DateTime timestamp,
    required String status,
    String? errorMessage,
    required int activeFeeds,
    required int totalFeeds,
  }) async {
    if (!_initialized) await init();
    try {
      await _settingsBox.put(
        'harmoney_last_update_ms',
        timestamp.millisecondsSinceEpoch,
      );
      await _settingsBox.put('harmoney_last_status', status);
      await _settingsBox.put('harmoney_last_error', errorMessage ?? '');
      await _settingsBox.put('harmoney_active_feeds', activeFeeds);
      await _settingsBox.put('harmoney_total_feeds', totalFeeds);
    } catch (_) {}
  }

  Map<String, dynamic> getHarmoneyUpdateMetadata() {
    if (!_initialized) {
      return {
        'lastUpdate': null,
        'status': 'idle',
        'error': null,
        'activeFeeds': 0,
        'totalFeeds': 0,
      };
    }
    try {
      final ms = _settingsBox.get('harmoney_last_update_ms') as int?;
      final status =
          _settingsBox.get('harmoney_last_status') as String? ?? 'idle';
      final err = _settingsBox.get('harmoney_last_error') as String?;
      final active = _settingsBox.get('harmoney_active_feeds') as int? ?? 0;
      final total = _settingsBox.get('harmoney_total_feeds') as int? ?? 0;
      return {
        'lastUpdate': ms != null
            ? DateTime.fromMillisecondsSinceEpoch(ms)
            : null,
        'status': status,
        'error': (err != null && err.isNotEmpty) ? err : null,
        'activeFeeds': active,
        'totalFeeds': total,
      };
    } catch (_) {
      return {
        'lastUpdate': null,
        'status': 'idle',
        'error': null,
        'activeFeeds': 0,
        'totalFeeds': 0,
      };
    }
  }

  Future<void> saveCachedHarmoneyFlowline(String flowlineJson) async {
    if (!_initialized) await init();
    try {
      await _settingsBox.put('harmoney_cached_flowline', flowlineJson);
    } catch (_) {}
  }

  String? getCachedHarmoneyFlowline() {
    if (!_initialized) return null;
    try {
      final val = _settingsBox.get('harmoney_cached_flowline');
      return val is String && val.isNotEmpty ? val : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    if (!_initialized) return;
    await _serversBox.clear();
    await _iconsBox.clear();
    await _trafficBox.clear();
    await _settingsBox.clear();
  }
}
