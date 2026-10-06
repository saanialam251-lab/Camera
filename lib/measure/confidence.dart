import 'dart:math' as math;

/// Confidence score 0–100 → High / Medium / Low + error range.
/// Weighted inputs exactly as Section 3.3.
class ConfidenceResult {
  final int score; // 0–100
  final ConfidenceLevel level;
  final double errorRangeMeters; // ± value
  final List<String> reasons;

  const ConfidenceResult({
    required this.score,
    required this.level,
    required this.errorRangeMeters,
    required this.reasons,
  });
}

enum ConfidenceLevel { high, medium, low }

class Confidence {
  Confidence._();

  /// All inputs normalized 0–1 except cameraSpeed (m/s) and variance (m²) and distance (m).
  static ConfidenceResult compute({
    required double trackingState, // 0–1
    required double depthSourceQuality, // 1.0 hardware → 0.25 feature
    required double cameraSpeed, // m/s
    required double featureDensity, // 0–1
    required double lightingQuality, // 0-1
    double blurScore = 1.0, // 1=sharp 0=blurry
    required double sampleVariance, // m²
    required double distanceToSurface, // m
  }) {
    final reasons = <String>[];

    // Tracking 30%
    final trackingScore = trackingState.clamp(0.0, 1.0) * 30;
    if (trackingState < 0.6) reasons.add('Tracking unstable');

    // Depth source 25%
    final depthScore = depthSourceQuality.clamp(0.0, 1.0) * 25;
    if (depthSourceQuality < 0.4) {
      reasons.add('No depth / feature only');
    } else if (depthSourceQuality < 0.7) {
      reasons.add('Plane estimate only');
    }

    // Camera speed 15% – penalize fast movement
    final speedPenalty = (cameraSpeed / 1.5).clamp(0.0, 1.0);
    final speedScore = (1.0 - speedPenalty) * 15;
    if (cameraSpeed > 0.8) reasons.add('Fast movement');

    // Feature + lighting 15%
    final envScore = ((featureDensity + lightingQuality) / 2 * (0.5 + 0.5 * blurScore.clamp(0.0, 1.0))).clamp(0.0, 1.0) * 15;
    if (lightingQuality < 0.4) reasons.add('Low light');
    if (blurScore < 0.45) reasons.add('Blurry image');
    // blur pulls env score down
    final blurFactor = blurScore.clamp(0.0, 1.0);
    if (featureDensity < 0.3) reasons.add('Low feature density / blank surface');

    // Sample variance 10%
    final varianceScore = (1.0 - (sampleVariance * 100).clamp(0.0, 1.0)) * 10;
    if (sampleVariance > 0.0025) reasons.add('High sample variance');

    // Distance 5%
    final distPenalty = (distanceToSurface / 8.0).clamp(0.0, 1.0);
    final distScore = (1.0 - distPenalty) * 5;
    if (distanceToSurface > 5.0) reasons.add('Long distance');

    final total = (trackingScore + depthScore + speedScore + envScore + varianceScore + distScore)
        .clamp(0.0, 100.0);
    final score = total.round();

    final level = score >= 80
        ? ConfidenceLevel.high
        : score >= 50
            ? ConfidenceLevel.medium
            : ConfidenceLevel.low;

    // Error range model
    final baseError = 0.01 + distanceToSurface * 0.008;
    final varianceError = math.sqrt(sampleVariance) * 2.0;
    final qualityFactor = 1.0 + (1.0 - total / 100.0) * 1.5;
    final errorRange = (baseError + varianceError) * qualityFactor;

    return ConfidenceResult(
      score: score,
      level: level,
      errorRangeMeters: errorRange,
      reasons: reasons.toSet().toList(),
    );
  }
}
