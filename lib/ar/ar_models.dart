import '../measure/vec3.dart';

/// Immutable frame snapshot produced by the native AR bridge.
/// Measurement thread consumes these; UI never sees raw frames.
class ArFrameSnapshot {
  final Vec3 hitPoint;
  final double timestamp;
  final double trackingQuality; // 0–1
  final double depthQuality; // 1.0 hardware → 0.25 feature
  final double cameraSpeed; // m/s
  final double featureDensity; // 0–1
  final double lighting; // 0–1
  final bool hasPlane;
  final bool hasDepth;

  const ArFrameSnapshot({
    required this.hitPoint,
    required this.timestamp,
    required this.trackingQuality,
    required this.depthQuality,
    required this.cameraSpeed,
    required this.featureDensity,
    required this.lighting,
    this.hasPlane = false,
    this.hasDepth = false,
  });
}

enum ArTrackingState { notAvailable, limited, normal }

class ArSessionStatus {
  final ArTrackingState tracking;
  final bool depthSupported;
  final bool lidar;
  final String depthType; // hardware / estimated / none

  const ArSessionStatus({
    this.tracking = ArTrackingState.notAvailable,
    this.depthSupported = false,
    this.lidar = false,
    this.depthType = 'none',
  });
}
