import '../../measure/room_builder.dart';
import '../../measure/vec3.dart';

/// SVG floor plan exporter  Section 4.5 / 9.3
class SvgFloorplanExporter {
  static String export(FloorPlan2D plan, {double padding = 40}) {
    if (plan.corners.isEmpty) {
      return '<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" '
          'width="200" height="200"/>';
    }

    double minX = double.infinity, maxX = -double.infinity;
    double minZ = double.infinity, maxZ = -double.infinity;
    for (final c in plan.corners) {
      if (c.x < minX) minX = c.x;
      if (c.x > maxX) maxX = c.x;
      if (c.z < minZ) minZ = c.z;
      if (c.z > maxZ) maxZ = c.z;
    }
    final rangeX = (maxX - minX).clamp(0.01, double.infinity);
    final rangeZ = (maxZ - minZ).clamp(0.01, double.infinity);
    const scale = 100.0;
    final width = rangeX * scale + 2 * padding;
    final height = rangeZ * scale + 2 * padding;

    String map(Vec3 v) {
      final x = padding + (v.x - minX) * scale;
      final y = padding + (v.z - minZ) * scale;
      return '${x.toStringAsFixed(1)},${y.toStringAsFixed(1)}';
    }

    final points = plan.corners.map(map).join(' ');
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buf.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${width.toStringAsFixed(0)}" height="${height.toStringAsFixed(0)}" '
      'viewBox="0 0 ${width.toStringAsFixed(0)} ${height.toStringAsFixed(0)}">',
    );
    buf.writeln('<rect width="100%" height="100%" fill="#0B0E14"/>');
    buf.writeln(
      '<polygon points="$points" fill="#3DD6F518" stroke="#3DD6F5" stroke-width="2"/>',
    );

    for (var i = 0; i < plan.corners.length; i++) {
      final a = plan.corners[i];
      final b = plan.corners[(i + 1) % plan.corners.length];
      final mx = padding + ((a.x + b.x) / 2 - minX) * scale;
      final my = padding + ((a.z + b.z) / 2 - minZ) * scale;
      final len = plan.edgeLengths.length > i
          ? plan.edgeLengths[i].toStringAsFixed(2)
          : '';
      buf.writeln(
        '<text x="${mx.toStringAsFixed(1)}" y="${my.toStringAsFixed(1)}" '
        'fill="#ffffffb3" font-size="12" text-anchor="middle">$len m</text>',
      );
    }

    for (final m in plan.markers) {
      final pos = map(m.position).split(',');
      final color = m.isDoor ? '#FFB020' : '#3EE08F';
      buf.writeln(
        '<circle cx="${pos[0]}" cy="${pos[1]}" r="5" fill="$color"/>',
      );
    }

    buf.writeln('</svg>');
    return buf.toString();
  }
}
