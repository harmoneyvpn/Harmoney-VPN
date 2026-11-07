import '../../../../shared/country_flag.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/app_state.dart';

import '../../../../core/traffic_analytics_service.dart';
import '../../../../core/harmoney_subscription_service.dart';
import '../../../../core/vpn_core.dart';
import '../../../../core/vpn_core_providers.dart';
import '../../../../features/diagnostics/vpn_debug_log_sheet.dart';
import '../../../../features/shared/harmoney_pro_download_card.dart';
import '../../../../shared/layout/main_screen_background.dart';
import '../widgets/connection_button.dart';
import '../widgets/header_section.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class MainScreen extends ConsumerStatefulWidget {
  final AppState appState;
  final VpnServer? selectedServer;
  final bool isActive;
  final VoidCallback onOpenLocations;
  final VoidCallback onOpenSpeedTest;
  final VoidCallback onOpenProtection;
  final VoidCallback onOpenSettings;

  const MainScreen({
    super.key,
    required this.appState,
    this.selectedServer,
    this.isActive = true,
    required this.onOpenLocations,
    required this.onOpenSpeedTest,
    required this.onOpenProtection,
    required this.onOpenSettings,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int? _pingMs;
  bool _actionBusy = false;
  bool _cancelBusy = false;
  bool _cancelSubscriptionFailover = false;
  Timer? _pingTimer;
  bool _pingInProgress = false;
  bool _copiedIp = false;
  Timer? _copiedTimer;
  StreamSubscription<TrafficDataSnapshot>? _trafficSub;
  late final ValueNotifier<TrafficDataSnapshot> _trafficNotifier;

  @override
  void initState() {
    super.initState();
    _trafficNotifier = ValueNotifier(TrafficAnalyticsService.instance.current);
    TrafficAnalyticsService.instance.init();
    _trafficSub = TrafficAnalyticsService.instance.stream.listen((data) {
      _trafficNotifier.value = data;
    });
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      final state = ref.read(connectionStateProvider).asData?.value;
      _syncPingTimer(state?.isConnected == true);
    }
  }

  void _syncPingTimer(bool isConnected) {
    if (!widget.isActive || !isConnected) {
      _pingTimer?.cancel();
      _pingTimer = null;
      return;
    }
    if (_pingTimer != null) return;
    _refreshPing();
    _pingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshPing(),
    );
  }

  @override
  void dispose() {
    _trafficSub?.cancel();
    _pingTimer?.cancel();
    _copiedTimer?.cancel();
    _trafficNotifier.dispose();
    TrafficAnalyticsService.instance.stopMonitoring();
    super.dispose();
  }

  void _copyIp(String ip) {
    Clipboard.setData(ClipboardData(text: ip));
    setState(() => _copiedIp = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedIp = false);
    });
  }

  Future<void> _refreshPing() async {
    if (_pingInProgress) return;
    final state = ref.read(connectionStateProvider).asData?.value;
    final server = state?.server;
    if (state?.isConnected != true || server == null) {
      if (mounted && _pingMs != null) setState(() => _pingMs = null);
      return;
    }
    _pingInProgress = true;
    try {
      final ping = await ref.read(vpnCoreProvider).probeServer(
            providerId: server.providerId,
            serverId: server.id,
            protocol: state?.protocol ?? widget.appState.protocol,
          );
      if (!mounted) return;
      final current = ref.read(connectionStateProvider).asData?.value;
      if (current?.isConnected == true &&
          current?.server?.id == server.id &&
          current?.server?.providerId == server.providerId) {
        setState(() => _pingMs = ping);
      }
    } catch (_) {
      if (mounted) setState(() => _pingMs = null);
    } finally {
      _pingInProgress = false;
    }
  }

  Future<void> _toggleConnection(VpnConnectionState state) async {
    if (_cancelBusy ||
        state.status == VpnConnectionStatus.disconnecting ||
        state.status == VpnConnectionStatus.cancelling) {
      return;
    }
    // Waiting for the handshake must leave the button available for cancel.
    if (state.isTransitioning) {
      _cancelSubscriptionFailover = true;
      setState(() => _cancelBusy = true);
      try {
        await ref.read(vpnCoreProvider).cancelConnect();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: LocalizedText('Error: $error')));
        }
      } finally {
        if (mounted) setState(() => _cancelBusy = false);
      }
      return;
    }
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    _cancelSubscriptionFailover = false;
    try {
      if (state.isConnected) {
        await ref.read(vpnCoreProvider).disconnect();
      } else {
        var selectedServer =
            widget.selectedServer?.providerId == widget.appState.provider
                ? widget.selectedServer
                : null;
        final effectiveProvider =
            (selectedServer?.providerId.isNotEmpty == true)
                ? selectedServer!.providerId
                : widget.appState.provider;
        if (effectiveProvider == 'harmoney' &&
            selectedServer?.subscriptionId != null &&
            selectedServer?.subscriptionNodeId == null) {
          final subscriptionId = selectedServer!.subscriptionId!;
          final candidates = (await ref
                  .read(vpnCoreProvider)
                  .listServers(providerId: 'harmoney'))
              .where((candidate) =>
                  candidate.available &&
                  candidate.subscriptionId == subscriptionId &&
                  candidate.subscriptionNodeId != null)
              .toList(growable: false);
          if (candidates.isEmpty) {
            throw StateError('This subscription has no compatible servers.');
          }
          final ranked = candidates
              .map((candidate) => (
                    server: candidate,
                    latency: HarmoneySubscriptionService.instance
                        .cachedNodeLatency(candidate.subscriptionNodeId!),
                  ))
              .where((entry) => entry.latency != null)
              .toList()
            ..sort((a, b) => a.latency!.compareTo(b.latency!));
          final rankedIds = ranked.map((entry) => entry.server.id).toSet();
          final attempts = <VpnServer>[
            ...ranked.map((entry) => entry.server),
            ...candidates
                .where((candidate) => !rankedIds.contains(candidate.id)),
          ];
          final errors = <String>[];
          var connected = false;
          for (final candidate in attempts) {
            if (_cancelSubscriptionFailover || !mounted) return;
            try {
              await ref.read(vpnCoreProvider).connect(
                    providerId: effectiveProvider,
                    server: candidate,
                    protocol: widget.appState.protocol.toLowerCase(),
                  );
              if (_cancelSubscriptionFailover) return;
              connected = true;
              break;
            } catch (error) {
              if (_cancelSubscriptionFailover || !mounted) return;
              errors.add('${candidate.country}: $error');
            }
          }
          if (!connected) {
            final lastErrors = errors.length > 3
                ? errors.skip(errors.length - 3).join(' | ')
                : errors.join(' | ');
            throw StateError(
              'Could not connect to any server in this subscription '
              '(${attempts.length} tried). $lastErrors',
            );
          }
        } else {
          await ref.read(vpnCoreProvider).connect(
                providerId: effectiveProvider,
                server: selectedServer,
                protocol: widget.appState.protocol.toLowerCase(),
              );
        }
        await _refreshPing();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: LocalizedText('Error: $error')));
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionStateProvider);
    final isPersian = widget.appState.locale.languageCode == 'fa';

    return connectionAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF61F2C2)),
      ),
      error: (e, _) => Center(child: LocalizedText('Error: $e')),
      data: (state) {
        final status = state.status;
        _syncPingTimer(state.isConnected);
        final selectedServer =
            widget.selectedServer?.providerId == widget.appState.provider
                ? widget.selectedServer
                : null;
        final server = state.server ?? selectedServer;
        TrafficAnalyticsService.instance.onVpnStatusChanged(
          isConnected: status == VpnConnectionStatus.connected,
        );

        return MainScreenBackground(
          status: status,
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w.clamp(16.0, 32.0),
                vertical: 16.h.clamp(12.0, 24.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section with brand, active server, ping
                      HeaderSection(
                        status: status,
                        server: server,
                        providerId: widget.appState.provider,
                        protocol: widget.appState.protocol,
                        pingMs: _pingMs,
                        onSelectServer: widget.onOpenLocations,
                        onRefreshPing: _refreshPing,
                        onOpenMenu: widget.onOpenSettings,
                        onOpenDebugLogs: () => _showDebugLogs(context),
                      ),

                      SizedBox(height: 16.h),
                      const HarmoneyProDownloadCard(),

                      SizedBox(height: 22.h.clamp(16.0, 32.0)),

                      // Main Harmoney Connection Button with animated shield
                      Center(
                        child: ConnectionButton(
                          status: status,
                          connectedAt: state.connectedAt,
                          onTap: () => _toggleConnection(state),
                        ),
                      ),

                      SizedBox(height: 16.h.clamp(12.0, 22.0)),

                      // Status Text
                      Center(
                        child: LocalizedText(
                          _getStatusTitle(status, isPersian),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp.clamp(16.0, 22.0),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: LocalizedText(
                          _getStatusSubtitle(status, isPersian),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13.sp.clamp(11.0, 15.0),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h.clamp(12.0, 24.0)),

                      // Connected Country Card with Country Flag & Telemetry
                      if (status == VpnConnectionStatus.connected) ...[
                        _buildConnectedCountryCard(
                          context,
                          server,
                          state.publicIp,
                          isPersian,
                        ),
                        _buildTelemetryHud(context, state, isPersian),
                      ],

                      // Quick Feature Cards (Bypass Iran, Kill Switch, Speed Test)
                      _buildQuickCards(context, isPersian, server),

                      // Bottom clearance for floating glass navbar
                      SizedBox(height: 110.h.clamp(90.0, 130.0)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedCountryCard(
    BuildContext context,
    VpnServer? server,
    String? publicIp,
    bool isPersian,
  ) {
    final code = CountryFlags.resolve(server);
    final hasSvg = code.isNotEmpty;
    final isHarmoney = server?.providerId == 'harmoney';
    final isUndetected = server == null ||
        server.countryCode == 'UNKNOWN' ||
        (isHarmoney &&
            (code.isEmpty ||
                server.country.isEmpty ||
                server.country == 'Unknown'));
    final countryName = isUndetected
        ? (localizedUiText(context, (isPersian ? 'نامشخص' : 'Unknown')))
        : (server.country.isNotEmpty
            ? server.country
            : (localizedUiText(
                context, (isPersian ? 'مسیر خودکار' : 'Automatic route'))));
    final cityName = server?.city ??
        (localizedUiText(
            context,
            (isPersian
                ? 'تونل ایمن و ترافیک رمزنگاری‌شده'
                : 'Verified Secure Tunnel')));

    return Container(
      margin: EdgeInsets.only(bottom: 20.h.clamp(14.0, 26.0)),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w.clamp(14.0, 20.0),
        vertical: 14.h.clamp(12.0, 18.0),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4AA).withValues(alpha: 0.18),
            const Color(0xFF0A2E3F).withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Country Flag with glow
          Container(
            width: 44.w.clamp(40.0, 50.0),
            height: 44.w.clamp(40.0, 50.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00D4AA), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasSvg
                ? CountryFlag(code: code, size: 42.w)
                : Container(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.public_rounded,
                      color: const Color(0xFF00D4AA),
                      size: 24.sp,
                    ),
                  ),
          ),
          SizedBox(width: 14.w.clamp(10.0, 18.0)),
          // Country & City
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: LocalizedText(
                        countryName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp.clamp(14.0, 18.0),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00D4AA).withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: LocalizedText(
                        localizedUiText(
                            context, (isPersian ? 'متصل' : 'CONNECTED')),
                        style: const TextStyle(
                          color: Color(0xFF00D4AA),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                LocalizedText(
                  cityName,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp.clamp(11.0, 13.5),
                    fontFamily: 'Lato',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (publicIp != null && publicIp.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  LocalizedText(
                    '${localizedUiText(context, (isPersian ? 'IP خروجی' : 'Exit IP'))}: $publicIp',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp.clamp(10.0, 12.0),
                      fontFamily: 'Lato',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Ping & Protocol Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF61F2C2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  LocalizedText(
                    _pingMs != null && _pingMs! > 0
                        ? '$_pingMs ms'
                        : (localizedUiText(
                            context, (isPersian ? 'فعال' : 'Online'))),
                    style: TextStyle(
                      color: const Color(0xFF61F2C2),
                      fontSize: 13.sp.clamp(11.0, 14.0),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              LocalizedText(
                widget.appState.protocol.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryHud(
    BuildContext context,
    VpnConnectionState state,
    bool isPersian,
  ) {
    final ping = _pingMs;
    final (pingColor, pingLabel) = switch (ping) {
      null => (
          Colors.white60,
          localizedUiText(
              context, (isPersian ? 'در حال سنجش...' : 'Measuring...'))
        ),
      < 85 => (
          const Color(0xFF61F2C2),
          localizedUiText(context, (isPersian ? 'عالی' : 'Excellent'))
        ),
      < 160 => (
          const Color(0xFFFFC46B),
          localizedUiText(context, (isPersian ? 'خوب' : 'Good'))
        ),
      _ => (
          const Color(0xFFFF7E7E),
          localizedUiText(context, (isPersian ? 'متوسط' : 'Fair'))
        ),
    };

    final hasIp = state.publicIp != null && state.publicIp!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h.clamp(12.0, 20.0)),
      padding: const EdgeInsets.all(14),
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
          color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Real-time Speed Telemetry Cards
          Row(
            children: [
              // Download Block
              Expanded(
                child: Tooltip(
                  message: localizedUiText(
                      context,
                      (isPersian
                          ? 'ضربه بزنید برای آزمون سرعت کامل'
                          : 'Tap to run full speed test')),
                  child: InkWell(
                    onTap: widget.onOpenSpeedTest,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFF00E5FF).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              color: Color(0xFF00E5FF),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedText(
                                  localizedUiText(context,
                                      (isPersian ? 'دانلود' : 'Download')),
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10.5.sp.clamp(9.5, 12.0),
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ValueListenableBuilder<TrafficDataSnapshot>(
                                  valueListenable: _trafficNotifier,
                                  builder: (context, traffic, _) =>
                                      LocalizedText(
                                    TrafficDataSnapshot.formatSpeed(
                                      traffic.rxBps,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp.clamp(12.0, 16.0),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Upload Block
              Expanded(
                child: Tooltip(
                  message: localizedUiText(
                      context,
                      (isPersian
                          ? 'ضربه بزنید برای آزمون سرعت کامل'
                          : 'Tap to run full speed test')),
                  child: InkWell(
                    onTap: widget.onOpenSpeedTest,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFF61F2C2).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF61F2C2)
                                  .withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(0xFF61F2C2)
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFF61F2C2),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedText(
                                  localizedUiText(context,
                                      (isPersian ? 'آپلود' : 'Upload')),
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10.5.sp.clamp(9.5, 12.0),
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ValueListenableBuilder<TrafficDataSnapshot>(
                                  valueListenable: _trafficNotifier,
                                  builder: (context, traffic, _) =>
                                      LocalizedText(
                                    TrafficDataSnapshot.formatSpeed(
                                      traffic.txBps,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp.clamp(12.0, 16.0),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
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

          const SizedBox(height: 10),

          // Row 2: Live Ping Badge + Copyable Exit IP Pill
          Row(
            children: [
              // Interactive Ping Pill
              Tooltip(
                message: localizedUiText(
                    context,
                    (isPersian
                        ? 'برای تازه‌سازی پینگ کلیک کنید'
                        : 'Tap to re-test latency')),
                child: InkWell(
                  onTap: _refreshPing,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pingColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: pingColor.withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_pingInProgress)
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF61F2C2),
                            ),
                          )
                        else
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pingColor,
                              boxShadow: [
                                BoxShadow(
                                  color: pingColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 6),
                        LocalizedText(
                          ping != null && ping > 0
                              ? '$ping ms ($pingLabel)'
                              : pingLabel,
                          style: TextStyle(
                            color: pingColor,
                            fontSize: 11.sp.clamp(10.0, 13.0),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Copyable IP Pill
              if (hasIp)
                Tooltip(
                  message: localizedUiText(
                      context, (isPersian ? 'کپی آدرس IP' : 'Copy Public IP')),
                  child: InkWell(
                    onTap: () => _copyIp(state.publicIp!),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _copiedIp
                              ? const Color(0xFF61F2C2)
                              : Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copiedIp
                                ? Icons.check_circle_rounded
                                : Icons.copy_rounded,
                            size: 13,
                            color: _copiedIp
                                ? const Color(0xFF61F2C2)
                                : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          LocalizedText(
                            _copiedIp
                                ? (localizedUiText(context,
                                    (isPersian ? 'کپی شد!' : 'Copied!')))
                                : 'IP: ${state.publicIp}',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: _copiedIp
                                  ? const Color(0xFF61F2C2)
                                  : Colors.white70,
                              fontSize: 11.sp.clamp(10.0, 12.5),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCards(
    BuildContext context,
    bool isPersian,
    VpnServer? server,
  ) {
    return Column(
      children: [
        // Row 1: Split Tunneling & Iran Domestic Bypass
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.alt_route_rounded,
                iconColor: const Color(0xFFFFC46B),
                title: localizedUiText(context,
                    (isPersian ? 'دورزدن سایت‌های داخلی' : 'Domestic Bypass')),
                subtitle: localizedUiText(context,
                    (isPersian ? 'ترافیک ایران مستقیم' : 'Direct IR routes')),
                onTap: widget.onOpenProtection,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.shield_outlined,
                iconColor: widget.appState.killSwitch
                    ? const Color(0xFF61F2C2)
                    : Colors.white54,
                title: localizedUiText(
                    context, (isPersian ? 'کیل‌سوئیچ امن' : 'Kill Switch')),
                subtitle: widget.appState.killSwitch
                    ? (localizedUiText(
                        context, (isPersian ? 'فعال و محافظت‌شده' : 'Active')))
                    : (localizedUiText(
                        context, (isPersian ? 'غیرفعال' : 'Disabled'))),
                onTap: () async {
                  await widget.appState.setKillSwitch(
                    !widget.appState.killSwitch,
                  );
                  ref
                      .read(vpnCoreProvider)
                      .setKillSwitch(widget.appState.killSwitch);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Speed Test & Network Diagnostics
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFF72D9FF),
                title: localizedUiText(
                    context, (isPersian ? 'تست سرعت و کیفیت' : 'Speed Test')),
                subtitle: localizedUiText(
                    context,
                    (isPersian
                        ? 'سنجش پینگ و پهنای‌باند'
                        : 'Measure latency & speed')),
                onTap: widget.onOpenSpeedTest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.hub_rounded,
                iconColor: const Color(0xFFB572FF),
                title: localizedUiText(context,
                    (isPersian ? 'سرویس اتصال' : 'Connection service')),
                subtitle: widget.appState.provider == 'firetunnel'
                    ? 'Firefox VPN'
                    : (server?.country ?? 'Harmoney Smart'),
                onTap: widget.onOpenLocations,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDebugLogs(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF123D50),
      builder: (_) => const VpnDebugLogSheet(),
    );
  }

  String _getStatusTitle(VpnConnectionStatus status, bool isPersian) {
    return switch (status) {
      VpnConnectionStatus.connected => localizedUiText(
          context, (isPersian ? 'متصل و محافظت‌شده' : 'Connected & Protected')),
      VpnConnectionStatus.connecting ||
      VpnConnectionStatus.preparing ||
      VpnConnectionStatus.discovering =>
        localizedUiText(context,
            (isPersian ? 'در حال برقراری ارتباط...' : 'Connecting...')),
      VpnConnectionStatus.authenticating ||
      VpnConnectionStatus.verifying ||
      VpnConnectionStatus.reconnecting ||
      VpnConnectionStatus.recovering =>
        localizedUiText(
            context,
            (isPersian
                ? 'در حال اعتبارسنجی و دورزدن...'
                : 'Authenticating & Bypassing...')),
      VpnConnectionStatus.error ||
      VpnConnectionStatus.failed =>
        localizedUiText(
            context, (isPersian ? 'خطا در اتصال' : 'Connection Failed')),
      VpnConnectionStatus.disconnecting ||
      VpnConnectionStatus.cancelling =>
        localizedUiText(
            context, (isPersian ? 'در حال قطع ارتباط...' : 'Disconnecting...')),
      _ => localizedUiText(
          context, (isPersian ? 'آماده برای اتصال' : 'Ready to Connect')),
    };
  }

  String _getStatusSubtitle(VpnConnectionStatus status, bool isPersian) {
    return switch (status) {
      VpnConnectionStatus.connected => localizedUiText(
          context,
          (isPersian
              ? 'تمام ترافیک شما رمزنگاری شده و ایمن است'
              : 'All your traffic is encrypted and anonymous')),
      VpnConnectionStatus.connecting ||
      VpnConnectionStatus.preparing ||
      VpnConnectionStatus.authenticating =>
        localizedUiText(
            context,
            (isPersian
                ? 'در حال پیدا کردن سریع‌ترین مسیر ضدفیلتر...'
                : 'Finding the fastest censorship-resistant route...')),
      VpnConnectionStatus.error ||
      VpnConnectionStatus.failed =>
        localizedUiText(
            context,
            (isPersian
                ? 'برای تلاش مجدد روی دکمه ضربه بزنید'
                : 'Tap the button to reconnect')),
      _ => localizedUiText(
          context,
          (isPersian
              ? 'جهت اتصال به اینترنت آزاد و امن، دکمه را لمس کنید'
              : 'Tap the shield button to secure your internet')),
    };
  }
}

class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: _isHovered ? 0.12 : 0.07),
                  const Color(0xFF09222E).withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? widget.iconColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: widget.iconColor.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(
                      alpha: _isHovered ? 0.25 : 0.15,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.iconColor.withValues(
                        alpha: _isHovered ? 0.6 : 0.25,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocalizedText(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp.clamp(10.5, 14.0),
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      LocalizedText(
                        widget.subtitle,
                        style: TextStyle(
                          color: _isHovered ? Colors.white70 : Colors.white54,
                          fontSize: 10.5.sp.clamp(9.0, 12.0),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
