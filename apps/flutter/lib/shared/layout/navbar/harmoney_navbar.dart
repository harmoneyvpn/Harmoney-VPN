import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import 'widgets/harmoney_nav_item.dart';

class HarmoneyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onMore;

  const HarmoneyNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.onMore,
  });

  static const double _itemWidth = 52.0;
  static const double _itemHeight = 50.0;
  static const double _spacing = 6.0;
  static const int _itemCount = 5;
  static const double _trackWidth =
      (_itemWidth * _itemCount) + (_spacing * (_itemCount - 1));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF061A26).withValues(alpha: 0.50),
            const Color(0xFF04121A).withValues(alpha: 0.95),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 14.h.clamp(8.0, 20.0)),
          child: Center(
            heightFactor: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0C2434).withValues(alpha: 0.50),
                      const Color(0xFF051722).withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: _trackWidth,
                  height: _itemHeight,
                  child: Stack(
                    children: [
                      // Sliding Active Apple Glass Capsule
                      AnimatedPositionedDirectional(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        start: currentIndex.clamp(0, _itemCount - 1) *
                            (_itemWidth + _spacing),
                        top: 0,
                        width: _itemWidth,
                        height: _itemHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF00F5B8).withValues(alpha: 0.26),
                                const Color(0xFF00E5FF).withValues(alpha: 0.12),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF00F5B8)
                                  .withValues(alpha: 0.65),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00F5B8)
                                    .withValues(alpha: 0.25),
                                blurRadius: 12,
                                spreadRadius: -1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Interactive Nav Items Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HarmoneyNavItem(
                            index: 0,
                            icon: 'chield',
                            label: l10n.appString_Connect,
                            currentIndex: currentIndex,
                            onTap: onSelect,
                            width: _itemWidth,
                            height: _itemHeight,
                          ),
                          const SizedBox(width: _spacing),
                          HarmoneyNavItem(
                            index: 1,
                            icon: 'vpn_cloud',
                            label: l10n.appString_Locations,
                            currentIndex: currentIndex,
                            onTap: onSelect,
                            width: _itemWidth,
                            height: _itemHeight,
                          ),
                          const SizedBox(width: _spacing),
                          HarmoneyNavItem(
                            index: 2,
                            icon: 'speed',
                            label: l10n.appString_Statistics,
                            currentIndex: currentIndex,
                            onTap: onSelect,
                            width: _itemWidth,
                            height: _itemHeight,
                          ),
                          const SizedBox(width: _spacing),
                          HarmoneyNavItem(
                            index: 3,
                            icon: 'Shield',
                            label: l10n.appString_Protection,
                            currentIndex: currentIndex,
                            onTap: onSelect,
                            width: _itemWidth,
                            height: _itemHeight,
                          ),
                          const SizedBox(width: _spacing),
                          HarmoneyNavItem(
                            index: 4,
                            icon: 'settings',
                            label: l10n.appString_Settings,
                            currentIndex: currentIndex,
                            onTap: onSelect,
                            width: _itemWidth,
                            height: _itemHeight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
