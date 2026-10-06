import 'package:flutter/material.dart';
import '../theme.dart';

/// Magnifier Loupe  Section 5.2
/// Small zoom circle around the reticle when holding still, for pixel-precise points.
class Loupe extends StatelessWidget {
  final bool visible;
  final double zoom; // 2.03.0 typical
  final Size size;

  const Loupe({
    super.key,
    required this.visible,
    this.zoom = 2.5,
    this.size = const Size(100, 100),
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return IgnorePointer(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentCyan.withOpacity(0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // In production: RawImage / Texture of magnified camera region
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '${zoom.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Crosshair
            CustomPaint(painter: _LoupeCrosshairPainter()),
          ],
        ),
      ),
    );
  }
}

class _LoupeCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentCyan.withOpacity(0.7)
      ..strokeWidth = 1;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(c.dx - 12, c.dy), Offset(c.dx + 12, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - 12), Offset(c.dx, c.dy + 12), paint);
    canvas.drawCircle(
      c,
      3,
      Paint()..color = AppColors.accentCyan,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
