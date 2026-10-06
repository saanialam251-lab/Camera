import '../../measure/level_engine.dart';

/// Level mode handler  wraps LevelEngine for the state layer.
/// Surface mode: place phone edge on object.
/// Camera mode: point at surface and read plane tilt.
enum LevelInputMode { surface, camera }

class LevelModeHandler {
  final LevelEngine engine = LevelEngine();
  LevelInputMode inputMode = LevelInputMode.surface;

  LevelReading get reading => engine.reading();

  void onSensor({
    required double accelX,
    required double accelY,
    required double accelZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
    required double timestamp,
  }) {
    engine.onSensor(
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      timestamp: timestamp,
    );
  }

  void calibrate() => engine.calibrate();
  void resetCalibration() => engine.resetCalibration();
  void lock() => engine.lock();
  void unlock() => engine.unlock();
  bool get isLocked => engine.isLocked;
  bool get shouldHapticTick => engine.shouldHapticTick;

  void reset() {
    engine.unlock();
    engine.resetCalibration();
    inputMode = LevelInputMode.surface;
  }
}
