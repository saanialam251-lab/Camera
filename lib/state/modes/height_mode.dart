import 'dart:math' as math;
import '../../measure/vec3.dart';
import '../../measure/geometry.dart';

/// Height mode  Section 4.3
/// Ground-to-point (auto floor) + Two-point vertical.
/// Person Height preset, Tilt compensation, Tree/pole Estimate.
enum HeightMethod { groundToPoint, twoPointVertical, treePoleEstimate }

class HeightModeHandler {
  HeightMethod method = HeightMethod.groundToPoint;
  Vec3? base;
  Vec3? top;
  double? baseDistance; // for tree/pole trig
  double? elevationAngleDeg; // for tree/pole
  bool personPreset = false;
  double phonePitchDeg = 0; // for tilt warning

  void setBase(Vec3 p) => base = p;
  void setTop(Vec3 p) => top = p;

  double get height {
    if (method == HeightMethod.treePoleEstimate &&
        baseDistance != null &&
        elevationAngleDeg != null) {
      final rad = elevationAngleDeg! * math.pi / 180.0;
      return baseDistance! * math.tan(rad).abs();
    }
    if (base == null || top == null) return 0;
    return Geometry.height(base!, top!);
  }

  bool get isEstimate => method == HeightMethod.treePoleEstimate;

  bool get tiltWarning => phonePitchDeg.abs() > 45;

  /// Feet + inches + cm for person preset.
  String personDisplay(double meters) {
    final cm = meters * 100;
    final totalInches = meters / 0.0254;
    final feet = totalInches ~/ 12;
    final inches = totalInches - feet * 12;
    return '${feet}\' ${inches.toStringAsFixed(1)}"  (${cm.toStringAsFixed(1)} cm)';
  }

  void reset() {
    base = null;
    top = null;
    baseDistance = null;
    elevationAngleDeg = null;
    personPreset = false;
    phonePitchDeg = 0;
  }
}
