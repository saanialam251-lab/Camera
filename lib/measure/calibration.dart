import 'vec3.dart';
import 'geometry.dart';

/// Reference Object Scale + Accuracy Test Tool  Section 5.3 + 5.16
/// Place credit card, A4, coin ' auto-calibrate scale.
/// Accuracy Test: measure known 1 m reference, report device error.
/// Correction is NEVER applied silently  only suggested.

enum ReferenceObject {
  creditCard, // 85.60 x 53.98 mm
  a4Sheet, // 297 x 210 mm
  coinUSQuarter, // 24.26 mm diameter
  coinEuro1, // 23.25 mm diameter
  custom,
}

class ReferenceSpec {
  final String name;
  final double lengthMeters; // primary dimension
  final double? widthMeters;

  const ReferenceSpec(this.name, this.lengthMeters, [this.widthMeters]);
}

const referenceLibrary = {
  ReferenceObject.creditCard:
      ReferenceSpec('Credit Card', 0.08560, 0.05398),
  ReferenceObject.a4Sheet: ReferenceSpec('A4 Sheet', 0.297, 0.210),
  ReferenceObject.coinUSQuarter:
      ReferenceSpec('US Quarter', 0.02426),
  ReferenceObject.coinEuro1: ReferenceSpec('¬1 Coin', 0.02325),
};

class CalibrationResult {
  final double scaleFactor; // multiply measured distances by this
  final double measuredLength;
  final double trueLength;
  final double errorPercent;
  final String source; // 'creditCard' / 'a4' / 'accuracyTest' / ...
  final DateTime timestamp;
  final bool suggestedOnly; // true = never auto-applied

  const CalibrationResult({
    required this.scaleFactor,
    required this.measuredLength,
    required this.trueLength,
    required this.errorPercent,
    required this.source,
    required this.timestamp,
    this.suggestedOnly = true,
  });
}

class CalibrationEngine {
  CalibrationResult? lastResult;
  double activeScaleFactor = 1.0; // only set if user explicitly accepts

  /// Compute scale from a measured segment vs known reference.
  CalibrationResult fromReference({
    required Vec3 a,
    required Vec3 b,
    required ReferenceObject object,
    double? customTrueLength,
  }) {
    final measured = Geometry.distance(a, b);
    final trueLen = object == ReferenceObject.custom
        ? (customTrueLength ?? measured)
        : referenceLibrary[object]!.lengthMeters;

    final factor = trueLen / (measured > 1e-9 ? measured : 1e-9);
    final errorPct = ((measured - trueLen) / trueLen * 100).abs();

    final result = CalibrationResult(
      scaleFactor: factor,
      measuredLength: measured,
      trueLength: trueLen,
      errorPercent: errorPct,
      source: object.name,
      timestamp: DateTime.now(),
      suggestedOnly: true,
    );
    lastResult = result;
    return result;
  }

  /// Accuracy Test Tool  measure a known 1 m reference.
  CalibrationResult accuracyTest({
    required Vec3 a,
    required Vec3 b,
    double knownLength = 1.0,
  }) {
    final measured = Geometry.distance(a, b);
    final factor = knownLength / (measured > 1e-9 ? measured : 1e-9);
    final errorPct = ((measured - knownLength) / knownLength * 100).abs();

    final result = CalibrationResult(
      scaleFactor: factor,
      measuredLength: measured,
      trueLength: knownLength,
      errorPercent: errorPct,
      source: 'accuracyTest',
      timestamp: DateTime.now(),
      suggestedOnly: true,
    );
    lastResult = result;
    return result;
  }

  /// User explicitly accepts the suggested correction.
  void acceptSuggestion() {
    if (lastResult != null) {
      activeScaleFactor = lastResult!.scaleFactor;
    }
  }

  void resetScale() {
    activeScaleFactor = 1.0;
    lastResult = null;
  }

  /// Apply active scale to a raw meter value (display / storage).
  double apply(double meters) => meters * activeScaleFactor;
}
