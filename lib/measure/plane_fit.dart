import 'dart:math' as math;
import 'vec3.dart';

/// Best-fit plane via SVD-style covariance + planarity check.
/// Section 3.4  warn when points are non-planar beyond tolerance.
class PlaneFitResult {
  final Vec3 centroid;
  final Vec3 normal;
  final double residualRms; // meters  RMS distance of points to plane
  final bool isPlanar;
  final double planarityScore; // 01 (1 = perfectly planar)

  const PlaneFitResult({
    required this.centroid,
    required this.normal,
    required this.residualRms,
    required this.isPlanar,
    required this.planarityScore,
  });
}

class PlaneFit {
  PlaneFit._();

  /// Default planarity tolerance: 2 cm RMS.
  static const defaultTolerance = 0.02;

  static PlaneFitResult fit(
    List<Vec3> points, {
    double tolerance = defaultTolerance,
  }) {
    if (points.length < 3) {
      return const PlaneFitResult(
        centroid: Vec3.zero,
        normal: Vec3.up,
        residualRms: 0,
        isPlanar: false,
        planarityScore: 0,
      );
    }

    // Centroid
    var cx = 0.0, cy = 0.0, cz = 0.0;
    for (final p in points) {
      cx += p.x;
      cy += p.y;
      cz += p.z;
    }
    final n = points.length.toDouble();
    final centroid = Vec3(cx / n, cy / n, cz / n);

    // Covariance matrix (3x3 symmetric)
    var xx = 0.0, xy = 0.0, xz = 0.0;
    var yy = 0.0, yz = 0.0, zz = 0.0;
    for (final p in points) {
      final d = p - centroid;
      xx += d.x * d.x;
      xy += d.x * d.y;
      xz += d.x * d.z;
      yy += d.y * d.y;
      yz += d.y * d.z;
      zz += d.z * d.z;
    }

    // Normal H eigenvector of smallest eigenvalue (cofactor method)
    // det(C - »I) H 0; for smallest » use adjugate row
    final nx = yy * zz - yz * yz;
    final ny = xz * yz - xy * zz;
    final nz = xy * yz - xz * yy;
    var normal = Vec3(nx, ny, nz);
    if (normal.length < 1e-12) {
      // Degenerate  try alternate cofactors
      normal = Vec3(xy * yz - xz * yy, xx * yz - xz * xy, xx * yy - xy * xy);
    }
    normal = normal.normalized();
    if (normal.length < 1e-9) normal = Vec3.up;

    // Ensure normal points somewhat upward (consistent orientation)
    if (normal.y < 0) normal = -normal;

    // RMS residual
    var sumSq = 0.0;
    for (final p in points) {
      final dist = (p - centroid).dot(normal);
      sumSq += dist * dist;
    }
    final residualRms = math.sqrt(sumSq / n);

    final isPlanar = residualRms <= tolerance;
    // Score: 1 at 0 residual, 0 at 3x tolerance
    final planarityScore =
        (1.0 - (residualRms / (tolerance * 3)).clamp(0.0, 1.0));

    return PlaneFitResult(
      centroid: centroid,
      normal: normal,
      residualRms: residualRms,
      isPlanar: isPlanar,
      planarityScore: planarityScore,
    );
  }

  /// Project a point onto the fitted plane.
  static Vec3 project(Vec3 point, PlaneFitResult plane) {
    final d = (point - plane.centroid).dot(plane.normal);
    return point - plane.normal * d;
  }

  /// Signed distance from point to plane.
  static double signedDistance(Vec3 point, PlaneFitResult plane) {
    return (point - plane.centroid).dot(plane.normal);
  }
}
