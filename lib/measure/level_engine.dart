import 'dart:math' as math;

/// Level & Vertical engine  Section 4.8
/// Fused accelerometer + gyroscope (complementary filter).
/// Updated at sensor rate, rendered at 60 FPS.
/// Circular bubble + numeric tilt + color AND text state
/// ("Level", "Slightly off", "Tilted") so it works without color.
/// Calibrate on known flat surface; store offset.
/// Lock reading; haptic tick within +/-0.5 deg.

enum LevelState { level, slightlyOff, tilted }

class LevelReading {
  final double pitchDeg; // degrees from horizontal (X axis)
  final double rollDeg; // degrees from horizontal (Z axis)
  final double tiltMagnitude; // combined absolute tilt
  final LevelState state;
  final String label; // "Level" / "Slightly off" / "Tilted"
  final bool isLocked;

  const LevelReading({
    required this.pitchDeg,
    required this.rollDeg,
    required this.tiltMagnitude,
    required this.state,
    required this.label,
    this.isLocked = false,
  });
}

/// Complementary filter fusion of accel + gyro.
class LevelEngine {
  // Calibration offsets (degrees)
  double _pitchOffset = 0;
  double _rollOffset = 0;

  // Filtered state
  double _pitch = 0;
  double _roll = 0;

  // Complementary filter coefficient (0 = pure accel, 1 = pure gyro)
  double alpha = 0.98;

  bool _locked = false;
  LevelReading? _lockedReading;

  double? _lastTimestamp;

  /// Feed raw sensor data (radians/s for gyro, m/s2 for accel).
  /// Call at sensor rate (~50100 Hz).
  void onSensor({
    required double accelX,
    required double accelY,
    required double accelZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
    required double timestamp,
  }) {
    if (_locked) return;

    final dt = _lastTimestamp == null
        ? 0.01
        : (timestamp - _lastTimestamp!).clamp(0.001, 0.1);
    _lastTimestamp = timestamp;

    // Accel-derived pitch / roll (degrees)
    final accelPitch = math.atan2(accelY, math.sqrt(accelX * accelX + accelZ * accelZ)) *
        180.0 /
        math.pi;
    final accelRoll =
        math.atan2(-accelX, accelZ) * 180.0 / math.pi;

    // Gyro integration (gyro in rad/s ' deg)
    final gyroPitchDelta = gyroX * dt * 180.0 / math.pi;
    final gyroRollDelta = gyroZ * dt * 180.0 / math.pi;

    // Complementary filter
    _pitch = alpha * (_pitch + gyroPitchDelta) + (1 - alpha) * accelPitch;
    _roll = alpha * (_roll + gyroRollDelta) + (1 - alpha) * accelRoll;
  }

  LevelReading reading() {
    if (_locked && _lockedReading != null) return _lockedReading!;

    final pitch = _pitch - _pitchOffset;
    final roll = _roll - _rollOffset;
    final mag = math.sqrt(pitch * pitch + roll * roll);

    LevelState state;
    String label;
    if (mag <= 0.5) {
      state = LevelState.level;
      label = 'Level';
    } else if (mag <= 2.0) {
      state = LevelState.slightlyOff;
      label = 'Slightly off';
    } else {
      state = LevelState.tilted;
      label = 'Tilted';
    }

    return LevelReading(
      pitchDeg: pitch,
      rollDeg: roll,
      tiltMagnitude: mag,
      state: state,
      label: label,
      isLocked: false,
    );
  }

  /// Calibrate on a known flat surface  store current as zero offset.
  void calibrate() {
    _pitchOffset = _pitch;
    _rollOffset = _roll;
  }

  void resetCalibration() {
    _pitchOffset = 0;
    _rollOffset = 0;
  }

  /// Lock current reading on screen.
  void lock() {
    _locked = true;
    _lockedReading = reading().copyWith(isLocked: true);
  }

  void unlock() {
    _locked = false;
    _lockedReading = null;
  }

  bool get isLocked => _locked;

  /// True when within +/-0.5 deg  used for haptic tick.
  bool get shouldHapticTick {
    final r = reading();
    return r.tiltMagnitude <= 0.5 && !r.isLocked;
  }
}

extension on LevelReading {
  LevelReading copyWith({bool? isLocked}) => LevelReading(
        pitchDeg: pitchDeg,
        rollDeg: rollDeg,
        tiltMagnitude: tiltMagnitude,
        state: state,
        label: label,
        isLocked: isLocked ?? this.isLocked,
      );
}
