import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 360);
  static const slow = Duration(milliseconds: 620);
  static const curve = Curves.easeOutCubic;
}

class MotionEntrance extends StatelessWidget {
  const MotionEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .035),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    return child
        .animate(delay: delay)
        .fadeIn(duration: AppMotion.normal, curve: AppMotion.curve)
        .slide(
          begin: offset,
          end: Offset.zero,
          duration: AppMotion.slow,
          curve: AppMotion.curve,
        );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.height = 72, this.borderRadius = 18});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final box = Container(
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return box;
    return box
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1300),
          color: scheme.onSurface.withValues(alpha: .08),
        );
  }
}
