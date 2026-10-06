import 'package:flutter/material.dart';
import '../../measure/room_builder.dart';
import '../../measure/vec3.dart';
import '../theme.dart';

/// 2D Floor plan viewer  Section 4.5
/// Dimension labels, drag-to-edit corners (stub), door/window markers.
/// Export hooks for PNG/PDF/SVG (P5).
class FloorplanScreen extends StatelessWidget {
  final RoomResult room;

  const FloorplanScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: const Text('Floor Plan'),
        backgroundColor: AppColors.nearBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.accentCyan),
            onPressed: () {
              // P5: export PNG/PDF/SVG
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _stat('Length', '${room.length.toStringAsFixed(2)} m'),
                _stat('Width', '${room.width.toStringAsFixed(2)} m'),
                _stat('Height', '${room.height.toStringAsFixed(2)} m'),
                _stat('Area', '${room.floorArea.toStringAsFixed(2)} m2'),
                _stat('Volume', '${room.volume.toStringAsFixed(1)} m3'),
                if (room.isEstimate)
                  const Chip(
                    label: Text('Estimate'),
                    backgroundColor: Color(0x33FFB020),
                    labelStyle: TextStyle(color: AppColors.warningAmber, fontSize: 12),
                  ),
              ],
            ),
          ),
          // Coverage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Coverage', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: room.coveragePercent / 100,
                    backgroundColor: Colors.white12,
                    color: AppColors.accentCyan,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${room.coveragePercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.accentCyan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Plan canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: _FloorPlanPainter(room.floorPlan),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
      ],
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  final FloorPlan2D plan;

  _FloorPlanPainter(this.plan);

  @override
  void paint(Canvas canvas, Size size) {
    if (plan.corners.isEmpty) return;

    // Fit corners into canvas with padding
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
    final pad = 40.0;
    final scale = ((size.width - 2 * pad) / rangeX)
        .clamp(0.0, (size.height - 2 * pad) / rangeZ);

    Offset map(Vec3 v) {
      final x = pad + (v.x - minX) * scale;
      final y = pad + (v.z - minZ) * scale;
      return Offset(x, y);
    }

    final wallPaint = Paint()
      ..color = AppColors.accentCyan
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.accentCyan.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Fill
    final path = Path();
    final first = map(plan.corners.first);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < plan.corners.length; i++) {
      final o = map(plan.corners[i]);
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, wallPaint);

    // Dimension labels
    final textStyle = TextStyle(color: Colors.white70, fontSize: 11);
    for (var i = 0; i < plan.corners.length; i++) {
      final a = map(plan.corners[i]);
      final b = map(plan.corners[(i + 1) % plan.corners.length]);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final len = plan.edgeLengths.length > i
          ? plan.edgeLengths[i].toStringAsFixed(2)
          : '';
      final tp = TextPainter(
        text: TextSpan(text: '$len m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }

    // Door/window markers
    for (final m in plan.markers) {
      final o = map(m.position);
      final paint = Paint()
        ..color = m.isDoor ? AppColors.warningAmber : AppColors.successGreen
        ..style = PaintingStyle.fill;
      canvas.drawCircle(o, 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloorPlanPainter old) => old.plan != plan;
}
