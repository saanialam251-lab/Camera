import 'package:flutter/material.dart';
import 'theme.dart';

/// AR grid overlay painter  P2
/// Spacing, units, opacity from settings.
/// Drawn only when Adaptive Quality allows (Level 01).
class GridPainter extends CustomPainter {
  final double spacingMeters;
  final double opacity;
  final int majorEvery; // thicker line every N

  GridPainter({
    this.spacingMeters = 0.5,
    this.opacity = 0.25,
    this.majorEvery = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentCyan.withOpacity(opacity)
      ..strokeWidth = 1;

    final majorPaint = Paint()
      ..color = AppColors.accentCyan.withOpacity(opacity * 1.6)
      ..strokeWidth = 1.5;

    // Simple screen-space grid (world-aligned grid needs camera projection  P3)
    final step = size.width / 8; // approximate visual spacing
    var i = 0;
    for (double x = 0; x <= size.width; x += step) {
      final p = (i % majorEvery == 0) ? majorPaint : paint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      i++;
    }
    i = 0;
    for (double y = 0; y <= size.height; y += step) {
      final p = (i % majorEvery == 0) ? majorPaint : paint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.spacingMeters != spacingMeters ||
      old.opacity != opacity ||
      old.majorEvery != majorEvery;
}
