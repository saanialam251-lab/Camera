import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../measure/models.dart';
import '../measure/confidence.dart';
import '../measure/vec3.dart';

/// Local measurement storage  Section 9
/// Values stored in meters. Auto-save drafts every point.
class MeasurementRepository {
  static const _key = 'measurements_v1';
  final List<Measurement> _cache = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _cache.clear();
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (final item in list) {
      try {
        _cache.add(_fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (_) {
        // skip corrupt entries
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_cache.map(_toJson).toList());
    await prefs.setString(_key, encoded);
  }

  List<Measurement> get all => List.unmodifiable(_cache);

  List<Measurement> get favorites =>
      _cache.where((m) => m.favorite).toList();

  List<Measurement> byProject(String projectId) =>
      _cache.where((m) => m.projectId == projectId).toList();

  Future<void> save(Measurement m) async {
    final idx = _cache.indexWhere((e) => e.id == m.id);
    if (idx >= 0) {
      _cache[idx] = m;
    } else {
      _cache.insert(0, m);
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((m) => m.id == id);
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _cache.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final m = _cache[idx];
    _cache[idx] = Measurement(
      id: m.id,
      name: m.name,
      mode: m.mode,
      createdAt: m.createdAt,
      updatedAt: DateTime.now(),
      points: m.points,
      segments: m.segments,
      totalDistance: m.totalDistance,
      totalArea: m.totalArea,
      totalPerimeter: m.totalPerimeter,
      totalVolume: m.totalVolume,
      totalAngle: m.totalAngle,
      displayUnit: m.displayUnit,
      precision: m.precision,
      confidence: m.confidence,
      deviceModel: m.deviceModel,
      arEngine: m.arEngine,
      depthType: m.depthType,
      osVersion: m.osVersion,
      scaleFactor: m.scaleFactor,
      scaleSource: m.scaleSource,
      thumbnailPath: m.thumbnailPath,
      screenshotPath: m.screenshotPath,
      notes: m.notes,
      tags: m.tags,
      projectId: m.projectId,
      favorite: !m.favorite,
      isDraft: m.isDraft,
    );
    await _persist();
  }

  Future<void> clearAll() async {
    _cache.clear();
    await _persist();
  }

  Map<String, dynamic> _toJson(Measurement m) => {
        'id': m.id,
        'name': m.name,
        'mode': m.mode.name,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
        'points': m.points.map((p) => p.toJson()).toList(),
        'segments': m.segments,
        'totalDistance': m.totalDistance,
        'totalArea': m.totalArea,
        'totalPerimeter': m.totalPerimeter,
        'totalVolume': m.totalVolume,
        'totalAngle': m.totalAngle,
        'displayUnit': m.displayUnit,
        'precision': m.precision,
        'confidenceScore': m.confidence.score,
        'confidenceLevel': m.confidence.level.name,
        'confidenceReasons': m.confidence.reasons,
        'errorRange': m.confidence.errorRangeMeters,
        'deviceModel': m.deviceModel,
        'arEngine': m.arEngine,
        'depthType': m.depthType,
        'osVersion': m.osVersion,
        'scaleFactor': m.scaleFactor,
        'scaleSource': m.scaleSource,
        'thumbnailPath': m.thumbnailPath,
        'screenshotPath': m.screenshotPath,
        'notes': m.notes,
        'tags': m.tags,
        'projectId': m.projectId,
        'favorite': m.favorite,
        'isDraft': m.isDraft,
      };

  Measurement _fromJson(Map<String, dynamic> j) {
    final levelName = j['confidenceLevel'] as String? ?? 'low';
    final level = ConfidenceLevel.values.firstWhere(
      (e) => e.name == levelName,
      orElse: () => ConfidenceLevel.low,
    );
    final modeName = j['mode'] as String? ?? 'distance';
    final mode = MeasureMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => MeasureMode.distance,
    );
    final pointsRaw = j['points'] as List<dynamic>? ?? [];
    final points = pointsRaw
        .map((e) => MeasurePoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Measurement(
      id: j['id'] as String,
      name: j['name'] as String? ?? '',
      mode: mode,
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      points: points,
      segments: (j['segments'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      totalDistance: (j['totalDistance'] as num?)?.toDouble(),
      totalArea: (j['totalArea'] as num?)?.toDouble(),
      totalPerimeter: (j['totalPerimeter'] as num?)?.toDouble(),
      totalVolume: (j['totalVolume'] as num?)?.toDouble(),
      totalAngle: (j['totalAngle'] as num?)?.toDouble(),
      displayUnit: j['displayUnit'] as String? ?? 'm',
      precision: j['precision'] as int? ?? 2,
      confidence: ConfidenceResult(
        score: j['confidenceScore'] as int? ?? 0,
        level: level,
        errorRangeMeters: (j['errorRange'] as num?)?.toDouble() ?? 0,
        reasons: (j['confidenceReasons'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      ),
      deviceModel: j['deviceModel'] as String? ?? '',
      arEngine: j['arEngine'] as String? ?? '',
      depthType: j['depthType'] as String? ?? 'none',
      osVersion: j['osVersion'] as String? ?? '',
      scaleFactor: (j['scaleFactor'] as num?)?.toDouble() ?? 1.0,
      scaleSource: j['scaleSource'] as String? ?? 'none',
      thumbnailPath: j['thumbnailPath'] as String?,
      screenshotPath: j['screenshotPath'] as String?,
      notes: j['notes'] as String? ?? '',
      tags: (j['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      projectId: j['projectId'] as String?,
      favorite: j['favorite'] as bool? ?? false,
      isDraft: j['isDraft'] as bool? ?? false,
    );
  }
}
