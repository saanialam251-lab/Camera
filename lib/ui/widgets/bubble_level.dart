import 'package:flutter/material.dart';
import '../../measure/level_engine.dart';
import '../theme.dart';

/// Circular bubble level widget  works with color AND without (text state).
class BubbleLevel extends StatelessWidget {
  final double pitchDeg;
  final double rollDeg;
  final LevelState state;
  final double size;

  const BubbleLevel({
    super.key,
    required this.pitchDeg,
    required this.rollDeg,
    required this.state,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Map degrees to pixel offset (clamp visual range +/-10 deg)
    final maxDeg = 10.0;
    final dx = (rollDeg / maxDeg).clamp(-1.0, 1.0) * (size * 0.35);
    final dy = (pitchDeg / maxDeg).clamp(-1.0, 1.0) * (size * 0.35);

    final ringColor = switch (state) {
      LevelState.level => AppColors.successGreen,
      LevelState.slightlyOff => AppColors.warningAmber,
      LevelState.tilted => AppColors.errorRed,
    };

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BubblePainter(
          bubbleOffset: Offset(dx, dy),
          ringColor: ringColor,
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Offset bubbleOffset;
  final Color ringColor;

  _BubblePainter({required this.bubbleOffset, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer ring
    final ringPaint = Paint()
      ..color = ringColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // Center crosshair
    final crossPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - 12, center.dy),
      Offset(center.dx + 12, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 12),
      Offset(center.dx, center.dy + 12),
      crossPaint,
    );

    // Target circle
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = ringColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Bubble
    final bubbleCenter = center + bubbleOffset;
    canvas.drawCircle(
      bubbleCenter,
      14,
      Paint()..color = ringColor.withOpacity(0.9),
    );
    canvas.drawCircle(
      bubbleCenter,
      14,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.bubbleOffset != bubbleOffset || old.ringColor != ringColor;
}
