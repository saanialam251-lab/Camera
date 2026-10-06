import 'package:flutter/material.dart';
import '../theme.dart';

/// Help sheet  the "?" explanations on every setting and mode.
/// Plain-language + optional "Advanced information" expander.
class HelpSheet extends StatelessWidget {
  final String title;
  final String body;
  final String? advanced;

  const HelpSheet({
    super.key,
    required this.title,
    required this.body,
    this.advanced,
  });

  /// Convenience: show as modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    String? advanced,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HelpSheet(title: title, body: body, advanced: advanced),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.accentCyan, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
          ),
          if (advanced != null) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Advanced information',
                  style: TextStyle(fontSize: 14, color: AppColors.accentCyan),
                ),
                children: [
                  Text(
                    advanced!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pre-written help content for common settings.
class HelpContent {
  static const snap = (
    title: 'Snap (Edge / Corner)',
    body:
        'When enabled, the reticle gently pulls toward nearby corners and edges so you can place points more precisely. '
        'A thin line shows the pull direction. You can undo a snap with one tap.',
    advanced:
        'Snap radius: Low 1.5 cm, Medium 3 cm, High 5.5 cm. '
        'Priority order: corner ' edge ' plane feature. '
        'Snap never auto-commits the endpoint.',
  );

  static const precision = (
    title: 'Precision Mode',
    body:
        'Uses more samples (3060 frames) and optional Kalman filtering when you lock a point. '
        'Slower but more stable for critical measurements.',
    advanced:
        'Median-of-N drops the top and bottom 10% of samples before averaging. '
        'Display hysteresis prevents digit flicker.',
  );

  static const confidence = (
    title: 'Confidence',
    body:
        'Every measurement shows High / Medium / Low confidence and an error range (for example 2.37 m +/- 0.03 m). '
        'Tap the badge to see why (fast movement, low light, etc.).',
    advanced:
        'Weighted: tracking 30%, depth source 25%, camera speed 15%, features/lighting 15%, variance 10%, distance 5%.',
  );

  static const endpoint = (
    title: 'Why isn\'t the endpoint automatic?',
    body:
        'The app never auto-locks the endpoint. Only the SET END POINT button (or a deliberate tap) commits it. '
        'This avoids accidental measurements when the phone moves.',
    advanced: null,
  );

  static const handMark = (
    title: 'Hand mark (basic method)',
    body:
        'The basic reliable way to measure is to aim the reticle at any visible point and tap START or SET END POINT. '
        'You do not need a corner or edge. Use your hand (the phone reticle) to choose start and end. '
        'Corners and snap are optional assist only — turn Snap Off for pure freehand marks.',
    advanced:
        'Endpoint is never auto-locked. Only the SET END POINT button commits. Undo removes the last mark or snap.',
  );

  static const roomCorners = (
    title: 'Room corners and walls',
    body:
        'In a room, mark walls by aiming and tapping. Corners are useful for rectangular rooms but not required. '
        'You may mark several points along a long wall, or mix corners with mid-edge points. '
        'If a corner is wrong: Undo, stand closer, aim again, and tap — correct by hand.',
    advanced:
        'Snap can gently pull toward a detected corner; one-tap undo clears a bad snap. Coverage meter tracks floor scan quality.',
  );

}
