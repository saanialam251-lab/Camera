import 'package:flutter/services.dart';

/// Sound feedback  P4
/// Uses system click for now; replace with asset players when sounds/ is filled.
class SoundFeedback {
  static bool enabled = true;

  static Future<void> click() async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> pointPlaced() async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> complete() async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> error() async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }
}
