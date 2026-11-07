import 'dart:async';

import 'package:flutter/foundation.dart';

class VpnDebugLogEntry {
  const VpnDebugLogEntry({
    required this.time,
    required this.level,
    required this.provider,
    required this.protocol,
    required this.message,
  });

  final DateTime time;
  final String level;
  final String provider;
  final String protocol;
  final String message;

  @override
  String toString() =>
      '${time.toIso8601String()} [$level] [$provider/$protocol] $message';
}

/// Bounded in-memory diagnostics shared by every VPN backend.
class VpnDebugLogService {
  VpnDebugLogService._();

  static final VpnDebugLogService instance = VpnDebugLogService._();
  static const int _maxEntries = 1200;

  final List<VpnDebugLogEntry> _entries = [];
  final StreamController<VpnDebugLogEntry> _events =
      StreamController<VpnDebugLogEntry>.broadcast();

  List<VpnDebugLogEntry> get entries => List.unmodifiable(_entries);
  Stream<VpnDebugLogEntry> get events => _events.stream;

  void record({
    required String level,
    required String message,
    String provider = 'app',
    String protocol = '-',
  }) {
    if (!kDebugMode) return;
    final entry = VpnDebugLogEntry(
      time: DateTime.now(),
      level: level.toUpperCase(),
      provider: _cleanLabel(provider),
      protocol: _cleanLabel(protocol),
      message: _redact(message),
    );
    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    // flutter run streams Dart stdout to its attached terminal. Keep this
    // alongside the in-app buffer so Windows debug sessions can be diagnosed
    // live even when the UI is difficult to reach.
    debugPrintSynchronously(entry.toString());
    _events.add(entry);
  }

  void clear() => _entries.clear();

  static String _cleanLabel(String input) =>
      _redact(input).replaceAll(RegExp(r'[\r\n\t]'), ' ').trim();

  static String _redact(String input) {
    var value = input;
    value = value.replaceAll(
      RegExp(r'(://)[^/@\s]+@', caseSensitive: false),
      r'$1<redacted>@',
    );
    value = value.replaceAll(
      RegExp(
        r'"(password|passwd|token|access[_-]?token|refresh[_-]?token|secret|authorization|api[_-]?key|private[_-]?key)"\s*:\s*"[^"]*"',
        caseSensitive: false,
      ),
      r'"$1":"<redacted>"',
    );
    value = value.replaceAll(
      RegExp(
        r'(password|passwd|token|access[_-]?token|refresh[_-]?token|secret|authorization|api[_-]?key|private[_-]?key)\s*[:=]\s*[^\s,&;]+',
        caseSensitive: false,
      ),
      r'$1=<redacted>',
    );
    value = value.replaceAll(
      RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
      '<email>',
    );
    return value;
  }
}
