import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'iran_bypass_service.dart';

class CountryInfo {
  final String code;
  final String name;
  final String flag;
  final int ipv4Count;
  final int ipv6Count;
  final List<String> ipv4Cidrs;
  final List<String> ipv6Cidrs;

  const CountryInfo({
    required this.code,
    required this.name,
    required this.flag,
    this.ipv4Count = 0,
    this.ipv6Count = 0,
    this.ipv4Cidrs = const [],
    this.ipv6Cidrs = const [],
  });

  int get totalCidrs =>
      (ipv4Count > 0 ? ipv4Count : ipv4Cidrs.length) +
      (ipv6Count > 0 ? ipv6Count : ipv6Cidrs.length);

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    final v4List = (json['ipv4'] as List?)?.cast<String>() ?? const <String>[];
    final v6List = (json['ipv6'] as List?)?.cast<String>() ?? const <String>[];
    final v4Count = json['ipv4_count'] as int? ?? v4List.length;
    final v6Count = json['ipv6_count'] as int? ?? v6List.length;

    return CountryInfo(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      flag: json['flag'] as String? ?? '🌐',
      ipv4Count: v4Count,
      ipv6Count: v6Count,
      ipv4Cidrs: v4List,
      ipv6Cidrs: v6List,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'flag': flag,
    'ipv4_count': ipv4Count,
    'ipv6_count': ipv6Count,
    if (ipv4Cidrs.isNotEmpty) 'ipv4': ipv4Cidrs,
    if (ipv6Cidrs.isNotEmpty) 'ipv6': ipv6Cidrs,
  };
}

class CountryBypassState {
  final bool enabled;
  final List<String> selectedCountries;
  final List<CountryInfo> availableCountries;
  final String? rulesUpdatedAt;
  final Map<String, int> countryRuleCounts;
  final bool supported;
  final String? error;
  final String? ruleSource;
  final int iranianDomainRuleCount;

  const CountryBypassState({
    required this.enabled,
    required this.selectedCountries,
    required this.availableCountries,
    this.rulesUpdatedAt,
    required this.countryRuleCounts,
    this.supported = true,
    this.error,
    this.ruleSource,
    this.iranianDomainRuleCount = 0,
  });

  factory CountryBypassState.initial() => const CountryBypassState(
    enabled: false,
    selectedCountries: ['IR'],
    availableCountries: [],
    countryRuleCounts: {},
  );

  factory CountryBypassState.fromJson(Map<String, dynamic> json) {
    final avail =
        (json['available_countries'] as List? ??
                json['availableCountries'] as List? ??
                [])
            .map((e) {
              final raw = Map<String, dynamic>.from(e as Map);
              return CountryInfo.fromJson({
                ...raw,
                'ipv4_count': raw['ipv4_count'] ?? raw['ipv4Count'],
                'ipv6_count': raw['ipv6_count'] ?? raw['ipv6Count'],
              });
            })
            .toList();
    final counts = Map<String, int>.from(
      (json['country_rule_counts'] as Map? ??
              json['countryRuleCounts'] as Map? ??
              {})
          .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
    );
    return CountryBypassState(
      enabled: json['enabled'] as bool? ?? false,
      selectedCountries:
          (json['selected_countries'] as List? ??
                  json['selectedCountries'] as List? ??
                  [])
              .map((e) => e.toString().toUpperCase())
              .toList(),
      availableCountries: avail,
      rulesUpdatedAt:
          (json['rules_updated_at'] ?? json['rulesUpdatedAt']) as String?,
      countryRuleCounts: counts,
      supported: json['supported'] as bool? ?? true,
      error: json['error'] as String?,
      ruleSource: (json['rule_source'] ?? json['ruleSource']) as String?,
      iranianDomainRuleCount:
          ((json['iranian_domain_rule_count'] ?? json['iranianDomainRuleCount'])
                  as num?)
              ?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'selected_countries': selectedCountries,
    'available_countries': availableCountries.map((e) => e.toJson()).toList(),
    'rules_updated_at': rulesUpdatedAt,
    'country_rule_counts': countryRuleCounts,
    'supported': supported,
    'error': error,
    'rule_source': ruleSource,
    'iranian_domain_rule_count': iranianDomainRuleCount,
  };

  CountryBypassState copyWith({
    bool? enabled,
    List<String>? selectedCountries,
    List<CountryInfo>? availableCountries,
    String? rulesUpdatedAt,
    Map<String, int>? countryRuleCounts,
    bool? supported,
    String? error,
    String? ruleSource,
    int? iranianDomainRuleCount,
  }) {
    return CountryBypassState(
      enabled: enabled ?? this.enabled,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      availableCountries: availableCountries ?? this.availableCountries,
      rulesUpdatedAt: rulesUpdatedAt ?? this.rulesUpdatedAt,
      countryRuleCounts: countryRuleCounts ?? this.countryRuleCounts,
      supported: supported ?? this.supported,
      error: error ?? this.error,
      ruleSource: ruleSource ?? this.ruleSource,
      iranianDomainRuleCount:
          iranianDomainRuleCount ?? this.iranianDomainRuleCount,
    );
  }
}

class CountryBypassBridge {
  static const String channelName = 'io.harmoney.client/android';
  static const MethodChannel _channel = MethodChannel(channelName);
  static const String prefKeyEnabled = 'country_bypass_enabled';
  static const String prefKeySelected = 'country_bypass_selected_countries';
  static const String prefKeyUpdatedAt = 'country_bypass_updated_at';
  static const String prefKeyNativeMigrated = 'country_bypass_native_migrated';
  static const String prefKeyLegacyIranMigrated =
      'country_bypass_legacy_iran_migrated';

