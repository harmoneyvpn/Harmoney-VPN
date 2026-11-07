import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Sends process-aware bypass policy to the privileged Windows service.
/// The service applies it independently of the selected VPN protocol.
class WindowsPerAppSplitTunnel {
  static const String _host = '127.0.0.1';
  static const int _port = 47631;

  static Future<void> prepare() async {
    if (!Platform.isWindows) return;
    await _send({'action': 'prepare_per_app'});
  }

  static Future<void> configure({
    required bool enabled,
    required List<String> executables,
  }) async {
    if (!Platform.isWindows) return;
    await _send({
      'action': 'per_app_split',
      'enabled': enabled,
      'interface_index': null,
      'applications': executables,
    });
  }

  static Future<void> _send(Map<String, Object?> payload) async {
    final socket = await Socket.connect(
      _host,
      _port,
      timeout: const Duration(seconds: 3),
    );
    try {
      socket.write('${jsonEncode(payload)}\n');
      await socket.flush();
      final response = await utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .first
          .timeout(const Duration(seconds: 60));
      final result = jsonDecode(response) as Map<String, dynamic>;
      if (result['ok'] != true) {
        throw StateError(
          result['error']?.toString() ??
              'Windows service rejected the per-app split policy',
        );
      }
    } finally {
      socket.destroy();
    }
  }
}
