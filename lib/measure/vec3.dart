import 'dart:math' as math;

/// Immutable 3D vector – all measurement math uses double precision.
class Vec3 {
  final double x, y, z;

  const Vec3(this.x, this.y, this.z);

  static const zero = Vec3(0, 0, 0);
  static const up = Vec3(0, 1, 0); // gravity opposite in AR world often -Y

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);
  Vec3 operator -() => Vec3(-x, -y, -z);

  double get length => math.sqrt(x * x + y * y + z * z);
  double get lengthSquared => x * x + y * y + z * z;

  Vec3 normalized() {
    final l = length;
    if (l < 1e-12) return Vec3.zero;
    return this * (1.0 / l);
  }

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) => Vec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double distanceTo(Vec3 o) => (this - o).length;

  @override
  String toString() => 'Vec3(${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)}, ${z.toStringAsFixed(4)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vec3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);
}
