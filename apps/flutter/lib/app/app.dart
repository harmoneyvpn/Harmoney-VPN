import '../shared/layout/main_screen_background.dart';
import '../core/updater/app_update_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../core/vpn_core.dart';
import '../core/vpn_core_providers.dart';
import '../core/harmoney_vpn_bridge.dart';
import '../core/vpn_notifications.dart';
import '../core/windows_tray_bridge.dart';
import '../core/windows_startup_scheduler.dart';
import '../features/hotspot/hotspot_page.dart';
import '../features/locations/locations_page.dart';
import '../features/protection/protection_page.dart';
import '../features/diagnostics/talker_logs_page.dart';
import '../features/settings/settings_page.dart';
import '../features/split_tunnel/split_tunnel_page.dart';
import '../features/statistics/statistics_page.dart';
import '../l10n/app_localizations.dart';
import '../modules/main/presentation/screens/main_screen.dart';
import '../modules/speed_test/presentation/screens/speed_test_diagnostics_page.dart';
import '../shared/layout/navbar/harmoney_navbar.dart';
import '../shared/widgets/apple_glass_card.dart';
import 'app_state.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class VpnClientApp extends StatefulWidget {
  const VpnClientApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<VpnClientApp> createState() => _VpnClientAppState();
}

class _VpnClientAppState extends State<VpnClientApp> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    final isDesktop =
        io.Platform.isLinux || io.Platform.isMacOS || io.Platform.isWindows;

    return ScreenUtilInit(
      designSize: isDesktop ? const Size(1000, 700) : const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      enableScaleWH: () => !isDesktop,
      enableScaleText: () => !isDesktop,
      fontSizeResolver: (fontSize, instance) => isDesktop
          ? fontSize.toDouble()
          : FontSizeResolvers.width(fontSize, instance),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Harmoney',
          themeMode: state.themeMode,
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.themeFor(state.locale, isDark: false),
          darkTheme: AppTheme.themeFor(state.locale, isDark: true),
          builder: (context, child) {
            final rtl = state.locale.languageCode == 'fa' ||
                state.locale.languageCode == 'ar';
            return Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: AppShell(appState: state),
        );
      },
    );
  }
}

