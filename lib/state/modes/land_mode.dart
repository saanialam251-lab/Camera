import '../../measure/vec3.dart';
import '../../measure/geometry.dart';
import '../../measure/plane_fit.dart';

/// Land / plot measuring – outdoor parcels, fields, landmarks.
/// Not room-only: large outdoor loops with high-precision defaults.
/// Workflow: hand-mark boundary vertices (or path along fence), close loop → area + perimeter.
class LandModeHandler {
  final List<Vec3> vertices = [];
  bool closed = false;
  bool highPrecision = true; // more samples, stricter confidence for land

  void addVertex(Vec3 p) {
    if (closed) return;
    vertices.add(p);
  }

  void undo() {
    if (vertices.isEmpty) return;
    if (closed) {
      closed = false;
      return;
    }
    vertices.removeLast();
  }

  void closeLoop() {
    if (vertices.length >= 3) closed = true;
  }

  double get perimeter {
    if (vertices.length < 2) return 0;
    var sum = 0.0;
    for (var i = 0; i < vertices.length; i++) {
      final j = closed
          ? (i + 1) % vertices.length
          : (i + 1 < vertices.length ? i + 1 : -1);
      if (j < 0) break;
      sum += Geometry.distance(vertices[i], vertices[j]);
    }
    return sum;
  }

  double get area {
    if (vertices.length < 3) return 0;
    // Project to best-fit horizontal plane (land is mostly XZ)
    final pts = vertices;
    final plane = PlaneFit.fit(pts);
    // Shoelace on XZ
    var a = 0.0;
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      a += pts[i].x * pts[j].z - pts[j].x * pts[i].z;
    }
    final planar = a.abs() / 2.0;
    // If plane fit is good, prefer polygon area on plane
    if (plane.planarityScore > 0.85) {
      return Geometry.polygonArea(pts);
    }
    return planar;
  }

  /// Area in acres (1 acre = 4046.8564224 m²)
  double get areaAcres => area / 4046.8564224;

  /// Area in hectares
  double get areaHectares => area / 10000.0;

  String get instruction {
    if (vertices.isEmpty) {
      return 'Land: aim at first boundary mark, then START';
    }
    if (!closed) {
      return 'Add boundary points along the plot (corners or fence). Close when done.';
    }
    return 'Plot closed — review perimeter and area';
  }

  void reset() {
    vertices.clear();
    closed = false;
  }
}
