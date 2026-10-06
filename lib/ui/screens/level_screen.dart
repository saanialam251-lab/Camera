import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../measure/level_engine.dart';
import '../../state/modes/level_mode.dart';
import '../theme.dart';
import '../widgets/bubble_level.dart';
import '../widgets/primary_button.dart';

/// Full Level & Vertical screen  Section 4.8
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final handler = LevelModeHandler();
  bool _wasLevel = false;

  @override
  void initState() {
    super.initState();
    // In production: listen to SensorFusion native channel
    // and call handler.onSensor(...)
  }

  @override
  Widget build(BuildContext context) {
    final reading = handler.reading();

    // Haptic tick when entering Level state
    if (reading.state == LevelState.level && !_wasLevel) {
      HapticFeedback.lightImpact();
    }
    _wasLevel = reading.state == LevelState.level;

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: const Text('Level'),
        backgroundColor: AppColors.nearBlack,
        actions: [
          TextButton(
            onPressed: () => setState(() => handler.calibrate()),
            child: const Text('Calibrate', style: TextStyle(color: AppColors.accentCyan)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: BubbleLevel(
                pitchDeg: reading.pitchDeg,
                rollDeg: reading.rollDeg,
                state: reading.state,
              ),
            ),
          ),
          Text(
            '${reading.tiltMagnitude.toStringAsFixed(1)} deg',
            style: const TextStyle(
              fontSize: 48,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reading.label,
            style: TextStyle(
              fontSize: 20,
              color: _colorFor(reading.state),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pitch ${reading.pitchDeg.toStringAsFixed(1)} deg  ·  Roll ${reading.rollDeg.toStringAsFixed(1)} deg',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PrimaryButton(
              label: reading.isLocked ? 'UNLOCK' : 'LOCK',
              onPressed: () {
                setState(() {
                  if (reading.isLocked) {
                    handler.unlock();
                  } else {
                    handler.lock();
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Surface'),
                selected: handler.inputMode == LevelInputMode.surface,
                onSelected: (_) =>
                    setState(() => handler.inputMode = LevelInputMode.surface),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Camera'),
                selected: handler.inputMode == LevelInputMode.camera,
                onSelected: (_) =>
                    setState(() => handler.inputMode = LevelInputMode.camera),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Color _colorFor(LevelState s) {
    switch (s) {
      case LevelState.level:
        return AppColors.successGreen;
      case LevelState.slightlyOff:
        return AppColors.warningAmber;
      case LevelState.tilted:
        return AppColors.errorRed;
    }
  }
}
