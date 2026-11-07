import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  HapticService._();

  static bool _hasCheckedSupport = false;
  static bool _hasVibrator = false;
  static bool _hasCustomSupport = false;

  static Future<void> _checkSupport() async {
    if (_hasCheckedSupport) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _hasVibrator = await Vibration.hasVibrator();
        _hasCustomSupport = await Vibration.hasCustomVibrationsSupport();
      }
    } catch (_) {
      _hasVibrator = false;
      _hasCustomSupport = false;
    } finally {
      _hasCheckedSupport = true;
    }
  }

  /// Light feedback (Click) when pressing connect button or touching switches
  static Future<void> lightClick() async {
    try {
      await HapticFeedback.lightImpact();
      await _checkSupport();
      if (_hasVibrator) {
        if (_hasCustomSupport) {
          await Vibration.vibrate(duration: 35, amplitude: 120);
        } else {
          await Vibration.vibrate(duration: 35);
        }
      }
    } catch (_) {}
  }

  /// Success vibration pulse when connection is successfully established
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await _checkSupport();
      if (_hasVibrator) {
        if (_hasCustomSupport) {
          // Double pulse: wait 0, buzz 60, pause 70, buzz 120
          await Vibration.vibrate(
            pattern: [0, 60, 70, 120],
            intensities: [0, 180, 0, 255],
          );
        } else {
          await Vibration.vibrate(pattern: [0, 60, 70, 120]);
        }
      }
    } catch (_) {}
  }

  /// Warning / Error double pulse when connection drops or fails
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await _checkSupport();
      if (_hasVibrator) {
        if (_hasCustomSupport) {
          await Vibration.vibrate(
            pattern: [0, 140, 90, 180],
            intensities: [0, 255, 0, 255],
          );
        } else {
          await Vibration.vibrate(pattern: [0, 140, 90, 180]);
        }
      }
    } catch (_) {}
  }

  /// Subtle touch switch feedback
  static Future<void> switchToggle() async {
    try {
      await HapticFeedback.selectionClick();
      await _checkSupport();
      if (_hasVibrator) {
        if (_hasCustomSupport) {
          await Vibration.vibrate(duration: 25, amplitude: 90);
        } else {
          await Vibration.vibrate(duration: 25);
        }
      }
    } catch (_) {}
  }

  /// Selection click feedback for selecting items, chips or servers
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
      await _checkSupport();
      if (_hasVibrator) {
        if (_hasCustomSupport) {
          await Vibration.vibrate(duration: 20, amplitude: 80);
        } else {
          await Vibration.vibrate(duration: 20);
        }
      }
    } catch (_) {}
  }
}
