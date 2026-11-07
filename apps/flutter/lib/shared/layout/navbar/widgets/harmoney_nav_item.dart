import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HarmoneyNavItem extends StatefulWidget {
  final int index;
  final String icon;
  final String label;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isLoading;
  final double width;
  final double height;

  const HarmoneyNavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.currentIndex,
    required this.onTap,
    this.isLoading = false,
    this.width = 50.0,
    this.height = 50.0,
  });

  @override
  State<HarmoneyNavItem> createState() => _HarmoneyNavItemState();
}

class _HarmoneyNavItemState extends State<HarmoneyNavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  IconData _getIconData(String icon) {
    return switch (icon) {
      'chield' => Icons.power_settings_new_rounded,
      'vpn_cloud' => Icons.public_rounded,
      'speed' => Icons.speed_rounded,
      'Shield' => Icons.shield_rounded,
      _ => Icons.tune_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final iconData = _getIconData(widget.icon);

    return Tooltip(
      message: widget.label,
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: const Color(0xFF07212E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF00D4AA).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: const Color(0xFF61F2C2),
        fontSize: 11.sp.clamp(10.0, 13.0),
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => _pressController.forward(),
          onTapUp: (_) {
            _pressController.reverse();
            widget.onTap(widget.index);
          },
          onTapCancel: () => _pressController.reverse(),
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: !isSelected && _isHovered
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF61F2C2),
                        ),
                      )
                    : TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: isSelected ? 0.9 : 1.0,
                          end: isSelected ? 1.12 : (_isHovered ? 1.06 : 1.0),
                        ),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    if (isSelected) {
                                      return const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF61F2C2),
                                          Color(0xFF00E5FF),
                                        ],
                                      ).createShader(bounds);
                                    }
                                    final baseColor = _isHovered
                                        ? Colors.white
                                        : Colors.white60;
                                    return LinearGradient(
                                      colors: [baseColor, baseColor],
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    iconData,
                                    size: 22.sp.clamp(20.0, 26.0),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    width: isSelected ? 14 : 0,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF61F2C2),
                                          Color(0xFF00E5FF),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00D4AA)
                                              .withValues(alpha: 0.7),
                                          blurRadius: 6,
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
