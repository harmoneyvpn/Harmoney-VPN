import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager_linux/workmanager_linux.dart';

import 'harmoney_subscription_service.dart';

/// Keeps subscription refreshes scheduled by the host OS when the UI is closed.
class HarmoneySubscriptionRefreshScheduler {
  HarmoneySubscriptionRefreshScheduler._();

  static final instance = HarmoneySubscriptionRefreshScheduler._();
  static const taskName = 'harmoneySubscriptionRefresh';
  static const taskId = 'io.harmoney.client.subscription-refresh';
  bool _workmanagerInitialized = false;
  bool _scheduled = false;
  bool _headless = false;

  void setHeadless(bool value) => _headless = value;

  Future<void> sync({required bool hasSubscriptions}) async {
    if (_headless || kIsWeb) return;
    try {
      if (Platform.isWindows) {
        await _syncWindows(hasSubscriptions);
      } else if (Platform.isAndroid || Platform.isLinux) {
        if (!_workmanagerInitialized) {
          await Workmanager().initialize(subscriptionRefreshDispatcher);
          _workmanagerInitialized = true;
        }
        if (_scheduled == hasSubscriptions) return;
        if (hasSubscriptions) {
          await Workmanager().registerPeriodicTask(
            taskId,
            taskName,
            frequency: const Duration(hours: 6),
            existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
            constraints: Constraints(networkType: NetworkType.connected),
          );
        } else {
          await Workmanager().cancelByUniqueName(taskId);
        }
        _scheduled = hasSubscriptions;
      }
    } catch (error) {
      // A missing Linux systemd user session or restricted scheduler must not
      // prevent the app from showing or refreshing subscriptions manually.
      debugPrint('Subscription background scheduling unavailable: $error');
    }
  }

  Future<void> _syncWindows(bool enabled) async {
    const task = 'HarmoneySubscriptionRefresh';
    await Process.run('schtasks.exe', [
      '/Delete',
      '/TN',
      r'Harmoney\SubscriptionRefresh',
      '/F',
    ]);
    if (!enabled) {
      await Process.run('schtasks.exe', ['/Delete', '/TN', task, '/F']);
      _scheduled = false;
      return;
    }
    if (_scheduled) return;
    final existing = await Process.run('schtasks.exe', ['/Query', '/TN', task]);
    if (existing.exitCode == 0) {
      _scheduled = true;
      return;
    }
    final executable = Platform.resolvedExecutable;
    final created = await Process.run('schtasks.exe', [
      '/Create',
      '/TN',
      task,
      '/TR',
      '"$executable" --subscription-refresh',
      '/SC',
      'HOURLY',
      '/MO',
      '6',
      '/F',
      '/RL',
      'LIMITED',
      '/IT',
    ]);
    if (created.exitCode != 0) {
      throw ProcessException(
        'schtasks.exe',
        const ['/Create'],
        created.stderr.toString(),
        created.exitCode,
      );
    }
    _scheduled = true;
  }
}

@pragma('vm:entry-point')
void subscriptionRefreshDispatcher() {
  if (Platform.isLinux) {
    WorkmanagerLinux.executeTask((task, inputData) async {
      if (task != HarmoneySubscriptionRefreshScheduler.taskName) return true;
      await _refreshSubscriptionsInBackground();
      return true;
    });
    return;
  }
  Workmanager().executeTask((task, inputData) async {
    if (task != HarmoneySubscriptionRefreshScheduler.taskName) return true;
    await _refreshSubscriptionsInBackground();
    return true;
  });
}

Future<void> _refreshSubscriptionsInBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  HarmoneySubscriptionRefreshScheduler.instance.setHeadless(true);
  await HarmoneySubscriptionService.instance.refreshAll();
}
