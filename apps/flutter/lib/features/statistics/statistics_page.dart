import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/network_speed_test.dart';
import '../../core/traffic_analytics_service.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class StatisticsPage extends StatefulWidget {
  final bool isEmbedded;

  const StatisticsPage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StreamSubscription<TrafficDataSnapshot>? _trafficSub;
  TrafficDataSnapshot _snapshot = TrafficAnalyticsService.instance.current;
  NetworkSpeedResult? _latestSpeed;

  @override
  void initState() {
    super.initState();
    TrafficAnalyticsService.instance.init();
    _trafficSub = TrafficAnalyticsService.instance.stream.listen((data) {
      if (mounted) {
        setState(() => _snapshot = data);
      }
    });
    _loadLatestSpeed();
  }

  Future<void> _loadLatestSpeed() async {
    try {
      final history = await NetworkSpeedTest.getHistory();
      if (history.isNotEmpty && mounted) {
        setState(() => _latestSpeed = history.first);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _trafficSub?.cancel();
    super.dispose();
  }

  void _showQuotaDialog(bool isPersian) {
    double selectedGb = _snapshot.quotaLimitGb ?? 50.0;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F2B3B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFF00D4AA), width: 1.2),
            ),
            title: Row(
              children: [
                const Icon(Icons.data_usage_rounded, color: Color(0xFF00D4AA)),
                const SizedBox(width: 10),
                LocalizedText(
                  localizedUiText(
                      context,
                      (isPersian
                          ? 'تنظیم سقف مصرف ماهانه'
                          : 'Monthly Data Quota')),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LocalizedText(
                  localizedUiText(
                      context,
                      (isPersian
                          ? 'با رسیدن به این سقف، برنامه به شما هشدار خواهد داد.'
                          : 'You will receive visual alerts when reaching this limit.')),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Center(
                  child: LocalizedText(
                    selectedGb > 0
                        ? '${selectedGb.toStringAsFixed(0)} GB'
                        : (localizedUiText(
                            context,
                            (isPersian
                                ? 'نامحدود (غیرفعال)'
                                : 'Unlimited (Off)'))),
                    style: const TextStyle(
                      color: Color(0xFF61F2C2),
                      fontSize: 26,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Slider(
                  value: selectedGb.clamp(0.0, 200.0),
                  min: 0.0,
                  max: 200.0,
                  divisions: 20,
                  activeColor: const Color(0xFF00D4AA),
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    setDialogState(() => selectedGb = val);
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LocalizedText('0 GB (Off)',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    LocalizedText('50 GB',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    LocalizedText('100 GB',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    LocalizedText('200 GB',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: LocalizedText(
                  localizedUiText(context, (isPersian ? 'انصراف' : 'Cancel')),
                  style: const TextStyle(color: Colors.white60),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: const Color(0xFF07212E),
                ),
                onPressed: () {
                  TrafficAnalyticsService.instance
                      .setQuotaLimit(selectedGb > 0 ? selectedGb : null);
                  Navigator.pop(ctx);
                },
                child: LocalizedText(
                  localizedUiText(
                      context, (isPersian ? 'ذخیره سقف' : 'Save Quota')),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    final s = _snapshot;

    final bodyContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and live active badge
            _buildHeader(isPersian, s.isConnected),
            const SizedBox(height: 18),

            // Live Bandwidth Graph Card
            _buildLiveChartCard(s, isPersian),
            const SizedBox(height: 18),

            // Quota & Data Alert Card
            _buildQuotaCard(s, isPersian),
            const SizedBox(height: 18),

            // Usage 4-Grid Cards (Today, Month, Peak, Lifetime)
            _buildUsageGrid(s, isPersian),
            const SizedBox(height: 18),

            // Session & Speed Benchmark Card
            _buildSessionAndSpeedCard(s, isPersian),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w.clamp(14.0, 28.0),
            vertical: 14.h.clamp(10.0, 22.0),
          ),
          child: bodyContent,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isPersian, bool isConnected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalizedText(
              localizedUiText(context,
                  (isPersian ? 'نمودار و آمار ترافیک' : 'Traffic Analytics')),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp.clamp(17.0, 24.0),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            LocalizedText(
              localizedUiText(
                  context,
                  (isPersian
                      ? 'مانیتورینگ مصرف دیتا، سرعت زنده و سقف ترافیک'
                      : 'Live bandwidth, data accounting & quota')),
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected
                ? const Color(0xFF00D4AA).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnected
                  ? const Color(0xFF00D4AA).withValues(alpha: 0.45)
                  : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? const Color(0xFF00F5B8)
                      : const Color(0xFFFFC46B),
                  boxShadow: [
                    BoxShadow(
                      color: isConnected
                          ? const Color(0xFF00F5B8)
                          : const Color(0xFFFFC46B),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LocalizedText(
                isConnected
                    ? (localizedUiText(context,
                        (isPersian ? 'مانیتورینگ فعال (متصل)' : 'Live Monitoring Active')))
                    : (localizedUiText(context,
                        (isPersian ? 'در انتظار اتصال VPN (استندبای)' : 'Waiting for VPN (Standby)'))),
                style: TextStyle(
                  color: isConnected
                      ? const Color(0xFF00F5B8)
                      : const Color(0xFFFFC46B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChartCard(TrafficDataSnapshot s, bool isPersian) {
    // Ensure we always have at least 2 points to avoid spline curve errors in fl_chart
    final List<TrafficSpeedPoint> spots;
    if (s.recentHistory.isEmpty) {
      spots = [
        const TrafficSpeedPoint(timestamp: 0, downloadMbps: 0, uploadMbps: 0),
        const TrafficSpeedPoint(timestamp: 1, downloadMbps: 0, uploadMbps: 0),
      ];
    } else if (s.recentHistory.length == 1) {
      final first = s.recentHistory.first;
      spots = [
        TrafficSpeedPoint(
            timestamp: first.timestamp - 1, downloadMbps: 0, uploadMbps: 0),
        first,
      ];
    } else {
      spots = s.recentHistory;
    }

    final minX = spots.first.timestamp;
    final lastX = spots.last.timestamp;
    final maxX = lastX > minX ? lastX : minX + 30.0;

    double maxY = 5.0;
    for (final pt in spots) {
      if (pt.downloadMbps > maxY) maxY = pt.downloadMbps;
      if (pt.uploadMbps > maxY) maxY = pt.uploadMbps;
    }
    maxY = (maxY * 1.25).ceilToDouble();
    final horizontalInterval = (maxY / 3).clamp(1.0, 10000.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF103649).withValues(alpha: 0.90),
            const Color(0xFF08202D).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart_rounded,
                      color: Color(0xFF00D4AA), size: 20),
                  const SizedBox(width: 8),
                  LocalizedText(
                    localizedUiText(
                        context,
                        (isPersian
                            ? 'سرعت زنده لحظه‌ای'
                            : 'Live Real-Time Speed')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BadgeChip(
                    label:
                        localizedUiText(context, (isPersian ? 'دانلود' : 'DL')),
                    value: TrafficDataSnapshot.formatSpeed(s.rxBps),
                    color: const Color(0xFF00D4AA),
                    icon: Icons.arrow_downward_rounded,
                  ),
                  _BadgeChip(
                    label:
                        localizedUiText(context, (isPersian ? 'آپلود' : 'UL')),
                    value: TrafficDataSnapshot.formatSpeed(s.txBps),
                    color: const Color(0xFF61F2C2),
                    icon: Icons.arrow_upward_rounded,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: horizontalInterval,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF07212E),
                    tooltipRoundedRadius: 10,
                    tooltipBorder:
                        const BorderSide(color: Color(0xFF00D4AA), width: 1.0),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isDl = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isDl ? (isPersian ? "دانلود: " : "DL: ") : (isPersian ? "آپلود: " : "UL: ")}${spot.y.toStringAsFixed(1)} Mbps',
                          TextStyle(
                            color: isDl
                                ? const Color(0xFF00D4AA)
                                : const Color(0xFF61F2C2),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Download Line
                  LineChartBarData(
                    spots: spots
                        .map((p) => FlSpot(p.timestamp, p.downloadMbps))
                        .toList(),
                    isCurved: spots.length > 2,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF00D4AA),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00D4AA).withValues(alpha: 0.32),
                          const Color(0xFF00D4AA).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Upload Line
                  LineChartBarData(
                    spots: spots
                        .map((p) => FlSpot(p.timestamp, p.uploadMbps))
                        .toList(),
                    isCurved: spots.length > 2,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF61F2C2),
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF61F2C2).withValues(alpha: 0.20),
                          const Color(0xFF61F2C2).withValues(alpha: 0.0),
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

  Widget _buildQuotaCard(TrafficDataSnapshot s, bool isPersian) {
    final hasLimit = s.quotaLimitGb != null && s.quotaLimitGb! > 0;
    final usedPercent = s.quotaUsedPercent;
    final isWarning = usedPercent >= 0.8;
    final isExceeded = s.isQuotaExceeded;

    final barColor = isExceeded
        ? const Color(0xFFFF5252)
        : (isWarning ? const Color(0xFFFFC46B) : const Color(0xFF00D4AA));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2230).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: barColor.withValues(alpha: isWarning ? 0.7 : 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExceeded
                        ? Icons.warning_rounded
                        : Icons.pie_chart_rounded,
                    color: barColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  LocalizedText(
                    localizedUiText(context,
                        (isPersian ? 'سقف مصرف ماهانه' : 'Monthly Data Quota')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showQuotaDialog(isPersian),
                icon: const Icon(Icons.tune_rounded,
                    size: 16, color: Color(0xFF00D4AA)),
                label: LocalizedText(
                  hasLimit
                      ? '${s.quotaLimitGb!.toStringAsFixed(0)} GB'
                      : (localizedUiText(
                          context, (isPersian ? 'تنظیم سقف' : 'Set Quota'))),
                  style: const TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hasLimit ? usedPercent : 0.05,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              LocalizedText(
                '${TrafficDataSnapshot.formatBytes(s.monthTotalBytes)} ${localizedUiText(context, (isPersian ? 'مصرف شده' : 'used'))}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
              LocalizedText(
                hasLimit
                    ? '${(usedPercent * 100).toStringAsFixed(1)}% / ${s.quotaLimitGb!.toStringAsFixed(0)} GB'
                    : (localizedUiText(context,
                        (isPersian ? 'بدون سقف محدودیت' : 'No Limit Set'))),
                style: TextStyle(
                  color: barColor,
                  fontSize: 12,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageGrid(TrafficDataSnapshot s, bool isPersian) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StatTile(
                title: localizedUiText(
                    context, (isPersian ? 'مصرف امروز' : 'Today')),
                value: TrafficDataSnapshot.formatBytes(s.todayTotalBytes),
                sub:
                    '↓ ${TrafficDataSnapshot.formatBytes(s.todayRxBytes)}  ↑ ${TrafficDataSnapshot.formatBytes(s.todayTxBytes)}',
                icon: Icons.today_rounded,
                accentColor: const Color(0xFF00D4AA),
              ),
              const SizedBox(height: 12),
              _StatTile(
                title: localizedUiText(
                    context, (isPersian ? 'بالاترین سرعت' : 'Peak Speed')),
                value: TrafficDataSnapshot.formatSpeed(s.peakDownloadBps),
                sub: localizedUiText(context,
                    (isPersian ? 'اوج سرعت ثبت شده' : 'Highest recorded')),
                icon: Icons.bolt_rounded,
                accentColor: const Color(0xFFFFC46B),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _StatTile(
                title: localizedUiText(
                    context, (isPersian ? 'مصرف این ماه' : 'This Month')),
                value: TrafficDataSnapshot.formatBytes(s.monthTotalBytes),
                sub:
                    '↓ ${TrafficDataSnapshot.formatBytes(s.monthRxBytes)}  ↑ ${TrafficDataSnapshot.formatBytes(s.monthTxBytes)}',
                icon: Icons.calendar_month_rounded,
                accentColor: const Color(0xFF00E5FF),
              ),
              const SizedBox(height: 12),
              _StatTile(
                title: localizedUiText(
                    context, (isPersian ? 'کل طول عمر' : 'Lifetime Total')),
                value: TrafficDataSnapshot.formatBytes(s.lifetimeTotalBytes),
                sub: localizedUiText(context,
                    (isPersian ? 'مجموع دیتا روی دستگاه' : 'All-time volume')),
                icon: Icons.all_inclusive_rounded,
                accentColor: const Color(0xFFB572FF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionAndSpeedCard(TrafficDataSnapshot s, bool isPersian) {
    final dur = s.connectedDuration;
    final hours = dur.inHours.toString().padLeft(2, '0');
    final minutes = (dur.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (dur.inSeconds % 60).toString().padLeft(2, '0');

    final latest = _latestSpeed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2230).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_rounded,
                      color: Color(0xFF72D9FF), size: 20),
                  const SizedBox(width: 8),
                  LocalizedText(
                    localizedUiText(context,
                        (isPersian ? 'مدت زمان اتصال' : 'Session Duration')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              LocalizedText(
                '$hours:$minutes:$seconds',
                style: const TextStyle(
                  color: Color(0xFF72D9FF),
                  fontSize: 15,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              LocalizedText(
                localizedUiText(context,
                    (isPersian ? 'داده دانلود نشست:' : 'Session Download:')),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              LocalizedText(
                TrafficDataSnapshot.formatBytes(s.sessionRxBytes),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              LocalizedText(
                localizedUiText(context,
                    (isPersian ? 'داده آپلود نشست:' : 'Session Upload:')),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              LocalizedText(
                TrafficDataSnapshot.formatBytes(s.sessionTxBytes),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded,
                        color: Color(0xFF61F2C2), size: 18),
                    const SizedBox(width: 6),
                    LocalizedText(
                      localizedUiText(
                          context,
                          (isPersian
                              ? 'آخرین تست سرعت:'
                              : 'Last Speed Benchmark:')),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                LocalizedText(
                  '${latest.downloadMbps.toStringAsFixed(1)} Mbps (Ping ${latest.latencyMs.toStringAsFixed(0)}ms)',
                  style: const TextStyle(
                    color: Color(0xFF61F2C2),
                    fontFamily: 'Lato',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2D3E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: LocalizedText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LocalizedText(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          LocalizedText(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _BadgeChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          LocalizedText(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
