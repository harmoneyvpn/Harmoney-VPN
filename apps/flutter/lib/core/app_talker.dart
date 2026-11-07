import 'package:talker_flutter/talker_flutter.dart';

class AppTalker {
  AppTalker._();

  static final Talker instance = TalkerFlutter.init(
    settings: TalkerSettings(maxHistoryItems: 1000, useConsoleLogs: true),
  );

  static void info(String message) {
    instance.info(message);
  }

  static void debug(String message) {
    instance.debug(message);
  }

  static void warning(String message) {
    instance.warning(message);
  }

  static void error(
    String message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    instance.error(message, exception, stackTrace);
  }

  static void vpnEvent(String event, [Map<String, dynamic>? details]) {
    final detailStr = details != null ? ' | details: $details' : '';
    instance.info('[VPN] $event$detailStr');
  }

  static void networkEvent(String event) {
    instance.info('[NETWORK] $event');
  }
}
