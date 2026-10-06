import 'package:flutter_test/flutter_test.dart';
import 'package:measure_reality/measure/models.dart';
import 'package:measure_reality/measure/confidence.dart';
import 'package:measure_reality/measure/vec3.dart';
import 'package:measure_reality/measure/room_builder.dart';
import 'package:measure_reality/measure/estimators.dart';
import 'package:measure_reality/core/fractions.dart';
import 'package:measure_reality/data/exporters/csv_exporter.dart';
import 'package:measure_reality/data/exporters/json_exporter.dart';
import 'package:measure_reality/data/exporters/svg_floorplan_exporter.dart';

Measurement _sample() {
  return Measurement(
    id: 'test-1',
    name: 'Sample',
    mode: MeasureMode.distance,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    points: [
      const MeasurePoint(id: 'p1', label: 'A', world: Vec3(0, 0, 0)),
      const MeasurePoint(id: 'p2', label: 'B', world: Vec3(1, 0, 0)),
    ],
    totalDistance: 1.0,
    confidence: const ConfidenceResult(
      score: 85,
      level: ConfidenceLevel.high,
      errorRangeMeters: 0.02,
      reasons: [],
    ),
  );
}

void main() {
  group('CsvExporter', () {
    test('exports header and row', () {
      final csv = CsvExporter.export([_sample()]);
      expect(csv, contains('id,name,mode'));
      expect(csv, contains('test-1'));
      expect(csv, contains('1.0000'));
    });
  });

  group('JsonExporter', () {
    test('exports valid structure', () {
      final json = JsonExporter.export(_sample());
      expect(json, contains('"schemaVersion": 1'));
      expect(json, contains('"distance_m": 1.0'));
      expect(json, contains('"score": 85'));
    });

    test('exportMany has count', () {
      final json = JsonExporter.exportMany([_sample(), _sample()]);
      expect(json, contains('"count": 2'));
    });
  });

  group('SvgFloorplanExporter', () {
    test('exports svg with polygon', () {
      final plan = FloorPlan2D(
        corners: const [
          Vec3(0, 0, 0),
          Vec3(4, 0, 0),
          Vec3(4, 0, 3),
          Vec3(0, 0, 3),
        ],
        edgeLengths: const [4, 3, 4, 3],
        area: 12,
        perimeter: 14,
      );
      final svg = SvgFloorplanExporter.export(plan);
      expect(svg, contains('<svg'));
      expect(svg, contains('<polygon'));
      expect(svg, contains('4.00 m'));
    });
  });

  group('Estimators', () {
    test('paint with waste', () {
      final e = Estimators.paint(areaM2: 50, coveragePerLiter: 10, wastePercent: 10);
      expect(e.litersNeeded, closeTo(5.5, 0.01));
      expect(e.cansRounded, 6);
    });

    test('flooring rounds up', () {
      final e = Estimators.flooring(areaM2: 20, coveragePerBox: 2.5, wastePercent: 10);
      expect(e.boxesRounded, greaterThanOrEqualTo(9));
    });

    test('parcel volumetric weight', () {
      final e = Estimators.parcel(lengthM: 0.5, widthM: 0.4, heightM: 0.3);
      expect(e.volumeCm3, closeTo(60000, 1));
      expect(e.volumetricWeightKg, closeTo(12.0, 0.1));
    });

    test('net area', () {
      expect(Estimators.netArea(20, [2, 3]), closeTo(15, 0.01));
      expect(Estimators.netArea(5, [10]), 0);
    });
  });

  group('FractionFormat', () {
    test('formats mixed fraction', () {
      // 3.625 inches = 3 5/8
      final s = FractionFormat.inchesToFraction(3.625, denom: FractionDenom.eighth);
      expect(s, contains('3'));
      expect(s, contains('5/8'));
    });

    test('round trip parse', () {
      final m = FractionFormat.fractionInchesToMeters('3 5/8');
      expect(m, isNotNull);
      expect(m!, closeTo(3.625 * 0.0254, 1e-6));
    });
  });
}
