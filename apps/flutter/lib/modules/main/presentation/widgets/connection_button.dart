import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/vpn_core.dart';

/// Professional Cyber-Glass Shield Connection Button
/// Engineered for ultra-smooth 60/120 FPS performance with zero idle lag:
/// - No heavy repeating animations or radar sweeps while connecting.
/// - Single-shot holographic shockwave and lock-in spring on connection success.
/// - Graceful fade-out transitions when disconnecting.
/// - Single-shot crimson warning ripple and cyber recoil shake when connection fails.
class ConnectionButton extends StatefulWidget {
  final VpnConnectionStatus status;
  final VoidCallback onTap;
  final DateTime? connectedAt;

  const ConnectionButton({
    super.key,
    required this.status,
    required this.onTap,
    this.connectedAt,
  });

  @override
  State<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<ConnectionButton>
    with TickerProviderStateMixin {
  late final AnimationController _connectSuccessController;
  late final AnimationController _errorController;
  late final AnimationController _pressController;

  late final Animation<double> _connectProgressAnimation;
  late final Animation<double> _connectScaleAnimation;
  late final Animation<double> _errorProgressAnimation;
  late final Animation<double> _errorShakeAnimation;
  late final Animation<double> _pressScaleAnimation;

  Timer? _timer;
  int _seconds = 0;
  String _formattedTime = "00:00:00";
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleTimerState(widget.status);
  }

