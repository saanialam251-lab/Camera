import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/level_engine.dart';

void main() {
  group('LevelEngine', () {
    late LevelEngine engine;

    setUp(() {
      engine = LevelEngine();
    });

    test('starts near level with gravity-only input', () {
      engine.onSensor(
        accelX: 0,
        accelY: -9.81,
        accelZ: 0,
        gyroX: 0,
        gyroY: 0,
        gyroZ: 0,
        timestamp: 0.01,
      );
      final r = engine.reading();
      expect(r.tiltMagnitude, lessThan(5.0));
    });

    test('detects tilted state', () {
      for (var i = 0; i < 20; i++) {
        engine.onSensor(
          accelX: 5,
          accelY: -7,
          accelZ: 0,
          gyroX: 0,
          gyroY: 0,
          gyroZ: 0,
          timestamp: i * 0.016,
        );
      }
      final r = engine.reading();
      expect(r.state, isNot(LevelState.level));
    });

    test('calibrate zeros the reading', () {
      for (var i = 0; i < 10; i++) {
        engine.onSensor(
          accelX: 2,
          accelY: -9,
          accelZ: 1,
          gyroX: 0,
          gyroY: 0,
          gyroZ: 0,
          timestamp: i * 0.016,
        );
      }
      engine.calibrate();
      final r = engine.reading();
      expect(r.pitchDeg.abs(), lessThan(0.5));
      expect(r.rollDeg.abs(), lessThan(0.5));
    });

    test('lock freezes reading', () {
      engine.onSensor(
        accelX: 0,
        accelY: -9.81,
        accelZ: 0,
        gyroX: 0,
        gyroY: 0,
        gyroZ: 0,
        timestamp: 0.01,
      );
      engine.lock();
      expect(engine.isLocked, isTrue);
      final locked = engine.reading();

      engine.onSensor(
        accelX: 5,
        accelY: -5,
        accelZ: 5,
        gyroX: 1,
        gyroY: 1,
        gyroZ: 1,
        timestamp: 1.0,
      );
      final after = engine.reading();
      expect(after.pitchDeg, locked.pitchDeg);
      expect(after.rollDeg, locked.rollDeg);
      expect(after.isLocked, isTrue);
    });

    test('haptic tick only when level', () {
      engine.onSensor(
        accelX: 0,
        accelY: -9.81,
        accelZ: 0,
        gyroX: 0,
        gyroY: 0,
        gyroZ: 0,
        timestamp: 0.01,
      );
      engine.calibrate();
      expect(engine.shouldHapticTick, isTrue);
    });
  });
}
