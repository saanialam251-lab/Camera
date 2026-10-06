import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'measurement_repository.dart';
import 'project_repository.dart';

/// Backup / Restore  Section 5.14
class BackupService {
  final MeasurementRepository measurements;
  final ProjectRepository projects;

  BackupService({
    required this.measurements,
    required this.projects,
  });

  Future<String> exportJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final path = '${dir.path}/measure_reality_backup_$ts.json';

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'measurements': measurements.all.map((m) {
        return {
          'id': m.id,
          'name': m.name,
          'mode': m.mode.name,
          'totalDistance': m.totalDistance,
          'totalArea': m.totalArea,
          'totalAngle': m.totalAngle,
          'confidenceScore': m.confidence.score,
          'notes': m.notes,
          'tags': m.tags,
          'projectId': m.projectId,
          'favorite': m.favorite,
          'createdAt': m.createdAt.toIso8601String(),
        };
      }).toList(),
      'projects': projects.all.map((p) => p.toJson()).toList(),
    };

    final file = File(path);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return path;
  }

  Future<int> restoreJson(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;
    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    var count = 0;

    final projs = map['projects'] as List<dynamic>? ?? [];
    for (final item in projs) {
      try {
        final p = Project.fromJson(Map<String, dynamic>.from(item as Map));
        await projects.save(p);
        count++;
      } catch (_) {}
    }
    return count;
  }
}