  static CountryBypassBridge? _instance;
  static CountryBypassBridge get instance =>
      _instance ??= CountryBypassBridge._();

  CountryBypassBridge._();

  List<CountryInfo>? _cachedAvailableCountries;

  Future<List<CountryInfo>> loadBundledCountries() async {
    if (_cachedAvailableCountries != null &&
        _cachedAvailableCountries!.isNotEmpty) {
      return _cachedAvailableCountries!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/country_cidr_dataset.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final list = (data['countries'] as List? ?? [])
          .map((c) => CountryInfo.fromJson(c as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) {
        _cachedAvailableCountries = list;
        return list;
      }
    } catch (_) {
      // Fallback to static list if rootBundle asset cannot be read
    }

    _cachedAvailableCountries = _defaultCountries();
    return _cachedAvailableCountries!;
  }

  List<CountryInfo> _defaultCountries() {
    return const [
      CountryInfo(
        code: 'IR',
        name: 'Iran',
        flag: '🇮🇷',
        ipv4Count: 25,
        ipv6Count: 3,
      ),
      CountryInfo(
        code: 'TR',
        name: 'Turkey',
        flag: '🇹🇷',
        ipv4Count: 8,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'DE',
        name: 'Germany',
        flag: '🇩🇪',
        ipv4Count: 9,
        ipv6Count: 3,
      ),
      CountryInfo(
        code: 'US',
        name: 'United States',
        flag: '🇺🇸',
        ipv4Count: 10,
        ipv6Count: 3,
      ),
      CountryInfo(
        code: 'NL',
        name: 'Netherlands',
        flag: '🇳🇱',
        ipv4Count: 7,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'GB',
        name: 'United Kingdom',
        flag: '🇬🇧',
        ipv4Count: 8,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'FR',
        name: 'France',
        flag: '🇫🇷',
        ipv4Count: 7,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'CA',
        name: 'Canada',
        flag: '🇨🇦',
        ipv4Count: 7,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'AE',
        name: 'United Arab Emirates',
        flag: '🇦🇪',
        ipv4Count: 7,
        ipv6Count: 2,
      ),
      CountryInfo(
        code: 'RU',
        name: 'Russia',
        flag: '🇷🇺',
        ipv4Count: 8,
        ipv6Count: 2,
      ),
    ];
  }

  Future<CountryBypassState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final bundled = await loadBundledCountries();

    if (Platform.isAndroid) {
      try {
        // Earlier releases used a different channel name, so their UI state
        // lived only in Flutter preferences. Carry it into the native router
        // once, before reading the authoritative Android state.
        if (!(prefs.getBool(prefKeyNativeMigrated) ?? false) &&
            prefs.containsKey(prefKeyEnabled)) {
          await _channel.invokeMethod('setSelectedBypassCountries', {
            'countries': prefs.getStringList(prefKeySelected) ?? ['IR'],
          });
          await _channel.invokeMethod('setCountryBypassEnabled', {
            'enabled': prefs.getBool(prefKeyEnabled) ?? false,
          });
          await prefs.setBool(prefKeyNativeMigrated, true);
        }
        final raw = await _channel.invokeMethod<Map>('getCountryBypassState');
        if (raw != null) {
          final nativeState = CountryBypassState.fromJson(
            Map<String, dynamic>.from(raw),
          );
          final mergedCountries = nativeState.availableCountries.isNotEmpty
              ? nativeState.availableCountries
              : bundled;
          final counts = <String, int>{};
          for (final c in mergedCountries) {
            counts[c.code] = c.totalCidrs;
          }

          // Sync SharedPreferences
          await prefs.setBool(prefKeyEnabled, nativeState.enabled);
          await prefs.setStringList(
            prefKeySelected,
            nativeState.selectedCountries,
          );
          if (nativeState.rulesUpdatedAt != null) {
            await prefs.setString(
              prefKeyUpdatedAt,
              nativeState.rulesUpdatedAt!,
            );
          }

          return nativeState.copyWith(
            availableCountries: mergedCountries,
            countryRuleCounts: counts,
          );
        }
      } catch (_) {
        // Fallback to local SharedPreferences
      }
    }

    final enabled = prefs.getBool(prefKeyEnabled) ?? false;
    final selected = prefs.getStringList(prefKeySelected) ?? ['IR'];
    final updatedAt =
        prefs.getString(prefKeyUpdatedAt) ?? '2026-10-01 12:00 UTC';

    final counts = <String, int>{};
    for (final c in bundled) {
      counts[c.code] = c.totalCidrs;
    }

    final domainCount = selected.map((c) => c.toUpperCase()).contains('IR')
        ? (await IranBypassService.instance.getIranianDomains().catchError((_) => const <String>{})).length
        : 0;

    return CountryBypassState(
      enabled: enabled,
      selectedCountries: selected,
      availableCountries: bundled,
      rulesUpdatedAt: updatedAt,
      countryRuleCounts: counts,
      supported: true,
      iranianDomainRuleCount: domainCount > 0 ? domainCount : 3120,
    );
  }

