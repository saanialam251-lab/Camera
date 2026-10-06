import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/vec3.dart';
import 'package:measure_reality/measure/snap_engine.dart';

void main() {
  group('SnapEngine', () {
    late SnapEngine engine;

    setUp(() {
      engine = SnapEngine(strength: SnapStrength.medium, enabled: true);
    });

    test('no snap when far from candidates', () {
      final result = engine.evaluate(
        rawHit: const Vec3(1, 0, 0),
        corners: [const Vec3(0, 0, 0)],
      );
      expect(result.didSnap, isFalse);
      expect(result.type, SnapType.none);
    });

    test('snaps to corner within radius', () {
      final corner = const Vec3(0, 0, 0);
      final result = engine.evaluate(
        rawHit: const Vec3(0.02, 0.01, 0),
        corners: [corner],
      );
      expect(result.didSnap, isTrue);
      expect(result.type, SnapType.corner);
      expect(result.snapped, corner);
      expect(result.pullFrom, isNotNull);
    });

    test('prefers corner over edge', () {
      final corner = const Vec3(0, 0, 0);
      final result = engine.evaluate(
        rawHit: const Vec3(0.01, 0, 0),
        corners: [corner],
        edges: [(const Vec3(-1, 0, 0), const Vec3(1, 0, 0))],
      );
      expect(result.type, SnapType.corner);
    });

    test('edge projection', () {
      final result = engine.evaluate(
        rawHit: const Vec3(0.5, 0.02, 0),
        edges: [(const Vec3(0, 0, 0), const Vec3(1, 0, 0))],
      );
      expect(result.didSnap, isTrue);
      expect(result.type, SnapType.edge);
      expect(result.snapped.y, closeTo(0, 1e-9));
      expect(result.snapped.x, closeTo(0.5, 1e-6));
    });

    test('undo last snap', () {
      final corner = const Vec3(0, 0, 0);
      final raw = const Vec3(0.02, 0, 0);
      engine.evaluate(rawHit: raw, corners: [corner]);
      final restored = engine.undoLastSnap();
      expect(restored, raw);
    });

    test('disabled engine returns none', () {
      engine.enabled = false;
      final result = engine.evaluate(
        rawHit: const Vec3(0.01, 0, 0),
        corners: [const Vec3(0, 0, 0)],
      );
      expect(result.didSnap, isFalse);
    });
  });
}
