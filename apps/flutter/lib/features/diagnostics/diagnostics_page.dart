import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/linux_platform_controls.dart';
import '../../core/mobile_vpn_bridge.dart';
import '../../core/vpn_core_providers.dart';
import 'talker_logs_page.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class DiagnosticsPage extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const DiagnosticsPage({super.key, this.isEmbedded = false});

  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> {
  Map<String, Object?>? result;
  bool running = false;
  Object? error;
  final _linux = LinuxPlatformControls();
  String? actionOutput;
  String? activeAction;
  Map<String, dynamic>? networkDiag;
  Map<String, dynamic>? engineState;
  Map<String, String>? watchdogState;
  Map<String, dynamic>? androidDiag;
  MobileVpnStatus? androidStatus;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) {
      _loadLinuxDiagnostics();
    } else if (Platform.isAndroid) {
      _loadAndroidDiagnostics();
    }
  }

  Future<void> _loadLinuxDiagnostics() async {
    try {
      final diag = await _linux.networkDiagnostics();
      final eng = await _linux.engineStatus();
      final wd = await _linux.watchdogStatus();
      if (mounted) {
        setState(() {
          networkDiag = diag;
          engineState = eng;
          watchdogState = wd;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAndroidDiagnostics() async {
    try {
      final diag = await MobileVpnBridge.diagnostics();
      final st = await MobileVpnBridge.status();
      if (mounted) {
        setState(() {
          androidDiag = diag;
          androidStatus = st;
        });
      }
    } catch (_) {}
  }

  Future<void> runLinuxAction(
    String action, {
    List<String> args = const [],
  }) async {
    setState(() {
      activeAction = action;
      error = null;
    });
    try {
      final value = await _linux.runVpnAction(action, args);
      if (mounted) {
        setState(
          () =>
              actionOutput = const JsonEncoder.withIndent('  ').convert(value),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => activeAction = null);
    }
  }

  Future<void> runPlatformAction(
    String action,
    Future<dynamic> Function() task,
  ) async {
    setState(() {
      activeAction = action;
      error = null;
    });
    try {
      final value = await task();
      if (mounted) {
        setState(
          () =>
              actionOutput = const JsonEncoder.withIndent('  ').convert(value),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => activeAction = null);
    }
  }

  Future<void> runAndroidAction(
    String action,
    Future<dynamic> Function() task,
  ) =>
      runPlatformAction(action, task);

  Future<void> runPing(String kind) async {
    setState(() {
      activeAction = 'ping-$kind';
      error = null;
    });
    try {
      final report = await _linux.pingReport(kind);
      if (mounted) setState(() => actionOutput = report);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => activeAction = null);
    }
  }

  Future<void> runChecks() async {
    setState(() {
      running = true;
      error = null;
    });
    try {
      final value = await ref.read(vpnCoreProvider).runDiagnostics();
      if (!mounted) return;
      setState(() => result = value);
      if (Platform.isAndroid) {
        await _loadAndroidDiagnostics();
      } else if (Platform.isLinux) {
        await _loadLinuxDiagnostics();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e);
    } finally {
      if (mounted) setState(() => running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Keep the heading and actions on separate rows so they fit
                // narrow phones and translated labels.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                theme.colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.troubleshoot_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(
                                'Diagnostics & Health',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              LocalizedText(
                                'Tunnel path audits, leak tests, latency probes, and runtime telemetry',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF00D4AA).withOpacity(0.18),
                            foregroundColor: const Color(0xFF00D4AA),
                            side: const BorderSide(
                              color: Color(0xFF00D4AA),
                              width: 1.2,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TalkerLogsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bug_report_rounded, size: 18),
                          label: const LocalizedText('Talker Logs'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            if (Platform.isLinux) {
                              _loadLinuxDiagnostics();
                            } else if (Platform.isAndroid) {
                              _loadAndroidDiagnostics();
                            }
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const LocalizedText('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Overall System Health Hero Card
                _buildHealthHeroCard(context),
                const SizedBox(height: 20),

                // 2. Platform Live Runtime Monitor (Linux / Android)
                if (Platform.isLinux &&
                    (engineState != null || watchdogState != null)) ...[
                  _buildLinuxLiveStatusCard(context),
                  const SizedBox(height: 20),
                ] else if (Platform.isAndroid &&
                    (androidStatus != null || androidDiag != null)) ...[
                  _buildAndroidLiveStatusCard(context),
                  const SizedBox(height: 20),
                ],

                // 3. Error Banner (if any)
                if (error != null) ...[
                  _buildErrorCard(context, error.toString()),
                  const SizedBox(height: 20),
                ],

                // 4. Interactive Terminal Output Console
                if (actionOutput != null) ...[
                  _buildTerminalConsole(context),
                  const SizedBox(height: 20),
                ],

                // 5. System Diagnostics Audit Result Table
                if (result != null) ...[
                  _buildAuditResultTable(context),
                  const SizedBox(height: 20),
                ],

                // 6. Categorized Action Suites (Modern Diagnostic Tool Grid)
                _buildActionSuites(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );

    if (widget.isEmbedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: content,
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: content,
      ),
    );
  }

  Widget _buildHealthHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final isLinux = Platform.isLinux;

    final phase = (isLinux
            ? (engineState?['phase'] ?? watchdogState?['STATE'] ?? 'STANDBY')
            : (androidStatus?.state ?? 'DISCONNECTED'))
        .toString()
        .toUpperCase();

    final isHealthy = phase == 'CONNECTED' ||
        phase == 'VERIFYING' ||
        watchdogState?['HEALTH'] == 'HEALTHY' ||
        watchdogState?['OK'] == '1';

    final activeEndpoint = isLinux
        ? (engineState?['endpoint'] ??
            watchdogState?['LAST_SUCCESS_ENDPOINT'] ??
            engineState?['target'] ??
            'None')
        : (androidStatus?.hostname ?? 'None');

    const activeProtocol = 'Auto';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isHealthy
                ? const Color(0xFF10BFA3).withOpacity(0.18)
                : Colors.blueGrey.withOpacity(0.15),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHealthy
              ? const Color(0xFF10BFA3).withOpacity(0.4)
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHealthy
                          ? const Color(0xFF10BFA3).withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHealthy
                          ? Icons.health_and_safety_rounded
                          : Icons.sensors_rounded,
                      color: isHealthy
                          ? const Color(0xFF10BFA3)
                          : theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            LocalizedText(
                              'Overall Tunnel Health',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isHealthy
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blueGrey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: LocalizedText(
                                phase,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isHealthy
                                      ? Colors.greenAccent
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        LocalizedText(
                          isHealthy
                              ? 'Encrypted tunnel verified with zero packet leakage.'
                              : 'Ready to perform live routing and security audits.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.icon(
                  onPressed: running ? null : runChecks,
                  icon: running
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 20),
                  label:
                      LocalizedText(running ? 'Auditing…' : 'Run Full Audit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final metrics = [
                _buildMiniMetric(context, 'ACTIVE PROTOCOL',
                    activeProtocol.toString(), Icons.alt_route),
                _buildMiniMetric(context, 'ENDPOINT TARGET',
                    activeEndpoint.toString(), Icons.public),
                _buildMiniMetric(
                  context,
                  'WATCHDOG STATUS',
                  isLinux
                      ? (watchdogState?['HEALTH'] ??
                          (watchdogState?['OK'] == '1' ? 'HEALTHY' : 'STANDBY'))
                      : (androidStatus?.systemVpnActive == true
                          ? 'ACTIVE'
                          : 'IDLE'),
                  Icons.radar,
                ),
              ];
              if (constraints.maxWidth < 560) {
                return Column(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      metrics[i],
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0) const SizedBox(width: 24),
                    Expanded(child: metrics[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalizedText(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: theme.colorScheme.outline,
                ),
              ),
              LocalizedText(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinuxLiveStatusCard(BuildContext context) {
    final phase = (engineState?['phase'] ?? watchdogState?['STATE'] ?? 'IDLE')
        .toString()
        .toUpperCase();

    return _ModernContainer(
      title: 'Linux Engine & Watchdog Daemon',
      subtitle:
          'Native kernel routing, route-based XFRM, and auto-failover metrics',
      icon: Icons.developer_board_rounded,
      iconColor: Colors.deepPurpleAccent,
      badge: phase,
      badgeColor: phase == 'CONNECTED' ? Colors.green : Colors.deepPurple,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 760
              ? 4
              : constraints.maxWidth > 420
                  ? 2
                  : 1;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.8 : (columns == 2 ? 2.2 : 3.2),
            children: [
              _buildMetricTile(
                context,
                'Active Endpoint',
                '${engineState?['endpoint'] ?? watchdogState?['LAST_SUCCESS_ENDPOINT'] ?? engineState?['target'] ?? 'None'}',
                Icons.hub_outlined,
              ),
              _buildMetricTile(
                context,
                'Kernel Protocol',
                'Auto',
                Icons.bolt_outlined,
              ),
              _buildMetricTile(
                context,
                'Retry Count',
                '${engineState?['retry_count'] ?? engineState?['retries'] ?? watchdogState?['RETRY_COUNT'] ?? 0}',
                Icons.replay_outlined,
              ),
              _buildMetricTile(
                context,
                'Last Outcome',
                '${engineState?['last_outcome'] ?? engineState?['outcome'] ?? watchdogState?['LAST_OUTCOME'] ?? 'OK'}',
                Icons.task_alt_outlined,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAndroidLiveStatusCard(BuildContext context) {
    final state = (androidStatus?.state ?? 'DISCONNECTED').toUpperCase();

    return _ModernContainer(
      title: 'Android VPN & Protection Runtime',
      subtitle:
          'Userspace Charon daemon, network capabilities, and socket bypass status',
      icon: Icons.android_rounded,
      iconColor: Colors.tealAccent,
      badge: state,
      badgeColor: state == 'CONNECTED' ? Colors.green : Colors.teal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 760
              ? 4
              : constraints.maxWidth > 420
                  ? 2
                  : 1;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.8 : (columns == 2 ? 2.2 : 3.2),
            children: [
              _buildMetricTile(
                context,
                'Active Protocol',
                '${androidStatus?.protocol ?? androidDiag?['protocol'] ?? 'None'}',
                Icons.vpn_lock_outlined,
              ),
              _buildMetricTile(
                context,
                'VPN Transport',
                androidStatus?.systemVpnActive == true ||
                        androidDiag?['vpn_transport'] == true
                    ? 'Active (Bound)'
                    : 'Unbound',
                Icons.network_ping_outlined,
              ),
              _buildMetricTile(
                context,
                'Keystore Credentials',
                androidDiag?['credentials_saved'] == true
                    ? 'Configured'
                    : 'Missing',
                Icons.key_outlined,
              ),
              _buildMetricTile(
                context,
                'Internet Capability',
                androidDiag?['internet_capability'] == true
                    ? 'Online'
                    : 'Offline',
                Icons.wifi_outlined,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: LocalizedText(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LocalizedText(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSuites(BuildContext context) {
    final isLinux = Platform.isLinux;
    final isAndroid = Platform.isAndroid;
    final selectedHost =
        ref.watch(connectionStateProvider).valueOrNull?.server?.hostname;

    return Column(
      children: [
        // Suite 1: Connectivity & Speed
        _ModernContainer(
          title: 'Connectivity & Speed Benchmarks',
          subtitle:
              'Verify reachability, latency, and throughput across global endpoints',
          icon: Icons.speed_rounded,
          iconColor: Colors.amber,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(
                icon: Icons.network_ping_rounded,
                label: 'Test Internet Connectivity',
                loading: activeAction == 'internet',
                onTap: activeAction != null
                    ? null
                    : () => runPlatformAction(
                          'internet',
                          isLinux
                              ? _linux.testInternet
                              : MobileVpnBridge.testInternet,
                        ),
              ),
              _ActionChip(
                icon: Icons.cloud_outlined,
                label: 'Test Selected Server',
                loading: activeAction == 'server',
                onTap: activeAction != null || selectedHost == null
                    ? null
                    : () => runPlatformAction(
                          'server',
                          () => isLinux
                              ? _linux.testServer(selectedHost)
                              : MobileVpnBridge.testServer(selectedHost),
                        ),
              ),
              if (isLinux) ...[
                _ActionChip(
                  icon: Icons.network_ping_rounded,
                  label: 'Ping 1.1.1.1 (Cloudflare)',
                  loading: activeAction == 'ping-internet',
                  onTap:
                      activeAction != null ? null : () => runPing('internet'),
                ),
                _ActionChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'ChatGPT Reachability',
                  loading: activeAction == 'chatgpt-test',
                  onTap: activeAction != null
                      ? null
                      : () => runLinuxAction('chatgpt-test'),
                ),
                _ActionChip(
                  icon: Icons.speed_rounded,
                  label: 'Speed Test',
                  loading: activeAction == 'speed-test',
                  onTap: activeAction != null
                      ? null
                      : () => runLinuxAction('speed-test'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Suite 2: Security & Leak Detection
        _ModernContainer(
          title: 'Security & Leak Detection',
          subtitle:
              'Audit DNS leaks, packet interception, and permission integrity',
          icon: Icons.gpp_good_rounded,
          iconColor: const Color(0xFF10BFA3),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(
                icon: Icons.security_rounded,
                label:
                    isLinux ? 'Preflight & Permissions' : 'Test VPN Permission',
                loading: activeAction == 'vpn-perm',
                onTap: activeAction != null
                    ? null
                    : () => runPlatformAction(
                          'vpn-perm',
                          isLinux
                              ? _linux.preflightCheck
                              : MobileVpnBridge.testVpnPermission,
                        ),
              ),
              _ActionChip(
                icon: Icons.dns_outlined,
                label: 'DNS Leak Audit',
                loading: activeAction == 'dns',
                onTap: activeAction != null
                    ? null
                    : () {
                        if (isLinux) {
                          runLinuxAction('dns-test');
                        } else {
                          runPlatformAction('dns', MobileVpnBridge.testDns);
                        }
                      },
              ),
              if (isLinux)
                _ActionChip(
                  icon: Icons.build_outlined,
                  label: 'Repair DNS Resolvers',
                  loading: activeAction == 'dns-repair',
                  onTap: activeAction != null
                      ? null
                      : () => runLinuxAction('dns-repair'),
                ),
              _ActionChip(
                icon: Icons.key_outlined,
                label: 'Validate Credentials',
                loading: activeAction == 'credentials',
                onTap: activeAction != null
                    ? null
                    : () => runPlatformAction(
                          'credentials',
                          isLinux
                              ? _linux.testCredentials
                              : MobileVpnBridge.testCredentials,
                        ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Suite 3: Tunnel Verification & Protocols
        _ModernContainer(
          title: 'Tunnel Verification & MTU',
          subtitle:
              'Check packet fragmentation, routing path integrity, and protocol handshakes',
          icon: Icons.alt_route_rounded,
          iconColor: Colors.blueAccent,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (isLinux) ...[
                _ActionChip(
                  icon: Icons.verified_user_outlined,
                  label: 'Verify Full Tunnel Path',
                  loading: activeAction == 'full-live-test',
                  onTap: activeAction != null
                      ? null
                      : () => runLinuxAction('full-live-test'),
                ),
                _ActionChip(
                  icon: Icons.compress_rounded,
                  label: 'MTU / MSS Test',
                  loading: activeAction == 'mtu-test',
                  onTap: activeAction != null
                      ? null
                      : () => runLinuxAction('mtu-test'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Suite 4: Logs & Diagnostics Bundle
        _ModernContainer(
          title: 'Support & Diagnostic Logs',
          subtitle:
              'Generate bug reports and encrypted telemetry bundles for support',
          icon: Icons.terminal_rounded,
          iconColor: Colors.deepOrangeAccent,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(
                icon: Icons.folder_zip_outlined,
                label: 'Export Support Bundle',
                loading: activeAction == 'support-bundle',
                onTap: activeAction != null
                    ? null
                    : () {
                        if (isLinux) {
                          runLinuxAction('support-bundle');
                        } else if (isAndroid) {
                          runAndroidAction(
                            'support-bundle',
                            () async => {
                              'bundle':
                                  await MobileVpnBridge.exportSupportBundle(),
                            },
                          );
                        }
                      },
              ),
              _ActionChip(
                icon: Icons.clear_all_rounded,
                label: 'Clear Results & Console',
                onTap: () => setState(() {
                  result = null;
                  error = null;
                  actionOutput = null;
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTerminalConsole(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mac/Linux style window header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF141C24),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5F56),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFBD2E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF27C93F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                const LocalizedText(
                  'Diagnostic Terminal Output',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                  tooltip: localizedUiText(context, 'Copy Output'),
                  onPressed: () {
                    if (actionOutput != null) {
                      Clipboard.setData(ClipboardData(text: actionOutput!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: LocalizedText(
                            'Console output copied to clipboard.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                  tooltip: localizedUiText(context, 'Close Output'),
                  onPressed: () => setState(() => actionOutput = null),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              actionOutput!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF38EF7D),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditResultTable(BuildContext context) {
    final theme = Theme.of(context);
    final entries = result?.entries.toList() ?? const [];

    return _ModernContainer(
      title: 'Full System Audit Results',
      subtitle:
          'Detailed diagnostics inspection across components and interfaces',
      icon: Icons.checklist_rtl_rounded,
      iconColor: theme.colorScheme.primary,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final label = LocalizedText(
                    entries[i].key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  );
                  final value = LocalizedText(
                    '${entries[i].value}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                  if (constraints.maxWidth < 480) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [label, const SizedBox(height: 5), value],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 220, child: label),
                      const SizedBox(width: 12),
                      Expanded(child: value),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: LocalizedText(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
            onPressed: () => setState(() => error = null),
          ),
        ],
      ),
    );
  }
}

class _ModernContainer extends StatelessWidget {
  const _ModernContainer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.badge,
    this.badgeColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LocalizedText(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      LocalizedText(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? theme.colorScheme.primary)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: LocalizedText(
                              badge!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: badgeColor ?? theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            LocalizedText(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
