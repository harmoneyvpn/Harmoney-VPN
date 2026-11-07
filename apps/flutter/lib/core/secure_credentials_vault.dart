import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'country_bypass_bridge.dart';

class SecureCredentialsVault {
  SecureCredentialsVault._();

  static final SecureCredentialsVault instance = SecureCredentialsVault._();

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );

  static const _linuxOptions = LinuxOptions();

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static const _macOsOptions = MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static const _windowsOptions = WindowsOptions();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    lOptions: _linuxOptions,
    iOptions: _iosOptions,
    mOptions: _macOsOptions,
    wOptions: _windowsOptions,
  );

  static const _keyHarmoneySubscriptions = 'vault_harmoney_subscriptions_v1';
  static const _keyBypassIran = 'vault_bypass_iran_traffic';
  static const _keyHotspotSharing = 'vault_hotspot_vpn_sharing';

  Future<void> saveSecret(String key, String secret) async {
    await _storage.write(key: 'secret_$key', value: secret);
  }

  Future<String?> getSecret(String key) async {
    return await _storage.read(key: 'secret_$key');
  }

  Future<String?> getHarmoneySubscriptions() =>
      _storage.read(key: _keyHarmoneySubscriptions);

  Future<void> saveHarmoneySubscriptions(String value) =>
      _storage.write(key: _keyHarmoneySubscriptions, value: value);

  Future<bool> isBypassIranEnabled() async {
    final legacyValue = await _storage.read(key: _keyBypassIran);
    if (legacyValue != null) {
      await CountryBypassBridge.instance.migrateLegacyIranBypass(
        legacyValue == 'true',
      );
      await _storage.delete(key: _keyBypassIran);
    }
    try {
      final state = await CountryBypassBridge.instance.getState();
      return state.enabled &&
          state.selectedCountries.map((c) => c.toUpperCase()).contains('IR');
    } catch (_) {
      return false;
    }
  }

  Future<void> setBypassIranEnabled(bool enabled) async {
    await CountryBypassBridge.instance.setIranBypassEnabled(enabled);
    await _storage.delete(key: _keyBypassIran);
  }

  Future<bool> isHotspotSharingEnabled() async {
    final value = await _storage.read(key: _keyHotspotSharing);
    return value == 'true'; // Default OFF
  }

  Future<void> setHotspotSharingEnabled(bool enabled) async {
    await _storage.write(key: _keyHotspotSharing, value: enabled.toString());
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
