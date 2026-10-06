import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/state/measure_controller.dart';
import 'package:measure_reality/measure/models.dart';
import 'package:measure_reality/measure/vec3.dart';

void main() {
  late MeasureController ctrl;

  setUp(() {
    ctrl = MeasureController();
  });

  test('starts in idle', () {
    expect(ctrl.state.state, MeasureWorkflowState.idle);
  });

  test('endpoint is never auto-locked', () {
    ctrl.setReady();
    ctrl.lockStart();
    expect(ctrl.state.state, MeasureWorkflowState.stretching);

    // Feed many frames – endpoint must stay unlocked
    for (var i = 0; i < 100; i++) {
      ctrl.onFrame(
        hit: Vec3(0.5 + i * 0.001, 0, -1.0),
        timestamp: i * 0.016,
        trackingQuality: 0.9,
        depthQuality: 0.8,
        cameraSpeed: 0.1,
        featureDensity: 0.7,
        lighting: 0.8,
      );
    }
    expect(ctrl.state.state, MeasureWorkflowState.stretching);
    expect(ctrl.state.primaryLabel, 'SET END POINT');
  });

  test('lockEnd only works from stretching / endPreview', () {
    ctrl.setReady();
    ctrl.lockEnd(); // should be ignored
    expect(ctrl.state.state, MeasureWorkflowState.ready);

    ctrl.lockStart();
    ctrl.lockEnd();
    expect(ctrl.state.state, MeasureWorkflowState.complete);
  });

  test('reset clears everything', () {
    ctrl.setReady();
    ctrl.lockStart();
    ctrl.reset();
    expect(ctrl.state.state, MeasureWorkflowState.idle);
    expect(ctrl.state.start, isNull);
  });
}
