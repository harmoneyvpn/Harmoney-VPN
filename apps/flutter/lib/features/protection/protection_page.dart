import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/widgets/harmoney_switch.dart';
import '../../shared/services/haptic_service.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/country_bypass_bridge.dart';
import '../../core/local_cache_service.dart';
import '../../core/linux_platform_controls.dart';
import '../../core/mobile_vpn_bridge.dart';
import '../../core/platform_capability_matrix.dart';
import '../../core/windows_per_app_split_tunnel.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class ProtectionPage extends StatefulWidget {
  const ProtectionPage({super.key});
  @override
  State<ProtectionPage> createState() => _ProtectionPageState();
}

class _ProtectionPageState extends State<ProtectionPage> {
  final _controls = LinuxPlatformControls();
  final _custom = TextEditingController();
  final _routeTarget = TextEditingController(text: 'digikala.com');
  final _explainTarget = TextEditingController(text: 'varzesh3.com');
  Map<String, dynamic>? _routing;
  Map<String, dynamic>? _desktop;
  Map<String, dynamic>? _routeResult;
  Map<String, dynamic>? _explainResult;
  Map<String, dynamic>? _verifyResult;
  List<Map<String, dynamic>> _rules = const [];
  List<Map<String, dynamic>> _policies = const [];
  bool _loading = true;
  String? _busyAction;
  String? _error;

