import 'dart:io';

/// Registers app startup with Windows Task Scheduler for the current user.
class WindowsStartupScheduler {
  WindowsStartupScheduler._();

  static const _taskName = 'HarmoneyLaunchAtLogon';

  static Future<bool> isEnabled() async {
    if (!Platform.isWindows) return false;
    final result = await Process.run('schtasks.exe', [
      '/Query',
      '/TN',
      _taskName,
    ]);
    return result.exitCode == 0;
  }

  static Future<void> setEnabled(
    bool enabled, {
    bool startMinimized = false,
  }) async {
    if (!Platform.isWindows) return;
    if (!enabled) {
      if (!await isEnabled()) return;
      final result = await Process.run('schtasks.exe', [
        '/Delete',
        '/TN',
        _taskName,
        '/F',
      ]);
      if (result.exitCode != 0) {
        throw ProcessException(
          'schtasks.exe',
          const ['/Delete', '/TN', _taskName],
          result.stderr.toString(),
          result.exitCode,
        );
      }
      return;
    }

    final executable = Platform.resolvedExecutable;
    final executableDirectory = File(executable).parent.path;
    String quotePowerShell(String value) => "'${value.replaceAll("'", "''")}'";
    final startMinimizedArgument =
        startMinimized ? " -ArgumentList '--start-minimized'" : '';
    final launchCommand =
        'Start-Process -FilePath ${quotePowerShell(executable)} '
        '-WorkingDirectory ${quotePowerShell(executableDirectory)}$startMinimizedArgument';
    final result = await Process.run('schtasks.exe', [
      '/Create',
      '/TN',
      _taskName,
      '/TR',
      'powershell.exe -NoProfile -WindowStyle Hidden -Command "$launchCommand"',
      '/SC',
      'ONLOGON',
      '/F',
      '/RL',
      'LIMITED',
      '/IT',
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'schtasks.exe',
        const ['/Create', '/TN', _taskName],
        result.stderr.toString(),
        result.exitCode,
      );
    }
  }
}
