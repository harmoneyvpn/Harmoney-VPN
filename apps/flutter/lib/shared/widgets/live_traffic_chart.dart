import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/traffic_analytics_service.dart';
import 'package:harmoney_vpn_client/app/localized_text.dart';

class LiveTrafficChart extends StatefulWidget {
  const LiveTrafficChart({
    super.key,
    required this.isConnected,
    this.currentDownloadMbps,
    this.currentUploadMbps,
  });

  final bool isConnected;
  final double? currentDownloadMbps;
  final double? currentUploadMbps;

  @override
  State<LiveTrafficChart> createState() => _LiveTrafficChartState();
}

class _LiveTrafficChartState extends State<LiveTrafficChart> {
  static const int _maxDataPoints = 20;
  StreamSubscription<TrafficDataSnapshot>? _trafficSub;
  TrafficDataSnapshot _snapshot = TrafficAnalyticsService.instance.current;
  final List<FlSpot> _downloadSpots = [];
  final List<FlSpot> _uploadSpots = [];
  Timer? _timer;
  double _timeCursor = 0;
  int _lastDownloadBps = 0;
  int _lastUploadBps = 0;

  @override
  void initState() {
    super.initState();
    TrafficAnalyticsService.instance.init();
    _trafficSub = TrafficAnalyticsService.instance.stream.listen((snapshot) {
      if (mounted) setState(() => _snapshot = snapshot);
    });
    // Initialize initial flat line
    for (int i = 0; i < _maxDataPoints; i++) {
      _downloadSpots.add(FlSpot(i.toDouble(), 0));
      _uploadSpots.add(FlSpot(i.toDouble(), 0));
    }
    _timeCursor = (_maxDataPoints - 1).toDouble();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    _timeCursor += 1;

    final hasLiveTraffic = widget.isConnected &&
        (_snapshot.isConnected ||
            widget.currentDownloadMbps != null ||
            widget.currentUploadMbps != null);
    final rxBps = hasLiveTraffic
        ? (widget.currentDownloadMbps != null
            ? (widget.currentDownloadMbps! * 1024 * 1024 / 8).round()
            : _snapshot.rxBps)
        : 0;
    final txBps = hasLiveTraffic
        ? (widget.currentUploadMbps != null
            ? (widget.currentUploadMbps! * 1024 * 1024 / 8).round()
            : _snapshot.txBps)
        : 0;
    final newDown = rxBps * 8 / (1024 * 1024);
    final newUp = txBps * 8 / (1024 * 1024);

    _lastDownloadBps = rxBps;
    _lastUploadBps = txBps;

    setState(() {
      _downloadSpots.add(FlSpot(_timeCursor, newDown));
      _uploadSpots.add(FlSpot(_timeCursor, newUp));

      if (_downloadSpots.length > _maxDataPoints) {
        _downloadSpots.removeAt(0);
        _uploadSpots.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _trafficSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    final minX = _downloadSpots.isNotEmpty ? _downloadSpots.first.x : 0.0;
    final maxX = _downloadSpots.isNotEmpty
        ? _downloadSpots.last.x
        : _maxDataPoints.toDouble();

    double maxY = 10.0;
    for (var i = 0; i < _downloadSpots.length; i++) {
      if (_downloadSpots[i].y > maxY) maxY = _downloadSpots[i].y;
      if (_uploadSpots[i].y > maxY) maxY = _uploadSpots[i].y;
    }
    maxY = (maxY * 1.3).ceilToDouble();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with live stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isConnected && _snapshot.isConnected
                          ? const Color(0xFF00D4AA)
                          : Colors.white38,
                      boxShadow: widget.isConnected && _snapshot.isConnected
                          ? [
                              const BoxShadow(
                                color: Color(0xFF00D4AA),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  LocalizedText(
                    isFa ? 'ترافیک و سرعت زنده' : 'Live Speed & Traffic',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Download Chip
                  _TrafficBadge(
                    label: isFa ? 'دانلود' : 'DL',
                    value: TrafficDataSnapshot.formatSpeed(_lastDownloadBps),
                    color: const Color(0xFF00D4AA),
                    icon: Icons.arrow_downward_rounded,
                  ),
                  const SizedBox(width: 10),
                  // Upload Chip
                  _TrafficBadge(
                    label: isFa ? 'آپلود' : 'UL',
                    value: TrafficDataSnapshot.formatSpeed(_lastUploadBps),
                    color: const Color(0xFF76F959),
                    icon: Icons.arrow_upward_rounded,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Chart
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  // Download Line (Neon Turquoise)
                  LineChartBarData(
                    spots: _downloadSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF00D4AA),
                    barWidth: 2.8,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00D4AA).withValues(alpha: 0.28),
                          const Color(0xFF00D4AA).withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                  // Upload Line (Neon Purple / Green)
                  LineChartBarData(
                    spots: _uploadSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF76F959),
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF76F959).withValues(alpha: 0.18),
                          const Color(0xFF76F959).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficBadge extends StatelessWidget {
  const _TrafficBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          LocalizedText(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
