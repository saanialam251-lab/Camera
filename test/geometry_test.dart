import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/vec3.dart';
import 'package:measure_reality/measure/geometry.dart';

void main() {
  group('Geometry', () {
    test('distance of 3-4-5 triangle', () {
      const a = Vec3(0, 0, 0);
      const b = Vec3(3, 0, 0);
      const c = Vec3(0, 4, 0);
      expect(Geometry.distance(a, b), closeTo(3.0, 1e-9));
      expect(Geometry.distance(a, c), closeTo(4.0, 1e-9));
      expect(Geometry.distance(b, c), closeTo(5.0, 1e-9));
    });

    test('unit square area (Newell)', () {
      final points = [
        const Vec3(0, 0, 0),
        const Vec3(1, 0, 0),
        const Vec3(1, 1, 0),
        const Vec3(0, 1, 0),
      ];
      expect(Geometry.polygonArea(points), closeTo(1.0, 1e-9));
    });

    test('height ignores horizontal offset', () {
      const a = Vec3(1, 0, 2);
      const b = Vec3(4, 5, 2);
      expect(Geometry.height(a, b), closeTo(5.0, 1e-9));
    });

    test('degenerate single point', () {
      const a = Vec3(1, 2, 3);
      expect(Geometry.distance(a, a), closeTo(0.0, 1e-12));
    });

    test('path length', () {
      final pts = [
        const Vec3(0, 0, 0),
        const Vec3(1, 0, 0),
        const Vec3(1, 1, 0),
      ];
      expect(Geometry.pathLength(pts), closeTo(2.0, 1e-9));
    });
  });
}
