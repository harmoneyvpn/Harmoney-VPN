import 'dart:ui';
import '../../../../shared/country_flag.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/vpn_core.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class HeaderSection extends StatelessWidget {
  final VpnConnectionStatus status;
  final VpnServer? server;
  final String providerId;
  final String protocol;
  final int? pingMs;
  final VoidCallback onSelectServer;
  final VoidCallback onRefreshPing;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenDebugLogs;

  const HeaderSection({
    super.key,
    required this.status,
    this.server,
    required this.providerId,
    this.protocol = 'Auto',
    this.pingMs,
    required this.onSelectServer,
    required this.onRefreshPing,
    this.onOpenMenu,
    this.onOpenDebugLogs,
  });

  @override
  Widget build(BuildContext context) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    final fallbackCountry = providerId == 'firetunnel'
        ? (localizedUiText(
            context,
            (isPersian
                ? 'سرور خودکار Firefox VPN'
                : 'Automatic Firefox VPN server')))
        : (localizedUiText(context,
            (isPersian ? 'مسیریابی هوشمند Harmoney' : 'Harmoney Smart Route')));
    final fallbackCity = localizedUiText(
        context,
        (isPersian
            ? 'انتخاب خودکار سریع‌ترین سرور'
            : 'Automatic fastest route selection'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo & Title
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'H',
                            style: TextStyle(
                              fontSize: 34.sp.clamp(28.0, 40.0),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFC46B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'armoney',
                            style: TextStyle(
                              fontSize: 30.sp.clamp(24.0, 36.0),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Info & Server Button
            IconButton(
              icon: AppIcons.info(
                width: 22.w.clamp(20.0, 26.0),
                height: 22.w.clamp(20.0, 26.0),
                colorFilter: const ColorFilter.mode(
                  Colors.white70,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onOpenMenu,
              tooltip: localizedUiText(context, 'Quick Menu'),
            ),
            if (kDebugMode)
              IconButton(
                icon: Icon(
                  Icons.bug_report_outlined,
                  size: 22.w.clamp(20.0, 26.0),
                  color: Colors.orangeAccent,
                ),
                onPressed: onOpenDebugLogs,
                tooltip: localizedUiText(context, 'Debug Logs'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Server selection pill and real-time Ping
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: InkWell(
              onTap: onSelectServer,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      const Color(0xFF08202D).withValues(alpha: 0.45),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Flag / Route Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: _buildLocationIcon(),
                    ),
                    const SizedBox(width: 12),

                    // Location Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LocalizedText(
                            (server?.countryCode == 'UNKNOWN' ||
                                    server?.country == 'Unknown')
                                ? (Localizations.localeOf(context)
                                            .languageCode ==
                                        'fa'
                                    ? 'نامشخص'
                                    : 'Unknown')
                                : (server?.country ?? fallbackCountry),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp.clamp(13.0, 17.0),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          LocalizedText(
                            server?.city ?? fallbackCity,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp.clamp(10.0, 14.0),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Ping Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _pingColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        LocalizedText(
                          pingMs != null && pingMs! > 0
                              ? '$pingMs ms'
                              : '-- ms',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp.clamp(10.0, 14.0),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationIcon() {
    final code = CountryFlags.resolve(server);
    if (code.isNotEmpty) {
      return Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF00D4AA).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CountryFlag(code: code, size: 34.w),
      );
    }

    if (server?.countryCode?.toLowerCase() == 'auto') {
      return const Icon(
        Icons.flash_on_rounded,
        color: Color(0xFFFFC46B),
        size: 20,
      );
    }
    return const Icon(Icons.public_rounded, color: Color(0xFF72D9FF), size: 20);
  }

  Color get _pingColor {
    if (pingMs == null || pingMs! <= 0) return Colors.grey;
    if (pingMs! < 120) return const Color(0xFF61F2C2);
    if (pingMs! < 240) return const Color(0xFFFFC46B);
    return const Color(0xFFE72E44);
  }
}
