/// Camera / tracking quality gate for reliable marks.
/// Bad camera (blur, dark, fast motion) must not look like high precision.

enum CameraQualityLevel {
  good, // clear, usable for listing-grade marks
  fair, // usable with care; show tips
  poor, // blurry / dark — warn strongly; prefer loupe + hold still
  unusable, // tracking lost or image not viable
}

class CameraQualityReport {
  final CameraQualityLevel level;
  final String headline;
  final List<String> tips;
  final bool allowLock; // if false, disable START / SET END until improved
  final bool preferLoupe; // auto-suggest magnifier
  final bool preferPinch; // allow pinch fine-adjust before lock

  const CameraQualityReport({
    required this.level,
    required this.headline,
    this.tips = const [],
    this.allowLock = true,
    this.preferLoupe = false,
    this.preferPinch = false,
  });
}

class CameraQuality {
  CameraQuality._();

  /// Inputs are 0–1 except cameraSpeed (m/s).
  /// [blurScore] 1 = sharp, 0 = very blurry (from native focus/variance when available).
  static CameraQualityReport evaluate({
    required double trackingQuality,
    required double lighting,
    required double featureDensity,
    required double cameraSpeed,
    double blurScore = 1.0,
  }) {
    final tips = <String>[];
    var score = 0.0;
    score += trackingQuality.clamp(0.0, 1.0) * 0.30;
    score += lighting.clamp(0.0, 1.0) * 0.25;
    score += featureDensity.clamp(0.0, 1.0) * 0.20;
    score += blurScore.clamp(0.0, 1.0) * 0.20;
    final speedOk = (1.0 - (cameraSpeed / 1.2).clamp(0.0, 1.0));
    score += speedOk * 0.05;

    if (lighting < 0.35) {
      tips.add('Add light — dark rooms make marks unreliable');
    }
    if (blurScore < 0.45) {
      tips.add('Image is blurry — hold still, tap to focus, or move closer');
    }
    if (featureDensity < 0.3) {
      tips.add('Blank walls are hard to track — aim near texture, edges, or furniture');
    }
    if (cameraSpeed > 0.7) {
      tips.add('Move slower before locking a point');
    }
    if (trackingQuality < 0.5) {
      tips.add('Tracking weak — pan slowly across the floor/wall until it stabilizes');
    }

    if (trackingQuality < 0.25 || score < 0.28) {
      return CameraQualityReport(
        level: CameraQualityLevel.unusable,
        headline: 'Camera not viable — improve view before marking',
        tips: tips.isEmpty
            ? ['Move to better light', 'Hold phone steady', 'Point at a textured surface']
            : tips,
        allowLock: false,
        preferLoupe: true,
        preferPinch: true,
      );
    }
    if (blurScore < 0.5 || score < 0.45) {
      return CameraQualityReport(
        level: CameraQualityLevel.poor,
        headline: 'Blurry / weak camera — use loupe + pinch, then lock',
        tips: tips,
        allowLock: true,
        preferLoupe: true,
        preferPinch: true,
      );
    }
    if (score < 0.65) {
      return CameraQualityReport(
        level: CameraQualityLevel.fair,
        headline: 'Fair quality — hold still when you mark',
        tips: tips,
        allowLock: true,
        preferLoupe: blurScore < 0.7,
        preferPinch: true,
      );
    }
    return CameraQualityReport(
      level: CameraQualityLevel.good,
      headline: 'Camera good — mark start/end when ready',
      tips: const [],
      allowLock: true,
      preferLoupe: false,
      preferPinch: false,
    );
  }
}
