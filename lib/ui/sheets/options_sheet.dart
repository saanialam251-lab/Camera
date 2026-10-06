import 'package:flutter/material.dart';
import '../../measure/snap_engine.dart';
import '../theme.dart';

/// Options sheet  snap on/off + strength, axis lock, etc. (P2)
class OptionsSheet extends StatelessWidget {
  final bool snapEnabled;
  final SnapStrength snapStrength;
  final ValueChanged<bool> onSnapEnabled;
  final ValueChanged<SnapStrength> onSnapStrength;

  const OptionsSheet({
    super.key,
    required this.snapEnabled,
    required this.snapStrength,
    required this.onSnapEnabled,
    required this.onSnapStrength,
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
          const Text(
            'Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Snap (Edge / Corner)'),
            subtitle: const Text('Magnet to corners and edges'),
            value: snapEnabled,
            activeColor: AppColors.accentCyan,
            onChanged: onSnapEnabled,
          ),
          if (snapEnabled) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Text(
                'Snap strength',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            RadioListTile<SnapStrength>(
              title: const Text('Low (1.5 cm)'),
              value: SnapStrength.low,
              groupValue: snapStrength,
              activeColor: AppColors.accentCyan,
              onChanged: (v) => v != null ? onSnapStrength(v) : null,
            ),
            RadioListTile<SnapStrength>(
              title: const Text('Medium (3 cm)'),
              value: SnapStrength.medium,
              groupValue: snapStrength,
              activeColor: AppColors.accentCyan,
              onChanged: (v) => v != null ? onSnapStrength(v) : null,
            ),
            RadioListTile<SnapStrength>(
              title: const Text('High (5.5 cm)'),
              value: SnapStrength.high,
              groupValue: snapStrength,
              activeColor: AppColors.accentCyan,
              onChanged: (v) => v != null ? onSnapStrength(v) : null,
            ),
          ],
        ],
      ),
    );
  }
}
