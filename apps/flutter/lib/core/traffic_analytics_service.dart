import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'linux_platform_controls.dart';
import 'mobile_vpn_bridge.dart';

class TrafficSpeedPoint {
  final double timestamp;
  final double downloadMbps;
  final double uploadMbps;

  const TrafficSpeedPoint({
    required this.timestamp,
    required this.downloadMbps,
    required this.uploadMbps,
  });
}

class TrafficDataSnapshot {
  final bool isConnected;
  final int rxBps; // Bytes per second download
  final int txBps; // Bytes per second upload
  final int sessionRxBytes;
  final int sessionTxBytes;
  final int todayRxBytes;
  final int todayTxBytes;
  final int monthRxBytes;
  final int monthTxBytes;
  final int totalRxBytes;
  final int totalTxBytes;
  final int peakDownloadBps;
  final int peakUploadBps;
  final double? quotaLimitGb;
  final Duration connectedDuration;
  final List<TrafficSpeedPoint> recentHistory;

  const TrafficDataSnapshot({
    this.isConnected = false,
    this.rxBps = 0,
    this.txBps = 0,
    this.sessionRxBytes = 0,
    this.sessionTxBytes = 0,
    this.todayRxBytes = 0,
    this.todayTxBytes = 0,
    this.monthRxBytes = 0,
    this.monthTxBytes = 0,
    this.totalRxBytes = 0,
    this.totalTxBytes = 0,
    this.peakDownloadBps = 0,
    this.peakUploadBps = 0,
    this.quotaLimitGb,
    this.connectedDuration = Duration.zero,
    this.recentHistory = const [],
  });

  double get downloadMbps => (rxBps * 8.0) / (1024 * 1024);
  double get uploadMbps => (txBps * 8.0) / (1024 * 1024);
  double get peakDownloadMbps => (peakDownloadBps * 8.0) / (1024 * 1024);
  double get peakUploadMbps => (peakUploadBps * 8.0) / (1024 * 1024);

  int get sessionTotalBytes => sessionRxBytes + sessionTxBytes;
  int get todayTotalBytes => todayRxBytes + todayTxBytes;
  int get monthTotalBytes => monthRxBytes + monthTxBytes;
  int get lifetimeTotalBytes => totalRxBytes + totalTxBytes;

  double get quotaUsedPercent {
    if (quotaLimitGb == null || quotaLimitGb! <= 0) return 0.0;
    final limitBytes = quotaLimitGb! * 1024 * 1024 * 1024;
    return (monthTotalBytes / limitBytes).clamp(0.0, 1.0);
  }

  bool get isQuotaExceeded =>
      quotaLimitGb != null &&
      quotaLimitGb! > 0 &&
      monthTotalBytes >= (quotaLimitGb! * 1024 * 1024 * 1024);

  static String formatBytes(num bytes) {
    var val = bytes.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var idx = 0;
    while (val >= 1024 && idx < units.length - 1) {
      val /= 1024;
      idx++;
    }
    return '${val.toStringAsFixed(idx == 0 ? 0 : 1)} ${units[idx]}';
  }

  static String formatSpeed(num bps) {
    final mbps = (bps * 8.0) / (1024 * 1024);
    if (mbps >= 1.0) {
      return '${mbps.toStringAsFixed(1)} Mbps';
    }
    final kbps = (bps * 8.0) / 1024;
    if (kbps >= 1.0) {
      return '${kbps.toStringAsFixed(0)} Kbps';
    }
    return '${formatBytes(bps)}/s';
  }
}

class TrafficAnalyticsService {
  TrafficAnalyticsService._();
  static final TrafficAnalyticsService instance = TrafficAnalyticsService._();

  static const String _prefQuotaKey = 'traffic_quota_limit_gb';
  static const String _prefTodayKeyPrefix = 'traffic_today_';
  static const String _prefMonthKeyPrefix = 'traffic_month_';
  static const String _prefTotalRxKey = 'traffic_total_rx';
  static const String _prefTotalTxKey = 'traffic_total_tx';

  final LinuxPlatformControls _linuxControls = LinuxPlatformControls();
  final StreamController<TrafficDataSnapshot> _controller =
      StreamController<TrafficDataSnapshot>.broadcast();

  TrafficDataSnapshot _current = const TrafficDataSnapshot();
  Timer? _ticker;
  DateTime? _connectedSince;
  bool _vpnConnected = false;

  int _lastRawRx = -1;
  int _lastRawTx = -1;
  DateTime? _lastSampleTime;
  String? _lastCounterSource;

  int _sessionRx = 0;
  int _sessionTx = 0;
  int _todayRx = 0;
  int _todayTx = 0;
  int _monthRx = 0;
  int _monthTx = 0;
  int _lifetimeRx = 0;
  int _lifetimeTx = 0;
  int _peakRxBps = 0;
  int _peakTxBps = 0;
  double? _quotaLimitGb;