  void _initAnimations() {
    // 1. Connection Success Animation (Single-shot, plays once on connect and stops)
    _connectSuccessController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _connectProgressAnimation = CurvedAnimation(
      parent: _connectSuccessController,
      curve: Curves.easeOutCubic,
    );

    // Tactile lock-in pop curve
    _connectScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 28,
      ),
    ]).animate(_connectSuccessController);

    // 2. Connection Failed/Error Animation (Single-shot, plays once on fail and stops)
    _errorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _errorProgressAnimation = CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeOutCubic,
    );

    // Subtle cyber recoil shake
    _errorShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -6.5)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -6.5, end: 5.5)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 5.5, end: -4.0)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -4.0, end: 2.5)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 2.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 25,
      ),
    ]).animate(_errorController);

    // 3. Press scale animation for spring tactile feedback
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pressScaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant ConnectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _handleStatusTransition(oldWidget.status, widget.status);
      _handleTimerState(widget.status);
    }
  }

  void _handleStatusTransition(
      VpnConnectionStatus oldStatus, VpnConnectionStatus newStatus) {
    if (newStatus == VpnConnectionStatus.connected) {
      HapticFeedback.mediumImpact();
      _errorController.stop();
      _connectSuccessController.forward(from: 0.0);
    } else if (newStatus == VpnConnectionStatus.failed ||
        newStatus == VpnConnectionStatus.error ||
        newStatus == VpnConnectionStatus.authRequired) {
      HapticFeedback.heavyImpact();
      _connectSuccessController.stop();
      _errorController.forward(from: 0.0);
    } else if (newStatus == VpnConnectionStatus.disconnected ||
        newStatus == VpnConnectionStatus.idle) {
      if (oldStatus == VpnConnectionStatus.connected) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _handleTimerState(VpnConnectionStatus status) {
    if (status == VpnConnectionStatus.connected) {
      if (_timer == null || !_timer!.isActive) {
        if (widget.connectedAt != null) {
          _seconds = DateTime.now().difference(widget.connectedAt!).inSeconds;
        } else {
          _seconds = 0;
        }
        _updateFormattedTime();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _seconds++;
            _updateFormattedTime();
          });
        });
      }
    } else {
      _timer?.cancel();
      _timer = null;
      // Do not clear _formattedTime immediately to permit graceful fade-out
    }
  }

  void _updateFormattedTime() {
    final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    _formattedTime = "$hours:$minutes:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectSuccessController.dispose();
    _errorController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = 136.w.clamp(120.0, 160.0);
    final double effectAreaSize = (buttonSize + 84.0).clamp(204.0, 250.0);

    final isConnected = widget.status == VpnConnectionStatus.connected;
    final isTransitioning = widget.status == VpnConnectionStatus.connecting ||
        widget.status == VpnConnectionStatus.authenticating ||
        widget.status == VpnConnectionStatus.preparing ||
        widget.status == VpnConnectionStatus.verifying ||
        widget.status == VpnConnectionStatus.reconnecting ||
        widget.status == VpnConnectionStatus.discovering ||
        widget.status == VpnConnectionStatus.recovering;
    final isError = widget.status == VpnConnectionStatus.error ||
        widget.status == VpnConnectionStatus.failed ||
        widget.status == VpnConnectionStatus.authRequired;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
              _pressController.forward();
            },
            onTapUp: (_) {
              _pressController.reverse();
              widget.onTap();
            },
            onTapCancel: () => _pressController.reverse(),
            child: ScaleTransition(
              scale: _pressScaleAnimation,
              child: SizedBox(
                width: effectAreaSize,
                height: effectAreaSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Single-Shot Holographic Ripple / Error Shockwave
                    RepaintBoundary(
                      child: AnimatedOpacity(
                        opacity: isConnected || isError ? 1 : 0,
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOut,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _connectSuccessController,
                            _errorController,
                          ]),
                          builder: (context, _) => CustomPaint(
                            size: Size.square(effectAreaSize),
                            painter: _ConnectionBurstPainter(
                              connectProgress: _connectProgressAnimation.value,
                              isConnectAnimating:
                                  _connectSuccessController.isAnimating,
                              errorProgress: _errorProgressAnimation.value,
                              isErrorAnimating: _errorController.isAnimating,
                              showError: isError,
                              baseRadius: buttonSize * 0.49,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Core Shield Button with Connect-Pop and Error-Shake
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _connectScaleAnimation,
                        _errorShakeAnimation,
                      ]),
                      builder: (context, child) {
                        final double popScale =
                            _connectSuccessController.isAnimating
                                ? _connectScaleAnimation.value
                                : 1.0;
                        final double shakeOffset = _errorController.isAnimating
                            ? _errorShakeAnimation.value
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(shakeOffset, 0),
                          child: Transform.scale(
                            scale: popScale,
                            child: child,
                          ),
                        );
                      },
                      child: _buildMainButton(
                        buttonSize,
                        isConnected,
                        isTransitioning,
                        isError,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Smooth Fade-out Duration HUD
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          reverseDuration: const Duration(milliseconds: 380),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child: isConnected
              ? Padding(
                  key: const ValueKey('hud_connected'),
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildDurationHud(),
                )
              : const SizedBox.shrink(key: ValueKey('hud_none')),
        ),
      ],
    );
  }

  Widget _buildMainButton(
    double buttonSize,
    bool isConnected,
    bool isTransitioning,
    bool isError,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isConnected
                ? const Color(0xFF00F5B8)
                    .withValues(alpha: _isHovered ? 0.45 : 0.30)
                : (isError
                    ? const Color(0xFFFF5252).withValues(alpha: 0.40)
                    : (isTransitioning
                        ? const Color(0xFFFFC46B).withValues(alpha: 0.28)
                        : const Color(0xFF00D4AA)
                            .withValues(alpha: _isHovered ? 0.26 : 0.12))),
            blurRadius:
                isConnected ? 28 : (isError ? 24 : (isTransitioning ? 20 : 16)),
            spreadRadius: isConnected ? 2 : (isError ? 1 : 0),
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Shield Outline Vector
          AppIcons.shieldAnime(width: buttonSize, height: buttonSize),

          // Clipped Shield Core with smooth gradient transition
          Positioned.fill(
            child: ClipPath(
              clipper: SvgShieldClipper(size: buttonSize),
              clipBehavior: Clip.antiAlias,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isConnected
                        ? [
                            const Color(0xFF00F5B8).withValues(alpha: 0.28),
                            const Color(0xFF093E48).withValues(alpha: 0.88),
                          ]
                        : (isError
                            ? [
                                const Color(0xFFFF5252).withValues(alpha: 0.25),
                                const Color(0xFF381016).withValues(alpha: 0.90),
                              ]
                            : (isTransitioning
                                ? [
                                    const Color(0xFFFFC46B)
                                        .withValues(alpha: 0.22),
                                    const Color(0xFF2C200B)
                                        .withValues(alpha: 0.85),
                                  ]
                                : [
                                    const Color(0xFF133D50)
                                        .withValues(alpha: 0.80),
                                    const Color(0xFF071E2B)
                                        .withValues(alpha: 0.95),
                                  ])),
                  ),
                ),
                alignment: Alignment.center,
                child: _buildButtonContent(
                  buttonSize,
                  isConnected,
                  isTransitioning,
                  isError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent(
    double buttonSize,
    bool isConnected,
    bool isTransitioning,
    bool isError,
  ) {
    final double iconSize = (buttonSize * 0.52).clamp(52.0, 82.0);

    return AnimatedScale(
      scale: isConnected ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow behind emblem with smooth cross-fade
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: iconSize * 0.82,
            height: iconSize * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isConnected
                      ? const Color(0xFF00F5B8).withValues(alpha: 0.55)
                      : (isError
                          ? const Color(0xFFFF5252).withValues(alpha: 0.40)
                          : (isTransitioning
                              ? const Color(0xFFFFC46B).withValues(alpha: 0.35)
                              : const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.25))),
                  blurRadius: isConnected ? 28 : (isError ? 24 : 16),
                  spreadRadius: isConnected ? 3 : 1,
                ),
              ],
            ),
          ),

          // Official Harmoney Emblem
          Image.asset(
            'assets/images/app_logo_emblem.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),

          // Dynamic Badge: Checkmark for Connected, Refresh for Error
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: isConnected
                  ? Container(
                      key: const ValueKey('badge_connected'),
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00F5B8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00F5B8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Color(0xFF071E2B),
                      ),
                    )
                  : (isError
                      ? Container(
                          key: const ValueKey('badge_error'),
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF5252),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 11,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('badge_none'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2938).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00F5B8).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5B8).withValues(alpha: 0.18),
            blurRadius: 14,
            spreadRadius: -2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emerald pulsating beacon dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00F5B8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5B8).withValues(alpha: 0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          LocalizedText(
            _formattedTime,
            style: const TextStyle(
              color: Color(0xFF00F5B8),
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// High-Performance Single-Shot Effect Painter
/// Runs only during the single-shot success or error transitions and then halts completely.
class _ConnectionBurstPainter extends CustomPainter {
  final double connectProgress;
  final bool isConnectAnimating;
  final double errorProgress;
  final bool isErrorAnimating;
  final bool showError;
  final double baseRadius;

  const _ConnectionBurstPainter({
    required this.connectProgress,
    required this.isConnectAnimating,
    required this.errorProgress,
    required this.isErrorAnimating,
    required this.showError,
    required this.baseRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // 1. Connection Success Holographic Burst (Emerald / Cyan)
    if (isConnectAnimating && connectProgress > 0.0 && connectProgress < 1.0) {
      // Primary Emerald Shockwave
      final primaryRadius = baseRadius + (connectProgress * 42.0);
      final primaryAlpha = ((1.0 - connectProgress) * 0.75).clamp(0.0, 1.0);
      final primaryPaint = Paint()
        ..color = const Color(0xFF00F5B8).withValues(alpha: primaryAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - connectProgress) * 3.5 + 1.2
        ..isAntiAlias = true;
      canvas.drawCircle(center, primaryRadius, primaryPaint);

      // Secondary Cyan Shockwave
      if (connectProgress > 0.12) {
        final delayedProgress =
            ((connectProgress - 0.12) / 0.88).clamp(0.0, 1.0);
        final secondaryRadius = baseRadius + (delayedProgress * 28.0);
        final secondaryAlpha = ((1.0 - delayedProgress) * 0.55).clamp(0.0, 1.0);
        final secondaryPaint = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: secondaryAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - delayedProgress) * 2.4 + 1.0
          ..isAntiAlias = true;
        canvas.drawCircle(center, secondaryRadius, secondaryPaint);
      }

      // Quick Luminous Radial Flash Halo
      if (connectProgress < 0.40) {
        final flashAlpha =
            (math.sin(connectProgress / 0.40 * math.pi) * 0.28).clamp(0.0, 1.0);
        final flashPaint = Paint()
          ..color = const Color(0xFF00F5B8).withValues(alpha: flashAlpha)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
        canvas.drawCircle(center, baseRadius * 1.05, flashPaint);
      }
    }

    // 2. Connection Failed / Error Warning Halo (Crimson Red)
    if (isErrorAnimating && errorProgress > 0.0 && errorProgress < 1.0) {
      // Primary Crimson Shockwave Ring
      final errRadius = baseRadius + (errorProgress * 40.0);
      final errAlpha = ((1.0 - errorProgress) * 0.80).clamp(0.0, 1.0);
      final errorPaint = Paint()
        ..color = const Color(0xFFFF3B30).withValues(alpha: errAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - errorProgress) * 3.2 + 1.0
        ..isAntiAlias = true;
      canvas.drawCircle(center, errRadius, errorPaint);

      // Soft Red Warning Flash
      if (errorProgress < 0.45) {
        final flashAlpha =
            (math.sin(errorProgress / 0.45 * math.pi) * 0.26).clamp(0.0, 1.0);
        final flashPaint = Paint()
          ..color = const Color(0xFFFF5252).withValues(alpha: flashAlpha)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(center, baseRadius * 1.05, flashPaint);
      }
    }

    // Keep a subdued error ring visible after the warning ripple finishes.
    // The fade above removes it after the next disconnect or retry.
    if (showError && !isErrorAnimating) {
      final outline = Paint()
        ..color = const Color(0xFFFF3B30).withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;
      canvas.drawCircle(center, baseRadius * 1.06, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionBurstPainter oldDelegate) {
    return oldDelegate.connectProgress != connectProgress ||
        oldDelegate.isConnectAnimating != isConnectAnimating ||
        oldDelegate.errorProgress != errorProgress ||
        oldDelegate.isErrorAnimating != isErrorAnimating ||
        oldDelegate.showError != showError ||
        oldDelegate.baseRadius != baseRadius;
  }
}

/// Svg Shield Path Clipper
class SvgShieldClipper extends CustomClipper<Path> {
  final double size;

  const SvgShieldClipper({required this.size});

  @override
  Path getClip(Size clipSize) {
    const String svgPathData =
        "M51.39 1.16517L100.313 21.8855C100.72 22.0581 100.966 22.4781 100.917 22.918L94.1288 83.2901C93.9546 84.8395 93.1841 86.2602 91.9806 87.2513L51.6357 120.476C51.2665 120.781 50.7336 120.781 50.3643 120.476L10.0194 87.2513C8.8159 86.2602 8.04544 84.8395 7.87124 83.2901L1.08337 22.918C1.03392 22.4781 1.27953 22.0581 1.68712 21.8855L50.61 1.16517C50.8593 1.0596 51.1407 1.0596 51.39 1.16517Z";

    final path = parseSvgPathData(svgPathData);
    final bounds = path.getBounds();

    final scaleX = clipSize.width / bounds.width;
    final scaleY = clipSize.height / bounds.height;
    final scale = math.min(scaleX, scaleY);

    final scaledWidth = bounds.width * scale;
    final scaledHeight = bounds.height * scale;
    final offsetX = (clipSize.width - scaledWidth) / 2;
    final offsetY = (clipSize.height - scaledHeight) / 2;

    final matrix4 = Matrix4.identity()
      ..translate(
        offsetX - (bounds.left * scale),
        offsetY - (bounds.top * scale),
      )
      ..scale(scale, scale);

    return path.transform(matrix4.storage);
  }

  @override
  bool shouldReclip(covariant SvgShieldClipper oldClipper) =>
      oldClipper.size != size;
}
