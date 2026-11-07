import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'github_edition.dart';

class AppState extends ChangeNotifier {
  AppState._();

  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _autoConnectKey = 'auto_connect';
  static const _launchOnStartupKey = 'launch_on_startup';
  static const _startMinimizedKey = 'start_minimized';
  static const _killSwitchKey = 'kill_switch';
  static const _dnsProtectionKey = 'dns_protection';
  static const _ipv6ProtectionKey = 'ipv6_protection';
  static const _protocolKey = 'protocol';
  static const _providerKey = 'provider';
  static const _bypassLanKey = 'bypass_lan';
  static const _bypassDomesticKey = 'bypass_domestic';
  static const _customDnsKey = 'custom_dns';
  static const _mtuKey = 'mtu';
  static const _hapticsKey = 'haptics_enabled';
  static const _splitTunnelKey = 'split_tunneling_enabled';

  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('en');
  bool autoConnect = true;
  bool launchOnStartup = false;
  bool startMinimized = false;
  bool killSwitch = true;
  bool dnsProtection = true;
  bool ipv6Protection = true;
  bool bypassLan = true;
  bool bypassDomestic = true;
  bool splitTunnelingEnabled = false;
  String customDns = '1.1.1.1';
  int mtu = 1420;
  bool hapticsEnabled = true;
  String protocol = 'Auto';
  String provider = 'harmoney';

  static Future<AppState> load() async {
    final state = AppState._();
    late final SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      return state;
    }

    state.themeMode = switch (prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark, // Default to Harmoney's sleek dark cyber theme
    };
    state.locale = Locale(
      prefs.getString(_localeKey) ?? 'fa',
    ); // Default to Persian/Farsi as requested
    state.autoConnect = prefs.getBool(_autoConnectKey) ?? true;
    state.launchOnStartup = prefs.getBool(_launchOnStartupKey) ?? false;
    state.startMinimized = prefs.getBool(_startMinimizedKey) ?? false;
    state.killSwitch = prefs.getBool(_killSwitchKey) ?? true;
    state.dnsProtection = prefs.getBool(_dnsProtectionKey) ?? true;
    state.ipv6Protection = prefs.getBool(_ipv6ProtectionKey) ?? true;
    state.bypassLan = prefs.getBool(_bypassLanKey) ?? true;
    state.bypassDomestic = prefs.getBool(_bypassDomesticKey) ?? true;
    state.splitTunnelingEnabled = prefs.getBool(_splitTunnelKey) ?? false;
    state.customDns = prefs.getString(_customDnsKey) ?? '1.1.1.1';
    state.mtu = prefs.getInt(_mtuKey) ?? 1420;
    state.hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
    state.protocol = 'Auto';
    final savedProvider = prefs.getString(_providerKey) ?? 'harmoney';
    // Migrate the old provider preference without losing the user's settings.
    final normalizedProvider = savedProvider.toLowerCase();
    state.provider = GithubEdition.allowedProviders.contains(normalizedProvider)
        ? normalizedProvider
        : 'harmoney';
    if (state.provider != savedProvider) {
      unawaited(prefs.setString(_providerKey, state.provider));
    }

    return state;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value.name);
  }

  Future<void> setLocale(Locale value) async {
    locale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.languageCode);
  }

  Future<void> setAutoConnect(bool value) =>
      _setBool(_autoConnectKey, value, () => autoConnect = value);
  Future<void> setLaunchOnStartup(bool value) =>
      _setBool(_launchOnStartupKey, value, () => launchOnStartup = value);
  Future<void> setStartMinimized(bool value) =>
      _setBool(_startMinimizedKey, value, () => startMinimized = value);
  Future<void> setKillSwitch(bool value) =>
      _setBool(_killSwitchKey, value, () => killSwitch = value);
  Future<void> setDnsProtection(bool value) =>
      _setBool(_dnsProtectionKey, value, () => dnsProtection = value);
  Future<void> setIpv6Protection(bool value) =>
      _setBool(_ipv6ProtectionKey, value, () => ipv6Protection = value);
  Future<void> setBypassLan(bool value) =>
      _setBool(_bypassLanKey, value, () => bypassLan = value);
  Future<void> setBypassDomestic(bool value) =>
      _setBool(_bypassDomesticKey, value, () => bypassDomestic = value);
  Future<void> setSplitTunneling(bool value) =>
      _setBool(_splitTunnelKey, value, () => splitTunnelingEnabled = value);
  Future<void> setHapticsEnabled(bool value) =>
      _setBool(_hapticsKey, value, () => hapticsEnabled = value);

  Future<void> setCustomDns(String value) async {
    customDns = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customDnsKey, value);
  }

  Future<void> setMtu(int value) async {
    mtu = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_mtuKey, value);
  }

  Future<void> setProtocol(String value) async {
    if (value.toLowerCase() != 'auto') return;
    protocol = 'Auto';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_protocolKey, protocol);
  }

  Future<void> setProvider(String value) async {
    if (!GithubEdition.allowedProviders.contains(value.toLowerCase())) return;
    provider = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, value);
  }

  Future<void> _setBool(String key, bool value, VoidCallback update) async {
    update();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
