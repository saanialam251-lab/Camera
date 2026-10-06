import 'vec3.dart';

/// Edge / Corner Magnet (Snap Pro)  Section 5.1 + 4.1
/// Snap radius adjustable (Low / Med / High).
/// Visible pull line + one-tap undo of a snap.
enum SnapStrength { low, medium, high }

class SnapCandidate {
  final Vec3 point;
  final SnapType type;
  final double distance; // meters from raw hit
  final Vec3? edgeDirection; // for edge snaps

  const SnapCandidate({
    required this.point,
    required this.type,
    required this.distance,
    this.edgeDirection,
  });
}

enum SnapType { corner, edge, plane, none }

class SnapResult {
  final Vec3 snapped;
  final SnapType type;
  final bool didSnap;
  final Vec3? pullFrom; // raw hit before snap (for visible pull line)
  final Vec3? edgeDirection;

  const SnapResult({
    required this.snapped,
    required this.type,
    required this.didSnap,
    this.pullFrom,
    this.edgeDirection,
  });

  static SnapResult none(Vec3 raw) => SnapResult(
        snapped: raw,
        type: SnapType.none,
        didSnap: false,
      );
}

/// Pure Dart snap engine  no Flutter dependency.
class SnapEngine {
  SnapStrength strength;
  bool enabled;

  // Last snap for one-tap undo
  SnapResult? _lastSnap;
  Vec3? _preSnapPoint;

  SnapEngine({
    this.strength = SnapStrength.medium,
    this.enabled = true,
  });

  double get _radius {
    switch (strength) {
      case SnapStrength.low:
        return 0.015; // 1.5 cm
      case SnapStrength.medium:
        return 0.030; // 3 cm
      case SnapStrength.high:
        return 0.055; // 5.5 cm
    }
  }

  /// Main entry: given raw hit + known corners / edges / plane points,
  /// return the best snap (or original).
  SnapResult evaluate({
    required Vec3 rawHit,
    List<Vec3> corners = const [],
    List<(Vec3, Vec3)> edges = const [], // (start, end)
    List<Vec3> planePoints = const [],
  }) {
    if (!enabled) return SnapResult.none(rawHit);

    final candidates = <SnapCandidate>[];

    // Corners  highest priority
    for (final c in corners) {
      final d = rawHit.distanceTo(c);
      if (d <= _radius) {
        candidates.add(SnapCandidate(point: c, type: SnapType.corner, distance: d));
      }
    }

    // Edges  project onto segment
    for (final (a, b) in edges) {
      final projected = _projectOnSegment(rawHit, a, b);
      final d = rawHit.distanceTo(projected);
      if (d <= _radius) {
        final dir = (b - a).normalized();
        candidates.add(SnapCandidate(
          point: projected,
          type: SnapType.edge,
          distance: d,
          edgeDirection: dir,
        ));
      }
    }

    // Plane points (feature / grid intersections)  lowest priority among snaps
    for (final p in planePoints) {
      final d = rawHit.distanceTo(p);
      if (d <= _radius * 0.7) {
        candidates.add(SnapCandidate(point: p, type: SnapType.plane, distance: d));
      }
    }

    if (candidates.isEmpty) {
      _lastSnap = null;
      _preSnapPoint = null;
      return SnapResult.none(rawHit);
    }

    // Prefer corner > edge > plane, then closest
    candidates.sort((a, b) {
      final prio = _priority(a.type) - _priority(b.type);
      if (prio != 0) return prio;
      return a.distance.compareTo(b.distance);
    });

    final best = candidates.first;
    final result = SnapResult(
      snapped: best.point,
      type: best.type,
      didSnap: true,
      pullFrom: rawHit,
      edgeDirection: best.edgeDirection,
    );

    _preSnapPoint = rawHit;
    _lastSnap = result;
    return result;
  }

  /// One-tap undo of the last snap (returns the pre-snap point).
  Vec3? undoLastSnap() {
    if (_lastSnap == null || _preSnapPoint == null) return null;
    final restored = _preSnapPoint!;
    _lastSnap = null;
    _preSnapPoint = null;
    return restored;
  }

  int _priority(SnapType t) {
    switch (t) {
      case SnapType.corner:
        return 0;
      case SnapType.edge:
        return 1;
      case SnapType.plane:
        return 2;
      case SnapType.none:
        return 3;
    }
  }

  /// Closest point on segment AB to P.
  Vec3 _projectOnSegment(Vec3 p, Vec3 a, Vec3 b) {
    final ab = b - a;
    final lenSq = ab.lengthSquared;
    if (lenSq < 1e-12) return a;
    final t = ((p - a).dot(ab) / lenSq).clamp(0.0, 1.0);
    return a + ab * t;
  }
}
