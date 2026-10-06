import 'dart:io';
import '../ar/ar_models.dart';

/// Device Analysis – Section 7 + 13
/// Live checks: AR support, depth type, IMU, camera quality, expected accuracy.
class DeviceReport {
  final bool arSupported;
  final String depthType; // hardware / estimated / none
  final bool hasAccel;
  final bool hasGyro;
  final String platform;
  final String expectedAccuracy;
  final List<String> warnings;

  const DeviceReport({
    required this.arSupported,
    required this.depthType,
    required this.hasAccel,
    required this.hasGyro,
    required this.platform,
    required this.expectedAccuracy,
    this.warnings = const [],
  });
}

class DeviceChecks {
  DeviceChecks._();

  /// Build a report from AR session status + sensor availability.
  static DeviceReport analyze({
    required ArSessionStatus arStatus,
    bool hasAccel = true,
    bool hasGyro = true,
  }) {
    final warnings = <String>[];
    final platform = Platform.isIOS
        ? 'iOS'
        : Platform.isAndroid
            ? 'Android'
            : 'unknown';

    if (!arStatus.depthSupported && arStatus.depthType == 'none') {
      warnings.add('No depth sensor – accuracy drops at long range');
    }
    if (!hasAccel || !hasGyro) {
      warnings.add('Incomplete IMU – Level mode limited');
    }

    String accuracy;
    switch (arStatus.depthType) {
      case 'hardware':
        accuracy = 'Typical +/-0.5-1.5% at 1-3 m (LiDAR/ToF)';
        break;
      case 'estimated':
      case 'simulated':
        accuracy = 'Typical +/-1-3% at 1-3 m';
        break;
      default:
        accuracy = 'Typical +/-2-5% at 1-3 m (no depth)';
        warnings.add('Depth-less device – prefer short range measurements');
    }

    return DeviceReport(
      arSupported: arStatus.tracking != ArTrackingState.notAvailable,
      depthType: arStatus.depthType,
      hasAccel: hasAccel,
      hasGyro: hasGyro,
      platform: platform,
      expectedAccuracy: accuracy,
      warnings: warnings,
    );
  }
}

/// Release gates – Section 13
class ReleaseGates {
  static const maxCrashRate = 0.0; // 0 crashes in 1000 sessions
  static const maxP95FrameMs = 16.6;
  static const maxMedianErrorPercent = 2.0; // at 1-3 m with good tracking

  static bool checkFrameTime(double p95Ms) => p95Ms < maxP95FrameMs;

  static bool checkAccuracy(double medianErrorPercent) =>
      medianErrorPercent <= maxMedianErrorPercent;

  static bool checkCrashes(int crashes, int sessions) {
    if (sessions <= 0) return false;
    return crashes == 0;
  }

  static Map<String, bool> evaluate({
    required double p95FrameMs,
    required double medianErrorPercent,
    required int crashes,
    required int sessions,
  }) {
    return {
      'frameTime': checkFrameTime(p95FrameMs),
      'accuracy': checkAccuracy(medianErrorPercent),
      'crashes': checkCrashes(crashes, sessions),
    };
  }

  static bool allPassed(Map<String, bool> results) =>
      results.values.every((v) => v);
}
