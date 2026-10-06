import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../measure/vec3.dart';
import '../measure/filters.dart';
import '../measure/confidence.dart';
import '../measure/models.dart';
import '../measure/geometry.dart';

/// Workflow state machine + live measurement engine.
/// Golden Rule #1: endpoint is NEVER auto-locked.
class MeasureController extends StateNotifier<LiveMeasurement> {
  MeasureController()
      : super(LiveMeasurement(
          confidence: const ConfidenceResult(
            score: 0,
            level: ConfidenceLevel.low,
            errorRangeMeters: 0,
            reasons: [],
          ),
          state: MeasureWorkflowState.idle,
          instruction: 'Choose a mode to begin',
          primaryLabel: 'START',
          primaryEnabled: false,
        ));

  final _oneEuro = OneEuroFilter3D();
  final List<Vec3> _recentSamples = [];
  Vec3? _start;
  Vec3? _lockedEnd;
  Vec3? _lastAccepted;
  double _lastTimestamp = 0;
  bool _precisionMode = false;
  MeasureMode _mode = MeasureMode.distance;

  static const _maxSpeed = 1.5; // m/s outlier rejection

  // ── Frame input (called from AR provider isolate / channel) ──────────

  void onFrame({
    required Vec3 hit,
    required double timestamp,
    required double trackingQuality,
    required double depthQuality,
    required double cameraSpeed,
    required double featureDensity,
    required double lighting,
  }) {
    if (state.state == MeasureWorkflowState.trackingLost ||
        state.state == MeasureWorkflowState.paused ||
        state.state == MeasureWorkflowState.error) {
      return;
    }

    // 1. Outlier rejection
    if (_lastAccepted != null) {
      final dt = math.max(timestamp - _lastTimestamp, 1e-4);
      final dist = hit.distanceTo(_lastAccepted!);
      if (dist / dt > _maxSpeed) return;
    }

    // 2. One-Euro smoothing
    final smoothed = _oneEuro.filter(hit, timestamp);
    _lastAccepted = smoothed;
    _lastTimestamp = timestamp;
    _recentSamples.add(smoothed);
    while (_recentSamples.length > 60) {
      _recentSamples.removeAt(0);
    }

    // 3. Live distance
    final dist = _start != null ? Geometry.distance(_start!, smoothed) : 0.0;

    // 4. Confidence
    final variance = _sampleVariance();
    final conf = Confidence.compute(
      trackingState: trackingQuality,
      depthSourceQuality: depthQuality,
      cameraSpeed: cameraSpeed,
      featureDensity: featureDensity,
      lightingQuality: lighting,
      sampleVariance: variance,
      distanceToSurface: dist,
    );

    // 5. Update live UI state (never commits endpoint)
    final workflow = state.state;
    final (instruction, label, enabled, progress) = _primaryFor(workflow);

    state = LiveMeasurement(
      start: _start,
      current: smoothed,
      distanceMeters: dist,
      confidence: conf,
      state: workflow,
      instruction: instruction,
      primaryLabel: label,
      primaryEnabled: enabled,
      showProgress: progress,
    );
  }

  // ── User actions ─────────────────────────────────────────────────────

  void startScanning() {
    _setWorkflow(MeasureWorkflowState.scanning);
  }

  void setReady() {
    _setWorkflow(MeasureWorkflowState.ready);
  }

  /// User pressed START – lock start point with Median-of-N.
  void lockStart() {
    if (state.state != MeasureWorkflowState.ready) return;
    _start = TrimmedMean.compute(_recentSamples, precisionMode: _precisionMode);
    _recentSamples.clear();
    _oneEuro.reset();
    _setWorkflow(MeasureWorkflowState.stretching);
  }

  /// User pressed SET END POINT.
  /// This is the ONLY way the endpoint is committed (Golden Rule #1).
  void lockEnd() {
    if (state.state != MeasureWorkflowState.stretching &&
        state.state != MeasureWorkflowState.endPreview) {
      return;
    }
    _lockedEnd = TrimmedMean.compute(_recentSamples, precisionMode: _precisionMode);
    _setWorkflow(MeasureWorkflowState.complete);
  }

  void setTrackingLost() => _setWorkflow(MeasureWorkflowState.trackingLost);
  void resumeTracking() => _setWorkflow(MeasureWorkflowState.ready);
  void pause() => _setWorkflow(MeasureWorkflowState.paused);

  void reset() {
    _start = null;
    _lockedEnd = null;
    _recentSamples.clear();
    _oneEuro.reset();
    _lastAccepted = null;
    _setWorkflow(MeasureWorkflowState.idle);
  }

  void setMode(MeasureMode mode) {
    _mode = mode;
    reset();
  }

  void setPrecisionMode(bool enabled) => _precisionMode = enabled;

  // ── Internals ────────────────────────────────────────────────────────

  void _setWorkflow(MeasureWorkflowState s) {
    final (instruction, label, enabled, progress) = _primaryFor(s);
    state = LiveMeasurement(
      start: _start,
      current: state.current,
      distanceMeters: state.distanceMeters,
      confidence: state.confidence,
      state: s,
      instruction: instruction,
      primaryLabel: label,
      primaryEnabled: enabled,
      showProgress: progress,
    );
  }

  (String, String, bool, bool) _primaryFor(MeasureWorkflowState s) {
    switch (s) {
      case MeasureWorkflowState.idle:
        return ('Choose a mode to begin', 'START', false, false);
      case MeasureWorkflowState.scanning:
        return ('Move slowly', '…', false, true);
      case MeasureWorkflowState.ready:
        return ('Tap START', 'START', true, false);
      case MeasureWorkflowState.startLocked:
      case MeasureWorkflowState.stretching:
        return ('Move to endpoint', 'SET END POINT', true, false);
      case MeasureWorkflowState.endPreview:
        return ('Endpoint ready', 'SET END POINT', true, false);
      case MeasureWorkflowState.complete:
        return ('Measurement complete', 'SAVE', true, false);
      case MeasureWorkflowState.trackingLost:
        return ('Move slowly until tracking returns', 'RESUME', true, false);
      case MeasureWorkflowState.paused:
        return ('Paused', 'RESUME', true, false);
      case MeasureWorkflowState.error:
        return ('Something went wrong', 'RETRY', true, false);
      default:
        return ('', 'START', false, false);
    }
  }

  double _sampleVariance() {
    if (_recentSamples.length < 3) return 0;
    final n = _recentSamples.length.toDouble();
    var mx = 0.0, my = 0.0, mz = 0.0;
    for (final p in _recentSamples) {
      mx += p.x;
      my += p.y;
      mz += p.z;
    }
    mx /= n;
    my /= n;
    mz /= n;
    var sum = 0.0;
    for (final p in _recentSamples) {
      final dx = p.x - mx, dy = p.y - my, dz = p.z - mz;
      sum += dx * dx + dy * dy + dz * dz;
    }
    return sum / n;
  }
}

final measureControllerProvider =
    StateNotifierProvider<MeasureController, LiveMeasurement>((ref) {
  return MeasureController();
});
