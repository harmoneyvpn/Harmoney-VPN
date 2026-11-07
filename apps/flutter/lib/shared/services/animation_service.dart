import 'package:flutter/material.dart';

class AnimationService {
  AnimationService._internal();
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;

  int _batteryLevel = 100;
  static const int _lowBatteryThreshold = 10;

  Future<void> init() async {
    // Battery check can be optionally wired to platform sensors
    _batteryLevel = 100;
  }

  bool shouldAnimate() {
    return _batteryLevel > _lowBatteryThreshold;
  }

  Duration adjustDuration(Duration originalDuration) {
    return shouldAnimate() ? originalDuration : Duration.zero;
  }

  void conditionalRepeat(
    AnimationController controller, {
    bool reverse = false,
  }) {
    if (shouldAnimate()) {
      controller.repeat(reverse: reverse);
    } else {
      controller.stop();
    }
  }

  void conditionalForward(AnimationController controller, {double? from}) {
    if (shouldAnimate()) {
      controller.forward(from: from);
    } else {
      controller.stop();
    }
  }
}
