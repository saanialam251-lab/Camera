import 'package:flutter/material.dart';
import '../../measure/confidence.dart';
import '../theme.dart';

class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel level;
  final double errorRange;

  const ConfidenceBadge({
    super.key,
    required this.level,
    required this.errorRange,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      ConfidenceLevel.high => ('High', AppColors.successGreen),
      ConfidenceLevel.medium => ('Medium', AppColors.warningAmber),
      ConfidenceLevel.low => ('Low', AppColors.errorRed),
    };

    return Text(
      '$label  ±${errorRange.toStringAsFixed(2)} m',
      style: TextStyle(color: color, fontSize: 14),
    );
  }
}
