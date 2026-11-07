import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

import '../services/haptic_service.dart';

enum ConnectButtonState { idle, connecting, connected, disconnecting }

class CyberConnectButton extends StatefulWidget {
  const CyberConnectButton({
    super.key,
    required this.state,
    required this.onTap,
    this.size = 140,
  });

  final ConnectButtonState state;
  final VoidCallback onTap;
  final double size;

  @override
  State<CyberConnectButton> createState() => _CyberConnectButtonState();
}

class _CyberConnectButtonState extends State<CyberConnectButton>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CyberConnectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (widget.state == ConnectButtonState.connected) {
        HapticService.success();
      } else if (widget.state == ConnectButtonState.idle &&
          oldWidget.state == ConnectButtonState.connected) {
        HapticService.error();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isConnecting = state == ConnectButtonState.connecting;
    final isConnected = state == ConnectButtonState.connected;
    final isDisconnecting = state == ConnectButtonState.disconnecting;

    final primaryColor = isConnected
        ? const Color(0xFF00D4AA)
        : isConnecting
        ? const Color(0xFF29B6F6)
        : const Color(0xFF7C4DFF);

    return Center(
      child: GestureDetector(
        onTap: () {
          HapticService.lightClick();
          widget.onTap();
        },
        child: SizedBox(
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar Ripples (Connecting / Connected)
              if (isConnecting || isConnected)
                AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(widget.size * 1.5, widget.size * 1.5),
                      painter: _RadarWavePainter(
                        progress: _rippleController.value,
                        color: primaryColor,
                        count: isConnecting ? 3 : 2,
                      ),
                    );
                  },
                ),

              // Rotating Neon Gradient Ring
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * pi,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.0),
                            primaryColor.withValues(alpha: 0.4),
                            primaryColor,
                            primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Button Center Plate
              Container(
                width: widget.size - 10,
                height: widget.size - 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10131C),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: isConnected
                            ? 0.45
                            : isConnecting
                            ? 0.35
                            : 0.2,
                      ),
                      blurRadius: isConnected ? 28 : 18,
                      spreadRadius: isConnected ? 4 : 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDisconnecting)
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      else if (isConnecting)
                        Icon(Icons.radar_rounded, size: 38, color: primaryColor)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.15, 1.15),
                              duration: 800.ms,
                            )
                      else if (isConnected)
                        const Icon(
                          Icons.shield_rounded,
                          size: 42,
                          color: Color(0xFF00D4AA),
                        ).animate().scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        )
                      else
                        const Icon(
                          Icons.power_settings_new_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      const SizedBox(height: 8),
                      LocalizedText(
                        isDisconnecting
                            ? 'DISCONNECTING'
                            : isConnecting
                            ? 'CONNECTING'
                            : isConnected
                            ? 'CONNECTED'
                            : 'CONNECT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: isConnected
                              ? const Color(0xFF00D4AA)
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarWavePainter extends CustomPainter {
  const _RadarWavePainter({
    required this.progress,
    required this.color,
    required this.count,
  });

  final double progress;
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < count; i++) {
      final waveProgress = (progress + (i / count)) % 1.0;
      final radius = maxRadius * 0.45 + (maxRadius * 0.55 * waveProgress);
      final alpha = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.4;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarWavePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
