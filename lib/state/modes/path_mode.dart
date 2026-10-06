import '../../measure/vec3.dart';
import '../../measure/geometry.dart';
import '../../measure/snap_engine.dart';

/// Multi-Point / Path mode  Section 4.2
/// Per-segment labels, drag points, undo/redo (50 steps),
/// Closed loop, Average / Longest / Shortest, Cumulative distance.
class PathModeHandler {
  final List<Vec3> points = [];
  final List<List<Vec3>> _undoStack = [];
  final List<List<Vec3>> _redoStack = [];
  static const maxUndo = 50;

  bool closedLoop = false;
  final SnapEngine snapEngine;

  PathModeHandler({SnapEngine? snap}) : snapEngine = snap ?? SnapEngine();

  void addPoint(Vec3 p) {
    _pushUndo();
    points.add(p);
    _redoStack.clear();
  }

  void movePoint(int index, Vec3 newPos) {
    if (index < 0 || index >= points.length) return;
    _pushUndo();
    points[index] = newPos;
    _redoStack.clear();
  }

  void removeLast() {
    if (points.isEmpty) return;
    _pushUndo();
    points.removeLast();
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List<Vec3>.from(points));
    points
      ..clear()
      ..addAll(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List<Vec3>.from(points));
    points
      ..clear()
      ..addAll(_redoStack.removeLast());
  }

  void toggleClosedLoop() => closedLoop = !closedLoop;

  double get totalLength {
    var len = Geometry.pathLength(points);
    if (closedLoop && points.length >= 2) {
      len += points.last.distanceTo(points.first);
    }
    return len;
  }

  List<double> get segmentLengths {
    if (points.length < 2) return [];
    final segs = <double>[];
    for (var i = 1; i < points.length; i++) {
      segs.add(points[i - 1].distanceTo(points[i]));
    }
    if (closedLoop && points.length >= 2) {
      segs.add(points.last.distanceTo(points.first));
    }
    return segs;
  }

  double? get averageSegment {
    final segs = segmentLengths;
    if (segs.isEmpty) return null;
    return segs.reduce((a, b) => a + b) / segs.length;
  }

  double? get longestSegment {
    final segs = segmentLengths;
    if (segs.isEmpty) return null;
    return segs.reduce((a, b) => a > b ? a : b);
  }

  double? get shortestSegment {
    final segs = segmentLengths;
    if (segs.isEmpty) return null;
    return segs.reduce((a, b) => a < b ? a : b);
  }

  /// Cumulative distance when scrubbing along the path (01).
  double cumulativeAt(double t) {
    final total = totalLength;
    if (total <= 0) return 0;
    return (t.clamp(0.0, 1.0)) * total;
  }

  void _pushUndo() {
    _undoStack.add(List<Vec3>.from(points));
    while (_undoStack.length > maxUndo) {
      _undoStack.removeAt(0);
    }
  }

  void reset() {
    points.clear();
    _undoStack.clear();
    _redoStack.clear();
    closedLoop = false;
  }
}
