import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_state.dart';
import '../../core/linux_platform_controls.dart';
import '../../core/vpn_core.dart';
import '../../core/vpn_core_providers.dart';
import '../../shared/layout/main_screen_background.dart';
import '../shared/harmoney_pro_download_card.dart';
import '../../shared/country_flag.dart';
import '../../shared/services/haptic_service.dart';
import '../../core/harmoney_source_updater.dart';
import '../../core/network_monitor_service.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../core/harmoney_subscription_service.dart';
import 'harmoney_subscriptions_dialog.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class LocationsPage extends ConsumerStatefulWidget {
  const LocationsPage({
    super.key,
    required this.appState,
    required this.onServerSelected,
    required this.onSubscriptionSelected,
  });

  final AppState appState;
  final ValueChanged<VpnServer> onServerSelected;
  final ValueChanged<VpnServer> onSubscriptionSelected;

  @override
  ConsumerState<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends ConsumerState<LocationsPage> {
  final _controls = LinuxPlatformControls();
  final controller = TextEditingController();
  final favorites = <String>{};
  final recent = <String>[];
  final probing = <String>{};
  final _probeResults = <String, int?>{};
  final _probeFailures = <String>{};
  final _probeErrors = <String, String>{};
  int _probeGeneration = 0;
  final _probeQueue = <String>{};
  int _probeCompleted = 0;
  int _probeTotal = 0;
  VpnServer? _activeProbe;
  StreamSubscription<String>? _physicalNetworkSub;
  bool _connectInProgress = false;

  List<Map<String, dynamic>> _customLists = [];
  String? _selectedCustomListId;
  String? _expandedHarmoneySubscriptionId;
  String? _selectedHarmoneySubscriptionId;
  String _selectedHarmoneyCategory = 'all';
  int _filterMode = 0; // 0: All, 1: Favorites, 2: Lowest Ping, 3: Recent
  bool _hideOfflineServers = true;

  Widget _buildFlagBadge(VpnServer server) {
    if (server.id == 'harmoney-smart' || server.countryCode == 'AUTO') {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00E5FF).withValues(alpha: 0.25),
              const Color(0xFF0091EA).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.bolt_rounded,
          size: 20.sp,
          color: const Color(0xFF00E5FF),
        ),
      );
    }

    if (server.providerId == 'harmoney' &&
        (server.id.contains('warp') || server.id.contains('masque'))) {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF9900).withValues(alpha: 0.25),
              const Color(0xFFFF6D00).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF9900).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9900).withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.cloud_queue_rounded,
          size: 18.sp,
          color: const Color(0xFFFF9900),
        ),
      );
    }

    if (server.id.contains('psiphon')) {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: 0.25),
              const Color(0xFF1D4ED8).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.hub_rounded,
          size: 18.sp,
          color: const Color(0xFF3B82F6),
        ),
      );
    }

    if (server.id.contains('xray')) {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10BFA3).withValues(alpha: 0.25),
              const Color(0xFF0F766E).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF10BFA3).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10BFA3).withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.security_rounded,
          size: 18.sp,
          color: const Color(0xFF61F2C2),
        ),
      );
    }

    if (server.id.contains('outline')) {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFA855F7).withValues(alpha: 0.25),
              const Color(0xFF7E22CE).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.key_rounded,
          size: 18.sp,
          color: const Color(0xFFA855F7),
        ),
      );
    }

    if (server.id.contains('trojan')) {
      return Container(
        width: 38.w.clamp(34.0, 42.0),
        height: 38.w.clamp(34.0, 42.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEC4899).withValues(alpha: 0.25),
              const Color(0xFFBE185D).withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFEC4899).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.lock_rounded,
          size: 18.sp,
          color: const Color(0xFFEC4899),
        ),
      );
    }

    return Container(
      width: 38.w.clamp(34.0, 42.0),
      height: 38.w.clamp(34.0, 42.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CountryFlag(
          code: CountryFlags.resolve(server),
          size: 38.w.clamp(34.0, 42.0),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAppStateChanged);
    _physicalNetworkSub = NetworkMonitorService.instance.physicalNetworkChanges
        .listen((_) => _onAppStateChanged(), onError: (Object error) {});
    _loadLists();
  }

  void _onAppStateChanged() {
    if (!mounted) return;
    _probeGeneration++;
    setState(() {
      _probeResults.clear();
      _probeFailures.clear();
      _probeErrors.clear();
      _probeQueue.clear();
      _probeCompleted = 0;
      _probeTotal = 0;
    });
  }

  Future<void> _loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteNodeIds =
        await HarmoneySubscriptionService.instance.favoriteNodeIds();
    List<Map<String, dynamic>> custom = [];
    if (Platform.isLinux) {
      custom = await _controls.getLocationLists();
    }
    if (!mounted) return;
    setState(() {
      favorites
        ..addAll(prefs.getStringList('favorite_locations') ?? const [])
        ..addAll(favoriteNodeIds.map((id) => 'harmoney-sub-$id'));
      recent.addAll(prefs.getStringList('recent_locations') ?? const []);
      _customLists = custom;
    });
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    _physicalNetworkSub?.cancel();
    controller.dispose();
    super.dispose();
  }

  void toggleFavorite(VpnServer server) {
    final wasFavorite = favorites.contains(server.id);
    setState(() {
      wasFavorite ? favorites.remove(server.id) : favorites.add(server.id);
    });
    if (server.subscriptionNodeId != null) {
      unawaited(
        HarmoneySubscriptionService.instance.setNodeFavorite(
          server.subscriptionNodeId!,
          !wasFavorite,
        ),
      );
    }
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList('favorite_locations', favorites.toList()),
    );
  }

  void markRecent(VpnServer server) {
    setState(() {
      recent.remove(server.id);
      recent.insert(0, server.id);
      if (recent.length > 5) recent.removeLast();
    });
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList('recent_locations', recent),
    );
  }

  Future<void> connect(VpnServer server) async {
    if (!server.available || _connectInProgress) return;
    _connectInProgress = true;
    try {
      markRecent(server);
      widget.onServerSelected(server);
      await ref.read(vpnCoreProvider).connect(
            providerId: server.providerId,
            server: server,
            protocol: widget.appState.protocol.toLowerCase(),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.shade700,
            content: LocalizedText(error.toString()),
          ),
        );
      }
    } finally {
      _connectInProgress = false;
    }
  }

  Future<void> _showHarmoneySubscriptions() async {
    await HarmoneySubscriptionsDialog.show(
      context,
      isPersian: widget.appState.locale.languageCode == 'fa',
    );
    if (!mounted) return;
    ref.invalidate(vpnServersProvider('harmoney'));
  }

  List<MapEntry<String, List<VpnServer>>> _harmoneySubscriptionGroups(
    List<VpnServer> servers,
  ) {
    final groups = <String, List<VpnServer>>{};
    for (final server in servers) {
      final subscriptionId = server.subscriptionId;
      if (server.subscriptionNodeId == null || subscriptionId == null) continue;
      groups.putIfAbsent(subscriptionId, () => <VpnServer>[]).add(server);
    }
    return groups.entries.toList(growable: false);
  }

  void _selectHarmoneySubscription(
    String subscriptionId,
    List<VpnServer> servers,
  ) {
    if (servers.isEmpty) return;
    setState(() {
      _selectedHarmoneySubscriptionId = subscriptionId;
      _expandedHarmoneySubscriptionId = subscriptionId;
    });
    final first = servers.first;
    widget.onSubscriptionSelected(
      VpnServer(
        id: 'harmoney-subscription-$subscriptionId',
        providerId: 'harmoney',
        country: first.country,
        city: widget.appState.locale.languageCode == 'fa'
            ? 'اشتراک انتخاب‌شده'
            : 'Selected subscription',
        hostname: '',
        countryCode: 'SUB',
        available: servers.any((server) => server.available),
        subscriptionId: subscriptionId,
      ),
    );
  }

  Widget _buildHarmoneySubscriptionCard(
    String subscriptionId,
    List<VpnServer> servers,
    bool isPersian,
  ) {
    final expanded = _expandedHarmoneySubscriptionId == subscriptionId;
    final selected = _selectedHarmoneySubscriptionId == subscriptionId;
    final connection = ref.watch(connectionStateProvider).valueOrNull;
    final activeNodeId = connection?.isConnected == true &&
            connection?.server?.subscriptionId == subscriptionId
        ? connection?.server?.subscriptionNodeId
        : null;
    final orderedServers = [...servers];
    if (activeNodeId != null) {
      final activeIndex = orderedServers.indexWhere(
        (server) => server.subscriptionNodeId == activeNodeId,
      );
      if (activeIndex > 0) {
        orderedServers.insert(0, orderedServers.removeAt(activeIndex));
      }
    }
    final name = servers.first.country;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF092936),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
                color: const Color(0xFF00D4AA).withValues(alpha: .3)),
          ),
          child: ListTile(
            onTap: () {
              if (!selected || !expanded) {
                _selectHarmoneySubscription(subscriptionId, servers);
              } else {
                setState(() => _expandedHarmoneySubscriptionId = null);
              }
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            leading: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D4AA).withValues(alpha: .12),
              ),
              child: Icon(Icons.link_rounded,
                  color: const Color(0xFF00D4AA), size: 22.sp),
            ),
            title: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${servers.length} ${isPersian ? 'سرور' : 'servers'} · ${isPersian ? 'برای دیدن و انتخاب لمس کنید' : 'Tap to view and select'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp),
            ),
            trailing: Icon(
              selected ? Icons.check_circle_rounded : Icons.expand_more_rounded,
              color: selected ? const Color(0xFF00D4AA) : Colors.white60,
              size: 24.sp,
            ),
          ),
        ),
        if (expanded)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF071D28),
              border: Border.all(
                color: const Color(0xFF00D4AA).withValues(alpha: .24),
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _probeTotal > 0
                            ? '${isPersian ? 'در حال پینگ' : 'Pinging'} $_probeCompleted/$_probeTotal'
                            : (isPersian
                                ? 'برای گرفتن پینگ دستی بزن'
                                : 'Run a manual latency check'),
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _probeTotal > 0
                          ? null
                          : () => unawaited(probeVisible(servers)),
                      icon: const Icon(Icons.speed_rounded, size: 17),
                      label: Text(isPersian
                          ? 'پینگ همه'
                          : 'Ping all'),
                    ),
                  ],
                ),
                if (_probeTotal > 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: LinearProgressIndicator(
                      value: _probeTotal == 0
                          ? null
                          : _probeCompleted / _probeTotal,
                      minHeight: 2,
                    ),
                  ),
                for (final server in orderedServers)
                  _buildHarmoneySubscriptionNode(server, isPersian),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHarmoneySubscriptionNode(VpnServer server, bool isPersian) {
    final latency = _probeResults[server.id] ?? server.latencyMs;
    final isProbing = probing.contains(server.id);
    final connection = ref.watch(connectionStateProvider).valueOrNull;
    final activeServer = connection?.server;
    String normalizedHost(String? value) => (value ?? '')
        .trim()
        .toLowerCase()
        .replaceFirst(RegExp(r'^https?://'), '')
        .split('/')
        .first;
    final sameSubscription =
        activeServer?.subscriptionId == server.subscriptionId;
    final activeHost = normalizedHost(activeServer?.hostname);
    final targetHost = normalizedHost(server.hostname);
    final endpointHost = normalizedHost(connection?.endpoint);
    final sameNode = (activeServer?.subscriptionNodeId != null &&
            activeServer?.subscriptionNodeId == server.subscriptionNodeId) ||
        activeServer?.id == server.id ||
        (sameSubscription &&
            activeHost.isNotEmpty &&
            activeHost == targetHost) ||
        (endpointHost.isNotEmpty && endpointHost == targetHost);
    final isConnected = connection?.isConnected == true &&
        (connection?.providerId == 'harmoney' ||
            activeServer?.providerId == 'harmoney') &&
        sameNode;
    final pingLabel = latency != null
        ? ' · $latency ms'
        : (_probeFailures.contains(server.id)
            ? (isPersian
                ? ' · بدون پاسخ'
                : ' · No response')
            : '');
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: ListTile(
        enabled: server.available,
        onTap: server.available ? () => connect(server) : null,
        leading: Icon(
          server.available ? Icons.dns_rounded : Icons.warning_amber_rounded,
          color:
              server.available ? const Color(0xFF00D4AA) : Colors.orangeAccent,
          size: 21.sp,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                server.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isConnected) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isPersian ? 'متصل' : 'Connected',
                  style: TextStyle(
                    color: const Color(0xFF00D4AA),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          server.available
              ? '${server.hostname}$pingLabel'
              : (isPersian
                  ? 'با این دستگاه سازگار نیست'
                  : 'Not compatible with this device'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white54, fontSize: 10.sp),
        ),
        trailing: isProbing
            ? SizedBox.square(
                dimension: 16.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                server.available
                    ? Icons.chevron_right_rounded
                    : Icons.block_rounded,
                color: server.available ? Colors.white54 : Colors.orangeAccent,
                size: 20.sp,
              ),
      ),
    );
  }

  String _probeErrorLabel(String serverId) {
    final error = (_probeErrors[serverId] ?? '').toLowerCase();
    final fa = widget.appState.locale.languageCode == 'fa';
    if (error.contains('profile') ||
        error.contains('پروفایل')) {
      return fa
          ? 'پروفایل لازم است'
          : 'Needs profile';
    }
    if (error.contains('vpn_busy'))
      return fa ? 'VPN فعال است' : 'VPN busy';
    if (error.contains('dns_error'))
      return fa ? 'خطای DNS' : 'DNS error';
    if (error.contains('data_path_blocked')) {
      return fa
          ? 'ترافیک عبور نمی‌کند'
          : 'Traffic blocked';
    }
    if (error.contains('auth_failed') || error.contains('credentials')) {
      return fa
          ? 'خطای احراز هویت'
          : 'Authentication failed';
    }
    if (error.contains('timeout') ||
        error.contains('timed out') ||
        error.contains('no response')) {
      return fa ? 'تایم‌اوت' : 'Timeout';
    }
    return fa ? 'تست ناموفق' : 'Test failed';
  }

  Future<void> probe(
    VpnServer server, {
    bool refresh = true,
    bool showError = true,
  }) async {
    if (!mounted || probing.contains(server.id)) return;
    final generation = _probeGeneration;
    final protocol = widget.appState.protocol.toLowerCase();
    setState(() {
      _probeQueue.remove(server.id);
      probing.add(server.id);
      _probeFailures.remove(server.id);
      _probeErrors.remove(server.id);
      _probeResults.remove(server.id);
      _activeProbe = server;
    });
    try {
      final latency = await ref.read(vpnCoreProvider).probeServer(
            providerId: server.providerId,
            serverId: server.id,
            protocol: protocol,
          );
      if (!mounted || generation != _probeGeneration) return;
      if (latency == null) {
        setState(() {
          _probeFailures.add(server.id);
          _probeErrors[server.id] = "No response";
        });
      } else if (mounted) {
        setState(() => _probeResults[server.id] = latency);
      }
      if (refresh) {
        ref.invalidate(vpnServersProvider(widget.appState.provider));
      }
    } catch (error) {
      if (!mounted || generation != _probeGeneration) return;
      final detail = error is PlatformException
          ? '${error.code}: ${error.message ?? ""}'
          : error.toString();
      setState(() {
        _probeFailures.add(server.id);
        _probeErrors[server.id] = detail;
      });
      if (mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: LocalizedText('Latency test failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          probing.remove(server.id);
          if (_activeProbe?.id == server.id) _activeProbe = null;
        });
      }
    }
  }

  Future<void> probeVisible(List<VpnServer> servers) async {
    if (!mounted) return;
    final generation = ++_probeGeneration;
    final visible = servers.where((server) => server.available).toList();
    setState(() {
      _probeCompleted = 0;
      _probeTotal = visible.length;
      _probeQueue
        ..clear()
        ..addAll(visible.map((server) => server.id));
      _probeFailures.clear();
      _probeErrors.clear();
    });

    var next = 0;
    Future<void> worker() async {
      while (true) {
        if (!mounted ||
            generation != _probeGeneration ||
            next >= visible.length) {
          return;
        }
        final server = visible[next++];
        await probe(server, refresh: false, showError: false);
        if (mounted && generation == _probeGeneration) {
          setState(() => _probeCompleted++);
        }
      }
    }

    final workers = Platform.isLinux ? 4 : 3;
    await Future.wait(List.generate(workers, (_) => worker()));
    if (mounted && generation == _probeGeneration) {
      setState(() {
        _probeCompleted = 0;
        _probeTotal = 0;
        _probeQueue.clear();
        _activeProbe = null;
      });
      ref.invalidate(vpnServersProvider(widget.appState.provider));
    }
  }

  Widget _buildTopBar(BuildContext context, int totalCount) {
    final isPersian = widget.appState.locale.languageCode == 'fa';
    final connState = ref.watch(connectionStateProvider);
    final isConnected = connState.valueOrNull?.isConnected ?? false;
    final title = LocalizedText(
      isPersian
          ? '\u0633\u0631\u0648\u0631\u0647\u0627 \u0648 \u0645\u0633\u06cc\u0631\u0647\u0627'
          : 'Locations & Routes',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18.sp.clamp(16, 21),
        fontFamily: 'Lato',
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
    final connectedBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00D4AA),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00D4AA),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          LocalizedText(
            isPersian ? '\u0645\u062a\u0635\u0644' : 'Connected',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00D4AA),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final titleAndStatus = Row(
          children: [
            Expanded(child: title),
            if (isConnected) ...[
              SizedBox(width: 8.w),
              connectedBadge,
            ],
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleAndStatus,
              SizedBox(height: 10.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _buildProviderSelector(context),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleAndStatus),
            SizedBox(width: 12.w),
            _buildProviderSelector(context),
          ],
        );
      },
    );
  }

  Widget _buildProviderSelector(BuildContext context) {
    final isPersian = widget.appState.locale.languageCode == 'fa';
    final isFirefox = widget.appState.provider == 'firetunnel';
    final badgeColor =
        isFirefox ? const Color(0xFFFF9100) : const Color(0xFF00E5FF);
    final name = isFirefox ? 'Firefox VPN' : 'Harmoney Smart';
    final icon =
        isFirefox ? Icons.local_fire_department_rounded : Icons.bolt_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isFirefox) ...[
          IconButton(
            tooltip: isPersian
                ? localizedUiText(context,
                    'اشتراک‌های شخصی')
                : localizedUiText(context, 'Personal subscriptions'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _showHarmoneySubscriptions,
            icon: Icon(
              Icons.link_rounded,
              color: const Color(0xFF00E5FF),
              size: 17.sp,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        InkWell(
          onTap: () {
            HapticService.selectionClick();
            _showProviderSheet(context);
          },
          borderRadius: BorderRadius.circular(100.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: 0.22),
                  badgeColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.45),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14.sp, color: badgeColor),
                SizedBox(width: 5.w),
                LocalizedText(
                  name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: badgeColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProviderSheet(BuildContext context) {
    final isPersian = widget.appState.locale.languageCode == 'fa';
    final current = widget.appState.provider;
    final providers = [
      (
        'harmoney',
        'Harmoney Smart',
        isPersian
            ? 'مسیریابی هوشمند و اشتراک‌های شخصی'
            : 'Smart routing and personal subscriptions',
        Icons.bolt_rounded,
        const Color(0xFF00E5FF),
      ),
      (
        'firetunnel',
        'Firefox VPN',
        isPersian
            ? 'تونل سبک Firefox VPN'
            : 'Lightweight Firefox VPN tunnel',
        Icons.local_fire_department_rounded,
        const Color(0xFFFF9100),
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF071F2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              LocalizedText(
                isPersian
                    ? 'انتخاب سرویس اتصال'
                    : 'Select connection service',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 14.h),
              ...providers.map((provider) {
                final (id, title, description, providerIcon, color) = provider;
                final selected = current == id;
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selected ? color : Colors.white10,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(providerIcon, color: color),
                    title: LocalizedText(
                      title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: LocalizedText(
                      description,
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded, color: color)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      if (current == id) return;
                      await widget.appState.setProvider(id);
                      ref.invalidate(vpnServersProvider(id));
                      setState(() {
                        _selectedHarmoneyCategory = 'all';
                        _filterMode = 0;
                      });
                    },
                  ),
                );
              }),
              SizedBox(height: 4.h),
              const HarmoneyProDownloadCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalBars(int latency) {
    final barsCount = latency <= 100 ? 3 : (latency <= 220 ? 2 : 1);
    final color = latency <= 100
        ? const Color(0xFF61F2C2)
        : (latency <= 220 ? const Color(0xFFFFC46B) : const Color(0xFFFF5252));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (idx) {
        final active = idx < barsCount;
        final barHeight = 4.0 + (idx * 3.5);
        return Container(
          width: 2.5,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: active ? color : Colors.white24,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildFirefoxProtocolBanner(bool isPersian) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.orangeAccent,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          LocalizedText(
            isPersian
                ? 'پروتکل اتصال Firefox'
                : 'Firefox VPN protocol',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: LocalizedText(
              'HTTP/2 CONNECT',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarmoneySourcesStatusBanner(
    BuildContext context,
    bool isPersian,
  ) {
    return ValueListenableBuilder<HarmoneyRefreshState>(
      valueListenable: HarmoneySourceUpdater.instance.stateNotifier,
      builder: (context, state, _) {
        final lastTimeStr = _formatLastUpdated(
          state.lastSuccessfulUpdate,
          isPersian,
        );

        final (
          Color accentColor,
          IconData statusIcon,
          String statusTitle,
        ) = switch (state.status) {
          'refreshing' => (
              const Color(0xFF00E5FF),
              Icons.sync_rounded,
              isPersian
                  ? 'در حال دریافت و بررسی منابع…'
                  : 'Fetching & validating feeds…',
            ),
          'success' => (
              const Color(0xFF00D4AA),
              Icons.verified_rounded,
              isPersian
                  ? 'منابع به‌روز و تأیید شدند (${state.activeFeeds} منبع فعال)'
                  : 'Feeds updated & verified (${state.activeFeeds} active)',
            ),
          'partial' => (
              const Color(0xFFFFC46B),
              Icons.info_outline_rounded,
              isPersian
                  ? '${state.activeFeeds} از ${state.totalFeeds} منبع فید تأیید شد'
                  : '${state.activeFeeds} of ${state.totalFeeds} feeds verified',
            ),
          'offline' => (
              const Color(0xFFFF5252),
              Icons.wifi_off_rounded,
              isPersian
                  ? 'اینترنت قطع است؛ کانفیگ سالم قبلی حفظ شد'
                  : 'Offline; preserved last healthy config',
            ),
          'failed' => (
              const Color(0xFFFF5252),
              Icons.error_outline_rounded,
              isPersian
                  ? (state.errorMessage ??
                      'خطا در دریافت؛ کانفیگ سالم قبلی حفظ شد')
                  : (state.errorMessage ??
                      'Update failed; preserved last healthy config'),
            ),
          _ => (
              const Color(0xFF00D4AA),
              Icons.cloud_done_rounded,
              state.activeFeeds > 0
                  ? (isPersian
                      ? '${state.activeFeeds} منبع فعال آماده اتصال'
                      : '${state.activeFeeds} active feeds ready')
                  : (isPersian
                      ? 'منابع بسته‌بندی‌شده هارمونی'
                      : 'Harmoney bundled sources'),
            ),
        };

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  state.isRefreshing
                      ? SizedBox(
                          width: 18.sp,
                          height: 18.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                          ),
                        )
                      : Icon(statusIcon, color: accentColor, size: 18.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedText(
                          statusTitle,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        LocalizedText(
                          isPersian
                              ? 'آخرین دریافت موفق: $lastTimeStr'
                              : 'Last successful update: $lastTimeStr',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: state.isRefreshing
                        ? null
                        : () async {
                            HapticService.lightClick();
                            await ref
                                .read(vpnCoreProvider)
                                .refreshServers(providerId: 'harmoney');
                            ref.invalidate(vpnServersProvider('harmoney'));
                          },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14.sp,
                            color: accentColor,
                          ),
                          SizedBox(width: 4.w),
                          LocalizedText(
                            isPersian
                                ? 'به‌روزرسانی'
                                : 'Refresh',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (state.isRefreshing) ...[
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: state.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 3.h,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatLastUpdated(DateTime? dt, bool isPersian) {
    if (dt == null) {
      return isPersian
          ? 'هنوز انجام نشده'
          : 'Never';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return isPersian ? 'لحظاتی پیش' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      return isPersian
          ? '${diff.inMinutes} دقیقه پیش'
          : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return isPersian
          ? '${diff.inHours} ساعت پیش'
          : '${diff.inHours}h ago';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSearchBar(int serverCount, List<VpnServer> allFiltered) {
    final isPersian = widget.appState.locale.languageCode == 'fa';
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0B2433).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.28),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF00D4AA),
            size: 19.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 13.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: isPersian
                    ? localizedUiText(context,
                        'جستجوی کشور، شهر، آی‌پی...')
                    : localizedUiText(context, 'Search country, city, IP...'),
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => controller.clear()),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white60,
                  size: 16.sp,
                ),
              ),
            ),
          Container(
            width: 1,
            height: 18.h,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            color: Colors.white12,
          ),
          if (allFiltered.isNotEmpty)
            Tooltip(
              message: isPersian
                  ? 'تست پینگ همه سرورها'
                  : 'Ping all visible',
              child: InkWell(
                onTap:
                    probing.isNotEmpty ? null : () => probeVisible(allFiltered),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        probing.isNotEmpty
                            ? Icons.radar_rounded
                            : Icons.speed_rounded,
                        size: 13.sp,
                        color: const Color(0xFF00D4AA),
                      ),
                      SizedBox(width: 4.w),
                      LocalizedText(
                        _probeTotal > 0
                            ? '$_probeCompleted/$_probeTotal'
                            : (isPersian
                                ? 'تست پینگ'
                                : 'Ping All'),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00D4AA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(width: 6.w),
          Tooltip(
            message: isPersian
                ? 'بروزرسانی کاتالوگ'
                : 'Refresh Catalog',
            child: GestureDetector(
              onTap: () async {
                HapticService.selectionClick();
                await ref
                    .read(vpnCoreProvider)
                    .refreshServers(providerId: widget.appState.provider);
                ref.invalidate(vpnServersProvider(widget.appState.provider));
              },
              child: Container(
                padding: EdgeInsets.all(5.5.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white70,
                  size: 15.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedFilterRow(List<VpnServer> allServers) {
    final isPersian = widget.appState.locale.languageCode == 'fa';
    final provider = widget.appState.provider;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // All
          _buildFilterChip(
            label: isPersian ? 'همه' : 'All',
            icon: Icons.grid_view_rounded,
            count: allServers.length,
            selected: _filterMode == 0 &&
                (provider != 'harmoney' || _selectedHarmoneyCategory == 'all'),
            onTap: () {
              setState(() {
                _filterMode = 0;
                _selectedHarmoneyCategory = 'all';
              });
            },
          ),
          SizedBox(width: 6.w),

          // Recent ("اونایی که قبلا وصل شده طرف")
          _buildFilterChip(
            label: isPersian
                ? 'اخیراً متصل‌شده'
                : 'Recent',
            icon: Icons.history_rounded,
            count: recent.length,
            selected: _filterMode == 3,
            accentColor: const Color(0xFF00E5FF),
            onTap: () {
              setState(() => _filterMode = 3);
            },
          ),
          SizedBox(width: 6.w),

          // Provider-specific category chips right in the SAME row!
          if (provider == 'harmoney') ...[
            _buildFilterChip(
              label: isPersian
                  ? 'هوشمند و وارپ'
                  : 'Smart & Warp',
              icon: Icons.bolt_rounded,
              selected:
                  _filterMode == 0 && _selectedHarmoneyCategory == 'smart',
              accentColor: const Color(0xFF00E5FF),
              onTap: () {
                setState(() {
                  _filterMode = 0;
                  _selectedHarmoneyCategory = 'smart';
                });
              },
            ),
            SizedBox(width: 6.w),
            _buildFilterChip(
              label:
                  isPersian ? 'سایفون / Reality' : 'Stealth',
              icon: Icons.shield_outlined,
              selected:
                  _filterMode == 0 && _selectedHarmoneyCategory == 'stealth',
              accentColor: const Color(0xFFFF9100),
              onTap: () {
                setState(() {
                  _filterMode = 0;
                  _selectedHarmoneyCategory = 'stealth';
                });
              },
            ),
            SizedBox(width: 6.w),
          ],

          // Favorites
          _buildFilterChip(
            label: isPersian
                ? 'برگزیده‌ها'
                : 'Favorites',
            icon: Icons.star_rounded,
            count: favorites.length,
            selected: _filterMode == 1,
            accentColor: const Color(0xFFFFC46B),
            onTap: () {
              setState(() => _filterMode = 1);
            },
          ),
          SizedBox(width: 6.w),

          // Lowest Ping
          _buildFilterChip(
            label: isPersian
                ? 'کمترین پینگ'
                : 'Lowest Ping',
            icon: Icons.bolt_rounded,
            selected: _filterMode == 2,
            accentColor: const Color(0xFF61F2C2),
            onTap: () {
              setState(() => _filterMode = 2);
            },
          ),
          SizedBox(width: 6.w),

          // Auto-hide offline servers ("یا اتوماتیک حذف بشه")
          _buildFilterChip(
            label: isPersian
                ? 'فقط آنلاین'
                : 'Online Only',
            icon: _hideOfflineServers
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            selected: _hideOfflineServers,
            accentColor: const Color(0xFF00D4AA),
            onTap: () {
              setState(() => _hideOfflineServers = !_hideOfflineServers);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    int? count,
    Color accentColor = const Color(0xFF00D4AA),
  }) {
    return InkWell(
      onTap: () {
        HapticService.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(100.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.5.h),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? accentColor : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.4 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: selected ? accentColor : Colors.white60,
            ),
            SizedBox(width: 5.w),
            LocalizedText(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: 'Lato',
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
            if (count != null && count > 0) ...[
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: selected
                      ? accentColor.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: LocalizedText(
                  '$count',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerCard(VpnServer server, {bool isFastest = false}) {
    final isProbing = probing.contains(server.id);
    final latency = _probeResults[server.id] ?? server.latencyMs;
    final isFav = favorites.contains(server.id);
    final probeFailed = _probeFailures.contains(server.id);
    final isQueued = _probeQueue.contains(server.id);

    final connState = ref.watch(connectionStateProvider);
    final activeServer = connState.valueOrNull?.server;
    final isConnected = connState.valueOrNull?.isConnected ?? false;
    final isActive = isConnected &&
        (activeServer?.id == server.id ||
            (activeServer?.hostname == server.hostname &&
                activeServer?.country == server.country));

    final isPersian = widget.appState.locale.languageCode == 'fa';

    return Container(
      margin: EdgeInsets.only(bottom: 9.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  const Color(0xFF0F3A44).withValues(alpha: 0.95),
                  const Color(0xFF082229).withValues(alpha: 0.98),
                ]
              : (isFastest
                  ? [
                      const Color(0xFF163647).withValues(alpha: 0.92),
                      const Color(0xFF0A2230).withValues(alpha: 0.96),
                    ]
                  : [
                      const Color(0xFF0E2C3D).withValues(alpha: 0.85),
                      const Color(0xFF081F2B).withValues(alpha: 0.95),
                    ]),
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00D4AA)
              : (isFastest
                  ? const Color(0xFFFFC46B).withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.08)),
          width: isActive ? 1.5 : (isFastest ? 1.2 : 1.0),
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 3),
            )
          else if (isFastest)
            BoxShadow(
              color: const Color(0xFFFFC46B).withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.selectionClick();
            connect(server);
          },
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _buildFlagBadge(server),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: LocalizedText(
                              server.country,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4AA)
                                    .withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFF00D4AA)
                                      .withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00D4AA),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  LocalizedText(
                                    isPersian ? 'متصل' : 'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF00D4AA),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isFastest) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC46B)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFFFFC46B)
                                      .withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: LocalizedText(
                                'FASTEST ⚡',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFC46B),
                                ),
                              ),
                            ),
                          ] else if (recent.contains(server.id)) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(5.r),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF)
                                      .withValues(alpha: 0.35),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 9.sp,
                                    color: const Color(0xFF00E5FF),
                                  ),
                                  SizedBox(width: 3.w),
                                  LocalizedText(
                                    isPersian ? 'اخیر' : 'Recent',
                                    style: TextStyle(
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00E5FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      LocalizedText(
                        '${server.city} · ${server.hostname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Latency Badge & Signal Indicator
                if (isProbing)
                  SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00D4AA),
                      ),
                    ),
                  )
                else if (isQueued)
                  LocalizedText(
                    'Queued…',
                    style: TextStyle(fontSize: 11.sp, color: Colors.white38),
                  )
                else if (latency != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: latency < 120
                          ? const Color(0xFF61F2C2).withValues(alpha: 0.15)
                          : (latency < 250
                              ? const Color(0xFFFFC46B).withValues(alpha: 0.15)
                              : Colors.redAccent.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: latency < 120
                            ? const Color(0xFF61F2C2).withValues(alpha: 0.4)
                            : (latency < 250
                                ? const Color(0xFFFFC46B).withValues(alpha: 0.4)
                                : Colors.redAccent.withValues(alpha: 0.4)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSignalBars(latency),
                        SizedBox(width: 5.w),
                        LocalizedText(
                          '${latency}ms',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Lato',
                            color: latency < 120
                                ? const Color(0xFF61F2C2)
                                : (latency < 250
                                    ? const Color(0xFFFFC46B)
                                    : Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (probeFailed)
                  Tooltip(
                    message: _probeErrors[server.id] ?? 'No response',
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        probe(server);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: LocalizedText(
                          _probeErrorLabel(server.id),
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      HapticService.selectionClick();
                      probe(server);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              const Color(0xFF00D4AA).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 12.sp,
                            color: const Color(0xFF00D4AA),
                          ),
                          SizedBox(width: 3.w),
                          LocalizedText(
                            'Ping',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'Lato',
                              color: const Color(0xFF00D4AA),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: 6.w),
                // Favorite Star
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? const Color(0xFFFFC46B) : Colors.white30,
                    size: 22.sp,
                  ),
                  onPressed: () {
                    HapticService.selectionClick();
                    toggleFavorite(server);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<VpnServer> _getCategoryServers(List<VpnServer> servers) {
    if (widget.appState.provider != 'harmoney' ||
        _selectedHarmoneyCategory == 'all') {
      return servers;
    }
    return servers.where((server) {
      if (_selectedHarmoneyCategory == 'smart') {
        return server.id == 'harmoney-smart' || server.id.contains('warp');
      }
      if (_selectedHarmoneyCategory == 'stealth') {
        return server.id.contains('psiphon') ||
            server.id.contains('xray') ||
            server.id.contains('outline') ||
            server.id.contains('trojan');
      }
      if (_selectedHarmoneyCategory == 'nodes') {
        return !server.id.contains('smart') &&
            !server.id.contains('warp') &&
            !server.id.contains('psiphon') &&
            !server.id.contains('xray') &&
            !server.id.contains('outline') &&
            !server.id.contains('trojan');
      }
      return true;
    }).toList();
  }

  List<VpnServer> _getFilteredServers({
    required List<VpnServer> servers,
    required String query,
  }) {
    final customList = _selectedCustomListId != null
        ? _customLists.firstWhere(
            (l) => l['id'] == _selectedCustomListId,
            orElse: () => <String, dynamic>{},
          )
        : null;
    final customIds = customList != null
        ? (customList['location_ids'] as List? ?? []).toSet()
        : null;

    final categoryServers = _getCategoryServers(servers);

    var filtered = categoryServers.where((server) {
      if (customIds != null && !customIds.contains(server.id)) {
        return false;
      }
      return server.country.toLowerCase().contains(query) ||
          server.city.toLowerCase().contains(query) ||
          server.hostname.toLowerCase().contains(query);
    }).toList();

    // Auto-hide offline/dead servers ("یا اتوماتیک حذف بشه")
    if (_hideOfflineServers) {
      filtered = filtered.where((server) {
        if (!server.available) return false;
        if (_probeFailures.contains(server.id)) return false;
        return true;
      }).toList();
    }

    if (_filterMode == 1) {
      filtered = filtered.where((s) => favorites.contains(s.id)).toList();
    } else if (_filterMode == 2) {
      filtered.sort((a, b) {
        final latA = _probeResults[a.id] ?? a.latencyMs ?? 9999;
        final latB = _probeResults[b.id] ?? b.latencyMs ?? 9999;
        return latA.compareTo(latB);
      });
    } else if (_filterMode == 3) {
      // Recent connections ("اونایی که قبلا وصل شده طرف")
      final idMap = {for (var s in categoryServers) s.id: s};
      filtered = recent.map((id) => idMap[id]).whereType<VpnServer>().toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(bool isPersian) {
    final (String emptyTitle, String emptySubtitle) = switch (_filterMode) {
      1 => (
          isPersian
              ? 'هنوز سروری به برگزیده‌ها اضافه نشده است'
              : 'No favorite servers yet',
          isPersian
              ? 'روی ستاره هر سرور کلیک کنید تا در این بخش قرار گیرد'
              : 'Star servers to pin them here for fast access',
        ),
      3 => (
          isPersian
              ? 'هنوز به سروری متصل نشده‌اید'
              : 'No recent connection history',
          isPersian
              ? 'پس از اتصال به هر سرور، مسیرهای شما اینجا ذخیره می‌شوند'
              : 'Servers you connect to will appear here for 1-tap reconnect',
        ),
      _ => (
          isPersian
              ? 'هیچ سروری با این مشخصات یافت نشد'
              : 'No servers match your criteria',
          isPersian
              ? 'فیلتر جستجو را پاک کنید یا فیلترهای دیگر را بررسی کنید'
              : 'Clear search term or reset filters',
        ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(
                _filterMode == 1
                    ? Icons.star_border_rounded
                    : (_filterMode == 3
                        ? Icons.history_rounded
                        : Icons.travel_explore_rounded),
                size: 38.sp,
                color: Colors.white38,
              ),
            ),
            SizedBox(height: 14.h),
            LocalizedText(
              emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 6.h),
            LocalizedText(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5.sp, color: Colors.white38),
            ),
            if (controller.text.isNotEmpty ||
                _filterMode != 0 ||
                _selectedHarmoneyCategory != 'all') ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    controller.clear();
                    _filterMode = 0;
                    _selectedHarmoneyCategory = 'all';
                    _hideOfflineServers = false;
                  });
                },
                icon: Icon(Icons.refresh_rounded, size: 16.sp),
                label: LocalizedText(
                  isPersian
                      ? 'نمایش همه سرورها'
                      : 'Show All Servers',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00D4AA).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF00D4AA),
                  side: const BorderSide(color: Color(0xFF00D4AA), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serversAsync = ref.watch(
      vpnServersProvider(widget.appState.provider),
    );
    final connState = ref.watch(connectionStateProvider);
    final connStatus =
        connState.valueOrNull?.status ?? VpnConnectionStatus.disconnected;
    final query = controller.text.trim().toLowerCase();
    final isPersian = widget.appState.locale.languageCode == 'fa';

    final currentServers = serversAsync.asData?.value ?? <VpnServer>[];
    final currentLocationServers = widget.appState.provider == 'harmoney'
        ? currentServers
            .where((server) => server.subscriptionNodeId == null)
            .toList()
        : currentServers;
    final currentFiltered = _getFilteredServers(
      servers: currentLocationServers,
      query: query,
    );

    return MainScreenBackground(
      status: connStatus,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context, currentServers.length),
                  SizedBox(height: 8.h),
                  if (widget.appState.provider == 'firetunnel')
                    _buildFirefoxProtocolBanner(isPersian)
                  else if (widget.appState.provider == 'harmoney')
                    _buildHarmoneySourcesStatusBanner(context, isPersian),
                  SizedBox(height: 8.h),
                  const HarmoneyProDownloadCard(),
                  SizedBox(height: 8.h),
                  _buildSearchBar(currentFiltered.length, currentFiltered),
                  SizedBox(height: 8.h),
                  _buildUnifiedFilterRow(currentServers),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: serversAsync.when(
                      loading: () => Skeletonizer(
                        enabled: true,
                        effect: const ShimmerEffect(
                          baseColor: Color(0xFF161B26),
                          highlightColor: Color(0xFF283145),
                        ),
                        child: ListView(
                          children: List.generate(
                            6,
                            (_) => Container(
                              height: 64.h,
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 130.w,
                                          height: 14.h,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 6.h),
                                        Container(
                                          width: 80.w,
                                          height: 10.h,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 45.w,
                                    height: 20.h,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      error: (error, _) {
                        return Center(
                          child: LocalizedText(
                            'Could not load servers: $error',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13.sp,
                            ),
                          ),
                        );
                      },
                      data: (servers) {
                        final subscriptionGroups =
                            widget.appState.provider == 'harmoney' &&
                                    _filterMode == 0
                                ? _harmoneySubscriptionGroups(servers)
                                    .where((entry) =>
                                        query.isEmpty ||
                                        entry.value.first.country
                                            .toLowerCase()
                                            .contains(query))
                                    .toList(growable: false)
                                : const <MapEntry<String, List<VpnServer>>>[];
                        final locationServers =
                            widget.appState.provider == 'harmoney'
                                ? servers
                                    .where((server) =>
                                        server.subscriptionNodeId == null)
                                    .toList()
                                : servers;
                        final filtered = _getFilteredServers(
                          servers: locationServers,
                          query: query,
                        );

                        final usableServers = filtered
                            .where(
                              (server) =>
                                  server.available &&
                                  !_probeFailures.contains(server.id),
                            )
                            .toList();

                        VpnServer? fastest;
                        int? bestLatency;
                        for (final server in (usableServers.isNotEmpty
                            ? usableServers
                            : locationServers)) {
                          final latency =
                              _probeResults[server.id] ?? server.latencyMs;
                          if (latency != null &&
                              (bestLatency == null || latency < bestLatency)) {
                            fastest = server;
                            bestLatency = latency;
                          }
                        }

                        if (filtered.isEmpty && subscriptionGroups.isEmpty) {
                          return _buildEmptyState(isPersian);
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 110.h),
                                physics: const BouncingScrollPhysics(),
                                itemCount:
                                    subscriptionGroups.length + filtered.length,
                                itemBuilder: (context, index) {
                                  if (index < subscriptionGroups.length) {
                                    final group = subscriptionGroups[index];
                                    return _buildHarmoneySubscriptionCard(
                                      group.key,
                                      group.value,
                                      isPersian,
                                    );
                                  }
                                  final serverIndex =
                                      index - subscriptionGroups.length;
                                  final server = filtered[serverIndex];
                                  return _buildServerCard(
                                    server,
                                    isFastest: fastest?.id == server.id,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
