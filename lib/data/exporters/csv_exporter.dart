import '../../measure/models.dart';

/// CSV exporter  Section 9.3
class CsvExporter {
  static String export(List<Measurement> items) {
    final buf = StringBuffer();
    buf.writeln(
      'id,name,mode,distance_m,area_m2,angle_deg,confidence,error_m,created,notes,tags',
    );
    for (final m in items) {
      final tags = m.tags.join(';');
      buf.writeln([
        _esc(m.id),
        _esc(m.name),
        m.mode.name,
        m.totalDistance?.toStringAsFixed(4) ?? '',
        m.totalArea?.toStringAsFixed(4) ?? '',
        m.totalAngle?.toStringAsFixed(2) ?? '',
        m.confidence.score,
        m.confidence.errorRangeMeters.toStringAsFixed(4),
        m.createdAt.toIso8601String(),
        _esc(m.notes),
        _esc(tags),
      ].join(','));
    }
    return buf.toString();
  }

  static String exportSingle(Measurement m) => export([m]);

  static String _esc(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
