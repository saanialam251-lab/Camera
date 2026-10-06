import 'dart:math' as math;
import 'vec3.dart';

/// One-Euro Filter – low jitter when still, low lag when moving fast.
/// Casiez et al. – used for 3D position smoothing (Measurement thread).
class OneEuroFilter {
  double minCutoff;
  double beta;
  double dCutoff;

  double? _xPrev;
  double _dxPrev = 0;
  double? _tPrev;

  OneEuroFilter({
    this.minCutoff = 1.0,
    this.beta = 0.007,
    this.dCutoff = 1.0,
  });

  double filter(double x, double t) {
    if (_tPrev == null) {
      _tPrev = t;
      _xPrev = x;
      return x;
    }

    final dt = math.max(t - _tPrev!, 1e-6);
    final dx = (x - _xPrev!) / dt;

    // Filtered derivative
    final edx = _lowPass(dx, _dxPrev, _alpha(dt, dCutoff));
    _dxPrev = edx;

    // Dynamic cutoff
    final cutoff = minCutoff + beta * edx.abs();
    final filtered = _lowPass(x, _xPrev!, _alpha(dt, cutoff));

    _xPrev = filtered;
    _tPrev = t;
    return filtered;
  }

  void reset() {
    _xPrev = null;
    _dxPrev = 0;
    _tPrev = null;
  }

  double _alpha(double dt, double cutoff) {
    final tau = 1.0 / (2 * math.pi * cutoff);
    return 1.0 / (1.0 + tau / dt);
  }

  double _lowPass(double x, double prev, double a) => a * x + (1 - a) * prev;
}

/// 3D One-Euro (independent axes).
class OneEuroFilter3D {
  final OneEuroFilter _fx;
  final OneEuroFilter _fy;
  final OneEuroFilter _fz;

  OneEuroFilter3D({
    double minCutoff = 1.0,
    double beta = 0.007,
    double dCutoff = 1.0,
  })  : _fx = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff),
        _fy = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff),
        _fz = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff);

  Vec3 filter(Vec3 p, double t) => Vec3(
        _fx.filter(p.x, t),
        _fy.filter(p.y, t),
        _fz.filter(p.z, t),
      );

  void reset() {
    _fx.reset();
    _fy.reset();
    _fz.reset();
  }
}

/// Median-of-N with trimmed mean (drop top/bottom 10%).
/// Used on SET END POINT (Section 3.1 step 5).
class TrimmedMean {
  /// [precisionMode] → 30–60 samples, else 10–30.
  static Vec3 compute(List<Vec3> samples, {bool precisionMode = false}) {
    if (samples.isEmpty) return Vec3.zero;
    final n = precisionMode ? 40 : 20;
    final window = samples.length > n ? samples.sublist(samples.length - n) : List<Vec3>.from(samples);

    final drop = (window.length * 0.1).floor().clamp(0, window.length ~/ 4);

    final xs = window.map((v) => v.x).toList()..sort();
    final ys = window.map((v) => v.y).toList()..sort();
    final zs = window.map((v) => v.z).toList()..sort();

    double med(List<double> sorted) {
      final trimmed = sorted.length > 2 * drop
          ? sorted.sublist(drop, sorted.length - drop)
          : sorted;
      return trimmed[trimmed.length ~/ 2];
    }

    return Vec3(med(xs), med(ys), med(zs));
  }
}
