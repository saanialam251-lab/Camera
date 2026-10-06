import 'dart:async';
import 'dart:math' as math;
import 'ar_models.dart';
import '../measure/vec3.dart';

/// Simulator AR provider for development without a physical device.
class MockArProvider {
  final _controller = StreamController<ArFrameSnapshot>.broadcast();
  Timer? _timer;
  double _t = 0;
  final _rng = math.Random(42);

  Stream<ArFrameSnapshot> get frames => _controller.stream;

  Future<ArSessionStatus> startSession() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _t += 0.016;
      // Simulate a slowly moving hit point with noise
      final noise = (_rng.nextDouble() - 0.5) * 0.002;
      final x = 0.5 + math.sin(_t * 0.3) * 0.4 + noise;
      final y = 0.0;
      final z = -1.2 + math.cos(_t * 0.2) * 0.1 + noise;

      _controller.add(ArFrameSnapshot(
        hitPoint: Vec3(x, y, z),
        timestamp: _t,
        trackingQuality: 0.92,
        depthQuality: 0.85,
        cameraSpeed: 0.05 + _rng.nextDouble() * 0.1,
        featureDensity: 0.7,
        lighting: 0.8,
        hasPlane: true,
        hasDepth: true,
      ));
    });
    return const ArSessionStatus(
      tracking: ArTrackingState.normal,
      depthSupported: true,
      depthType: 'simulated',
    );
  }

  Future<void> stopSession() async {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
