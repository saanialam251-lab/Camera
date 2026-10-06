import 'package:flutter/material.dart';
import '../../core/logger.dart';
import '../../core/perf_governor.dart';
import '../theme.dart';

/// Debug overlay  hidden, activated by tapping version 7 times (Section 10).
/// Shows FPS, frame time, quality level, tracking, sensor info.
class DebugOverlay extends StatelessWidget {
  final double fps;
  final double frameTimeMs;
  final QualityState quality;
  final String trackingState;
  final String depthSource;
  final int sampleCount;
  final VoidCallback? onClose;

  const DebugOverlay({
    super.key,
    required this.fps,
    required this.frameTimeMs,
    required this.quality,
    this.trackingState = '',
    this.depthSource = '',
    this.sampleCount = 0,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      child: Material(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.white70,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('DEBUG', style: TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, size: 14, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('FPS  ${fps.toStringAsFixed(1)}'),
                Text('Frame ${frameTimeMs.toStringAsFixed(1)} ms'),
                Text('Quality ${quality.label}'),
                Text('Track  $trackingState'),
                Text('Depth  $depthSource'),
                Text('Samples $sampleCount'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    AppLogger.verbose = !AppLogger.verbose;
                  },
                  child: Text(
                    'Verbose ${AppLogger.verbose ? "ON" : "OFF"}',
                    style: TextStyle(
                      color: AppLogger.verbose
                          ? AppColors.successGreen
                          : Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mixin / helper: count taps on version string to unlock debug.
class DebugUnlock {
  static int _taps = 0;
  static DateTime? _lastTap;

  /// Call from version ListTile onTap. Returns true when unlocked.
  static bool tap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) > const Duration(seconds: 3)) {
      _taps = 0;
    }
    _lastTap = now;
    _taps++;
    if (_taps >= 7) {
      _taps = 0;
      return true;
    }
    return false;
  }

  static void reset() => _taps = 0;
}
