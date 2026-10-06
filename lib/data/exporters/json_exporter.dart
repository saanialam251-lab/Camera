import 'dart:convert';
import '../../measure/models.dart';

/// JSON exporter  documented schema, Section 9.3
class JsonExporter {
  static const schemaVersion = 1;

  static Map<String, dynamic> toMap(Measurement m) => {
        'schemaVersion': schemaVersion,
        'id': m.id,
        'name': m.name,
        'mode': m.mode.name,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
        'points': m.points.map((p) => p.toJson()).toList(),
        'segments': m.segments,
        'totals': {
          'distance_m': m.totalDistance,
          'area_m2': m.totalArea,
          'perimeter_m': m.totalPerimeter,
          'volume_m3': m.totalVolume,
          'angle_deg': m.totalAngle,
        },
        'displayUnit': m.displayUnit,
        'precision': m.precision,
        'confidence': {
          'score': m.confidence.score,
          'level': m.confidence.level.name,
          'errorRange_m': m.confidence.errorRangeMeters,
          'reasons': m.confidence.reasons,
        },
        'device': {
          'model': m.deviceModel,
          'arEngine': m.arEngine,
          'depthType': m.depthType,
          'os': m.osVersion,
        },
        'calibration': {
          'scaleFactor': m.scaleFactor,
          'source': m.scaleSource,
        },
        'notes': m.notes,
        'tags': m.tags,
        'projectId': m.projectId,
        'favorite': m.favorite,
      };

  static String export(Measurement m, {bool pretty = true}) {
    final map = toMap(m);
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(map);
    }
    return jsonEncode(map);
  }

  static String exportMany(List<Measurement> items, {bool pretty = true}) {
    final list = items.map(toMap).toList();
    final payload = {
      'schemaVersion': schemaVersion,
      'count': list.length,
      'measurements': list,
    };
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(payload);
    }
    return jsonEncode(payload);
  }
}
