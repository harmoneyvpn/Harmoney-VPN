import '../../../../core/vpn_core.dart';
import '../../../../shared/layout/main_screen_background.dart';
import 'dart:ui';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network_speed_test.dart';
import '../../../../features/diagnostics/diagnostics_page.dart';
import '../../../../features/statistics/statistics_page.dart';
import '../painters/animated_grid_painter.dart';
import '../painters/semicircular_divider_painter.dart';
import '../painters/semicircular_progress_painter.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class SpeedTestDiagnosticsPage extends ConsumerStatefulWidget {
  const SpeedTestDiagnosticsPage({super.key});

  @override
  ConsumerState<SpeedTestDiagnosticsPage> createState() =>
      _SpeedTestDiagnosticsPageState();
}

class _SpeedTestDiagnosticsPageState
    extends ConsumerState<SpeedTestDiagnosticsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridController;
  NetworkSpeedTest? _activeTester;
  bool _testing = false;
  double _displaySpeed = 0.0;
  double _testProgress = 0.0;
  String _statusText = '';
  SpeedTestPhase _currentPhase = SpeedTestPhase.idle;
  List<double> _liveSpots = [];

  NetworkSpeedResult? _lastResult;
  String? _errorMessage;
  int _tabIndex = 0; // 0: Speed Test, 1: Live Traffic, 2: Diagnostics

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadLatestResult();
  }

  Future<void> _loadLatestResult() async {
    final history = await NetworkSpeedTest.getHistory();
    if (history.isNotEmpty && mounted) {
      setState(() {
        _lastResult = history.first;
        _displaySpeed = history.first.downloadMbps;
      });
    }
  }

  @override
  void dispose() {
    _activeTester?.cancel();
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _startSpeedTest() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _errorMessage = null;
      _displaySpeed = 0.0;
      _testProgress = 0.0;
      _currentPhase = SpeedTestPhase.ping;
      _statusText = 'در حال برقراری ارتباط...';
      _liveSpots = [];
    });

    try {
      _activeTester = NetworkSpeedTest();
      final result = await _activeTester!.run(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _currentPhase = progress.phase;
            _testProgress = progress.progress;
            _displaySpeed = progress.currentSpeedMbps;
            _statusText = progress.statusText;
            _liveSpots = progress.liveGraphSpots;
            if (progress.downloadMbps != null &&
                progress.phase == SpeedTestPhase.download) {
              _displaySpeed = progress.downloadMbps!;
            } else if (progress.uploadMbps != null &&
                progress.phase == SpeedTestPhase.upload) {
              _displaySpeed = progress.uploadMbps!;
            }
          });
        },
      );

      if (mounted) {
        setState(() {
          _lastResult = result;
          _displaySpeed = result.downloadMbps;
          _currentPhase = SpeedTestPhase.complete;
          _testing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _currentPhase = SpeedTestPhase.error;
          _testing = false;
        });
      }
    }
  }

  void _cancelSpeedTest() {
    _activeTester?.cancel();
    setState(() {
      _testing = false;
      _currentPhase = SpeedTestPhase.idle;
      _statusText = 'تست لغو شد';
    });
  }

  void _copyResultToClipboard(bool isPersian) {
    if (_lastResult == null) return;
    final r = _lastResult!;
    final text = '''
🚀 گزارش تست سرعت و کیفیت شبکه Harmoney VPN
━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 دانلود: ${r.downloadMbps.toStringAsFixed(1)} Mbps
📤 آپلود: ${r.uploadMbps.toStringAsFixed(1)} Mbps
⚡ پینگ: ${r.latencyMs.toStringAsFixed(0)} ms
🌊 نوسان (Jitter): ${r.jitterMs.toStringAsFixed(1)} ms
🎮 رتبه گیمینگ: ${r.gamingGrade} (${r.gamingScore}/100)
🎬 استریم ویدیو: ${r.streamingGrade}
📞 تماس صوتی/تصویری: ${r.videoCallQuality}
🛡️ شاخص پایداری: ${r.stabilityScore}%
📅 تاریخ: ${r.timestamp?.toString().substring(0, 19) ?? '-'}
━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F3042),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF00D4AA), width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00D4AA)),
            const SizedBox(width: 10),
            LocalizedText(
              localizedUiText(
                  context,
                  (isPersian
                      ? 'گزارش تست سرعت در کلیپ‌بورد کپی شد!'
                      : 'Speed report copied to clipboard!')),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHistoryModal(bool isPersian) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.70,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF09202E),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: FutureBuilder<List<NetworkSpeedResult>>(
              future: NetworkSpeedTest.getHistory(),
              builder: (context, snapshot) {
                final list = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_rounded,
                                color: Color(0xFF00D4AA)),
                            const SizedBox(width: 8),
                            LocalizedText(
                              localizedUiText(
                                  context,
                                  (isPersian
                                      ? 'تاریخچه تست‌های سرعت'
                                      : 'Speed Test History')),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (list.isNotEmpty)
                          TextButton.icon(
                            onPressed: () async {
                              await NetworkSpeedTest.clearHistory();
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.delete_sweep_rounded,
                                size: 16, color: Colors.white60),
                            label: LocalizedText(
                              localizedUiText(
                                  context, (isPersian ? 'پاک‌سازی' : 'Clear')),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.speed_rounded,
                                      size: 48,
                                      color:
                                          Colors.white.withValues(alpha: 0.2)),
                                  const SizedBox(height: 10),
                                  LocalizedText(
                                    localizedUiText(
                                        context,
                                        (isPersian
                                            ? 'هنوز تستی ثبت نشده است.'
                                            : 'No speed tests recorded yet.')),
                                    style:
                                        const TextStyle(color: Colors.white38),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final item = list[idx];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F2E3E)
                                        .withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF00D4AA)
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF00D4AA)
                                              .withValues(alpha: 0.15),
                                        ),
                                        child: LocalizedText(
                                          item.gamingGrade,
                                          style: const TextStyle(
                                            color: Color(0xFF61F2C2),
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                LocalizedText(
                                                  '↓ ${item.downloadMbps.toStringAsFixed(1)} Mbps',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Lato',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                LocalizedText(
                                                  '↑ ${item.uploadMbps.toStringAsFixed(1)} Mbps',
                                                  style: const TextStyle(
                                                    color: Color(0xFF61F2C2),
                                                    fontFamily: 'Lato',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LocalizedText(
                                              'Ping: ${item.latencyMs.toStringAsFixed(0)}ms · Jitter: ${item.jitterMs.toStringAsFixed(1)}ms · ${item.streamingGrade}',
                                              style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      LocalizedText(
                                        item.timestamp != null
                                            ? '${item.timestamp!.hour.toString().padLeft(2, '0')}:${item.timestamp!.minute.toString().padLeft(2, '0')}'
                                            : '',
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                            fontFamily: 'Lato'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';

    return MainScreenBackground(
      status: VpnConnectionStatus.disconnected,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 18.w.clamp(14.0, 30.0),
              vertical: 14.h.clamp(10.0, 22.0),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top 3-Tab Selector
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                const Color(0xFF08202D).withValues(alpha: 0.50),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TabButton(
                                  title: localizedUiText(
                                      context,
                                      (isPersian
                                          ? 'تست سرعت'
                                          : 'Speed & Grade')),
                                  icon: Icons.speed_rounded,
                                  selected: _tabIndex == 0,
                                  onTap: () => setState(() => _tabIndex = 0),
                                ),
                              ),
                              Expanded(
                                child: _TabButton(
                                  title: localizedUiText(
                                      context,
                                      (isPersian
                                          ? 'آمار مصرف زنده'
                                          : 'Live Traffic')),
                                  icon: Icons.insights_rounded,
                                  selected: _tabIndex == 1,
                                  onTap: () => setState(() => _tabIndex = 1),
                                ),
                              ),
                              Expanded(
                                child: _TabButton(
                                  title: localizedUiText(
                                      context,
                                      (isPersian
                                          ? 'عیب‌یابی شبکه'
                                          : 'Diagnostics')),
                                  icon: Icons.hub_rounded,
                                  selected: _tabIndex == 2,
                                  onTap: () => setState(() => _tabIndex = 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.98, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_tabIndex),
                        child: switch (_tabIndex) {
                          0 => _buildSpeedTestTab(isPersian),
                          1 => const StatisticsPage(isEmbedded: true),
                          _ => const DiagnosticsPage(isEmbedded: true),
                        },
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedTestTab(bool isPersian) {
    final progress = (_displaySpeed / 100.0).clamp(0.0, 1.0);

    return Column(
      children: [
        // Semicircular Cybernetic Speedometer
        SizedBox(
          height: 220.h.clamp(180.0, 260.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grid background
              Positioned.fill(
                child: CustomPaint(
                  painter: AnimatedGridPainter(
                    animation: _gridController,
                    gridColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Gauge arcs
              Positioned.fill(
                child: CustomPaint(
                  painter: SemicircularDividerPainter(strokeWidth: 4),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: SemicircularProgressPainter(
                    progress: progress,
                    color: const Color(0xFF61F2C2),
                    strokeWidth: 14,
                  ),
                ),
              ),

              // Speed value in center with unit
              Positioned(
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocalizedText(
                      _displaySpeed.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp.clamp(38.0, 60.0),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    LocalizedText(
                      'Mbps',
                      style: TextStyle(
                        color: const Color(0xFF61F2C2),
                        fontSize: 16.sp.clamp(14.0, 20.0),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Live Phase Banner & Linear Progress Bar
        if (_testing || _statusText.isNotEmpty)
          () {
            final phaseIcon = switch (_currentPhase) {
              SpeedTestPhase.ping => Icons.network_ping_rounded,
              SpeedTestPhase.download => Icons.arrow_downward_rounded,
              SpeedTestPhase.upload => Icons.arrow_upward_rounded,
              SpeedTestPhase.evaluating => Icons.analytics_rounded,
              SpeedTestPhase.complete => Icons.check_circle_rounded,
              SpeedTestPhase.error => Icons.error_outline_rounded,
              _ => Icons.speed_rounded,
            };
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2E3E).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(phaseIcon, color: const Color(0xFF61F2C2), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LocalizedText(
                          _statusText,
                          style: const TextStyle(
                            color: Color(0xFF61F2C2),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      LocalizedText(
                        '${(_testProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _testProgress,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D4AA)),
                    ),
                  ),
                ],
              ),
            );
          }(),

        // Live Real-Time Curve Chart while testing
        if (_testing && _liveSpots.length > 3) ...[
          const SizedBox(height: 14),
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: (_liveSpots.reduce((a, b) => a > b ? a : b) * 1.25)
                    .clamp(10.0, 1000.0),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _liveSpots
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF00D4AA),
                    barWidth: 2.4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00D4AA).withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),

        // 4 Telemetry Metrics Grid (Ping, Jitter, Download, Upload)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF103649).withValues(alpha: 0.88),
                const Color(0xFF09202E).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _MetricItem(
                  label: localizedUiText(context, (isPersian ? 'پینگ' : 'Ping')),
                  value: _lastResult != null
                      ? '${_lastResult!.latencyMs.toStringAsFixed(0)} ms'
                      : '-- ms',
                  icon: Icons.network_ping_rounded,
                  color: const Color(0xFFFFC46B),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  label: localizedUiText(
                      context, (isPersian ? 'نوسان (جیتر)' : 'Jitter')),
                  value: _lastResult != null
                      ? '${_lastResult!.jitterMs.toStringAsFixed(1)} ms'
                      : '-- ms',
                  icon: Icons.waves_rounded,
                  color: const Color(0xFF72D9FF),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  label: localizedUiText(
                      context, (isPersian ? 'دانلود' : 'Download')),
                  value: _lastResult != null
                      ? '${_lastResult!.downloadMbps.toStringAsFixed(1)} Mbps'
                      : '-- Mbps',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF61F2C2),
                ),
              ),
              Expanded(
                child: _MetricItem(
                  label:
                      localizedUiText(context, (isPersian ? 'آپلود' : 'Upload')),
                  value: _lastResult != null
                      ? '${_lastResult!.uploadMbps.toStringAsFixed(1)} Mbps'
                      : '-- Mbps',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFB572FF),
                ),
              ),
            ],
          ),
        ),

        // Quality Scorecard Matrix
        if (_lastResult != null) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2433).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFFFC46B), size: 20),
                    const SizedBox(width: 8),
                    LocalizedText(
                      localizedUiText(
                          context,
                          (isPersian
                              ? 'ارزیابی هوشمند کیفیت سرویس‌ها'
                              : 'Smart Service Suitability')),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _QualityPill(
                        icon: Icons.sports_esports_rounded,
                        title: localizedUiText(
                            context, (isPersian ? 'گیمینگ آنلاین' : 'Gaming')),
                        grade: _lastResult!.gamingGrade,
                        badgeColor: const Color(0xFF61F2C2),
                        desc: 'پایداری پینگ ${_lastResult!.gamingScore}%',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QualityPill(
                        icon: Icons.movie_filter_rounded,
                        title: localizedUiText(context,
                            (isPersian ? 'استریم ویدیو' : 'Streaming')),
                        grade: _lastResult!.streamingGrade,
                        badgeColor: const Color(0xFF72D9FF),
                        desc: localizedUiText(context,
                            (isPersian ? 'بدون بافرینگ' : 'No Buffering')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QualityPill(
                        icon: Icons.phone_in_talk_rounded,
                        title: localizedUiText(context,
                            (isPersian ? 'تماس صوتی/تصویری' : 'Calls (VoIP)')),
                        grade: _lastResult!.videoCallQuality,
                        badgeColor: const Color(0xFFFFC46B),
                        desc: localizedUiText(
                            context,
                            (isPersian
                                ? 'واتساپ، زوم، تلگرام'
                                : 'Zoom & Telegram')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QualityPill(
                        icon: Icons.shield_rounded,
                        title: localizedUiText(context,
                            (isPersian ? 'شاخص پایداری' : 'Stability Index')),
                        grade: '${_lastResult!.stabilityScore}%',
                        badgeColor: const Color(0xFFB572FF),
                        desc: localizedUiText(
                            context,
                            (isPersian
                                ? 'پکت‌لاس نزدیک صفر'
                                : 'Zero packet loss')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Start / Cancel Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 210),
              child: SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: _testing
                          ? [const Color(0xFFFF5252), const Color(0xFFFF7E7E)]
                          : [const Color(0xFF00D4AA), const Color(0xFF00E5FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_testing
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00D4AA))
                            .withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _testing ? _cancelSpeedTest : _startSpeedTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: const Color(0xFF07212E),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _testing
                              ? Icons.close_rounded
                              : Icons.play_arrow_rounded,
                          size: 24,
                          color:
                              _testing ? Colors.white : const Color(0xFF07212E),
                        ),
                        const SizedBox(width: 8),
                        LocalizedText(
                          _testing
                              ? (localizedUiText(context,
                                  (isPersian ? 'لغو تست' : 'Cancel Test')))
                              : (localizedUiText(
                                  context,
                                  (isPersian
                                      ? 'شروع تست سرعت'
                                      : 'Start Speed Test'))),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: _testing
                                ? Colors.white
                                : const Color(0xFF07212E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Result Action Buttons (Copy & History)
        if (_lastResult != null && !_testing) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copyResultToClipboard(isPersian),
                icon: const Icon(Icons.copy_rounded,
                    size: 16, color: Color(0xFF61F2C2)),
                label: LocalizedText(
                  localizedUiText(
                      context, (isPersian ? 'کپی گزارش نتیجه' : 'Copy Report')),
                  style: const TextStyle(
                      color: Color(0xFF61F2C2),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00D4AA), width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _showHistoryModal(isPersian),
                icon: const Icon(Icons.history_rounded,
                    size: 16, color: Colors.white70),
                label: LocalizedText(
                  localizedUiText(
                      context, (isPersian ? 'تاریخچه تست‌ها' : 'History')),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2), width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          LocalizedText(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFFE72E44), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF00D4AA).withValues(alpha: 0.35),
                    const Color(0xFF00E5FF).withValues(alpha: 0.20),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.8),
                  width: 1,
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? const Color(0xFF61F2C2) : Colors.white54,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: LocalizedText(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontSize: 12.sp.clamp(10.5, 14.0),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        LocalizedText(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp.clamp(11.0, 15.0),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        LocalizedText(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10.sp.clamp(9.0, 12.0),
          ),
        ),
      ],
    );
  }
}

class _QualityPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String grade;
  final Color badgeColor;
  final String desc;

  const _QualityPill({
    required this.icon,
    required this.title,
    required this.grade,
    required this.badgeColor,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3143).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: badgeColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LocalizedText(title,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    LocalizedText(
                      grade,
                      style: TextStyle(
                        color: badgeColor,
                        fontFamily: 'Lato',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                LocalizedText(
                  desc,
                  style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
