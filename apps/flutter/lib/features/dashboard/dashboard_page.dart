import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/linux_platform_controls.dart';
import '../../core/mobile_vpn_bridge.dart';
import '../../core/vpn_core.dart';
import '../../core/vpn_core_providers.dart';
import '../../core/firetunnel_vpn_core.dart';
import '../../core/harmoney_subscription_service.dart';
import '../../app/app_state.dart';
import '../../app/app_motion.dart';
import '../../core/network_monitor_service.dart';
import '../../shared/widgets/battery_optimization_banner.dart';
import '../../shared/widgets/cyber_connect_button.dart';
import '../../shared/widgets/live_traffic_chart.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key, required this.appState, this.selectedServer});
  final AppState appState;
  final VpnServer? selectedServer;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _actionBusy = false;
  String? _actionIntent;
  Timer? _actionTimeout;
  int _actionGeneration = 0;
  bool _startupConnectAttempted = false;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAppStateChanged);
    NetworkMonitorService.instance.autoReconnectOnNetworkSwitch =
        widget.appState.autoConnect;
    NetworkMonitorService.instance.isVpnConnected = () =>
        ref.read(connectionStateProvider).valueOrNull?.status ==
        VpnConnectionStatus.connected;
    NetworkMonitorService.instance.onReconnectionRequested = () async {
      final servers = ref.read(vpnServersProvider(widget.appState.provider));
      await _connect(context, ref, servers.valueOrNull, widget.selectedServer);
    };
    NetworkMonitorService.instance.start();
    if (Platform.isWindows && widget.appState.autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_autoConnectWindowsOnStartup());
      });
    }
  }

  void _onAppStateChanged() {
    if (!mounted) return;
    setState(() {});
    NetworkMonitorService.instance.autoReconnectOnNetworkSwitch =
        widget.appState.autoConnect;
  }

  Future<void> _autoConnectWindowsOnStartup() async {
    if (_startupConnectAttempted || !mounted || !widget.appState.autoConnect) {
      return;
    }
    _startupConnectAttempted = true;
    final current = ref.read(connectionStateProvider).valueOrNull;
    if (current?.isConnected == true || current?.isTransitioning == true) {
      return;
    }
    try {
      final servers = await ref.read(
        vpnServersProvider(widget.appState.provider).future,
      );
      if (!mounted || !widget.appState.autoConnect) return;
      await _runAction(
        'connect',
        () => _connect(context, ref, servers, widget.selectedServer),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(_humanReadableError(error.toString())),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    _actionTimeout?.cancel();
    NetworkMonitorService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final connection = ref.watch(connectionStateProvider);
    final servers = ref.watch(vpnServersProvider(appState.provider));
    final fireTunnelAccount = appState.provider == FireTunnelVpnCore.providerId
        ? ref.watch(fireTunnelAccountProvider).valueOrNull
        : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: connection.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ConnectionBody(
                appState: appState,
                state: VpnConnectionState(
                  status: VpnConnectionStatus.error,
                  errorMessage: _humanReadableError(error.toString()),
                ),
                servers: servers.valueOrNull ?? const [],
                providerId: appState.provider,
                selectedServer: widget.selectedServer,
                fireTunnelAccount: fireTunnelAccount,
                onConnect: () => _runAction(
                  'connect',
                  () => _connect(
                    context,
                    ref,
                    servers.valueOrNull,
                    widget.selectedServer,
                  ),
                ),
                onDisconnect: () =>
                    _runAction('disconnect', () => _disconnect(ref)),
                onCancel: () => _runAction('cancel', () => _cancel(ref)),
                onEmergencyStop: () => _emergencyStop(context, ref),
                onProviderChanged: (value) => _setProvider(ref, value),
                actionBusy: _actionBusy,
                actionIntent: _actionIntent,
              ),
              data: (state) {
                _completeObservedDisconnect(state);
                return _ConnectionBody(
                  appState: appState,
                  state: state,
                  servers: servers.valueOrNull ?? const [],
                  providerId: appState.provider,
                  selectedServer: widget.selectedServer,
                  fireTunnelAccount: fireTunnelAccount,
                  onConnect: () => _runAction(
                    'connect',
                    () => _connect(
                      context,
                      ref,
                      servers.valueOrNull,
                      widget.selectedServer,
                    ),
                  ),
                  onDisconnect: () =>
                      _runAction('disconnect', () => _disconnect(ref)),
                  onCancel: () => _runAction('cancel', () => _cancel(ref)),
                  onEmergencyStop: () => _emergencyStop(context, ref),
                  onProviderChanged: (value) => _setProvider(ref, value),
                  actionBusy: _actionBusy,
                  actionIntent: _actionIntent,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runAction(String intent, Future<void> Function() action) async {
    if (_actionBusy) return;
    final generation = ++_actionGeneration;
    setState(() {
      _actionBusy = true;
      _actionIntent = intent;
    });
    _actionTimeout?.cancel();
    _actionTimeout = Timer(
      Duration(seconds: intent == 'connect' ? 175 : 20),
      () {
        if (!mounted || _actionGeneration != generation) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(
              intent == 'disconnect'
                  ? 'Disconnect is taking longer than expected. You can try again.'
                  : 'The previous VPN operation timed out. You can try again.',
            ),
          ),
        );
        setState(() {
          _actionBusy = false;
          _actionIntent = null;
        });
      },
    );
    try {
      await action();
    } finally {
      if (mounted &&
          _actionGeneration == generation &&
          intent != 'disconnect') {
        _actionTimeout?.cancel();
        setState(() {
          _actionBusy = false;
          _actionIntent = null;
        });
      }
    }
  }

  void _completeObservedDisconnect(VpnConnectionState state) {
    if (_actionIntent != 'disconnect') return;
    final finished = state.status == VpnConnectionStatus.disconnected ||
        state.status == VpnConnectionStatus.failed ||
        state.status == VpnConnectionStatus.error;
    if (!finished) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _actionIntent != 'disconnect') return;
      _actionTimeout?.cancel();
      setState(() {
        _actionBusy = false;
        _actionIntent = null;
      });
    });
  }

  Future<void> _connect(
    BuildContext context,
    WidgetRef ref,
    List<VpnServer>? servers,
    VpnServer? selectedServer,
  ) async {
    // Let Flutter paint the immediate "Starting connection…" feedback before
    // the synchronous desktop FFI call performs privileged setup/DNS work.
    await Future<void>.delayed(Duration.zero);
    final availableServers =
        servers?.where((server) => server.available).toList() ??
            const <VpnServer>[];
    final requestedSubscriptionId = selectedServer?.subscriptionNodeId == null
        ? selectedServer?.subscriptionId
        : null;
    final selectedSubscriptionServers = requestedSubscriptionId == null
        ? <VpnServer>[]
        : availableServers
            .where((candidate) =>
                candidate.subscriptionId == requestedSubscriptionId &&
                candidate.subscriptionNodeId != null)
            .toList();
    if (requestedSubscriptionId != null &&
        selectedSubscriptionServers.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(
              widget.appState.locale.languageCode == 'fa'
                  ? '?? ??? ?????? ???? ?????? ? ????? ???? ???.'
                  : 'This subscription has no active compatible servers.',
            ),
          ),
        );
      }
      return;
    }
    final selectedNodeIsValid = selectedServer != null &&
        selectedServer.providerId == 'harmoney' &&
        selectedServer.subscriptionNodeId != null &&
        selectedServer.available;
    final selectedIsValid = selectedServer != null &&
        (selectedNodeIsValid ||
            selectedSubscriptionServers.isNotEmpty ||
            availableServers
                .any((candidate) => candidate.id == selectedServer.id));
    VpnServer? server = selectedSubscriptionServers.isNotEmpty
        ? null
        : selectedIsValid
            ? selectedServer
            : (availableServers.isEmpty ? null : availableServers.first);
    if (selectedSubscriptionServers.isNotEmpty) {
      final ranked = selectedSubscriptionServers
          .map((candidate) => (
                server: candidate,
                latency: HarmoneySubscriptionService.instance
                    .cachedNodeLatency(candidate.subscriptionNodeId!),
              ))
          .where((entry) => entry.latency != null)
          .toList()
        ..sort((a, b) => a.latency!.compareTo(b.latency!));
      server = ranked.isNotEmpty
          ? ranked.first.server
          : selectedSubscriptionServers.first;
    }
    try {
      // Kill-switch changes are applied from Settings. Do not synchronously
      // invoke the privileged helper on every Connect click: on Linux with a
      // cellular bearer, pkexec can return ECHILD while the polkit child is
      // being reaped, preventing the actual VPN worker from ever starting.
      await ref.read(vpnCoreProvider).connect(
            providerId: widget.appState.provider,
            server: server,
            protocol: widget.appState.protocol.toLowerCase(),
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(_humanReadableError(error.toString())),
          ),
        );
      }
    }
  }

  Future<void> _disconnect(WidgetRef ref) async {
    try {
      await ref.read(vpnCoreProvider).disconnect();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: LocalizedText('Disconnect failed: $error')),
        );
      }
    }
  }

  Future<void> _setProvider(WidgetRef ref, String value) async {
    if (value == widget.appState.provider) return;
    final previous = widget.appState.provider;
    await widget.appState.setProvider(value);
    ref.invalidate(vpnServersProvider(previous));
    ref.invalidate(vpnServersProvider(value));
    ref.invalidate(fireTunnelAccountProvider);
  }

  Future<void> _cancel(WidgetRef ref) async {
    try {
      await ref.read(vpnCoreProvider).cancelConnect();
    } catch (_) {}
  }

  Future<void> _emergencyStop(BuildContext context, WidgetRef ref) async {
    try {
      if (Platform.isLinux) {
        await LinuxPlatformControls().emergencyStop();
      }
      await ref.read(vpnCoreProvider).disconnect();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
              'Emergency Stop executed: Processes terminated and physical network unjammed.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: LocalizedText('Emergency Stop error: $e')),
        );
      }
    }
  }

  static String _humanReadableError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('auth_failed') ||
        lower.contains('authentication failed')) {
      return 'Authentication failed: Please check your service credentials in Settings.';
    }
    if (lower.contains('timeout')) {
      return 'Connection timed out: Server did not respond. The protocol or endpoint might be blocked by your ISP.';
    }
    if (lower.contains('data_path_blocked')) {
      return 'Data path blocked: Handshake completed but no encrypted packets passed through.';
    }
    return raw;
  }
}

