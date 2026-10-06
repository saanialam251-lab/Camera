import 'package:flutter/material.dart';
import '../../measure/confidence.dart';
import '../../core/units.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Result bottom sheet after measurement complete.
class ResultSheet extends StatelessWidget {
  final double distanceMeters;
  final ConfidenceResult confidence;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const ResultSheet({
    super.key,
    required this.distanceMeters,
    required this.confidence,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),
          Text(
            Units.formatStable(distanceMeters, unit: LengthUnit.m, decimals: 2),
            style: const TextStyle(
              fontSize: 40,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${confidence.level.name.toUpperCase()}  +/-${confidence.errorRangeMeters.toStringAsFixed(2)} m',
            style: TextStyle(
              color: confidence.level == ConfidenceLevel.high
                  ? AppColors.successGreen
                  : confidence.level == ConfidenceLevel.medium
                      ? AppColors.warningAmber
                      : AppColors.errorRed,
            ),
          ),
          if (confidence.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              confidence.reasons.join(' · '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(label: 'SAVE', onPressed: onSave),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onDiscard,
            child: const Text('Discard', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
