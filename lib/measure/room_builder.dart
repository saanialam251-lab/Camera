import 'dart:math' as math;
import 'vec3.dart';
import 'geometry.dart';
import 'plane_fit.dart';

/// Room scan builder  Section 4.5
/// Guided walk-through: floor ' walls ' ceiling.
/// Wall/corner detection from vertical planes.
/// Outputs length, width, height, area, perimeter, wall areas, volume.
/// 2D floor plan with dimension labels, door/window markers, coverage meter.

class WallSegment {
  final Vec3 start;
  final Vec3 end;
  final double height;
  final PlaneFitResult? plane;

  const WallSegment({
    required this.start,
    required this.end,
    required this.height,
    this.plane,
  });

  double get length => start.distanceTo(end);
  double get area => length * height;
}

class DoorWindowMarker {
  final Vec3 position;
  final double width;
  final double height;
  final bool isDoor; // false = window

  const DoorWindowMarker({
    required this.position,
    required this.width,
    required this.height,
    this.isDoor = true,
  });
}

class FloorPlan2D {
  final List<Vec3> corners; // top-down (X, Z) with Y ignored
  final List<double> edgeLengths;
  final double area;
  final double perimeter;
  final List<DoorWindowMarker> markers;

  const FloorPlan2D({
    required this.corners,
    required this.edgeLengths,
    required this.area,
    required this.perimeter,
    this.markers = const [],
  });
}

class RoomResult {
  final double length;
  final double width;
  final double height;
  final double floorArea;
  final double perimeter;
  final double wallArea;
  final double volume;
  final FloorPlan2D floorPlan;
  final double coveragePercent; // 0100
  final List<WallSegment> walls;
  final bool isEstimate;

  const RoomResult({
    required this.length,
    required this.width,
    required this.height,
    required this.floorArea,
    required this.perimeter,
    required this.wallArea,
    required this.volume,
    required this.floorPlan,
    required this.coveragePercent,
    required this.walls,
    this.isEstimate = false,
  });
}

enum RoomScanStage { floor, walls, ceiling, complete }

class RoomBuilder {
  final List<Vec3> floorPoints = [];
  final List<Vec3> wallPoints = [];
  final List<Vec3> ceilingPoints = [];
  final List<DoorWindowMarker> markers = [];
  final List<WallSegment> walls = [];

  RoomScanStage stage = RoomScanStage.floor;
  double _seenSolidAngle = 0; // rough coverage accumulator
  static const _targetCoverage = 1.0;

  void addFloorPoint(Vec3 p) {
    if (stage != RoomScanStage.floor) return;
    floorPoints.add(p);
    _seenSolidAngle += 0.02;
  }

  void addWallPoint(Vec3 p) {
    if (stage != RoomScanStage.walls) return;
    wallPoints.add(p);
    _seenSolidAngle += 0.015;
  }

  void addCeilingPoint(Vec3 p) {
    if (stage != RoomScanStage.ceiling) return;
    ceilingPoints.add(p);
    _seenSolidAngle += 0.02;
  }

  void addMarker(DoorWindowMarker m) => markers.add(m);

  void advanceStage() {
    switch (stage) {
      case RoomScanStage.floor:
        stage = RoomScanStage.walls;
        break;
      case RoomScanStage.walls:
        stage = RoomScanStage.ceiling;
        break;
      case RoomScanStage.ceiling:
        stage = RoomScanStage.complete;
        break;
      case RoomScanStage.complete:
        break;
    }
  }

  double get coveragePercent =>
      (_seenSolidAngle / _targetCoverage * 100).clamp(0.0, 100.0);

  String get stageInstruction {
    switch (stage) {
      case RoomScanStage.floor:
        return 'Point at the floor and move slowly (coverage fills)';
      case RoomScanStage.walls:
        return 'Hand-mark walls: aim + tap at corners or along edges';
      case RoomScanStage.ceiling:
        return 'Optional: look up to capture ceiling height';
      case RoomScanStage.complete:
        return 'Room complete — review and export';
    }
  }

  /// Build final room result from collected points.
  RoomResult build() {
    // Floor plane
    final floorPlane = floorPoints.length >= 3
        ? PlaneFit.fit(floorPoints)
        : null;

    // Estimate height from ceiling vs floor centroid
    double height = 0;
    if (floorPlane != null && ceilingPoints.isNotEmpty) {
      final ceilCentroid = Geometry.centroid(ceilingPoints);
      height = PlaneFit.signedDistance(ceilCentroid, floorPlane).abs();
    } else if (wallPoints.isNotEmpty && floorPlane != null) {
      // Fallback: max vertical extent of wall points
      var maxH = 0.0;
      for (final p in wallPoints) {
        final h = PlaneFit.signedDistance(p, floorPlane).abs();
        if (h > maxH) maxH = h;
      }
      height = maxH;
    }

    // Corners: convex hull of floor points projected to XZ
    final corners = _extractCorners(floorPoints);
    final edgeLengths = <double>[];
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      edgeLengths.add(a.distanceTo(b));
    }

    final floorArea = corners.length >= 3
        ? Geometry.polygonArea(corners)
        : 0.0;
    final perimeter = edgeLengths.fold(0.0, (a, b) => a + b);

    // Walls from consecutive corners
    walls.clear();
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      walls.add(WallSegment(start: a, end: b, height: height));
    }
    final wallArea = walls.fold(0.0, (s, w) => s + w.area);

    // Bounding box length / width
    double minX = double.infinity, maxX = -double.infinity;
    double minZ = double.infinity, maxZ = -double.infinity;
    for (final c in corners) {
      if (c.x < minX) minX = c.x;
      if (c.x > maxX) maxX = c.x;
      if (c.z < minZ) minZ = c.z;
      if (c.z > maxZ) maxZ = c.z;
    }
    final length = maxX - minX;
    final width = maxZ - minZ;

    final floorPlan = FloorPlan2D(
      corners: corners,
      edgeLengths: edgeLengths,
      area: floorArea,
      perimeter: perimeter,
      markers: List.from(markers),
    );

    return RoomResult(
      length: length.isFinite ? length : 0,
      width: width.isFinite ? width : 0,
      height: height,
      floorArea: floorArea,
      perimeter: perimeter,
      wallArea: wallArea,
      volume: floorArea * height,
      floorPlan: floorPlan,
      coveragePercent: coveragePercent,
      walls: List.from(walls),
      isEstimate: floorPoints.length < 4 || height < 0.5,
    );
  }

  /// Simple convex hull in XZ plane (Andrew's monotone chain).
  List<Vec3> _extractCorners(List<Vec3> pts) {
    if (pts.length < 3) return List.from(pts);

    final sorted = List<Vec3>.from(pts)
      ..sort((a, b) {
        final dx = a.x - b.x;
        if (dx.abs() > 1e-9) return dx.compareTo(0);
        return a.z.compareTo(b.z);
      });

    double cross(Vec3 o, Vec3 a, Vec3 b) =>
        (a.x - o.x) * (b.z - o.z) - (a.z - o.z) * (b.x - o.x);

    final lower = <Vec3>[];
    for (final p in sorted) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    final upper = <Vec3>[];
    for (final p in sorted.reversed) {
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    lower.removeLast();
    upper.removeLast();
    return [...lower, ...upper];
  }

  void reset() {
    floorPoints.clear();
    wallPoints.clear();
    ceilingPoints.clear();
    markers.clear();
    walls.clear();
    stage = RoomScanStage.floor;
    _seenSolidAngle = 0;
  }
}