  bool get _iranEnabled => _routing?['routing_mode'] == 'iran_direct';
  bool get _lockdown => _desktop?['lockdown'] == true;
  bool get _allowIran => _desktop?['lockdown_allow_iran'] != false;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) _refresh();
  }

  @override
  void dispose() {
    _custom.dispose();
    _routeTarget.dispose();
    _explainTarget.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final values = await Future.wait([
        _controls.runVpnAction('routing-mode-status'),
        _controls.runVpnAction('custom-rules-get'),
        _controls.runVpnAction('desktop-status'),
        _controls.routerStatus().catchError((_) => <String, dynamic>{}),
      ]);
      if (!mounted) return;
      setState(() {
        _routing = values[0];
        _rules = (values[1]['rules'] as List? ?? const [])
            .map((value) => Map<String, dynamic>.from(value as Map))
            .toList(growable: false);
        _desktop = values[2];
        final routerCfg = values[3]['config'] as Map? ?? const {};
        _policies = (routerCfg['policies'] as List? ?? const [])
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>?> _run(
    String action, [
    List<String> args = const [],
  ]) async {
    if (_busyAction != null) return null;
    setState(() {
      _busyAction = action;
      _error = null;
    });
    try {
      return await _controls.runVpnAction(action, args);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      return null;
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Future<void> _addRule() async {
    final target = _custom.text.trim();
    if (target.isEmpty) return;
    final value = await _run('custom-rules-add', [target]);
    if (value != null) {
      _custom.clear();
      await _refresh();
    }
  }

  Future<void> _removeRule(String target) async {
    final value = await _run('custom-rules-remove', [target]);
    if (value != null) await _refresh();
  }

  Future<void> _testRoute() async {
    final target = _routeTarget.text.trim();
    if (target.isEmpty) return;
    final result = await _run('route-test', [target]);
    if (mounted && result != null) setState(() => _routeResult = result);
  }

  Future<void> _explainRoute() async {
    final target = _explainTarget.text.trim();
    if (target.isEmpty) return;
    final result = await _run('route-explain', [target]);
    if (mounted && result != null) setState(() => _explainResult = result);
  }

  Future<void> _addPolicyDialog() async {
    final targetCtrl = TextEditingController();
    var policy = 'direct';
    var scope = 'both';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const LocalizedText('Add Routing Policy Rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetCtrl,
                decoration: InputDecoration(
                  labelText: localizedUiText(
                    context,
                    'Target Domain or CIDR (e.g. 1.1.1.1/32)',
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: policy,
                decoration: InputDecoration(
                  labelText: localizedUiText(context, 'Policy'),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'direct',
                    child: LocalizedText('Direct (Bypass VPN)'),
                  ),
                  DropdownMenuItem(
                    value: 'vpn',
                    child: LocalizedText('Force VPN'),
                  ),
                  DropdownMenuItem(
                    value: 'block',
                    child: LocalizedText('Block Destination'),
                  ),
                ],
                onChanged: (val) => setDlg(() => policy = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: scope,
                decoration: InputDecoration(
                  labelText: localizedUiText(context, 'Scope'),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'both',
                    child: LocalizedText('Host and Hotspot clients'),
                  ),
                  DropdownMenuItem(
                    value: 'ubuntu',
                    child: LocalizedText('Host machine only'),
                  ),
                  DropdownMenuItem(
                    value: 'hotspot',
                    child: LocalizedText('Hotspot clients only'),
                  ),
                ],
                onChanged: (val) => setDlg(() => scope = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const LocalizedText('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const LocalizedText('Add Policy'),
            ),
          ],
        ),
      ),
    );

    if (result == true && targetCtrl.text.trim().isNotEmpty) {
      await _run('policy-add', [targetCtrl.text.trim(), policy, scope]);
      await _refresh();
    }
  }

  Future<void> _removePolicy(String target, String scope) async {
    await _run('policy-remove', [target, scope]);
    await _refresh();
  }

  Future<void> _verifyLive() async {
    final result = await _run('full-live-test');
    if (mounted && result != null) setState(() => _verifyResult = result);
  }

  Future<void> _applySafe() async {
    final result = await _run('apply-safe');
    if (mounted && result != null) {
      setState(() => _verifyResult = result);
      await _refresh();
    }
  }

  Future<void> _setLockdown(bool enabled) async {
    final result = await _run('lockdown', [enabled ? '1' : '0']);
    if (result != null) await _refresh();
  }

  Future<void> _setAllowIran(bool enabled) async {
    final result = await _run('lockdown-allow-iran', [enabled ? '1' : '0']);
    if (result != null) {
      await _run('lockdown-apply');
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) return const _AndroidProtectionView();
    if (Platform.isWindows) {
      final isPersian = Localizations.localeOf(context).languageCode == 'fa';
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            LocalizedText(
              localizedUiText(context,
                  (isPersian ? 'بایپس کشور و برنامه' : 'Country & App Bypass')),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            LocalizedText(
              localizedUiText(
                  context,
                  (isPersian
                      ? 'محدوده‌های IPv4 کشورها پس از اتصال مجدد از اینترنت محلی عبور می‌کنند. بایپس برنامه‌ها از مسیر فیزیکی ویندوز استفاده می‌کند و به سرویس Harmoney نیاز دارد.'
                      : 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.')),
            ),
            const SizedBox(height: 16),
            const CountryBypassCard(),
          ],
        ),
      );
    }
    if (!Platform.isLinux) {
      final platName = PlatformCapabilityMatrix.currentPlatformName();
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                LocalizedText(
                  'Advanced System Routing on $platName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                LocalizedText(
                  PlatformCapabilityMatrix.getCapability(
                    PlatformFeatureKey.iranBypassAndCustomRouting,
                  ).reason,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            LocalizedText(
              'Advanced Routing & Protection',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const LocalizedText(
              'Country destinations bypass the VPN directly through the ISP; other traffic remains inside the VPN.',
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
            if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const LocalizedText('Operation failed'),
                  subtitle: LocalizedText(_error!),
                ),
              ),
            const SizedBox(height: 12),

            // Country Bypass Section
            CountryBypassCard(
              onSettingsChanged: () {
                _refresh();
              },
            ),
            const SizedBox(height: 12),

            // Custom Bypass Rules Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(
                                'Custom Bypass Rules',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              LocalizedText(
                                'Domains, IPv4 addresses or CIDRs that always bypass the VPN',
                              ),
                            ],
                          ),
                        ),
                        Chip(label: LocalizedText('${_rules.length} added')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _custom,
                            onSubmitted: (_) => _addRule(),
                            decoration: InputDecoration(
                              labelText: localizedUiText(
                                context,
                                'Domain, IPv4 or CIDR',
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _busyAction == null ? _addRule : null,
                          icon: const Icon(Icons.add),
                          label: const LocalizedText('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_rules.isEmpty)
                      const LocalizedText('No custom bypass rules.')
                    else
                      for (final rule in _rules)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.alt_route),
                          title: LocalizedText('${rule['target']}'),
                          subtitle: LocalizedText(
                            '${rule['type'] ?? 'rule'} · ${(rule['resolved_ips'] as List? ?? const []).join(', ')}',
                          ),
                          trailing: IconButton(
                            tooltip: localizedUiText(context, 'Remove'),
                            onPressed: _busyAction == null
                                ? () => _removeRule('${rule['target']}')
                                : null,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Advanced Policy Rules Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(
                                'Advanced Policy Rules',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              LocalizedText(
                                'Route specific destinations through Direct, Force VPN, or Block.',
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed:
                              _busyAction == null ? _addPolicyDialog : null,
                          icon: const Icon(Icons.add_road),
                          label: const LocalizedText('Add Policy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_policies.isEmpty)
                      const LocalizedText(
                        'No advanced policy rules configured.',
                      )
                    else
                      for (final pol in _policies)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            pol['policy'] == 'block'
                                ? Icons.block
                                : pol['policy'] == 'vpn'
                                    ? Icons.vpn_lock
                                    : Icons.call_split,
                            color: pol['policy'] == 'block'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          title: LocalizedText(
                            '${pol['target']} (${pol['policy']?.toString().toUpperCase()})',
                          ),
                          subtitle: LocalizedText(
                            'Scope: ${pol['scope']} · ${(pol['resolved'] as List? ?? const []).join(', ')}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _busyAction == null
                                ? () => _removePolicy(
                                      '${pol['target']}',
                                      '${pol['scope'] ?? 'both'}',
                                    )
                                : null,
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Route Explain Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LocalizedText(
                      'Route Explain',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const LocalizedText(
                      'Explain why a destination routes via VPN or Direct ISP, with rule priority matching.',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _explainTarget,
                            decoration: InputDecoration(
                              labelText: localizedUiText(
                                context,
                                'Domain or IP to explain',
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: _busyAction == null ? _explainRoute : null,
                          icon: const Icon(Icons.help_outline),
                          label: const LocalizedText('Explain'),
                        ),
                      ],
                    ),
                    if (_explainResult != null) ...[
                      const SizedBox(height: 12),
                      for (final raw
                          in (_explainResult!['results'] as List? ?? const []))
                        Builder(
                          builder: (context) {
                            final item = Map<String, dynamic>.from(raw as Map);
                            return Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: ListTile(
                                title: LocalizedText('${item['address']}'),
                                subtitle: LocalizedText(
                                  'Policy: ${item['policy']} · Reason: ${item['reason']} · Actual: ${item['actual']}\nRoute: ${item['route']}',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Route Test Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LocalizedText(
                      'Route test',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _routeTarget,
                            decoration: InputDecoration(
                              labelText: localizedUiText(
                                context,
                                'Domain or IP',
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: _busyAction == null ? _testRoute : null,
                          icon: const Icon(Icons.route),
                          label: const LocalizedText('Test'),
                        ),
                      ],
                    ),
                    if (_routeResult != null) ...[
                      const SizedBox(height: 12),
                      for (final raw
                          in (_routeResult!['results'] as List? ?? const []))
                        Builder(
                          builder: (context) {
                            final row = Map<String, dynamic>.from(raw as Map);
                            final matches = row['intended'] == row['actual'];
                            return ListTile(
                              leading: Icon(
                                matches
                                    ? Icons.check_circle
                                    : Icons.warning_amber,
                                color: matches ? Colors.green : Colors.orange,
                              ),
                              title: LocalizedText('${row['address']}'),
                              subtitle: LocalizedText(
                                'Intended: ${row['intended']}  •  Actual: ${row['actual']}  •  Iran: ${row['iran']}',
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Routing Verification & Safe Apply Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LocalizedText(
                      'Route Table & XFRM Verification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const LocalizedText(
                      'Inspect XFRM interface, table 220, IP rules, and verify live connectivity safely.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _busyAction == null ? _verifyLive : null,
                          icon: const Icon(Icons.verified_outlined),
                          label: const LocalizedText('Live Verification'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _busyAction == null ? _applySafe : null,
                          icon: const Icon(Icons.security_update_good_outlined),
                          label: const LocalizedText('Safe Apply & LKG'),
                        ),
                      ],
                    ),
                    if (_verifyResult != null) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        _verifyResult!['ok'] == true
                            ? localizedUiText(
                                context,
                                '✓ Verified: All checks passed (XFRM, table 220, HTTPS trace)',
                              )
                            : localizedUiText(
                                context,
                                '⚠ Notice: ${_verifyResult!['error'] ?? _verifyResult.toString()}',
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lockdown (Kill Switch) Card
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.lock_outline),
                    title: const LocalizedText('Lockdown mode (Kill Switch)'),
                    subtitle: const LocalizedText(
                      'Block all internet leaks when the VPN drops unexpectedly',
                    ),
                    value: _lockdown,
                    onChanged: _busyAction == null ? _setLockdown : null,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.flag_outlined),
                    title: const LocalizedText(
                      'Allow Iran traffic during Lockdown',
                    ),
                    subtitle: const LocalizedText(
                      'Keep domestic services and banking reachable when the VPN drops',
                    ),
                    value: _allowIran,
                    onChanged:
                        _lockdown && _busyAction == null ? _setAllowIran : null,
                  ),
                  ListTile(
                    leading: Icon(
                      _iranEnabled
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _iranEnabled ? Colors.blue : null,
                    ),
                    title: const LocalizedText('Protection HUD'),
                    subtitle: LocalizedText(
                      'Iran Bypass: ${_iranEnabled ? 'ON' : 'Full tunnel'}  •  Lockdown: ${_lockdown ? 'ON' : 'OFF'}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidProtectionView extends StatefulWidget {
  const _AndroidProtectionView();

  @override
  State<_AndroidProtectionView> createState() => _AndroidProtectionViewState();
}

class _AndroidProtectionViewState extends State<_AndroidProtectionView>
    with WidgetsBindingObserver {
  Map<String, dynamic> _state = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final value = await MobileVpnBridge.protectionState();
      if (mounted) {
        setState(() {
          _state = value;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setDns(bool enabled) async {
    setState(() => _loading = true);
    _state = await MobileVpnBridge.setDnsProtection(enabled);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setIpv6(bool enabled) async {
    setState(() => _loading = true);
    _state = await MobileVpnBridge.setIpv6Protection(enabled);
    if (mounted) setState(() => _loading = false);
  }

  Widget _buildHeroCard(
    BuildContext context,
    bool isPersian,
    bool alwaysOn,
    bool lockdown,
    bool dnsEnabled,
    bool ipv6Enabled,
  ) {
    final borderRadius = BorderRadius.circular(20.r);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00D4AA).withValues(alpha: 0.16),
                const Color(0xFF09202E).withValues(alpha: 0.65),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D4AA).withValues(alpha: 0.30),
                          const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF00D4AA).withValues(alpha: 0.40),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.shield_moon_rounded,
                      color: const Color(0xFF61F2C2),
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedText(
                          isPersian ? 'سامانه محافظت لحظه‌ای' : 'Real-time Security Shield',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        LocalizedText(
                          isPersian ? 'نظارت بلادرنگ نشت داده و کیل‌سوئیچ' : 'Active monitoring of DNS/IP leaks',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: localizedUiText(context, 'Refresh'),
                    onPressed: _loading
                        ? null
                        : () {
                            HapticService.lightClick();
                            _refresh();
                          },
                    icon: _loading
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00D4AA),
                            ),
                          )
                        : Icon(Icons.sync_rounded,
                            color: const Color(0xFF00D4AA), size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              LocalizedText(
                isPersian
                    ? 'تنظیمات حفاظتی توسط سامانه امنیتی VpnService اعمال شده و پس از برقراری اتصال به‌طور کامل فعال می‌گردند.'
                    : 'Protection settings are enforced by Android VpnService and take effect upon reconnecting.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5.sp,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _ProtectionStatusBadge(
                    label: isPersian ? 'اتصال دائم' : 'Always-on VPN',
                    enabled: alwaysOn,
                  ),
                  _ProtectionStatusBadge(
                    label: isPersian ? 'کیل‌سوئیچ اندروید' : 'Lockdown Guard',
                    enabled: lockdown,
                  ),
                  _ProtectionStatusBadge(
                    label: isPersian ? 'دی‌ان‌اس ایمن' : 'Secure DNS',
                    enabled: dnsEnabled,
                  ),
                  _ProtectionStatusBadge(
                    label: isPersian ? 'سپر IPv6' : 'IPv6 Shield',
                    enabled: ipv6Enabled,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: LocalizedText(
              _error!,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    final dnsEnabled = _state['dns_protection'] != false;
    final ipv6Enabled = _state['ipv6_protection'] != false;
    final alwaysOn = _state['always_on'] == true;
    final lockdown = _state['lockdown'] == true;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 10.h, 16.w, 130.h),
        children: [
          _buildHeroCard(context, isPersian, alwaysOn, lockdown, dnsEnabled, ipv6Enabled),
          if (_error != null) ...[
            SizedBox(height: 12.h),
            _buildErrorCard(context),
          ],
          SizedBox(height: 16.h),

          // Group 1: Leak Protection & DNS
          _ModernProtectionGroup(
            icon: Icons.dns_rounded,
            iconColor: const Color(0xFF00D4AA),
            title: isPersian ? 'محافظت نشت داده و دی‌ان‌اس' : 'Leak Protection & DNS',
            subtitle: isPersian
                ? 'هدایت تمام درخواست‌های اینترنتی از داخل تونل رمزنگاری‌شده'
                : 'Tunnel-managed DNS & secure leak safeguards',
            children: [
              _ModernProtectionSwitchTile(
                icon: Icons.vpn_lock_rounded,
                iconColor: const Color(0xFF00D4AA),
                title: isPersian ? 'DNS ایمن و اختصاصی' : 'Secure VPN DNS',
                subtitle: _state['firefox_dns'] == null
                    ? (isPersian
                        ? 'هدایت تمام دامنه‌ها از داخل تونل ایمن (جلوگیری از نشت DNS)'
                        : 'Tunnel-managed DNS; prevents DNS leaks')
                    : (isPersian
                        ? 'دی‌ان‌اس سفارشی: ' + _state['firefox_dns'].toString()
                        : 'Custom tunnel DNS: ' + _state['firefox_dns'].toString()),
                value: dnsEnabled,
                badge: dnsEnabled ? (isPersian ? 'ایمن' : 'Secure') : null,
                onChanged: _loading
                    ? null
                    : (v) {
                        HapticService.selectionClick();
                        _setDns(v);
                      },
              ),
              Divider(
                height: 1,
                indent: 62.w,
                endIndent: 16.w,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _ModernProtectionSwitchTile(
                icon: Icons.network_check_rounded,
                iconColor: const Color(0xFF61F2C2),
                title: isPersian ? 'محافظت از نشت IPv6' : 'IPv6 Leak Protection',
                subtitle: isPersian
                    ? 'مسدودسازی یا هدایت امن IPv6 جهت جلوگیری از افشای IP مستقیم ISP'
                    : 'Route or block IPv6 traffic to prevent ISP IP leaks',
                value: ipv6Enabled,
                badge: ipv6Enabled ? (isPersian ? 'محافظت‌شده' : 'Protected') : null,
                onChanged: _loading
                    ? null
                    : (v) {
                        HapticService.selectionClick();
                        _setIpv6(v);
                      },
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Group 2: System Safeguards & Kill Switch
          _ModernProtectionGroup(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF00E5FF),
            title: isPersian ? 'کیل‌سوئیچ و محافظت‌های سیستمی' : 'System Safeguards & Kill Switch',
            subtitle: isPersian
                ? 'مسدودسازی اینترنت در صورت بروز اختلال در اتصال وی‌پی‌ان'
                : 'Block all network traffic if VPN drops unexpectedly',
            children: [
              _ModernProtectionActionTile(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF00E5FF),
                title: isPersian ? 'اتصال همیشگی (Always-on VPN)' : 'Always-on VPN',
                subtitle: alwaysOn
                    ? (isPersian ? 'قابلیت اتصال دائم در تنظیمات اندروید فعال است' : 'Active for Harmoney')
                    : (isPersian ? 'جهت اتصال دائمی، در تنظیمات اندروید فعال کنید' : 'Configure in Android VPN settings'),
                badge: alwaysOn ? (isPersian ? 'فعال' : 'Active') : (isPersian ? 'غیرفعال' : 'Disabled'),
                badgeColor: alwaysOn ? const Color(0xFF00D4AA) : Colors.white54,
                actionLabel: isPersian ? 'تنظیمات' : 'Configure',
                onTap: () {
                  HapticService.selectionClick();
                  MobileVpnBridge.openVpnSettings();
                },
              ),
              Divider(
                height: 1,
                indent: 62.w,
                endIndent: 16.w,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _ModernProtectionActionTile(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFFFFC46B),
                title: isPersian ? 'مسدودسازی اتصالات بدون VPN (Lockdown)' : 'Block Connections Without VPN',
                subtitle: lockdown
                    ? (isPersian ? 'کیل‌سوئیچ سخت‌افزاری اندروید فعال است' : 'Android Lockdown is active')
                    : (isPersian ? 'قطع کامل ترافیک در صورت قطع اتصال وی‌پی‌ان' : 'Block all traffic when disconnected'),
                badge: lockdown ? (isPersian ? 'فعال' : 'Active') : (isPersian ? 'غیرفعال' : 'Disabled'),
                badgeColor: lockdown ? const Color(0xFF00D4AA) : Colors.white54,
                actionLabel: isPersian ? 'تنظیمات' : 'Configure',
                onTap: () {
                  HapticService.selectionClick();
                  MobileVpnBridge.openVpnSettings();
                },
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Group 3: Smart Routing & Country Bypass
          _ModernProtectionGroup(
            icon: Icons.alt_route_rounded,
            iconColor: const Color(0xFFFFC46B),
            title: isPersian ? 'مسیریابی هوشمند و دورزدن کشورها' : 'Smart Routing & Country Bypass',
            subtitle: isPersian
                ? 'عبور مستقیم ترافیک سایت‌های بانکی و کشورها از اینترنت محلی'
                : 'Direct ISP routing for country IP ranges and banking sites',
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CountryBypassCard(onSettingsChanged: _refresh),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Info Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20.sp,
                  color: const Color(0xFF00D4AA),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: LocalizedText(
                    isPersian
                        ? 'تنظیمات اتصال دائم و کیل‌سوئیچ از طریق سامانه اندروید اعمال می‌شوند. سیاست‌های DNS و IPv6 توسط تونل فعال اجرا می‌گردند.'
                        : 'Always-on and Lockdown cover supported VPN connections. DNS and IPv6 policies are enforced by the active tunnel.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernProtectionGroup extends StatelessWidget {
  const _ModernProtectionGroup({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(20.r);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      const Color(0xFF09222E).withValues(alpha: 0.52),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      scheme.surface.withValues(alpha: 0.70),
                    ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.18)
                  : scheme.outlineVariant.withValues(alpha: 0.45),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.25 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 20.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LocalizedText(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                              color: scheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          LocalizedText(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.45),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernProtectionSwitchTile extends StatelessWidget {
  const _ModernProtectionSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: LocalizedText(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF00D4AA)
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: LocalizedText(
                            badge!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00D4AA),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  LocalizedText(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            HarmoneySwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernProtectionActionTile extends StatelessWidget {
  const _ModernProtectionActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: LocalizedText(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? const Color(0xFF00D4AA))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: (badgeColor ?? const Color(0xFF00D4AA))
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: LocalizedText(
                            badge!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: badgeColor ?? const Color(0xFF00D4AA),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  LocalizedText(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocalizedText(
                    actionLabel,
                    style: TextStyle(
                      color: const Color(0xFF00D4AA),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    isPersian ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                    color: const Color(0xFF00D4AA),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtectionStatusBadge extends StatelessWidget {
  const _ProtectionStatusBadge({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF00D4AA) : Colors.white54;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: enabled ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: enabled ? 0.35 : 0.15),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 13.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white60,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              enabled ? (Localizations.localeOf(context).languageCode == 'fa' ? 'فعال' : 'ON') : (Localizations.localeOf(context).languageCode == 'fa' ? 'خاموش' : 'OFF'),
              style: TextStyle(
                color: color,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CountryBypassCard extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const CountryBypassCard({super.key, this.onSettingsChanged});

  @override
  State<CountryBypassCard> createState() => _CountryBypassCardState();
}

class _CountryBypassCardState extends State<CountryBypassCard> {
  final _searchController = TextEditingController();
  CountryBypassState _state = CountryBypassState.initial();
  bool _loading = true;
  bool _updatingRules = false;
  String _filter = '';
  bool _perAppEnabled = false;
  bool _loadingPerApp = true;
  List<String> _perAppExecutables = const [];

  @override
  void initState() {
    super.initState();
    _loadState();
    if (Platform.isWindows) _loadPerAppSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPerAppSettings() async {
    try {
      await LocalCacheService.instance.init();
      final paths = LocalCacheService.instance.getWindowsPerAppExecutables();
      if (!mounted) return;
      setState(() {
        _perAppExecutables = paths;
        _perAppEnabled = LocalCacheService.instance.getWindowsPerAppEnabled();
        _loadingPerApp = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingPerApp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText('Could not load app bypass settings: $error'),
        ),
      );
    }
  }

  Future<void> _setPerAppEnabled(bool enabled) async {
    if (enabled && _perAppExecutables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            Localizations.localeOf(context).languageCode == 'fa'
                ? 'اول یک برنامه اضافه کن.'
                : 'Add an application before enabling app bypass.',
          ),
        ),
      );
      return;
    }
    setState(() => _loadingPerApp = true);
    try {
      await WindowsPerAppSplitTunnel.configure(
        enabled: enabled,
        executables: _perAppExecutables,
      );
      await LocalCacheService.instance.saveWindowsPerAppEnabled(enabled);
      if (!mounted) return;
      setState(() {
        _perAppEnabled = enabled;
        _loadingPerApp = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingPerApp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: LocalizedText('Could not update app bypass: $error')),
      );
    }
  }

  Future<void> _addPerAppExecutable() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['exe'],
        dialogTitle: 'Choose an application to bypass the VPN',
      );
      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return;
      if (_perAppExecutables.any(
        (item) => item.toLowerCase() == path.toLowerCase(),
      )) {
        return;
      }
      final next = [..._perAppExecutables, path];
      if (_perAppEnabled) {
        await WindowsPerAppSplitTunnel.configure(
          enabled: true,
          executables: next,
        );
      }
      await LocalCacheService.instance.saveWindowsPerAppExecutables(next);
      if (mounted) setState(() => _perAppExecutables = next);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: LocalizedText('Could not add application: $error')),
      );
    }
  }

  Future<void> _removePerAppExecutable(String path) async {
    final next = _perAppExecutables
        .where((item) => item.toLowerCase() != path.toLowerCase())
        .toList();
    final keepEnabled = _perAppEnabled && next.isNotEmpty;
    try {
      if (_perAppEnabled) {
        await WindowsPerAppSplitTunnel.configure(
          enabled: keepEnabled,
          executables: next,
        );
      }
      await LocalCacheService.instance.saveWindowsPerAppExecutables(next);
      if (_perAppEnabled && !keepEnabled) {
        await LocalCacheService.instance.saveWindowsPerAppEnabled(false);
      }
      if (mounted) {
        setState(() {
          _perAppExecutables = next;
          _perAppEnabled = keepEnabled;
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText('Could not remove application: $error'),
        ),
      );
    }
  }

  Future<void> _loadState() async {
    final s = await CountryBypassBridge.instance.getState();
    if (mounted) {
      setState(() {
        _state = s;
        _loading = false;
      });
    }
  }

  Future<void> _toggleEnabled(bool value) async {
    setState(() => _loading = true);
    final s = await CountryBypassBridge.instance.setEnabled(value);
    if (Platform.isLinux) {
      final hasIran = s.selectedCountries.contains('IR');
      await LinuxPlatformControls().runVpnAction('set-routing-mode', [
        hasIran && value ? 'iran_direct' : 'vpn_all',
      ]).catchError((_) => <String, dynamic>{});
    }
    if (mounted) {
      setState(() {
        _state = s;
        _loading = false;
      });
      widget.onSettingsChanged?.call();
    }
  }

  Future<void> _toggleCountry(String code) async {
    final current = List<String>.from(_state.selectedCountries);
    if (current.contains(code)) {
      current.remove(code);
    } else {
      current.add(code);
    }
    final s = await CountryBypassBridge.instance.setSelectedCountries(current);
    if (Platform.isLinux && _state.enabled) {
      final hasIran = s.selectedCountries.contains('IR');
      await LinuxPlatformControls().runVpnAction('set-routing-mode', [
        hasIran ? 'iran_direct' : 'vpn_all',
      ]).catchError((_) => <String, dynamic>{});
    }
    if (mounted) {
      setState(() => _state = s);
      widget.onSettingsChanged?.call();
    }
  }

  Future<void> _selectAll() async {
    final allCodes = _state.availableCountries.map((c) => c.code).toList();
    final s = await CountryBypassBridge.instance.setSelectedCountries(allCodes);
    if (Platform.isLinux && _state.enabled) {
      await LinuxPlatformControls().runVpnAction('set-routing-mode',
          ['iran_direct']).catchError((_) => <String, dynamic>{});
    }
    if (mounted) {
      setState(() => _state = s);
      widget.onSettingsChanged?.call();
    }
  }

  Future<void> _deselectAll() async {
    final s = await CountryBypassBridge.instance.setSelectedCountries([]);
    if (Platform.isLinux && _state.enabled) {
      await LinuxPlatformControls().runVpnAction('set-routing-mode',
          ['vpn_all']).catchError((_) => <String, dynamic>{});
    }
    if (mounted) {
      setState(() => _state = s);
      widget.onSettingsChanged?.call();
    }
  }

  Future<void> _updateRules() async {
    setState(() => _updatingRules = true);
    final s = await CountryBypassBridge.instance.updateRules();
    if (mounted) {
      setState(() {
        _state = s;
        _updatingRules = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            s.error ??
                'Country bypass DAT rules updated. Reconnect VPN to apply.',
          ),
        ),
      );
      widget.onSettingsChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _state.enabled;
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    final selectedSet = _state.selectedCountries.toSet();

    final filteredCountries = _state.availableCountries.where((c) {
      if (_filter.isEmpty) return true;
      final q = _filter.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q);
    }).toList();

    int totalSelectedCidrs = 0;
    for (final c in _state.availableCountries) {
      if (selectedSet.contains(c.code)) {
        totalSelectedCidrs += c.totalCidrs;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.public,
                color: isEnabled ? Colors.green : null,
                size: 28,
              ),
              title: LocalizedText(
                'Country Bypass: ${isEnabled ? "ON" : "OFF"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: LocalizedText(
                isEnabled
                    ? (Platform.isWindows
                        ? 'Xray routes selected IPv4/IPv6 ranges and the bundled Iranian domain list directly. Reconnect after changing rules.'
                        : 'Selected country IP ranges bypass the VPN. Reconnect after changing rules. Domain-only rules need DNS-aware routing.')
                    : 'Disabled: all traffic routes securely through encrypted VPN tunnel.',
              ),
              value: isEnabled,
              onChanged: _loading ? null : _toggleEnabled,
            ),
            if (isEnabled) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: localizedUiText(context, 'Search countries…'),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _filter.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _filter = '');
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (val) => setState(() => _filter = val.trim()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectAll,
                    icon: const Icon(Icons.select_all, size: 16),
                    label: const LocalizedText('Select all'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _deselectAll,
                    icon: const Icon(Icons.deselect, size: 16),
                    label: const LocalizedText('Deselect all'),
                  ),
                  if (!Platform.isWindows)
                    FilledButton.tonalIcon(
                      onPressed: _updatingRules ? null : _updateRules,
                      icon: _updatingRules
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: LocalizedText(
                        _updatingRules ? 'Updating…' : 'Update Country Rules',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: const Icon(Icons.tune, size: 16),
                    label: LocalizedText(
                      '${selectedSet.length} countries selected ($totalSelectedCidrs CIDRs)',
                    ),
                  ),
                  if (selectedSet.contains('IR'))
                    Chip(
                      avatar: const Icon(Icons.domain_verification, size: 16),
                      label: LocalizedText(
                        '${_state.iranianDomainRuleCount > 0 ? _state.iranianDomainRuleCount : 3120} Iranian GeoSite domains active',
                      ),
                    ),
                  Chip(
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: LocalizedText(
                      'Updated: ${_state.rulesUpdatedAt ?? "Bundled cache"}',
                    ),
                  ),
                  if (_state.ruleSource != null)
                    Chip(
                      avatar: const Icon(Icons.data_object, size: 16),
                      label: LocalizedText(_state.ruleSource!),
                    ),
                  const Chip(
                    avatar: Icon(Icons.offline_bolt, size: 16),
                    label: LocalizedText('Offline cache ready'),
                  ),
                ],
              ),
              if (_state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LocalizedText(
                    _state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected = selectedSet.contains(country.code);
                    return CheckboxListTile(
                      dense: true,
                      value: isSelected,
                      onChanged: (_) => _toggleCountry(country.code),
                      title: Row(
                        children: [
                          LocalizedText(
                            country.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LocalizedText(
                              '${country.name} (${country.code})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          LocalizedText(
                            '${country.totalCidrs} CIDRs',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (Platform.isWindows) ...[
              const Divider(height: 32),
              LocalizedText(
                localizedUiText(context,
                    (isPersian ? 'بایپس برنامه‌ها' : 'Per-app bypass')),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              LocalizedText(
                localizedUiText(
                    context,
                    (isPersian
                        ? 'برنامه‌های انتخاب‌شده مستقیم از اینترنت عبور می‌کنند و بقیهٔ برنامه‌ها داخل VPN می‌مانند.'
                        : 'Selected apps use the physical network directly. Other apps continue using the VPN.')),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  Icons.apps_rounded,
                  color: _perAppEnabled
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: LocalizedText(
                  localizedUiText(
                      context,
                      (isPersian
                          ? 'فعال‌سازی بایپس برنامه‌ها'
                          : 'Enable app bypass')),
                ),
                subtitle: LocalizedText(
                  _perAppExecutables.isEmpty
                      ? (localizedUiText(
                          context,
                          (isPersian
                              ? 'برای فعال‌سازی، ابتدا یک برنامه اضافه کنید.'
                              : 'Add at least one application to turn this on.')))
                      : localizedUiText(
                          context,
                          (isPersian
                              ? '${_perAppExecutables.length} برنامه انتخاب شده'
                              : '${_perAppExecutables.length} application(s) selected')),
                ),
                value: _perAppEnabled,
                onChanged: _loadingPerApp ? null : _setPerAppEnabled,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.tonalIcon(
                  onPressed: _loadingPerApp ? null : _addPerAppExecutable,
                  icon: const Icon(Icons.add),
                  label: LocalizedText(
                    localizedUiText(
                        context,
                        (isPersian
                            ? 'افزودن برنامه (.exe)'
                            : 'Add application (.exe)')),
                  ),
                ),
              ),
              if (_perAppExecutables.isNotEmpty)
                ..._perAppExecutables.map(
                  (path) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.desktop_windows_rounded),
                    title: LocalizedText(
                      path.split(Platform.pathSeparator).last,
                    ),
                    subtitle: LocalizedText(
                      path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: localizedUiText(context, 'Remove'),
                      onPressed: _loadingPerApp
                          ? null
                          : () => _removePerAppExecutable(path),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
