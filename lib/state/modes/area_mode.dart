import '../../measure/vec3.dart';
import '../../measure/geometry.dart';
import '../../measure/snap_engine.dart';

/// Area mode  Section 4.4 (P2 core: rectangle / polygon)
/// Rectangle (3 points + auto-complete), polygon (any N).
/// Live area, filled overlay. Subtract + estimator later in P5.
enum AreaShape { rectangle, polygon, irregular }

class AreaModeHandler {
  AreaShape shape = AreaShape.polygon;
  final List<Vec3> points = [];
  final List<Vec3> subtractPoints = []; // cut-outs (P5, stubbed)
  final SnapEngine snapEngine;

  AreaModeHandler({SnapEngine? snap}) : snapEngine = snap ?? SnapEngine();

  void addPoint(Vec3 p) {
    points.add(p);
    // Rectangle auto-complete after 3 points
    if (shape == AreaShape.rectangle && points.length == 3) {
      final a = points[0];
      final b = points[1];
      final c = points[2];
      // Fourth point: a + (c - b) vector reflection
      final d = a + (c - b);
      points.add(d);
    }
  }

  void removeLast() {
    if (points.isNotEmpty) points.removeLast();
  }

  double get area => Geometry.polygonArea(points);

  double get perimeter => Geometry.perimeter(points, closed: true);

  int get pointCount => points.length;

  /// Unit conversion table values (m2 base).
  Map<String, double> get conversionTable {
    final m2 = area;
    return {
      'm2': m2,
      'ft2': m2 * 10.7639,
      'yd2': m2 * 1.19599,
      'acres': m2 / 4046.86,
      'hectares': m2 / 10000,
    };
  }

  void reset() {
    points.clear();
    subtractPoints.clear();
  }
}