class HarmoneySplash extends StatefulWidget {
  const HarmoneySplash({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<HarmoneySplash> createState() => _HarmoneySplashState();
}

class _HarmoneySplashState extends State<HarmoneySplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _entrance = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .72, curve: Curves.easeOutCubic),
    );
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.2, 1, curve: Curves.easeInOut),
    );
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF092B3B),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scale = .75 + (_entrance.value * .25);
          return Center(
            child: Opacity(
              opacity: _entrance.value.clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E5FF).withValues(alpha: 0.38),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color:
                                const Color(0xFF00F5B8).withValues(alpha: 0.24),
                            blurRadius: 48,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/images/app_launcher.png',
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'H',
                          style: TextStyle(
                            fontSize: 38,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFC46B),
                          ),
                        ),
                        TextSpan(
                          text: 'armoney',
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LocalizedText(
                    'A calmer connection. A brighter world.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .65),
                      fontSize: 13,
                      fontFamily: 'Lato',
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 76,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor: Colors.white.withValues(alpha: .12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF61F2C2),
                      ),
                      value: _pulse.value,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.appState});

  final AppState appState;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static bool _linuxTrayHandlerInstalled = false;
  static String? _lastLinuxTrayLabels;
  int _index = 0;
  VpnServer? _selectedServer;
  static const _lastSelectedServerKey = 'last_selected_vpn_server';

  @override
  void initState() {
    super.initState();
    unawaited(_restoreSelectedServer());
    if (io.Platform.isWindows) {
      unawaited(WindowsStartupScheduler.isEnabled().then((enabled) {
        if (mounted && widget.appState.launchOnStartup != enabled) {
          unawaited(widget.appState.setLaunchOnStartup(enabled));
        }
      }));
    }
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        AppUpdateService.instance.autoCheckOnStartup(context);
      }
    });
  }

  Future<void> _restoreSelectedServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_lastSelectedServerKey);
      if (encoded == null) return;
      final value = jsonDecode(encoded);
      if (value is! Map<String, dynamic>) return;
      final id = value['id'];
      final providerId = value['providerId'];
      if (id is! String || id.isEmpty || providerId is! String) return;
      final server = VpnServer(
        id: id,
        providerId: providerId,
        country: value['country'] as String? ?? '',
        city: value['city'] as String? ?? '',
        hostname: value['hostname'] as String? ?? '',
        countryCode: value['countryCode'] as String?,
        latencyMs: value['latencyMs'] as int?,
        fingerprint: value['fingerprint'] as String? ?? '',
        available: value['available'] as bool? ?? true,
        subscriptionNodeId: value['subscriptionNodeId'] as String?,
        subscriptionId: value['subscriptionId'] as String?,
      );
      if (mounted) setState(() => _selectedServer = server);
    } catch (_) {
      // Ignore an unreadable saved route and let the user pick another server.
    }
  }

  Future<void> _persistSelectedServer(VpnServer server) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastSelectedServerKey,
        jsonEncode({
          'id': server.id,
          'providerId': server.providerId,
          'country': server.country,
          'city': server.city,
          'hostname': server.hostname,
          'countryCode': server.countryCode,
          'latencyMs': server.latencyMs,
          'fingerprint': server.fingerprint,
          'available': server.available,
          'subscriptionNodeId': server.subscriptionNodeId,
          'subscriptionId': server.subscriptionId,
        }),
      );
    } catch (_) {
      // The active connection should not depend on local preference storage.
    }
  }

  void _select(int value) {
    if (_index == value) return;
    setState(() {
      _index = value;
    });
  }

  void _connectTo(VpnServer server) {
    if (server.providerId.isNotEmpty &&
        server.providerId != widget.appState.provider) {
      widget.appState.setProvider(server.providerId);
    }
    setState(() {
      _selectedServer = server;
      _index = 0; // Back to main screen
    });
    unawaited(_persistSelectedServer(server));
  }

  void _selectSubscription(VpnServer server) {
    if (server.providerId.isNotEmpty &&
        server.providerId != widget.appState.provider) {
      widget.appState.setProvider(server.providerId);
    }
    setState(() => _selectedServer = server);
    unawaited(_persistSelectedServer(server));
  }

  Future<void> _toggleFromWindowsTray() async {
    final core = ref.read(vpnCoreProvider);
    final current = ref.read(connectionStateProvider).asData?.value;
    if (current?.isTransitioning == true) {
      await core.cancelConnect();
    } else if (current?.isConnected == true) {
      await core.disconnect();
    } else {
      final selected = _selectedServer?.providerId == widget.appState.provider
          ? _selectedServer
          : null;
      await core.connect(
        providerId: selected?.providerId ?? widget.appState.provider,
        server: selected,
        protocol: widget.appState.protocol.toLowerCase(),
      );
    }
  }

  Future<void> _quitFromDesktopTray() async {
    final core = ref.read(vpnCoreProvider);
    final current = ref.read(connectionStateProvider).asData?.value;
    try {
      if (current?.isTransitioning == true) {
        await core.cancelConnect().timeout(const Duration(seconds: 8));
      } else if (current?.isConnected == true) {
        await core.disconnect().timeout(const Duration(seconds: 8));
      }
    } catch (_) {
      // An explicit Quit still takes effect if tunnel shutdown fails.
    } finally {
      try {
        if (io.Platform.isLinux) {
          await HarmoneyBridge().quitApplication();
        } else if (io.Platform.isWindows) {
          await WindowsTrayBridge.quitApplication();
        }
      } catch (_) {
        // Native exit fallback timers prevent a stuck tray process.
      }
    }
  }

  void _openLogsFromWindowsTray() {
    if (!mounted) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TalkerLogsPage()),
    );
  }

  Future<void> _toggleLaunchOnStartupFromWindowsTray() async {
    final enabled = !widget.appState.launchOnStartup;
    try {
      await WindowsStartupScheduler.setEnabled(
        enabled,
        startMinimized: widget.appState.startMinimized,
      );
      await widget.appState.setLaunchOnStartup(enabled);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: LocalizedText('Failed to update autostart: $error')),
        );
      }
    }
  }

  Future<void> _toggleStartMinimizedFromWindowsTray() async {
    final enabled = !widget.appState.startMinimized;
    try {
      if (widget.appState.launchOnStartup) {
        await WindowsStartupScheduler.setEnabled(
          true,
          startMinimized: enabled,
        );
      }
      await widget.appState.setStartMinimized(enabled);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: LocalizedText('Failed to update autostart: $error')),
        );
      }
    }
  }

  Map<String, String> _trayLabels(AppLocalizations l10n) => <String, String>{
        'appName': l10n.appTitle,
        'openApplication': l10n.desktopTrayOpenApplication,
        'chooseServer': l10n.desktopTrayChooseServer,
        'preferences': l10n.desktopTrayPreferences,
        'startupOptions': l10n.desktopTrayStartupOptions,
        'launchOnStartup': l10n.desktopTrayLaunchOnStartup,
        'autoConnect': l10n.appString_AutoConnect,
        'soundEffect': l10n.desktopTraySoundEffect,
        'startMinimized': l10n.desktopTrayStartMinimized,
        'forceClose': l10n.desktopTrayForceClose,
        'serviceMode': l10n.desktopTrayServiceMode,
        'proxyService': l10n.desktopTrayProxyService,
        'systemProxy': l10n.desktopTraySystemProxy,
        'vpnModeUnavailable': l10n.desktopTrayVpnModeUnavailable,
        'introduction': l10n.introduction,
        'speedTest': l10n.speedTest,
        'logs': l10n.appLogs,
        'exit': l10n.desktopTrayExit,
        'connect': l10n.connect,
        'disconnect': l10n.disconnect,
        'connected': l10n.connected,
        'disconnected': l10n.disconnected,
        'connecting': l10n.connecting,
        'disconnecting': l10n.desktopTrayDisconnecting,
        'cancelConnection': l10n.desktopTrayCancelConnection,
        'error': l10n.desktopTrayError,
        'ready': l10n.desktopTrayReady,
        'automatic': l10n.desktopTrayAutomatic,
      };

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    ref.watch(vpnNotificationsProvider).setLocale(state.locale);
    final connection = ref.watch(connectionStateProvider).asData?.value;
    final trayLabels = _trayLabels(AppLocalizations.of(context)!);
    if (io.Platform.isLinux && !_linuxTrayHandlerInstalled) {
      _linuxTrayHandlerInstalled = true;
      unawaited(HarmoneyBridge().setNativeActionHandler((call) async {
        switch (call.method) {
          case 'openServerList':
            _select(1);
            break;
          case 'openPreferences':
          case 'openSettings':
            _select(4);
            break;
          case 'openLogs':
            _openLogsFromWindowsTray();
            break;
          case 'openSpeedTest':
            _select(2);
            break;
          case 'openIntroduction':
            _select(0);
            break;
          case 'handleConnectionStatusClick':
          case 'triggerAutoConnect':
            await _toggleFromWindowsTray();
            break;
          case 'setAutoConnect':
            final args = call.arguments;
            if (args is Map && args['value'] is bool) {
              await widget.appState.setAutoConnect(args['value'] as bool);
            }
            break;
          case 'quitApplication':
            await _quitFromDesktopTray();
            break;
        }
        return null;
      }));
    }
    if (io.Platform.isLinux) {
      final signature = trayLabels.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('\u0000');
      if (_lastLinuxTrayLabels != signature) {
        _lastLinuxTrayLabels = signature;
        unawaited(HarmoneyBridge().updateTrayLabels(trayLabels));
      }
    }
    if (io.Platform.isWindows) {
      unawaited(WindowsTrayBridge.configure(
        onToggle: _toggleFromWindowsTray,
        onOpenApp: () => _select(0),
        onOpenServers: () => _select(1),
        onOpenSettings: () => _select(4),
        onOpenLogs: _openLogsFromWindowsTray,
        onToggleAutoConnect: () =>
            widget.appState.setAutoConnect(!widget.appState.autoConnect),
        onToggleLaunchOnStartup: _toggleLaunchOnStartupFromWindowsTray,
        onToggleStartMinimized: _toggleStartMinimizedFromWindowsTray,
        onQuit: _quitFromDesktopTray,
      ));
      unawaited(WindowsTrayBridge.update(
        connection,
        labels: trayLabels,
        autoConnect: state.autoConnect,
        launchOnStartup: state.launchOnStartup,
        startMinimized: state.startMinimized,
      ));
    }

    final pages = [
      // 0: Main Harmoney Screen
      MainScreen(
        appState: state,
        selectedServer: _selectedServer,
        isActive: _index == 0,
        onOpenLocations: () => _select(1),
        onOpenSpeedTest: () => _select(2),
        onOpenProtection: () => _select(3),
        onOpenSettings: () => _select(4),
      ),
      // 1: Locations & Server List
      LocationsPage(
        appState: state,
        onServerSelected: _connectTo,
        onSubscriptionSelected: _selectSubscription,
      ),
      // 2: Speed Test & Network Diagnostics
      const SpeedTestDiagnosticsPage(),
      // 3: Protection & Rules Suite
      _ProtectionAndRulesView(appState: state),
      // 4: Settings & Configuration
      SettingsPage(appState: state),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF092B3B),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: HarmoneyNavBar(
        currentIndex: _index,
        onSelect: _select,
      ),
    );
  }
}

