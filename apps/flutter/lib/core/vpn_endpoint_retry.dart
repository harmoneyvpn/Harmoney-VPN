import 'dart:async';

/// Retry only transport timeouts; authentication and certificate errors escape.
/// The connection callback must enforce the supplied per-attempt timeout.
Future<T> retryVpnEndpoint<T>({
  required Future<T> Function(Duration timeout) connect,
  required Future<void> Function() beforeRetry,
  required bool Function() isCurrent,
  int maximumAttempts = 4,
  Duration budget = const Duration(seconds: 150),
}) async {
  final watch = Stopwatch()..start();
  for (var attempt = 0; attempt < maximumAttempts; attempt++) {
    if (!isCurrent()) throw StateError('VPN_CANCELLED');
    final remaining = budget - watch.elapsed;
    if (remaining <= Duration.zero) {
      throw TimeoutException('VPN endpoint retry budget exhausted');
    }
    final timeout = remaining < const Duration(seconds: 85)
        ? remaining
        : const Duration(seconds: 85);
    try {
      return await connect(timeout);
    } on TimeoutException {
      if (attempt + 1 == maximumAttempts ||
          !isCurrent() ||
          watch.elapsed >= budget) {
        rethrow;
      }
      await beforeRetry();
    }
  }
  throw StateError('No VPN endpoint attempt was configured');
}
