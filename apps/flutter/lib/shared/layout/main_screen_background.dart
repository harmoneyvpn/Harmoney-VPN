import 'package:flutter/material.dart';
import '../../core/vpn_core.dart';

/// Authentic Apple Liquid Glass Canvas Background
/// Renders a deep atmospheric obsidian/midnight foundation with layered,
/// diffused luminous ambient glowing orbs (Apple mesh gradient) that react
/// to the VPN connection state and create breathtaking optical refraction
/// beneath frosted glass panels throughout the entire application.
class MainScreenBackground extends StatelessWidget {
  final Widget child;
  final VpnConnectionStatus status;

  const MainScreenBackground({
    super.key,
    required this.child,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final primaryAccent = _getPrimaryAccent(status);
    final secondaryAccent = _getSecondaryAccent(status);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF040C16),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Deep Atmospheric Gradient Canvas
          AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: _getBaseCanvasGradient(status),
            ),
          ),

          // 2. Luminous Ambient Mesh Orb - Top End
          PositionedDirectional(
            top: -60,
            end: -40,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryAccent.withValues(alpha: 0.35),
                      primaryAccent.withValues(alpha: 0.12),
                      primaryAccent.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Luminous Ambient Mesh Orb - Bottom Start
          PositionedDirectional(
            bottom: 60,
            start: -70,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeInOutCubic,
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      secondaryAccent.withValues(alpha: 0.28),
                      secondaryAccent.withValues(alpha: 0.08),
                      secondaryAccent.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Center Reactive Aurora Glow (Connecting / Connected pulse)
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeInOutCubic,
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryAccent.withValues(
                          alpha: status == VpnConnectionStatus.connected
                              ? 0.30
                              : (status == VpnConnectionStatus.connecting
                                  ? 0.24
                                  : 0.10),
                        ),
                        primaryAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Forefront Page Content (Frosted glass blurs the orbs below)
          child,
        ],
      ),
    );
  }

  LinearGradient _getBaseCanvasGradient(VpnConnectionStatus status) {
    switch (status) {
      case VpnConnectionStatus.connected:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF04111E),
            Color(0xFF07212E),
            Color(0xFF0A2B33),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.authenticating:
      case VpnConnectionStatus.preparing:
      case VpnConnectionStatus.verifying:
      case VpnConnectionStatus.reconnecting:
      case VpnConnectionStatus.discovering:
      case VpnConnectionStatus.recovering:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07121F),
            Color(0xFF132B3A),
            Color(0xFF1A3845),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case VpnConnectionStatus.error:
      case VpnConnectionStatus.failed:
      case VpnConnectionStatus.authRequired:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF11070A),
            Color(0xFF241016),
            Color(0xFF1F121C),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case VpnConnectionStatus.idle:
      case VpnConnectionStatus.disconnected:
      case VpnConnectionStatus.disconnecting:
      case VpnConnectionStatus.cancelling:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF05111B),
            Color(0xFF091C28),
            Color(0xFF0D2533),
          ],
          stops: [0.0, 0.5, 1.0],
        );
    }
  }

  Color _getPrimaryAccent(VpnConnectionStatus status) {
    switch (status) {
      case VpnConnectionStatus.connected:
        return const Color(0xFF00F5B8); // Apple vibrant emerald
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.authenticating:
      case VpnConnectionStatus.preparing:
      case VpnConnectionStatus.verifying:
      case VpnConnectionStatus.reconnecting:
      case VpnConnectionStatus.discovering:
      case VpnConnectionStatus.recovering:
        return const Color(0xFFFFC46B); // Amber glow
      case VpnConnectionStatus.error:
      case VpnConnectionStatus.failed:
      case VpnConnectionStatus.authRequired:
        return const Color(0xFFFF5252); // Red alert
      case VpnConnectionStatus.idle:
      case VpnConnectionStatus.disconnected:
      case VpnConnectionStatus.disconnecting:
      case VpnConnectionStatus.cancelling:
        return const Color(0xFF00E5FF); // Electric cyan
    }
  }

  Color _getSecondaryAccent(VpnConnectionStatus status) {
    switch (status) {
      case VpnConnectionStatus.connected:
        return const Color(0xFF00D4AA);
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.authenticating:
      case VpnConnectionStatus.preparing:
      case VpnConnectionStatus.verifying:
      case VpnConnectionStatus.reconnecting:
      case VpnConnectionStatus.discovering:
      case VpnConnectionStatus.recovering:
        return const Color(0xFF29B6F6);
      case VpnConnectionStatus.error:
      case VpnConnectionStatus.failed:
      case VpnConnectionStatus.authRequired:
        return const Color(0xFFE040FB);
      case VpnConnectionStatus.idle:
      case VpnConnectionStatus.disconnected:
      case VpnConnectionStatus.disconnecting:
      case VpnConnectionStatus.cancelling:
        return const Color(0xFF2575FC); // Sapphire blue
    }
  }
}