  final List<TrafficSpeedPoint> _history = [];
  double _historyCursor = 0;

  Stream<TrafficDataSnapshot> get stream => _controller.stream;
  TrafficDataSnapshot get current => _current;

  Future<void> init() async {
    await _loadPersistedCounters();
    _emitSnapshot(0, 0);
    startMonitoring();
  }

  void startMonitoring() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void stopMonitoring() {
    _ticker?.cancel();
    _ticker = null;
  }

  void onVpnStatusChanged({required bool isConnected}) {
    if (_vpnConnected == isConnected) return;
    _vpnConnected = isConnected;
    // The first counter sample after a state transition is a baseline. This
    // avoids reporting traffic accumulated before the VPN session as live use.
    _lastRawRx = -1;
    _lastRawTx = -1;
    _lastSampleTime = null;
    _lastCounterSource = null;
    if (isConnected) {
      _connectedSince = DateTime.now();
      _sessionRx = 0;
      _sessionTx = 0;
    } else {
      _connectedSince = null;
    }
    if (Platform.isAndroid) {
      if (isConnected) {
        startMonitoring();
      } else {
        stopMonitoring();
        _emitSnapshot(0, 0);
      }
    }
  }

  Future<void> setQuotaLimit(double? gb) async {
    _quotaLimitGb = gb;
    final prefs = await SharedPreferences.getInstance();
    if (gb == null || gb <= 0) {
      await prefs.remove(_prefQuotaKey);
    } else {
      await prefs.setDouble(_prefQuotaKey, gb);
    }
    _emitSnapshot(0, 0);
  }

  Future<void> _loadPersistedCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _quotaLimitGb = prefs.getDouble(_prefQuotaKey);

      final now = DateTime.now();
      final dayKey = '$_prefTodayKeyPrefix${now.year}_${now.month}_${now.day}';
      final monthKey = '$_prefMonthKeyPrefix${now.year}_${now.month}';

