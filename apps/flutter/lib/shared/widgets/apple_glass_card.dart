import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable frosted surface for cards, segmented controls, and compact panels.
class AppleGlassCard extends StatelessWidget {
  const AppleGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.blur = 8,
    this.surfaceColor = const Color(0xFF0D2535),
    this.surfaceAlpha = 0.52,
    this.borderAlpha = 0.20,
    this.onTap,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blur;
  final Color surfaceColor;
  final double surfaceAlpha;
  final double borderAlpha;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceColor.withValues(alpha: surfaceAlpha),
            surfaceColor.withValues(alpha: surfaceAlpha * 0.78),
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: borderAlpha),
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: onTap == null
                ? content
                : InkWell(
                    onTap: onTap,
                    borderRadius: borderRadius,
                    splashColor: Colors.white.withValues(alpha: 0.10),
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
