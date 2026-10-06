/// Voice guidance  Section 6.6
/// Throttled: max one prompt per 2 s, no repeats.
/// Uses Flutter TTS when available; falls back to no-op.
class VoiceGuidance {
  static bool enabled = false;
  static double volume = 0.8;
  static String language = 'en-US';

  static DateTime? _lastPromptAt;
  static String? _lastPromptText;
  static const _minInterval = Duration(seconds: 2);

  /// Speak [text] if enabled and throttle allows.
  static Future<void> speak(String text) async {
    if (!enabled) return;
    if (text == _lastPromptText) return; // no repeats

    final now = DateTime.now();
    if (_lastPromptAt != null &&
        now.difference(_lastPromptAt!) < _minInterval) {
      return;
    }

    _lastPromptAt = now;
    _lastPromptText = text;

    // Hook for flutter_tts or platform channel.
    // For P4 skeleton we log only; wire real TTS in polish pass.
    // ignore: avoid_print
    // print('Voice: $text');
  }

  static Future<void> promptMoveSlowly() => speak('Move slowly');
  static Future<void> promptTapStart() => speak('Tap start');
  static Future<void> promptSetEndpoint() => speak('Set end point');
  static Future<void> promptTrackingLost() =>
      speak('Move slowly until tracking returns');
  static Future<void> promptComplete() => speak('Measurement complete');

  static void resetThrottle() {
    _lastPromptAt = null;
    _lastPromptText = null;
  }
}