      _todayRx = prefs.getInt('${dayKey}_rx') ?? 0;
      _todayTx = prefs.getInt('${dayKey}_tx') ?? 0;
      _monthRx = prefs.getInt('${monthKey}_rx') ?? 0;
      _monthTx = prefs.getInt('${monthKey}_tx') ?? 0;
      _lifetimeRx = prefs.getInt(_prefTotalRxKey) ?? 0;
      _lifetimeTx = prefs.getInt(_prefTotalTxKey) ?? 0;
    } catch (_) {}
  }

  Future<void> _savePersistedCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dayKey = '$_prefTodayKeyPrefix${now.year}_${now.month}_${now.day}';
      final monthKey = '$_prefMonthKeyPrefix${now.year}_${now.month}';

      await prefs.setInt('${dayKey}_rx', _todayRx);
      await prefs.setInt('${dayKey}_tx', _todayTx);
      await prefs.setInt('${monthKey}_rx', _monthRx);
      await prefs.setInt('${monthKey}_tx', _monthTx);
      await prefs.setInt(_prefTotalRxKey, _lifetimeRx);
      await prefs.setInt(_prefTotalTxKey, _lifetimeTx);
    } catch (_) {}
  }

  Future<void> _tick() async {
    try {
      int rxBps = 0;
      int txBps = 0;

      if (Platform.isWindows) {
        final pair = await _sampleWindowsNetwork();
        if (pair != null) {
          final now = DateTime.now();
          if (_lastRawRx >= 0 && _lastRawTx >= 0 && _lastSampleTime != null) {
            final elapsed =
                now.difference(_lastSampleTime!).inMilliseconds / 1000.0;
            if (elapsed > 0.2) {
              final diffRx = pair.rx - _lastRawRx;
              final diffTx = pair.tx - _lastRawTx;

              if (diffRx >= 0 && diffTx >= 0) {
                rxBps = (diffRx / elapsed).round();
                txBps = (diffTx / elapsed).round();

                _sessionRx += diffRx;
                _sessionTx += diffTx;
                _todayRx += diffRx;
                _todayTx += diffTx;
                _monthRx += diffRx;
                _monthTx += diffTx;
                _lifetimeRx += diffRx;
                _lifetimeTx += diffTx;
              }
            }
          }
          _lastRawRx = pair.rx;
          _lastRawTx = pair.tx;
          _lastSampleTime = now;
        }
      } else if (Platform.isLinux) {
        final data = await _linuxControls.trafficSnapshot();
        rxBps = (data['rx_bps'] as num?)?.toInt() ?? 0;
        txBps = (data['tx_bps'] as num?)?.toInt() ?? 0;
        _todayRx = (data['day_rx_bytes'] as num?)?.toInt() ?? _todayRx;
        _todayTx = (data['day_tx_bytes'] as num?)?.toInt() ?? _todayTx;
        _monthRx = (data['month_rx_bytes'] as num?)?.toInt() ?? _monthRx;
        _monthTx = (data['month_tx_bytes'] as num?)?.toInt() ?? _monthTx;
        _sessionRx = (data['rx_bytes'] as num?)?.toInt() ?? _sessionRx;
        _sessionTx = (data['tx_bytes'] as num?)?.toInt() ?? _sessionTx;
      } else if (Platform.isAndroid) {
        if (!_vpnConnected) {
          _emitSnapshot(0, 0);
          return;
        }
        final data = await MobileVpnBridge.trafficSnapshot();
        final rawRx = (data['rx_bytes'] as num?)?.toInt() ?? -1;
        final rawTx = (data['tx_bytes'] as num?)?.toInt() ?? -1;
        final source = data['source']?.toString();
        final now = DateTime.now();
        if (_vpnConnected &&
            rawRx >= 0 &&
            rawTx >= 0 &&
            _lastRawRx >= 0 &&
            _lastRawTx >= 0 &&
            _lastSampleTime != null &&
            (_lastCounterSource == null || _lastCounterSource == source)) {
          final elapsed =
              now.difference(_lastSampleTime!).inMilliseconds / 1000;
          final deltaRx = rawRx - _lastRawRx;
          final deltaTx = rawTx - _lastRawTx;
          if (elapsed > 0.2 && deltaRx >= 0 && deltaTx >= 0) {
            rxBps = (deltaRx / elapsed).round();
            txBps = (deltaTx / elapsed).round();
            _sessionRx += deltaRx;
            _sessionTx += deltaTx;
            _lifetimeRx += deltaRx;
            _lifetimeTx += deltaTx;
          }
        }
        if (rawRx >= 0 && rawTx >= 0) {
          _lastRawRx = rawRx;
          _lastRawTx = rawTx;
          _lastSampleTime = now;
          _lastCounterSource = source;
        }
        _todayRx = (data['day_rx_bytes'] as num?)?.toInt() ?? _todayRx;
        _todayTx = (data['day_tx_bytes'] as num?)?.toInt() ?? _todayTx;
        _monthRx = (data['month_rx_bytes'] as num?)?.toInt() ?? _monthRx;
        _monthTx = (data['month_tx_bytes'] as num?)?.toInt() ?? _monthTx;
      }

      // Update peak speeds
      if (rxBps > _peakRxBps) _peakRxBps = rxBps;
      if (txBps > _peakTxBps) _peakTxBps = txBps;

      _emitSnapshot(rxBps, txBps);

      // Periodically persist counters every 10 ticks
      if ((_historyCursor.toInt() % 10) == 0) {
        unawaited(_savePersistedCounters());
      }
    } catch (e) {
      if (kDebugMode) print('Traffic ticker error: $e');
    }
  }

  void _emitSnapshot(int rxBps, int txBps) {
    _historyCursor += 1.0;
    final dlMbps = (rxBps * 8.0) / (1024 * 1024);
    final ulMbps = (txBps * 8.0) / (1024 * 1024);

    _history.add(TrafficSpeedPoint(
      timestamp: _historyCursor,
      downloadMbps: dlMbps,
      uploadMbps: ulMbps,
    ));
    if (_history.length > 30) {
      _history.removeAt(0);
    }

    final duration = _connectedSince != null
        ? DateTime.now().difference(_connectedSince!)
        : Duration.zero;

    _current = TrafficDataSnapshot(
      isConnected: _vpnConnected,
      rxBps: rxBps,
      txBps: txBps,
      sessionRxBytes: _sessionRx,
      sessionTxBytes: _sessionTx,
      todayRxBytes: _todayRx,
      todayTxBytes: _todayTx,
      monthRxBytes: _monthRx,
      monthTxBytes: _monthTx,
      totalRxBytes: _lifetimeRx,
      totalTxBytes: _lifetimeTx,
      peakDownloadBps: _peakRxBps,
      peakUploadBps: _peakTxBps,
      quotaLimitGb: _quotaLimitGb,
      connectedDuration: duration,
      recentHistory: List.unmodifiable(_history),
    );

    _controller.add(_current);
  }

  /// Fast Windows network counters via netstat -e
  static Future<({int rx, int tx})?> _sampleWindowsNetwork() async {
    try {
      final res = await Process.run('netstat', ['-e']);
      if (res.exitCode == 0) {
        final lines = (res.stdout as String).split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('Bytes')) {
            final parts = trimmed.split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              final rx = int.tryParse(parts[1]);
              final tx = int.tryParse(parts[2]);
              if (rx != null && tx != null) {
                return (rx: rx, tx: tx);
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
