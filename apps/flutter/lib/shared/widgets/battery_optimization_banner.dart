import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class BatteryOptimizationBanner extends StatefulWidget {
  const BatteryOptimizationBanner({super.key});

  @override
  State<BatteryOptimizationBanner> createState() =>
      _BatteryOptimizationBannerState();
}

class _BatteryOptimizationBannerState extends State<BatteryOptimizationBanner>
    with WidgetsBindingObserver {
  bool _isOptimizationActive = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    if (!Platform.isAndroid) return;
    try {
      final isDisabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      if (mounted) {
        setState(() {
          // If isDisabled is false, battery optimization is active (not disabled)
          _isOptimizationActive = isDisabled == false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOptimizationActive = false);
    }
  }

  Future<void> _disableOptimization() async {
    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid || !_isOptimizationActive || _dismissed) {
      return const SizedBox.shrink();
    }

    final isFa = Localizations.localeOf(context).languageCode == 'fa';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A11).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.battery_alert_rounded,
                  color: Color(0xFFFFB300),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      isFa
                          ? 'بهینه‌سازی باتری فعال است (Doze Mode)'
                          : 'Battery Optimization Active (Doze Mode)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFFFE082),
                      ),
                    ),
                    const SizedBox(height: 4),
                    LocalizedText(
                      isFa
                          ? 'برای جلوگیری از قطع ناگهانی اتصال VPN در پس‌زمینه توسط اندروید، بهینه‌سازی مصرف باتری را برای این برنامه غیرفعال کنید.'
                          : 'To prevent Android from killing the VPN connection in background, disable battery optimization for this app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18, color: Colors.white60),
                onPressed: () => setState(() => _dismissed = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: isFa ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300).withValues(alpha: 0.2),
                foregroundColor: const Color(0xFFFFE082),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              onPressed: _disableOptimization,
              icon: const Icon(Icons.settings_power_rounded, size: 16),
              label: LocalizedText(
                isFa ? 'تنظیمات باتری' : 'Disable Optimization',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
