import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/app_talker.dart';
import 'core/harmoney_vpn_bridge.dart';
import 'core/harmoney_subscription_refresh_scheduler.dart';
import 'core/harmoney_subscription_service.dart';
import 'core/local_cache_service.dart';
import 'core/vpn_debug_log_service.dart';

import 'package:workmanager_linux/workmanager_linux.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

Future<void> main(List<String> args) async {
  if (Platform.isLinux &&
      await WorkmanagerLinux.maybeRunBackgroundTask(
        args,
        subscriptionRefreshDispatcher,
      )) {
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (args.contains('--subscription-refresh')) {
    HarmoneySubscriptionRefreshScheduler.instance.setHeadless(true);
    await HarmoneySubscriptionService.instance.refreshAll();
    exit(0);
  }
  _installDebugErrorLogging();
  VpnDebugLogService.instance.record(
    level: 'INFO',
    provider: 'app',
    protocol: '-',
    message: 'Application started on ${Platform.operatingSystem}',
  );
  runApp(const ProviderScope(child: _AppBootstrap()));
  unawaited(_initializeOptionalServices());
}

void _installDebugErrorLogging() {
  if (!kDebugMode) return;
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    VpnDebugLogService.instance.record(
      level: 'ERROR',
      provider: 'flutter-ui',
      protocol: '-',
      message: '${details.exceptionAsString()}\n${details.stack ?? ''}',
    );
    if (previousFlutterHandler != null) {
      previousFlutterHandler(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    VpnDebugLogService.instance.record(
      level: 'ERROR',
      provider: 'platform',
      protocol: '-',
      message: '$error\n$stackTrace',
    );
    return previousPlatformHandler?.call(error, stackTrace) ?? false;
  };
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<AppState> _appState = AppState.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _appState,
      builder: (context, snapshot) {
        final appState = snapshot.data;
        if (appState != null) return VpnClientApp(appState: appState);
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Color(0xFF092B3B),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocalizedText(
                    'Harmoney',
                    style: TextStyle(
                      color: Color(0xFF61F2C2),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF61F2C2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _initializeOptionalServices() async {
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final cacheDir = await HarmoneyBridge().getSharedDirectory();
      if (cacheDir.isNotEmpty) {
        await HarmoneyBridge().setCacheDir(cacheDir);
      }
    } catch (_) {}
  }

  try {
    await LocalCacheService.instance.init();
    AppTalker.info('Harmoney started with Hive local cache (by Harmoney)');
  } catch (error) {
    AppTalker.warning('LocalCacheService init skipped/failed: $error');
  }
}
