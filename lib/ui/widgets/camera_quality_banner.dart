import 'package:flutter/material.dart';
import '../../core/camera_quality.dart';
import '../theme.dart';

/// Shows camera viability: good / fair / poor / unusable.
class CameraQualityBanner extends StatelessWidget {
  final CameraQualityReport report;

  const CameraQualityBanner({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.level == CameraQualityLevel.good) {
      return const SizedBox.shrink();
    }

    final color = switch (report.level) {
      CameraQualityLevel.fair => AppColors.warningAmber,
      CameraQualityLevel.poor => AppColors.warningAmber,
      CameraQualityLevel.unusable => AppColors.errorRed,
      CameraQualityLevel.good => AppColors.successGreen,
    };

    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  report.level == CameraQualityLevel.unusable
                      ? Icons.videocam_off
                      : Icons.videocam,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.headline,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (report.tips.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...report.tips.take(3).map(
                    (t) => Text(
                      '• $t',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
            ],
            if (report.preferLoupe || report.preferPinch) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (report.preferLoupe) 'Loupe on',
                  if (report.preferPinch) 'Pinch to fine-adjust mark',
                ].join(' · '),
                style: const TextStyle(color: AppColors.accentCyan, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
