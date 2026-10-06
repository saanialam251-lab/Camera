import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/vec3.dart';
import 'package:measure_reality/measure/calibration.dart';

void main() {
  group('CalibrationEngine', () {
    late CalibrationEngine engine;

    setUp(() {
      engine = CalibrationEngine();
    });

    test('scale factor from credit card', () {
      const trueLen = 0.08560;
      final measured = trueLen * 1.05; // 5% long
      final result = engine.fromReference(
        a: const Vec3(0, 0, 0),
        b: Vec3(measured, 0, 0),
        object: ReferenceObject.creditCard,
      );
      expect(result.scaleFactor, closeTo(1 / 1.05, 0.001));
      expect(result.errorPercent, closeTo(5.0, 0.1));
      expect(result.suggestedOnly, isTrue);
      expect(engine.activeScaleFactor, 1.0); // not applied yet
    });

    test('accept suggestion applies scale', () {
      engine.fromReference(
        a: const Vec3(0, 0, 0),
        b: const Vec3(0.09, 0, 0),
        object: ReferenceObject.creditCard,
      );
      engine.acceptSuggestion();
      expect(engine.activeScaleFactor, isNot(1.0));
      expect(engine.apply(1.0), closeTo(engine.activeScaleFactor, 1e-9));
    });

    test('accuracy test 1 m', () {
      final result = engine.accuracyTest(
        a: const Vec3(0, 0, 0),
        b: const Vec3(1.02, 0, 0),
        knownLength: 1.0,
      );
      expect(result.errorPercent, closeTo(2.0, 0.1));
      expect(result.source, 'accuracyTest');
      expect(result.suggestedOnly, isTrue);
    });

    test('reset clears scale', () {
      engine.fromReference(
        a: const Vec3(0, 0, 0),
        b: const Vec3(0.09, 0, 0),
        object: ReferenceObject.creditCard,
      );
      engine.acceptSuggestion();
      engine.resetScale();
      expect(engine.activeScaleFactor, 1.0);
      expect(engine.lastResult, isNull);
    });

    test('reference library has expected sizes', () {
      expect(referenceLibrary[ReferenceObject.creditCard]!.lengthMeters,
          closeTo(0.08560, 1e-5));
      expect(referenceLibrary[ReferenceObject.a4Sheet]!.lengthMeters,
          closeTo(0.297, 1e-4));
    });
  });
}
