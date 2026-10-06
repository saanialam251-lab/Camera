import 'package:flutter/material.dart';
import '../../measure/models.dart';
import '../theme.dart';

/// Mode picker  horizontal chip carousel + "More" bottom sheet.
/// Each mode: icon, name, one-liner, ? help.
class ModeSheet extends StatelessWidget {
  final MeasureMode current;
  final ValueChanged<MeasureMode> onSelect;

  const ModeSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  static const _modes = [
    (MeasureMode.distance, Icons.straighten, 'Distance', 'Two-point length'),
    (MeasureMode.path, Icons.timeline, 'Path', 'Multi-point path length'),
    (MeasureMode.height, Icons.height, 'Height', 'Vertical measurement'),
    (MeasureMode.area, Icons.crop_square, 'Area', 'Polygon or rectangle'),
    (MeasureMode.angle, Icons.architecture, 'Angle', 'Three-point angle'),
    (MeasureMode.level, Icons.architecture_outlined, 'Level', 'Bubble level & plumb'),
  ];

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
            'Measure Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._modes.map((m) {
            final selected = m.$1 == current;
            return ListTile(
              leading: Icon(
                m.$2,
                color: selected ? AppColors.accentCyan : AppColors.textSecondary,
              ),
              title: Text(
                m.$3,
                style: TextStyle(
                  color: selected ? AppColors.accentCyan : Colors.white,
                ),
              ),
              subtitle: Text(
                m.$4,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check, color: AppColors.accentCyan)
                  : IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {},
                    ),
              onTap: () {
                onSelect(m.$1);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
