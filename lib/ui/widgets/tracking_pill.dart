import 'package:flutter/material.dart';
import '../../ar/ar_models.dart';
import '../theme.dart';

/// Small tracking status pill shown on camera screen.
class TrackingPill extends StatelessWidget {
  final ArTrackingState tracking;
  final String? performanceLabel;

  const TrackingPill({
    super.key,
    required this.tracking,
    this.performanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tracking) {
      ArTrackingState.normal => ('Tracking', AppColors.successGreen),
      ArTrackingState.limited => ('Limited', AppColors.warningAmber),
      ArTrackingState.notAvailable => ('No tracking', AppColors.errorRed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          if (performanceLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              performanceLabel!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
