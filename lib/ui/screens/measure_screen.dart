import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/measure_controller.dart';
import '../../measure/models.dart';
import '../../measure/confidence.dart';
import '../../core/units.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/confidence_badge.dart';

/// Camera / measurement screen – Section 6.3
/// UI only reads state. Never touches AR render loop.
class MeasureScreen extends ConsumerStatefulWidget {
  const MeasureScreen({super.key});

  @override
  ConsumerState<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends ConsumerState<MeasureScreen> {
  @override
  void initState() {
    super.initState();
    // In production: start AR session + listen to frames → controller.onFrame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = ref.read(measureControllerProvider.notifier);
      ctrl.startScanning();
      // Simulate ready after short scan
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) ctrl.setReady();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(measureControllerProvider);
    final ctrl = ref.read(measureControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // AR view would sit here (Texture / PlatformView)
          const Center(
            child: Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white24),
          ),

          // Center reticle
          Center(
            child: _Reticle(state: live.state),
          ),

          // Bottom stack
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (live.state != MeasureWorkflowState.idle &&
                    live.state != MeasureWorkflowState.scanning) ...[
                  Text(
                    Units.formatStable(
                      live.distanceMeters,
                      unit: LengthUnit.m,
                      decimals: 2,
                    ),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConfidenceBadge(
                    level: live.confidence.level,
                    errorRange: live.confidence.errorRangeMeters,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  live.instruction,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: live.primaryLabel,
                  enabled: live.primaryEnabled,
                  showProgress: live.showProgress,
                  onPressed: () => _onPrimary(ctrl, live.state),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Undo', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Redo', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        ctrl.reset();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mode', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPrimary(MeasureController ctrl, MeasureWorkflowState state) {
    switch (state) {
      case MeasureWorkflowState.ready:
        ctrl.lockStart();
        break;
      case MeasureWorkflowState.stretching:
      case MeasureWorkflowState.endPreview:
        ctrl.lockEnd();
        break;
      case MeasureWorkflowState.complete:
        // save then pop
        ctrl.reset();
        Navigator.pop(context);
        break;
      case MeasureWorkflowState.trackingLost:
      case MeasureWorkflowState.paused:
        ctrl.resumeTracking();
        break;
      default:
        break;
    }
  }
}

class _Reticle extends StatelessWidget {
  final MeasureWorkflowState state;
  const _Reticle({required this.state});

  @override
  Widget build(BuildContext context) {
    Color ring;
    switch (state) {
      case MeasureWorkflowState.scanning:
      case MeasureWorkflowState.trackingLost:
        ring = Colors.grey;
        break;
      case MeasureWorkflowState.ready:
        ring = AppColors.accentCyan;
        break;
      case MeasureWorkflowState.stretching:
      case MeasureWorkflowState.endPreview:
        ring = AppColors.successGreen;
        break;
      default:
        ring = AppColors.accentCyan;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring.withOpacity(0.6), width: 2),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
