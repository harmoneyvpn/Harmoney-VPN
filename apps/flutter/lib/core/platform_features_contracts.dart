import 'dart:async';

abstract interface class LinuxPlatformFeatures {
  Future<Map<String, dynamic>> routerStatus();
  Future<Map<String, dynamic>> guestStatus();
  Future<void> guestStart({required int minutes, required String ssid});
  Future<void> guestStop();
  Future<Map<String, dynamic>> setDevicePolicy({
    required String mac,
    required String policy,
    int? speedLimitKbit,
    int? quotaMb,
    String? quotaAction,
    bool? paused,
  });
  Future<Map<String, dynamic>> removeDevicePolicy(String mac);
  Future<Map<String, dynamic>> splitStatus();
  Future<Map<String, dynamic>> setSplitEnabled(bool enabled);
  Future<Map<String, dynamic>> addSplitRule(String target, String mode);
  Future<Map<String, dynamic>> removeSplitRule(String target);
  Future<List<Map<String, dynamic>>> listDesktopApps();
  Future<Map<String, dynamic>> launchAppDirect(String desktopId);
  Future<Map<String, dynamic>> routingModeStatus();
  Future<Map<String, dynamic>> setRoutingMode(String mode);
  Future<Map<String, dynamic>> rulesUpdate();
  Future<Map<String, dynamic>> rulesStatus();
  Future<Map<String, dynamic>> engineStatus();
  Future<Map<String, dynamic>> candidateStatus();
  Future<Map<String, dynamic>> watchdogStatus();
  Future<Map<String, dynamic>> preflightCheck({String? protocol});
  Future<Map<String, dynamic>> testVpnPermission();
  Future<Map<String, dynamic>> testInternet();
  Future<Map<String, dynamic>> testDns();
  Future<Map<String, dynamic>> testServer(String hostname);
  Future<Map<String, dynamic>> testCredentials();
  Future<String> exportSupportBundle();
  Future<bool> isAlwaysOnVpnActive();
  Future<void> setAlwaysOnVpn(bool enabled);
  Future<Map<String, dynamic>> addSplitAppRule(
    String desktopId,
    String mode, [
    String? name,
  ]);
  Future<Map<String, dynamic>> removeSplitAppRule(String desktopId);
  Stream<String> watchConnectionLogEventStream();
}

abstract interface class AndroidPlatformFeatures {
  Future<void> openVpnSettings();
  Future<bool> isAlwaysOnVpnActive();
  Future<bool> isLockdownActive();
  Future<List<String>> listInstalledAppPackages();
  Future<void> setAppSplitTunneling({
    required List<String> allowedPackages,
    required List<String> disallowedPackages,
  });
  Stream<String> watchConnectionLogEventStream();
  Future<List<String>> getLogs();
  Future<void> clearLogs();
  Future<String> exportSupportBundle();
  Future<Map<String, dynamic>> testVpnPermission();
  Future<Map<String, dynamic>> testInternet();
  Future<Map<String, dynamic>> testDns();
  Future<Map<String, dynamic>> testServer(String hostname);
  Future<Map<String, dynamic>> testCredentials();
}

abstract interface class ApplePlatformFeatures {
  Future<void> setOnDemandEnabled(bool enabled);
  Future<bool> isOnDemandEnabled();
  Future<Map<String, dynamic>> networkExtensionStatus();
}
