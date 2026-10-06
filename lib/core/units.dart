import 'dart:math' as math;

/// Unit conversion + stable display number with hysteresis.
/// Values always stored in meters. Conversion is display-only.
enum LengthUnit { mm, cm, m, in_, ft, yd }

class Units {
  Units._();

  static const _toMeters = {
    LengthUnit.mm: 0.001,
    LengthUnit.cm: 0.01,
    LengthUnit.m: 1.0,
    LengthUnit.in_: 0.0254,
    LengthUnit.ft: 0.3048,
    LengthUnit.yd: 0.9144,
  };

  static double toMeters(double value, LengthUnit unit) => value * _toMeters[unit]!;

  static double fromMeters(double meters, LengthUnit unit) => meters / _toMeters[unit]!;

  static String symbol(LengthUnit unit) {
    switch (unit) {
      case LengthUnit.mm:
        return 'mm';
      case LengthUnit.cm:
        return 'cm';
      case LengthUnit.m:
        return 'm';
      case LengthUnit.in_:
        return 'in';
      case LengthUnit.ft:
        return 'ft';
      case LengthUnit.yd:
        return 'yd';
    }
  }

  /// Auto-unit: choose a readable unit based on magnitude.
  static LengthUnit autoUnit(double meters) {
    if (meters < 0.01) return LengthUnit.mm;
    if (meters < 1.0) return LengthUnit.cm;
    if (meters < 100) return LengthUnit.m;
    return LengthUnit.m;
  }

  /// Format with hysteresis so digits do not flicker.
  /// Value must change by more than half a display step before updating.
  static String formatStable(
    double meters, {
    required LengthUnit unit,
    required int decimals,
    double? lastDisplayed,
  }) {
    final value = fromMeters(meters, unit);
    final step = math.pow(10, -decimals).toDouble();
    double display = value;

    if (lastDisplayed != null) {
      final delta = (value - lastDisplayed).abs();
      if (delta < step * 0.5) {
        display = lastDisplayed;
      }
    }

    final formatted = display.toStringAsFixed(decimals);
    return '$formatted ${symbol(unit)}';
  }
}
