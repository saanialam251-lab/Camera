import 'dart:math' as math;
import '../../measure/vec3.dart';
import '../../measure/geometry.dart';

/// Angle mode  Section 4.7
/// Three-point angle + Surface angle + Slope/pitch.
enum AngleUnit { degrees, radians, gradians }

class AngleModeHandler {
  Vec3? a, b, c; // angle at B
  Vec3? planeNormal; // for signed / surface angle
  AngleUnit unit = AngleUnit.degrees;
  bool surfaceMode = false;
  bool slopeMode = false;

  void setA(Vec3 p) => a = p;
  void setB(Vec3 p) => b = p;
  void setC(Vec3 p) => c = p;

  double get angleDegrees {
    if (a == null || b == null || c == null) return 0;
    if (planeNormal != null) {
      return Geometry.signedAngleDegrees(a!, b!, c!, planeNormal!);
    }
    return Geometry.angleDegrees(a!, b!, c!);
  }

  double get displayValue {
    final deg = angleDegrees;
    switch (unit) {
      case AngleUnit.degrees:
        return deg;
      case AngleUnit.radians:
        return deg * math.pi / 180.0;
      case AngleUnit.gradians:
        return deg * 10 / 9;
    }
  }

  double get supplementary => 180.0 - angleDegrees;
  double get complementary => 90.0 - angleDegrees;

  /// Slope: degrees, percent grade, rise:run
  ({double degrees, double percent, String riseRun}) get slope {
    final deg = angleDegrees.abs();
    final rad = deg * math.pi / 180.0;
    final percent = math.tan(rad) * 100;
    const run = 12.0;
    final rise = run * math.tan(rad);
    return (
      degrees: deg,
      percent: percent,
      riseRun: '${rise.toStringAsFixed(1)}:$run',
    );
  }

  void reset() {
    a = b = c = null;
    planeNormal = null;
    surfaceMode = false;
    slopeMode = false;
  }
}
