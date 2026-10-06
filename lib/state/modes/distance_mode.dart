import 'dart:math' as math;
import '../../measure/vec3.dart';
import '../../measure/geometry.dart';
import '../../measure/snap_engine.dart';

/// Distance (two-point) mode handler  Section 4.1
/// Live preview, Hold-to-Freeze, Nudge (+/-1 mm), Axis lock,
/// Dimension breakdown (" horizontal, " vertical).
enum AxisLock { none, horizontal, vertical, edge }

class DistanceModeHandler {
  Vec3? start;
  Vec3? end;
  bool frozen = false; // Hold-to-Freeze
  AxisLock axisLock = AxisLock.none;
  Vec3? edgeDirection; // when axisLock == edge

  // Nudge offsets in meters (applied after lock)
  double nudgeStartX = 0, nudgeStartY = 0, nudgeStartZ = 0;
  double nudgeEndX = 0, nudgeEndY = 0, nudgeEndZ = 0;

  final SnapEngine snapEngine;

  DistanceModeHandler({SnapEngine? snap}) : snapEngine = snap ?? SnapEngine();

  void setStart(Vec3 p) {
    start = p;
    nudgeStartX = nudgeStartY = nudgeStartZ = 0;
  }

  void setEnd(Vec3 p) {
    end = p;
    nudgeEndX = nudgeEndY = nudgeEndZ = 0;
  }

  /// Apply axis lock constraint to a live endpoint relative to start.
  Vec3 applyAxisLock(Vec3 raw) {
    if (start == null || axisLock == AxisLock.none) return raw;

    final delta = raw - start!;
    switch (axisLock) {
      case AxisLock.horizontal:
        return Vec3(raw.x, start!.y, raw.z);
      case AxisLock.vertical:
        return Vec3(start!.x, raw.y, start!.z);
      case AxisLock.edge:
        if (edgeDirection == null) return raw;
        final proj = delta.dot(edgeDirection!);
        return start! + edgeDirection! * proj;
      case AxisLock.none:
        return raw;
    }
  }

  Vec3 get effectiveStart {
    if (start == null) return Vec3.zero;
    return Vec3(
      start!.x + nudgeStartX,
      start!.y + nudgeStartY,
      start!.z + nudgeStartZ,
    );
  }

  Vec3 get effectiveEnd {
    if (end == null) return Vec3.zero;
    return Vec3(
      end!.x + nudgeEndX,
      end!.y + nudgeEndY,
      end!.z + nudgeEndZ,
    );
  }

  double get distance {
    if (start == null || end == null) return 0;
    return Geometry.distance(effectiveStart, effectiveEnd);
  }

  /// Dimension breakdown: total + " horizontal + " vertical.
  ({double total, double horizontal, double vertical}) get breakdown {
    if (start == null || end == null) {
      return (total: 0.0, horizontal: 0.0, vertical: 0.0);
    }
    final s = effectiveStart;
    final e = effectiveEnd;
    final total = Geometry.distance(s, e);
    final vertical = Geometry.height(s, e);
    final horizontal = math.sqrt(math.max(0.0, total * total - vertical * vertical));
    return (total: total, horizontal: horizontal, vertical: vertical);
  }

  /// Nudge a point by +/-1 mm in the given axis (zoomed view).
  void nudgeStart({double dx = 0, double dy = 0, double dz = 0}) {
    nudgeStartX += dx;
    nudgeStartY += dy;
    nudgeStartZ += dz;
  }

  void nudgeEnd({double dx = 0, double dy = 0, double dz = 0}) {
    nudgeEndX += dx;
    nudgeEndY += dy;
    nudgeEndZ += dz;
  }

  void holdToFreeze(bool freeze) => frozen = freeze;

  void reset() {
    start = null;
    end = null;
    frozen = false;
    axisLock = AxisLock.none;
    edgeDirection = null;
    nudgeStartX = nudgeStartY = nudgeStartZ = 0;
    nudgeEndX = nudgeEndY = nudgeEndZ = 0;
  }
}