class _ProtectionAndRulesView extends StatefulWidget {
  final AppState appState;

  const _ProtectionAndRulesView({required this.appState});

  @override
  State<_ProtectionAndRulesView> createState() =>
      _ProtectionAndRulesViewState();
}

class _ProtectionAndRulesViewState extends State<_ProtectionAndRulesView> {
  int _subTab = 0;
  int _prevSubTab = 0;

  void _setSubTab(int index) {
    if (_subTab == index) return;
    setState(() {
      _prevSubTab = _subTab;
      _subTab = index;
    });
  }

  Widget _buildHeader(BuildContext context, bool isPersian) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.h, 20.w, 6.h),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              color: const Color(0xFF00D4AA),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(
                  isPersian ? 'امنیت و سپر' : 'Security & Shield',
                  style: TextStyle(
                    fontSize: 23.sp.clamp(20, 26),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(height: 3.h),
                LocalizedText(
                  isPersian
                      ? 'کیل‌سوئیچ، حفاظت از نشت داده و مسیریابی هوشمند'
                      : 'Kill switch, leak protection & smart routing',
                  style: TextStyle(
                    fontSize: 12.sp.clamp(11, 14),
                    color: Colors.white60,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPersian = widget.appState.locale.languageCode == 'fa';

    const subPages = [
      ProtectionPage(),
      SplitTunnelPage(),
      HotspotPage(),
      StatisticsPage(),
    ];

    return MainScreenBackground(
      status: VpnConnectionStatus.disconnected,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, isPersian),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 4.h, 16.w, 10.h),
              child: AppleGlassCard(
                padding: const EdgeInsets.all(4),
                blur: 8,
                borderRadius: BorderRadius.circular(100),
                surfaceColor: const Color(0xFF08202D),
                surfaceAlpha: 0.54,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SubTabPill(
                        label: io.Platform.isWindows
                            ? (localizedUiText(
                                context,
                                (isPersian
                                    ? 'بایپس کشور و برنامه'
                                    : 'Country & App Bypass')))
                            : (localizedUiText(
                                context,
                                (isPersian
                                    ? 'امنیت و کیل‌سوئیچ'
                                    : 'Security & Kill Switch'))),
                        selected: _subTab == 0,
                        icon: io.Platform.isWindows
                            ? Icons.public_rounded
                            : Icons.security_rounded,
                        onTap: () => _setSubTab(0),
                      ),
                      const SizedBox(width: 4),
                      if (!io.Platform.isWindows) ...[
                        _SubTabPill(
                          label: localizedUiText(
                              context,
                              (isPersian
                                  ? 'تونل تفکیکی و بایپس'
                                  : 'Split Tunnel & Bypass')),
                          selected: _subTab == 1,
                          icon: Icons.alt_route_rounded,
                          onTap: () => _setSubTab(1),
                        ),
                        const SizedBox(width: 4),
                      ],
                      _SubTabPill(
                        label: localizedUiText(
                            context,
                            (isPersian
                                ? 'اشتراک هات‌اسپات'
                                : 'Hotspot Shield')),
                        selected: _subTab == 2,
                        icon: Icons.wifi_tethering_rounded,
                        onTap: () => _setSubTab(2),
                      ),
                      const SizedBox(width: 4),
                      _SubTabPill(
                        label: localizedUiText(
                            context,
                            (isPersian
                                ? 'نمودار و آمار ترافیک'
                                : 'Traffic Stats')),
                        selected: _subTab == 3,
                        icon: Icons.bar_chart_rounded,
                        onTap: () => _setSubTab(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isIncoming = child.key == ValueKey<int>(_subTab);
                  final isForward = _subTab >= _prevSubTab;
                  final beginX = isIncoming
                      ? (isForward ? 0.05 : -0.05)
                      : (isForward ? -0.05 : 0.05);

                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(beginX, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_subTab),
                  child: subPages[_subTab],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubTabPill extends StatefulWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _SubTabPill({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SubTabPill> createState() => _SubTabPillState();
}

class _SubTabPillState extends State<_SubTabPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.selected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA).withValues(alpha: 0.35),
                      const Color(0xFF00E5FF).withValues(alpha: 0.20),
                    ],
                  )
                : (_isHovered
                    ? LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      )
                    : null),
            color: widget.selected
                ? null
                : (_isHovered ? null : Colors.transparent),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF00D4AA).withValues(alpha: 0.8)
                  : (_isHovered
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent),
              width: 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00D4AA).withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.selected
                    ? const Color(0xFF61F2C2)
                    : (_isHovered ? Colors.white : Colors.white60),
              ),
              const SizedBox(width: 6),
              LocalizedText(
                widget.label,
                style: TextStyle(
                  color: widget.selected
                      ? Colors.white
                      : (_isHovered ? Colors.white : Colors.white70),
                  fontSize: 12.sp.clamp(11.0, 14.0),
                  fontFamily: 'Lato',
                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
