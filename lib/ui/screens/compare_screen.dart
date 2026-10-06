import 'package:flutter/material.dart';
import '../../measure/models.dart';
import '../../measure/room_builder.dart';
import '../../measure/vec3.dart';
import '../theme.dart';

/// Compare mode  Section 5.15
class CompareScreen extends StatelessWidget {
  final Measurement a;
  final Measurement b;
  final FloorPlan2D? planA;
  final FloorPlan2D? planB;

  const CompareScreen({
    super.key,
    required this.a,
    required this.b,
    this.planA,
    this.planB,
  });

  @override
  Widget build(BuildContext context) {
    final distA = a.totalDistance;
    final distB = b.totalDistance;
    final areaA = a.totalArea;
    final areaB = b.totalArea;

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: const Text('Compare'),
        backgroundColor: AppColors.nearBlack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _card('A', a.name, distA, areaA)),
              const SizedBox(width: 12),
              Expanded(child: _card('B', b.name, distB, areaB)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Difference',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (distA != null && distB != null && distA > 0)
            _diffRow('Distance', distA, distB, 'm'),
          if (areaA != null && areaB != null && areaA > 0)
            _diffRow('Area', areaA, areaB, 'm2'),
          if (a.totalAngle != null && b.totalAngle != null)
            _diffRow('Angle', a.totalAngle!, b.totalAngle!, ' deg'),
          if (planA != null && planB != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Floor plan overlay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan A in cyan, Plan B in amber',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: CustomPaint(
                painter: _ComparePlanPainter(planA!, planB!),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(String label, String name, double? dist, double? area) {
    return Card(
      color: AppColors.glass,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              name.isEmpty ? 'Untitled' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (dist != null)
              Text(
                '${dist.toStringAsFixed(2)} m',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            if (area != null)
              Text(
                '${area.toStringAsFixed(2)} m2',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _diffRow(String label, double aVal, double bVal, String unit) {
    final delta = bVal - aVal;
    final pct = delta / aVal * 100;
    final color = delta.abs() < aVal * 0.02
        ? AppColors.successGreen
        : AppColors.warningAmber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(3)} $unit',
            style: TextStyle(fontFamily: 'monospace', color: color),
          ),
          const SizedBox(width: 12),
          Text(
            '(${pct >= 0 ? "+" : ""}${pct.toStringAsFixed(1)}%)',
            style: TextStyle(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ComparePlanPainter extends CustomPainter {
  final FloorPlan2D a;
  final FloorPlan2D b;

  _ComparePlanPainter(this.a, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    void drawPlan(FloorPlan2D plan, Color color) {
      if (plan.corners.isEmpty) return;
      double minX = double.infinity, maxX = -double.infinity;
      double minZ = double.infinity, maxZ = -double.infinity;
      for (final c in [...a.corners, ...b.corners]) {
        if (c.x < minX) minX = c.x;
        if (c.x > maxX) maxX = c.x;
        if (c.z < minZ) minZ = c.z;
        if (c.z > maxZ) maxZ = c.z;
      }
      final rangeX = (maxX - minX).clamp(0.01, double.infinity);
      final rangeZ = (maxZ - minZ).clamp(0.01, double.infinity);
      const pad = 20.0;
      final scale = ((size.width - 2 * pad) / rangeX)
          .clamp(0.0, (size.height - 2 * pad) / rangeZ);

      final path = Path();
      for (var i = 0; i < plan.corners.length; i++) {
        final c = plan.corners[i];
        final o = Offset(
          pad + (c.x - minX) * scale,
          pad + (c.z - minZ) * scale,
        );
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    drawPlan(a, AppColors.accentCyan);
    drawPlan(b, AppColors.warningAmber);
  }

  @override
  bool shouldRepaint(covariant _ComparePlanPainter old) =>
      old.a != a || old.b != b;
}