class _ConnectionBody extends StatelessWidget {
  const _ConnectionBody({
    required this.appState,
    required this.state,
    required this.servers,
    required this.providerId,
    this.selectedServer,
    this.fireTunnelAccount,
    required this.onConnect,
    required this.onDisconnect,
    required this.onCancel,
    required this.onEmergencyStop,
    required this.onProviderChanged,
    required this.actionBusy,
    this.actionIntent,
  });

  final AppState appState;
  final VpnConnectionState state;
  final List<VpnServer> servers;
  final String providerId;
  final VpnServer? selectedServer;
  final FireTunnelAccountState? fireTunnelAccount;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;
  final Future<void> Function() onCancel;
  final Future<void> Function() onEmergencyStop;
  final Future<void> Function(String value) onProviderChanged;
  final bool actionBusy;
  final String? actionIntent;

  void _showLogs(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => const _LiveLogTerminalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connected = state.status == VpnConnectionStatus.connected;
    final server = state.server ?? selectedServer;
    final transitioning = state.isTransitioning;
    final connecting = state.status == VpnConnectionStatus.preparing ||
        state.status == VpnConnectionStatus.discovering ||
        state.status == VpnConnectionStatus.connecting ||
        state.status == VpnConnectionStatus.authenticating ||
        state.status == VpnConnectionStatus.verifying ||
        state.status == VpnConnectionStatus.reconnecting ||
        state.status == VpnConnectionStatus.recovering ||
        state.status == VpnConnectionStatus.cancelling;
    final disconnecting = state.status == VpnConnectionStatus.disconnecting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BatteryOptimizationBanner(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LocalizedText(
              'Connection',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (Platform.isLinux) ...[
                  OutlinedButton.icon(
                    onPressed: onEmergencyStop,
                    icon: const Icon(
                      Icons.flash_on,
                      size: 18,
                      color: Colors.amber,
                    ),
                    label: const LocalizedText('Emergency Stop'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (Platform.isLinux || Platform.isAndroid)
                  FilledButton.tonalIcon(
                    onPressed: () => _showLogs(context),
                    icon: const Icon(Icons.terminal, size: 18),
                    label: const LocalizedText('Live Logs'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        MotionEntrance(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  CyberConnectButton(
                    state: disconnecting ||
                            (actionBusy && actionIntent == 'disconnect')
                        ? ConnectButtonState.disconnecting
                        : (connecting ||
                                (actionBusy && actionIntent == 'connect'))
                            ? ConnectButtonState.connecting
                            : connected
                                ? ConnectButtonState.connected
                                : ConnectButtonState.idle,
                    onTap: actionBusy || disconnecting
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: LocalizedText(
                                  actionBusy
                                      ? 'A VPN operation is already running. Please wait for its status to update.'
                                      : 'Disconnect is still being processed…',
                                ),
                              ),
                            )
                        : connecting
                            ? onCancel
                            : () => connected ? onDisconnect() : onConnect(),
                  ),
                  const SizedBox(height: 20),
                  LocalizedText(
                    connecting && server != null
                        ? 'Connecting to ${server.city}…'
                        : actionBusy && !transitioning
                            ? actionIntent == 'disconnect'
                                ? 'Disconnect requested…'
                                : 'Starting connection…'
                            : _statusText(state.status),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  LocalizedText(
                    server == null
                        ? 'Select a location or use fastest server'
                        : '${server.country} · ${server.city}',
                    textAlign: TextAlign.center,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LocalizedText(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                  if (actionBusy || transitioning) ...[
                    const SizedBox(height: 16),
                    _ConnectionProgress(
                      status: state.status,
                      actionIntent: actionIntent,
                      server: server,
                      detail: state.rawBackendState,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: actionBusy || disconnecting
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: LocalizedText(
                                  actionBusy
                                      ? 'A VPN operation is already running. Please wait for its status to update.'
                                      : 'Disconnect is still being processed…',
                                ),
                              ),
                            )
                        : connecting
                            ? onCancel
                            : () => connected ? onDisconnect() : onConnect(),
                    icon: actionBusy || disconnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            connecting
                                ? Icons.cancel_outlined
                                : connected
                                    ? Icons.stop_circle_outlined
                                    : Icons.power_settings_new,
                          ),
                    label: LocalizedText(
                      actionBusy
                          ? actionIntent == 'disconnect'
                              ? 'Disconnecting…'
                              : 'Working…'
                          : disconnecting
                              ? 'Disconnecting…'
                              : connecting
                                  ? 'Cancel'
                                  : connected
                                      ? 'Disconnect'
                                      : 'Quick connect',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LiveTrafficChart(isConnected: connected),
        const SizedBox(height: 16),

        // Protocol + provider selector: both affect the next connection and
        // belong together in the primary connection control.
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (appState.provider != FireTunnelVpnCore.providerId) ...[
                  Row(
                    children: [
                      const Icon(Icons.alt_route, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: LocalizedText(
                          'Protocol',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownButton<String>(
                        value: appState.protocol.toLowerCase(),
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: 'auto',
                            child: LocalizedText('Auto (Fallback)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) appState.setProtocol(val);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                ],
                Row(
                  children: [
                    const Icon(Icons.cloud_outlined, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: LocalizedText(
                        'Provider',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: appState.provider,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: 'harmoney',
                          child: LocalizedText('Harmoney Smart'),
                        ),
                        DropdownMenuItem(
                          value: 'firetunnel',
                          child: LocalizedText('Firefox VPN'),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value != null) await onProviderChanged(value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        MotionEntrance(
          delay: const Duration(milliseconds: 90),
          child: Row(
            children: [
              Expanded(
                child: _StatusCard(title: 'Active Protocol', value: 'Auto'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  title: 'Provider',
                  value: providerId == 'firetunnel'
                      ? 'Firefox VPN'
                      : 'Harmoney Smart',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (fireTunnelAccount?.quota != null) ...[
          _QuotaCard(quota: fireTunnelAccount!.quota!),
          const SizedBox(height: 12),
        ],
        MotionEntrance(
          delay: const Duration(milliseconds: 160),
          child: Row(
            children: [
              Expanded(
                child: _StatusCard(
                  title: 'Kill switch',
                  value: appState.killSwitch ? 'Active' : 'Off',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  title: 'Servers',
                  value: '${servers.length} loaded',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _statusText(VpnConnectionStatus status) => switch (status) {
        VpnConnectionStatus.idle => 'Idle',
        VpnConnectionStatus.preparing => 'Preparing environment…',
        VpnConnectionStatus.discovering => 'Discovering endpoints…',
        VpnConnectionStatus.connecting => 'Connecting…',
        VpnConnectionStatus.authenticating => 'Authenticating credentials…',
        VpnConnectionStatus.verifying => 'Verifying data path…',
        VpnConnectionStatus.connected => 'Protected',
        VpnConnectionStatus.cancelling => 'Cancelling connection…',
        VpnConnectionStatus.disconnecting => 'Disconnecting…',
        VpnConnectionStatus.disconnected => 'Not connected',
        VpnConnectionStatus.recovering => 'Recovering network…',
        VpnConnectionStatus.failed => 'Connection failed',
        VpnConnectionStatus.authRequired => 'Authentication required',
        VpnConnectionStatus.reconnecting => 'Reconnecting…',
        VpnConnectionStatus.error => 'Connection error',
      };
}

class _ConnectionProgress extends StatelessWidget {
  const _ConnectionProgress({
    required this.status,
    required this.actionIntent,
    required this.server,
    required this.detail,
  });

  final VpnConnectionStatus status;
  final String? actionIntent;
  final VpnServer? server;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final disconnect = actionIntent == 'disconnect' ||
        status == VpnConnectionStatus.disconnecting;
    final phases = disconnect
        ? const ['Disconnecting', 'Released']
        : const [
            'Preparing',
            'Discovering',
            'Connecting',
            'Authenticating',
            'Verifying',
            'Connected',
          ];
    final current = _phaseName(status, disconnect);
    final index = phases.indexOf(current);
    final value = index < 0 ? null : (index + 1) / phases.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5, value: value),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LocalizedText(
                current == 'Connecting' && server != null
                    ? 'Connecting to ${server!.city} · $current'
                    : current,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            LocalizedText(
              index < 0 ? '…' : '${index + 1}/${phases.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, minHeight: 5),
        if (detail != null && detail!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LocalizedText(
            detail!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        LocalizedText(
          phases.join('  ›  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  static String _phaseName(VpnConnectionStatus status, bool disconnect) {
    if (disconnect) {
      return status == VpnConnectionStatus.disconnected
          ? 'Released'
          : 'Disconnecting';
    }
    return switch (status) {
      VpnConnectionStatus.preparing => 'Preparing',
      VpnConnectionStatus.discovering => 'Discovering',
      VpnConnectionStatus.connecting => 'Connecting',
      VpnConnectionStatus.authenticating => 'Authenticating',
      VpnConnectionStatus.verifying => 'Verifying',
      VpnConnectionStatus.connected => 'Connected',
      _ => 'Preparing',
    };
  }
}

class _LiveLogTerminalSheet extends StatefulWidget {
  const _LiveLogTerminalSheet();

  @override
  State<_LiveLogTerminalSheet> createState() => _LiveLogTerminalSheetState();
}

class _LiveLogTerminalSheetState extends State<_LiveLogTerminalSheet> {
  final _controls = LinuxPlatformControls();
  final List<String> _logLines = [];
  String _filter = '';
  String _levelFilter = 'ALL';
  final _filterController = TextEditingController();
  StreamSubscription<String>? _sub;
  final bool _autoScroll = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  void _startStream() {
    if (Platform.isAndroid) {
      MobileVpnBridge.getLogs().then((lines) {
        if (!mounted) return;
        if (lines.isNotEmpty) {
          setState(() => _logLines.addAll(lines));
        }
      });
      _sub = MobileVpnBridge.watchEventLogStream().listen((line) {
        if (!mounted) return;
        setState(() => _logLines.add(line));
        if (_autoScroll &&
            _scrollController.hasClients &&
            _filter.isEmpty &&
            _levelFilter == 'ALL') {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } else {
      _sub = _controls.watchConnectionLogEventStream().listen((line) {
        if (!mounted) return;
        setState(() => _logLines.add(line));
        if (_autoScroll &&
            _scrollController.hasClients &&
            _filter.isEmpty &&
            _levelFilter == 'ALL') {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  List<String> get _filteredLines {
    if (_logLines.isEmpty) return const [];
    Iterable<String> list = _logLines;
    if (_levelFilter != 'ALL') {
      list = list.where((l) => l.startsWith('[$_levelFilter]'));
    }
    if (_filter.trim().isNotEmpty) {
      final term = _filter.trim().toLowerCase();
      list = list.where((l) => l.toLowerCase().contains(term));
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayLines = _filteredLines;
    final displayText = displayLines.join('\n');

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Colors.green),
              const SizedBox(width: 10),
              LocalizedText(
                'Live Connection Logs (Stream)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                tooltip: localizedUiText(context, 'Copy logs'),
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: displayText.isEmpty
                          ? _logLines.join('\n')
                          : displayText,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: LocalizedText(
                        'Logs copied to clipboard (secrets redacted).',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: localizedUiText(context, 'Export log file'),
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () async {
                  try {
                    if (Platform.isAndroid) {
                      final bundle =
                          await MobileVpnBridge.exportSupportBundle();
                      await Clipboard.setData(ClipboardData(text: bundle));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: LocalizedText(
                              'Support bundle exported and copied to clipboard.',
                            ),
                          ),
                        );
                      }
                    } else {
                      final home = Platform.environment['HOME'] ?? '/tmp';
                      final file = File('$home/harmoney-vpn-connection.log');
                      await file.writeAsString(_logLines.join('\n'));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: LocalizedText('Saved to ${file.path}'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: LocalizedText('Export failed: $e')),
                      );
                    }
                  }
                },
              ),
              IconButton(
                tooltip: localizedUiText(context, 'Clear view'),
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  if (Platform.isAndroid) {
                    MobileVpnBridge.clearLogs();
                  }
                  setState(() {
                    _logLines.clear();
                    _filterController.clear();
                    _filter = '';
                    _levelFilter = 'ALL';
                  });
                },
              ),
              IconButton(
                tooltip: localizedUiText(context, 'Close'),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final level in ['ALL', 'INFO', 'WARNING', 'ERROR'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: LocalizedText(level),
                    selected: _levelFilter == level,
                    onSelected: (val) {
                      if (val) setState(() => _levelFilter = level);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: localizedUiText(
                context,
                'Filter by phase (PREPARING, IKE, AUTHENTICATING, VERIFYING, CONNECTED, FAILED) or keyword…',
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _filterController.clear();
                        setState(() => _filter = '');
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (val) => setState(() => _filter = val),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText(
                  displayText.isEmpty
                      ? (_logLines.isEmpty
                          ? localizedUiText(
                              context,
                              'Waiting for engine connection log stream events…',
                            )
                          : localizedUiText(
                              context,
                              'No log lines matched the filter "$_filter" [$_levelFilter].',
                            ))
                      : displayText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    color: Colors.greenAccent,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalizedText(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            LocalizedText(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  const _QuotaCard({required this.quota});
  final Map<String, dynamic> quota;

  double _number(String key) => double.tryParse('${quota[key] ?? 0}') ?? 0;
  String _size(double bytes) =>
      '${(bytes / 1073741824).toStringAsFixed(1)} GiB';

  @override
  Widget build(BuildContext context) {
    final limit = _number('limit');
    final remaining = _number('remaining');
    final used = (limit - remaining).clamp(0, limit).toDouble();
    final progress = limit <= 0 ? 0.0 : used / limit;
    final reset = DateTime.tryParse('${quota['reset'] ?? ''}')?.toLocal();
    return MotionEntrance(
      delay: const Duration(milliseconds: 130),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.data_usage_rounded),
                  const SizedBox(width: 10),
                  LocalizedText(
                    'Firefox data allowance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  LocalizedText('${_size(remaining)} left'),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: progress, minHeight: 8),
              const SizedBox(height: 9),
              LocalizedText(
                '${_size(used)} used of ${_size(limit)}${reset == null ? '' : ' · resets ${reset.year}-${reset.month.toString().padLeft(2, '0')}-${reset.day.toString().padLeft(2, '0')}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
