import 'dart:io';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'harmoney_vpn_core.dart';
import 'desktop_protocol_parity_vpn_core.dart';
import 'firetunnel_vpn_core.dart';
import 'macos_vpn_core.dart';
import 'mobile_vpn_core.dart';
import 'provider_routing_vpn_core.dart';
import 'vpn_core.dart';

final sharedVpnCoreProvider = Provider<VpnCore>((ref) {
  // Provider-specific native cores are wired separately below.
  return const UnsupportedVpnCore();
});

final harmoneyVpnCoreProvider = Provider<HarmoneyCore>((ref) {
  final core = HarmoneyCore();
  ref.onDispose(core.dispose);
  return core;
});

final fireTunnelVpnCoreProvider = Provider<FireTunnelVpnCore>((ref) {
  return FireTunnelVpnCore();
});

final fireTunnelAccountProvider =
    FutureProvider.autoDispose<FireTunnelAccountState>((ref) {
      final refresh = Timer(const Duration(minutes: 1), ref.invalidateSelf);
      ref.onDispose(refresh.cancel);
      return ref.watch(fireTunnelVpnCoreProvider).accountState();
    });

final vpnCoreProvider = Provider<VpnCore>((ref) {
  try {
    final sharedCore = ref.watch(sharedVpnCoreProvider);
    final harmoneyCore = ref.watch(harmoneyVpnCoreProvider);
    final fireTunnelCore = ref.watch(fireTunnelVpnCoreProvider);
    if (Platform.isAndroid || Platform.isIOS) {
      final existing = MobileVpnCore(sharedCore);
      return ProviderRoutingVpnCore(existing, fireTunnelCore, harmoneyCore);
    }
    if (Platform.isMacOS) {
      final existing = MacOsVpnCore(sharedCore);
      return ProviderRoutingVpnCore(existing, fireTunnelCore, harmoneyCore);
    }
    if (Platform.isLinux || Platform.isWindows) {
      final existing = DesktopProtocolParityVpnCore(sharedCore);
      return ProviderRoutingVpnCore(existing, fireTunnelCore, harmoneyCore);
    }
    return ProviderRoutingVpnCore(sharedCore, fireTunnelCore, harmoneyCore);
  } catch (_) {
    return const UnsupportedVpnCore();
  }
});

final connectionStateProvider = StreamProvider<VpnConnectionState>((ref) {
  return ref.watch(vpnCoreProvider).watchConnection();
});

final harmoneyServersProvider = FutureProvider<List<VpnServer>>((ref) {
  return ref
      .watch(vpnCoreProvider)
      .listServers(providerId: HarmoneyCore.providerId);
});

final vpnServersProvider = FutureProvider.family<List<VpnServer>, String>((
  ref,
  providerId,
) {
  if (providerId == FireTunnelVpnCore.providerId && Platform.isAndroid) {
    final refresh = Timer(const Duration(seconds: 30), ref.invalidateSelf);
    ref.onDispose(refresh.cancel);
  }
  return ref.watch(vpnCoreProvider).listServers(providerId: providerId);
});
