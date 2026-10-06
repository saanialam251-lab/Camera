import 'package:flutter/material.dart';
import '../measure/snap_engine.dart';
import 'theme.dart';

/// AR overlay painter  markers, line, labels, reticle.
/// Screen-space for MVP; world-to-screen projection is supplied by caller.
class OverlayPainter extends CustomPainter {
  final Offset? startScreen;
  final Offset? endScreen;
  final Offset? reticleScreen;
  final String? distanceLabel;
  final Color lineColor;
  final SnapType snapType;
  final Offset? snapPullFrom;
  final bool showReticle;
  final Color reticleColor;

  OverlayPainter({
    this.startScreen,
    this.endScreen,
    this.reticleScreen,
    this.distanceLabel,
    this.lineColor = AppColors.accentCyan,
    this.snapType = SnapType.none,
    this.snapPullFrom,
    this.showReticle = true,
    this.reticleColor = AppColors.accentCyan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (snapPullFrom != null &&
        reticleScreen != null &&
        snapType != SnapType.none) {
      final pullPaint = Paint()
        ..color = AppColors.warningAmber.withOpacity(0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(snapPullFrom!, reticleScreen!, pullPaint);
    }

    if (startScreen != null && endScreen != null) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startScreen!, endScreen!, linePaint);
      _drawMarker(canvas, startScreen!, AppColors.successGreen);
      _drawMarker(canvas, endScreen!, lineColor);

      if (distanceLabel != null) {
        final mid = Offset(
          (startScreen!.dx + endScreen!.dx) / 2,
          (startScreen!.dy + endScreen!.dy) / 2 - 16,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: distanceLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
      }
    } else if (startScreen != null) {
      _drawMarker(canvas, startScreen!, AppColors.successGreen);
    }

    if (showReticle && reticleScreen != null) {
      _drawReticle(canvas, reticleScreen!, reticleColor);
    }
  }

  void _drawMarker(Canvas canvas, Offset o, Color color) {
    canvas.drawCircle(o, 8, Paint()..color = color.withOpacity(0.3));
    canvas.drawCircle(o, 5, Paint()..color = color);
    canvas.drawCircle(
      o,
      5,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawReticle(Canvas canvas, Offset o, Color color) {
    final ring = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(o, 28, ring);
    canvas.drawCircle(o, 4, Paint()..color = color);
    final cross = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(o.dx - 14, o.dy), Offset(o.dx + 14, o.dy), cross);
    canvas.drawLine(Offset(o.dx, o.dy - 14), Offset(o.dx, o.dy + 14), cross);
  }

  @override
  bool shouldRepaint(covariant OverlayPainter old) =>
      old.startScreen != startScreen ||
      old.endScreen != endScreen ||
      old.reticleScreen != reticleScreen ||
      old.distanceLabel != distanceLabel ||
      old.snapType != snapType ||
      old.reticleColor != reticleColor;
}
