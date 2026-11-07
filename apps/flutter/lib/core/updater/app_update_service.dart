import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_update_dialog.dart';
import 'app_update_info.dart';

/// Ultra-reliable in-app GitHub update service for Harmoney VPN.
/// Checks GitHub Releases, parses SemVer, detects target architecture/platform,
/// downloads installers with live progress metrics, and launches native platform updates.
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  /// Default GitHub repository slugs
  static const String primaryRepo = 'harmoneyvpn/Harmoney-VPN';
  static const String fallbackRepo = 'harmoneyvpn/Harmoney-VPN-PRO';

  static const String _lastCheckKey = 'harmoney_last_update_check_epoch';
  static const MethodChannel _androidChannel =
      MethodChannel('io.harmoney.client/android');
  static const MethodChannel _vpnChannel = MethodChannel('com.harmoney.vpn');

  final ValueNotifier<AppUpdateInfo?> updateAvailableNotifier =
      ValueNotifier<AppUpdateInfo?>(null);
  final ValueNotifier<bool> isCheckingNotifier = ValueNotifier<bool>(false);

  late final Dio _dio = _createSecureDio();

  static Dio _createSecureDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Harmoney-VPN-Client',
        },
      ),
    );
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) => 'DIRECT';
        client.badCertificateCallback = (cert, host, port) => false;
        return client;
      },
    );
    return dio;
  }

  /// Automatically check for update on app startup (debounced by 6 hours unless forced)
  Future<void> autoCheckOnStartup(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Check once every 6 hours
      if (now - lastCheck < 6 * 3600 * 1000) {
        return;
      }
      await prefs.setInt(_lastCheckKey, now);

      final update = await checkForUpdate();
      if (update != null && update.hasUpdate && context.mounted) {
        AppUpdateDialog.show(context, update);
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Auto-check ignored error: $e');
    }
  }

  /// Manually checks GitHub releases for an update
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    if (isCheckingNotifier.value) return updateAvailableNotifier.value;
    isCheckingNotifier.value = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVerStr = '${packageInfo.version}+${packageInfo.buildNumber}';

      // 1. Fetch release payload from GitHub
      final releaseData = await _fetchLatestRelease();
      if (releaseData == null) {
        updateAvailableNotifier.value = null;
        return null;
      }

      final tagName = releaseData['tag_name']?.toString() ?? '';
      final releaseTitle = releaseData['name']?.toString() ?? tagName;
      final releaseNotes = releaseData['body']?.toString() ?? '';
      final htmlUrl = releaseData['html_url']?.toString() ?? '';
      final publishedAtStr = releaseData['published_at']?.toString();
      final publishedAt =
          publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      final latestVerStr =
          tagName.startsWith('v') ? tagName.substring(1) : tagName;
      final hasNewer =
          _isVersionNewer(latestVerStr, packageInfo.version) || force;

      // 2. Select appropriate platform installer asset
      final rawAssets = releaseData['assets'] as List<dynamic>? ?? [];
      final matchedAsset = await _resolvePlatformAsset(rawAssets);

      final info = AppUpdateInfo(
        currentVersion: packageInfo.version.isNotEmpty
            ? packageInfo.version
            : currentVerStr,
        latestVersion: latestVerStr,
        tagName: tagName,
        releaseTitle: releaseTitle,
        releaseNotes: releaseNotes,
        releaseDate: publishedAt,
        assetName: matchedAsset?['name']?.toString() ?? '',
        downloadUrl: matchedAsset?['browser_download_url']?.toString() ??
            (rawAssets.isNotEmpty
                ? rawAssets.first['browser_download_url']?.toString() ?? ''
                : ''),
        fileSize: (matchedAsset?['size'] as num?)?.toInt() ?? 0,
        hasUpdate: hasNewer,
        htmlUrl: htmlUrl,
      );

      updateAvailableNotifier.value = hasNewer ? info : null;
      return info;
    } catch (e) {
      debugPrint('[AppUpdateService] Check for update failed: $e');
      return null;
    } finally {
      isCheckingNotifier.value = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchLatestRelease() async {
    for (final repo in [primaryRepo, fallbackRepo]) {
      try {
        final url = 'https://api.github.com/repos/$repo/releases/latest';
        final response = await _dio.get<Map<String, dynamic>>(url);
        if (response.statusCode == 200 && response.data != null) {
          return response.data;
        }
      } on DioException catch (e) {
        debugPrint(
            '[AppUpdateService] Failed fetching from $repo: ${e.response?.statusCode}');
      } catch (_) {}
    }
    return null;
  }

  /// Compares semantic versions (e.g. "0.1.1" > "0.1.0")
  bool _isVersionNewer(String latest, String current) {
    try {
      final cleanLatest = latest.split('+').first.trim();
      final cleanCurrent = current.split('+').first.trim();

      final latestParts =
          cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts =
          cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (var i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      final latestBuild = latest.contains('+')
          ? int.tryParse(latest.split('+').last) ?? 0
          : 0;
      final currentBuild = current.contains('+')
          ? int.tryParse(current.split('+').last) ?? 0
          : 0;
      return latestBuild > currentBuild;
    } catch (_) {
      return latest != current;
    }
  }

  /// Identifies the correct asset based on OS and architecture
  Future<Map<String, dynamic>?> _resolvePlatformAsset(
      List<dynamic> assets) async {
    if (assets.isEmpty) return null;

    if (Platform.isAndroid) {
      String preferredAbi = 'arm64-v8a';
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final supported = androidInfo.supportedAbis;
        if (supported.isNotEmpty) {
          preferredAbi = supported.first.toLowerCase();
        }
      } catch (_) {}

      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.apk') && name.contains(preferredAbi)) {
          return raw as Map<String, dynamic>;
        }
      }

      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.apk')) {
          return raw as Map<String, dynamic>;
        }
      }
    } else if (Platform.isWindows) {
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.exe') &&
            (name.contains('setup') || name.contains('windows'))) {
          return raw as Map<String, dynamic>;
        }
      }
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.exe')) return raw as Map<String, dynamic>;
      }
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.zip') && name.contains('windows')) {
          return raw as Map<String, dynamic>;
        }
      }
    } else if (Platform.isLinux) {
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.appimage')) return raw as Map<String, dynamic>;
      }
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.deb')) return raw as Map<String, dynamic>;
      }
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.zip') && name.contains('linux')) {
          return raw as Map<String, dynamic>;
        }
      }
    } else if (Platform.isMacOS) {
      for (final raw in assets) {
        final name = (raw['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.dmg') || name.endsWith('.pkg')) {
          return raw as Map<String, dynamic>;
        }
      }
    }

    return assets.first as Map<String, dynamic>?;
  }

  /// Downloads the installer asset with live progress tracking
  Future<File> downloadUpdate(
    AppUpdateInfo info, {
    void Function(double progress, int received, int total, double speedMBs)?
        onProgress,
    CancelToken? cancelToken,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = info.assetName.isNotEmpty
        ? info.assetName
        : 'HarmoneyUpdate_${info.latestVersion}${Platform.isWindows ? '.exe' : (Platform.isAndroid ? '.apk' : '')}';
    final savePath = '${tempDir.path}${Platform.pathSeparator}$fileName';

    final file = File(savePath);
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } catch (_) {}
    }

    int lastBytes = 0;
    int lastTime = DateTime.now().millisecondsSinceEpoch;
    double currentSpeed = 0.0;

    await _dio.download(
      info.downloadUrl,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final timeDiff = now - lastTime;
          if (timeDiff >= 400) {
            final bytesDiff = received - lastBytes;
            currentSpeed = (bytesDiff / (timeDiff / 1000.0)) / (1024 * 1024);
            lastTime = now;
            lastBytes = received;
          }
          final progress = (received / total).clamp(0.0, 1.0);
          onProgress?.call(progress, received, total, currentSpeed);
        }
      },
    );

    if (!file.existsSync() || file.lengthSync() == 0) {
      throw StateError('Downloaded update file is empty or missing.');
    }

    return file;
  }

  /// Launches platform native package / installer execution
  Future<void> installUpdate(File file) async {
    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('installApk', {
          'filePath': file.absolute.path,
        });
      } on PlatformException {
        await _vpnChannel.invokeMethod('installApk', {
          'filePath': file.absolute.path,
        });
      }
    } else if (Platform.isWindows) {
      await Process.start(
        file.path,
        [],
        mode: ProcessStartMode.detached,
      );
      Future.delayed(const Duration(milliseconds: 600), () => exit(0));
    } else if (Platform.isLinux) {
      if (file.path.toLowerCase().endsWith('.appimage')) {
        Process.runSync('chmod', ['+x', file.path]);
        await Process.start(file.path, [], mode: ProcessStartMode.detached);
      } else if (file.path.toLowerCase().endsWith('.deb')) {
        await Process.start('xdg-open', [file.path],
            mode: ProcessStartMode.detached);
      } else {
        await Process.start('xdg-open', [file.parent.path],
            mode: ProcessStartMode.detached);
      }
    } else if (Platform.isMacOS) {
      await Process.start('open', [file.path], mode: ProcessStartMode.detached);
    }
  }
}
