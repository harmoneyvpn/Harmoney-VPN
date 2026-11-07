import 'package:flutter/services.dart';

/// Minimal desktop settings bridge retained for the public Flutter app.
class HarmoneyVpnMacos {
  const HarmoneyVpnMacos();

  static const MethodChannel _channel = MethodChannel('io.harmoney.client/macos');

  Future<void> setAutoConnect(bool enabled) =>
      _channel.invokeMethod<void>('setAutoConnect', {'enabled': enabled});
}
