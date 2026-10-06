import 'package:flutter/services.dart';

/// Haptics feedback  Section 6 / Settings Feedback
/// Off / Light / Normal
enum HapticStrength { off, light, normal }

class Haptics {
  static HapticStrength strength = HapticStrength.normal;

  static Future<void> light() async {
    if (strength == HapticStrength.off) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (strength == HapticStrength.off) return;
    if (strength == HapticStrength.light) {
      await HapticFeedback.lightImpact();
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (strength == HapticStrength.off) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    if (strength == HapticStrength.off) return;
    await HapticFeedback.selectionClick();
  }

  /// Tick when level is within +/-0.5 deg
  static Future<void> levelTick() async {
    if (strength == HapticStrength.off) return;
    await HapticFeedback.lightImpact();
  }

  /// Confirm point placement
  static Future<void> pointPlaced() async {
    await medium();
  }

  /// Measurement complete
  static Future<void> complete() async {
    await heavy();
  }
}
