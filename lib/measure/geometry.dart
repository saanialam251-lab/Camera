import 'dart:math' as math;
import 'vec3.dart';

/// Pure geometry library – Section 3.4
/// All math in double. Convert to float only for rendering.
class Geometry {
  Geometry._();

  static double distance(Vec3 a, Vec3 b) => a.distanceTo(b);

  static Vec3 midpoint(Vec3 a, Vec3 b) => (a + b) * 0.5;

  static double pathLength(List<Vec3> points) {
    if (points.length < 2) return 0;
    var sum = 0.0;
    for (var i = 1; i < points.length; i++) {
      sum += points[i - 1].distanceTo(points[i]);
    }
    return sum;
  }

  /// Vertical component along gravity (ignore horizontal offset).
  static double height(Vec3 a, Vec3 b, {Vec3 gravity = const Vec3(0, -1, 0)}) {
    final g = gravity.normalized();
    return (b - a).dot(g).abs();
  }

  /// Polygon area using Newell's method (planar 3D polygons).
  static double polygonArea(List<Vec3> points) {
    if (points.length < 3) return 0;
    var nx = 0.0, ny = 0.0, nz = 0.0;
    for (var i = 0; i < points.length; i++) {
      final curr = points[i];
      final next = points[(i + 1) % points.length];
      nx += (curr.y - next.y) * (curr.z + next.z);
      ny += (curr.z - next.z) * (curr.x + next.x);
      nz += (curr.x - next.x) * (curr.y + next.y);
    }
    return 0.5 * math.sqrt(nx * nx + ny * ny + nz * nz);
  }

  /// Best-fit plane via simplified covariance (production: use SVD).
  /// Returns (centroid, normal).
  static (Vec3, Vec3) bestFitPlane(List<Vec3> points) {
    if (points.length < 3) return (Vec3.zero, Vec3.up);

    var cx = 0.0, cy = 0.0, cz = 0.0;
    for (final p in points) {
      cx += p.x;
      cy += p.y;
      cz += p.z;
    }
    final n = points.length.toDouble();
    final centroid = Vec3(cx / n, cy / n, cz / n);

    // Covariance
    var xx = 0.0, xy = 0.0, xz = 0.0, yy = 0.0, yz = 0.0, zz = 0.0;
    for (final p in points) {
      final d = p - centroid;
      xx += d.x * d.x;
      xy += d.x * d.y;
      xz += d.x * d.z;
      yy += d.y * d.y;
      yz += d.y * d.z;
      zz += d.z * d.z;
    }

    // Approximate normal from cofactors of covariance (smallest eigenvector)
    final nx = yy * zz - yz * yz;
    final ny = xz * yz - xy * zz;
    final nz = xy * yz - xz * yy;
    final normal = Vec3(nx, ny, nz).normalized();
    return (centroid, normal.length < 1e-9 ? Vec3.up : normal);
  }

  /// Angle at B in degrees (A-B-C).
  static double angleDegrees(Vec3 a, Vec3 b, Vec3 c) {
    final v1 = (a - b).normalized();
    final v2 = (c - b).normalized();
    final d = v1.dot(v2).clamp(-1.0, 1.0);
    return math.acos(d) * 180.0 / math.pi;
  }

  /// Signed angle when plane normal is known.
  static double signedAngleDegrees(Vec3 a, Vec3 b, Vec3 c, Vec3 normal) {
    final v1 = (a - b).normalized();
    final v2 = (c - b).normalized();
    final cross = v1.cross(v2);
    final angle = math.atan2(cross.dot(normal.normalized()), v1.dot(v2));
    return angle * 180.0 / math.pi;
  }

  static double perimeter(List<Vec3> points, {bool closed = true}) {
    var p = pathLength(points);
    if (closed && points.length >= 2) {
      p += points.last.distanceTo(points.first);
    }
    return p;
  }

  static Vec3 centroid(List<Vec3> points) {
    if (points.isEmpty) return Vec3.zero;
    var sx = 0.0, sy = 0.0, sz = 0.0;
    for (final p in points) {
      sx += p.x;
      sy += p.y;
      sz += p.z;
    }
    final n = points.length.toDouble();
    return Vec3(sx / n, sy / n, sz / n);
  }

  static double prismVolume(double baseArea, double height) => baseArea * height;
}
