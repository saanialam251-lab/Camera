import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/debug/replay_system.dart';
import 'package:measure_reality/debug/device_checks.dart';
import 'package:measure_reality/state/measure_controller.dart';
import 'package:measure_reality/measure/models.dart';
import 'package:measure_reality/ar/ar_models.dart';
import 'package:measure_reality/measure/vec3.dart';

/// Sample recorded session: start at origin, move to (1,0,-1) over ~1s.
ReplaySession sampleDistanceSession() {
  final frames = <ReplayFrame>[];
  for (var i = 0; i < 60; i++) {
    final t = i * 0.016;
    final f = i / 59.0;
    frames.add(ReplayFrame(
      timestamp: t,
      x: f * 1.0,
      y: 0,
      z: -1.0,
      trackingQuality: 0.95,
      depthQuality: 0.9,
      cameraSpeed: 0.05,
      featureDensity: 0.8,
      lighting: 0.85,
    ));
  }
  return ReplaySession(
    id: 'sample-distance-1m',
    name: '1m distance along X',
    frames: frames,
    metadata: {'expectedDistance': 1.0},
  );
}

void main() {
  group('ReplaySystem', () {
    test('serialize round-trip', () {
      final session = sampleDistanceSession();
      final json = session.toJsonString();
      final restored = ReplaySession.fromJsonString(json);
      expect(restored.frames.length, session.frames.length);
      expect(restored.id, 'sample-distance-1m');
      expect(restored.frames.first.x, closeTo(0, 1e-9));
      expect(restored.frames.last.x, closeTo(1.0, 1e-6));
    });

    test('player yields all frames', () {
      final session = sampleDistanceSession();
      final player = ReplayPlayer(session);
      var count = 0;
      player.playAll((_) => count++);
      expect(count, 60);
      expect(player.hasMore, isFalse);
    });

    test('replay into controller never auto-locks', () {
      final session = sampleDistanceSession();
      final ctrl = MeasureController();
      ctrl.setReady();
      ctrl.lockStart();

      final player = ReplayPlayer(session);
      // Skip first few (start region), feed rest
      player.playAll((snap) {
        ctrl.onFrame(
          hit: snap.hitPoint,
          timestamp: snap.timestamp,
          trackingQuality: snap.trackingQuality,
          depthQuality: snap.depthQuality,
          cameraSpeed: snap.cameraSpeed,
          featureDensity: snap.featureDensity,
          lighting: snap.lighting,
        );
      });

      // Must still be stretching – never auto-complete
      expect(ctrl.state.state, MeasureWorkflowState.stretching);
      expect(ctrl.state.primaryLabel, 'SET END POINT');
    });

    test('recorder captures frames', () {
      final recorder = ReplayRecorder();
      recorder.start();
      recorder.add(const ArFrameSnapshot(
        hitPoint: Vec3(0.5, 0, -1),
        timestamp: 0.1,
        trackingQuality: 0.9,
        depthQuality: 0.8,
        cameraSpeed: 0.1,
        featureDensity: 0.7,
        lighting: 0.8,
      ));
      final session = recorder.stop(id: 'r1', name: 'test');
      expect(session.frames.length, 1);
      expect(recorder.recording, isFalse);
    });
  });

  group('ReleaseGates', () {
    test('passes good metrics', () {
      final r = ReleaseGates.evaluate(
        p95FrameMs: 14.0,
        medianErrorPercent: 1.5,
        crashes: 0,
        sessions: 1000,
      );
      expect(ReleaseGates.allPassed(r), isTrue);
    });

    test('fails slow frames', () {
      final r = ReleaseGates.evaluate(
        p95FrameMs: 20.0,
        medianErrorPercent: 1.0,
        crashes: 0,
        sessions: 100,
      );
      expect(r['frameTime'], isFalse);
      expect(ReleaseGates.allPassed(r), isFalse);
    });

    test('fails any crash', () {
      final r = ReleaseGates.evaluate(
        p95FrameMs: 12.0,
        medianErrorPercent: 1.0,
        crashes: 1,
        sessions: 1000,
      );
      expect(r['crashes'], isFalse);
    });
  });

  group('DeviceChecks', () {
    test('hardware depth gets better accuracy string', () {
      final report = DeviceChecks.analyze(
        arStatus: const ArSessionStatus(
          tracking: ArTrackingState.normal,
          depthSupported: true,
          lidar: true,
          depthType: 'hardware',
        ),
      );
      expect(report.arSupported, isTrue);
      expect(report.expectedAccuracy, contains('0.5'));
      expect(report.warnings, isEmpty);
    });

    test('no depth adds warning', () {
      final report = DeviceChecks.analyze(
        arStatus: const ArSessionStatus(
          tracking: ArTrackingState.normal,
          depthSupported: false,
          depthType: 'none',
        ),
      );
      expect(report.warnings, isNotEmpty);
    });
  });
}
