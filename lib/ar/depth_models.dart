import '../measure/vec3.dart';

/// Depth data models  P3
/// Hardware depth > depth model > plane > feature points.
enum DepthSource {
  hardware, // ToF / LiDAR
  depthModel, // ML depth estimate
  plane,
  featurePoint,
  estimated, // instant placement fallback
  none,
}

extension DepthSourceQuality on DepthSource {
  /// 01 quality weight for confidence scoring.
  double get quality {
    switch (this) {
      case DepthSource.hardware:
        return 1.0;
      case DepthSource.depthModel:
        return 0.75;
      case DepthSource.plane:
        return 0.50;
      case DepthSource.featurePoint:
        return 0.30;
      case DepthSource.estimated:
        return 0.15;
      case DepthSource.none:
        return 0.0;
    }
  }

  String get label {
    switch (this) {
      case DepthSource.hardware:
        return 'Depth';
      case DepthSource.depthModel:
        return 'Depth AI';
      case DepthSource.plane:
        return 'Plane';
      case DepthSource.featurePoint:
        return 'Feature';
      case DepthSource.estimated:
        return 'Estimate';
      case DepthSource.none:
        return 'None';
    }
  }
}

/// Single depth sample from native DepthProcessor.
class DepthSample {
  final double u; // normalized screen X 01
  final double v; // normalized screen Y 01
  final double depthMeters;
  final DepthSource source;
  final double confidence; // 01 native confidence if available

  const DepthSample({
    required this.u,
    required this.v,
    required this.depthMeters,
    required this.source,
    this.confidence = 1.0,
  });
}

/// Depth frame at reduced rate (1530 Hz while render stays 60 Hz).
class DepthFrame {
  final double timestamp;
  final int width;
  final int height;
  final List<DepthSample> samples; // sparse or full
  final DepthSource primarySource;

  const DepthFrame({
    required this.timestamp,
    required this.width,
    required this.height,
    required this.samples,
    required this.primarySource,
  });
}

/// Hit-test result with depth source priority.
class DepthHit {
  final Vec3 worldPoint;
  final DepthSource source;
  final double confidence;
  final double distanceFromCamera;

  const DepthHit({
    required this.worldPoint,
    required this.source,
    required this.confidence,
    required this.distanceFromCamera,
  });
}

/// Priority picker: depth > plane > feature > estimated.
class DepthHitPicker {
  static DepthHit? pick(List<DepthHit> candidates) {
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final q = b.source.quality.compareTo(a.source.quality);
      if (q != 0) return q;
      return b.confidence.compareTo(a.confidence);
    });
    return candidates.first;
  }
}
