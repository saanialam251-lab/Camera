import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/vec3.dart';
import 'package:measure_reality/measure/room_builder.dart';
import 'package:measure_reality/measure/plane_fit.dart';

void main() {
  group('PlaneFit', () {
    test('fits a horizontal plane', () {
      final pts = [
        const Vec3(0, 0, 0),
        const Vec3(1, 0, 0),
        const Vec3(1, 0, 1),
        const Vec3(0, 0, 1),
      ];
      final fit = PlaneFit.fit(pts);
      expect(fit.isPlanar, isTrue);
      expect(fit.normal.y.abs(), closeTo(1.0, 0.1));
      expect(fit.residualRms, lessThan(0.01));
    });

    test('detects non-planar points', () {
      final pts = [
        const Vec3(0, 0, 0),
        const Vec3(1, 0, 0),
        const Vec3(1, 0, 1),
        const Vec3(0, 0.5, 1), // raised corner
      ];
      final fit = PlaneFit.fit(pts, tolerance: 0.05);
      // residual should be noticeable
      expect(fit.residualRms, greaterThan(0.01));
    });
  });

  group('RoomBuilder', () {
    late RoomBuilder builder;

    setUp(() {
      builder = RoomBuilder();
    });

    test('starts on floor stage', () {
      expect(builder.stage, RoomScanStage.floor);
      expect(builder.stageInstruction, contains('floor'));
    });

    test('advances stages', () {
      builder.advanceStage();
      expect(builder.stage, RoomScanStage.walls);
      builder.advanceStage();
      expect(builder.stage, RoomScanStage.ceiling);
      builder.advanceStage();
      expect(builder.stage, RoomScanStage.complete);
    });

    test('builds room from rectangular floor', () {
      // 4x3 m rectangle on XZ plane
      builder.addFloorPoint(const Vec3(0, 0, 0));
      builder.addFloorPoint(const Vec3(4, 0, 0));
      builder.addFloorPoint(const Vec3(4, 0, 3));
      builder.addFloorPoint(const Vec3(0, 0, 3));
      builder.advanceStage(); // walls
      // Add wall height points
      builder.addWallPoint(const Vec3(0, 2.5, 0));
      builder.addWallPoint(const Vec3(4, 2.5, 0));
      builder.advanceStage(); // ceiling
      builder.addCeilingPoint(const Vec3(2, 2.5, 1.5));
      builder.advanceStage(); // complete

      final room = builder.build();
      expect(room.floorArea, closeTo(12.0, 0.5));
      expect(room.height, greaterThan(1.0));
      expect(room.floorPlan.corners.length, greaterThanOrEqualTo(3));
      expect(room.coveragePercent, greaterThan(0));
    });

    test('coverage increases with points', () {
      final before = builder.coveragePercent;
      builder.addFloorPoint(const Vec3(0, 0, 0));
      builder.addFloorPoint(const Vec3(1, 0, 0));
      expect(builder.coveragePercent, greaterThan(before));
    });
  });
}