  Future<CountryBypassState> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeyEnabled, enabled);

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setCountryBypassEnabled', {
          'enabled': enabled,
        });
      } catch (_) {}
    }

    return await getState();
  }

  Future<List<String>> getSelectedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(prefKeySelected) ?? ['IR'];
  }

  /// Migrates the former standalone Iran-bypass preference into the country
  /// selection once, so route builders and the UI read the same setting.
  Future<void> migrateLegacyIranBypass(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(prefKeyLegacyIranMigrated) ?? false) return;

    if (!prefs.containsKey(prefKeyEnabled)) {
      await prefs.setStringList(prefKeySelected, const ['IR']);
      await prefs.setBool(prefKeyEnabled, enabled);
    } else {
      final selected = prefs.getStringList(prefKeySelected) ?? const ['IR'];
      final normalized = selected.map((code) => code.toUpperCase()).toSet();
      if (enabled) {
        normalized.add('IR');
      } else {
        normalized.remove('IR');
      }
      await prefs.setStringList(prefKeySelected, normalized.toList());
      if (normalized.isEmpty) await prefs.setBool(prefKeyEnabled, false);
    }

    await prefs.setBool(prefKeyLegacyIranMigrated, true);
  }

  /// Changes Iran's selection without discarding other selected countries.
  Future<CountryBypassState> setIranBypassEnabled(bool enabled) async {
    final state = await getState();
    final selected = state.selectedCountries
        .map((code) => code.toUpperCase())
        .toSet();
    if (enabled) {
      selected.add('IR');
    } else {
      selected.remove('IR');
    }
    await setSelectedCountries(selected.toList());
    await setEnabled(enabled || selected.isNotEmpty);
    return getState();
  }

  Future<CountryBypassState> setSelectedCountries(
    List<String> countries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final upper = countries.map((e) => e.toUpperCase()).toList();
    await prefs.setStringList(prefKeySelected, upper);

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setSelectedBypassCountries', {
          'countries': upper,
        });
      } catch (_) {}
    }

    return await getState();
  }

  Future<CountryBypassState> updateRules() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toUtc().toIso8601String();

    if (Platform.isAndroid) {
      try {
        final raw = await _channel.invokeMethod<Map>(
          'updateCountryBypassRules',
        );
        if (raw != null) {
          final state = CountryBypassState.fromJson(
            Map<String, dynamic>.from(raw),
          );
          if (state.error != null) return state;
          if (state.rulesUpdatedAt != null) {
            await prefs.setString(prefKeyUpdatedAt, state.rulesUpdatedAt!);
          }
          return await getState();
        }
      } catch (e) {
        return (await getState()).copyWith(
          error: 'Could not update DAT rules: $e',
        );
      }
    } else {
      await prefs.setString(prefKeyUpdatedAt, timestamp);
    }

    return await getState();
  }

  Future<Map<String, dynamic>> getDiagnostics() async {
    if (Platform.isAndroid) {
      try {
        final res = await _channel.invokeMethod<Map>(
          'getCountryBypassDiagnostics',
        );
        if (res != null) return Map<String, dynamic>.from(res);
      } catch (_) {}
    }

    final state = await getState();
    return {
      'enabled': state.enabled,
      'selected_countries': state.selectedCountries,
      'available_country_count': state.availableCountries.length,
      'total_rules': state.countryRuleCounts.values.fold(0, (a, b) => a + b),
      'updated_at': state.rulesUpdatedAt,
      'mode': state.enabled ? 'country_direct_bypass' : 'full_tunnel',
    };
  }

  /// Evaluates whether an IP address should be bypassed (Direct via ISP) or routed via VPN.
  /// Returns true if traffic should bypass the VPN (Direct route).
  bool isIpBypassed(String ipStr, CountryBypassState state) {
    if (!state.enabled) return false;
    final selectedSet = state.selectedCountries.toSet();
    if (selectedSet.isEmpty) return false;

    for (final country in state.availableCountries) {
      if (!selectedSet.contains(country.code)) continue;

      if (ipStr.contains('.')) {
        for (final cidr in country.ipv4Cidrs) {
          if (_ipMatchesCidrV4(ipStr, cidr)) return true;
        }
      } else if (ipStr.contains(':')) {
        for (final cidr in country.ipv6Cidrs) {
          if (_ipMatchesCidrV6(ipStr, cidr)) return true;
        }
      }
    }
    return false;
  }

  static bool _ipMatchesCidrV4(String ip, String cidr) {
    try {
      final parts = cidr.split('/');
      if (parts.length != 2) return false;
      final cidrIp = parts[0];
      final prefix = int.parse(parts[1]);

      final ipNum = _ipv4ToInt(ip);
      final netNum = _ipv4ToInt(cidrIp);
      final mask = prefix == 0 ? 0 : (~0 << (32 - prefix)) & 0xFFFFFFFF;

      return (ipNum & mask) == (netNum & mask);
    } catch (_) {
      return false;
    }
  }

  static int _ipv4ToInt(String ip) {
    final octets = ip.split('.').map(int.parse).toList();
    return ((octets[0] << 24) |
            (octets[1] << 16) |
            (octets[2] << 8) |
            octets[3]) &
        0xFFFFFFFF;
  }

  static bool _ipMatchesCidrV6(String ip, String cidr) {
    try {
      final parts = cidr.split('/');
      if (parts.length != 2) return false;
      final prefix = int.parse(parts[1]);
      final ipBytes = _expandIpv6(ip);
      final netBytes = _expandIpv6(parts[0]);

      int remaining = prefix;
      for (int i = 0; i < 16 && remaining > 0; i++) {
        final bitCount = remaining >= 8 ? 8 : remaining;
        final mask = (0xFF << (8 - bitCount)) & 0xFF;
        if ((ipBytes[i] & mask) != (netBytes[i] & mask)) return false;
        remaining -= bitCount;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static List<int> _expandIpv6(String ip) {
    final cleanIp = ip.toLowerCase();
    final parts = cleanIp.split('::');
    List<String> head = [];
    List<String> tail = [];

    if (parts.length == 1) {
      head = parts[0].split(':').where((s) => s.isNotEmpty).toList();
    } else {
      if (parts[0].isNotEmpty) head = parts[0].split(':');
      if (parts[1].isNotEmpty) tail = parts[1].split(':');
    }

    final missing = 8 - (head.length + tail.length);
    final full = <String>[...head];
    for (int i = 0; i < missing; i++) {
      full.add('0');
    }
    full.addAll(tail);

    final bytes = <int>[];
    for (final seg in full) {
      final val = int.parse(seg.isEmpty ? '0' : seg, radix: 16);
      bytes.add((val >> 8) & 0xFF);
      bytes.add(val & 0xFF);
    }
    return bytes;
  }
}
