import 'package:flutter/material.dart';
import '../theme.dart';

/// Pinch / drag fine-adjust for a point when the camera is soft or blurry.
/// User places approximate reticle, then pinches or drags to nudge the mark
/// before confirming START / SET END POINT.
class PinchMarkController extends ChangeNotifier {
  Offset offset = Offset.zero; // screen-space nudge from reticle
  double scale = 1.0;
  bool active = false;

  static const maxNudgePx = 48.0;

  void begin() {
    active = true;
    offset = Offset.zero;
    scale = 1.0;
    notifyListeners();
  }

  void end() {
    active = false;
    notifyListeners();
  }

  void reset() {
    offset = Offset.zero;
    scale = 1.0;
    notifyListeners();
  }

  void onScaleUpdate(ScaleUpdateDetails d) {
    if (!active) return;
    // Pan = fine position; scale = zoom assist for loupe
    offset += d.focalPointDelta;
    offset = Offset(
      offset.dx.clamp(-maxNudgePx, maxNudgePx),
      offset.dy.clamp(-maxNudgePx, maxNudgePx),
    );
    scale = (scale * d.scale).clamp(1.0, 3.0);
    // scale from details is cumulative per gesture — use focal only mainly
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails d) {
    if (!active) begin();
  }
}

/// Visual ring showing pinch-adjusted mark position.
class PinchMarkOverlay extends StatelessWidget {
  final Offset reticleCenter;
  final Offset nudge;
  final bool visible;

  const PinchMarkOverlay({
    super.key,
    required this.reticleCenter,
    required this.nudge,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final pos = reticleCenter + nudge;
    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 16,
      child: IgnorePointer(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.warningAmber, width: 2),
            color: AppColors.warningAmber.withOpacity(0.15),
          ),
          child: const Center(
            child: Icon(Icons.add, size: 16, color: AppColors.warningAmber),
          ),
        ),
      ),
    );
  }
}
