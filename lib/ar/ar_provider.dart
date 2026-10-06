import 'dart:async';
import 'package:flutter/services.dart';
import 'ar_models.dart';
import '../measure/vec3.dart';

/// Native channel provider for ARCore / ARKit.
/// Heavy work stays on native side; only immutable snapshots cross the channel.
class ArProvider {
  static const _channel = MethodChannel('measure_reality/ar');
  static const _eventChannel = EventChannel('measure_reality/ar_frames');

  StreamSubscription? _sub;
  final _controller = StreamController<ArFrameSnapshot>.broadcast();

  Stream<ArFrameSnapshot> get frames => _controller.stream;

  Future<ArSessionStatus> startSession() async {
    final map = await _channel.invokeMapMethod<String, dynamic>('startSession');
    if (map == null) {
      return const ArSessionStatus();
    }
    return ArSessionStatus(
      tracking: _parseTracking(map['tracking'] as String?),
      depthSupported: map['depthSupported'] as bool? ?? false,
      lidar: map['lidar'] as bool? ?? false,
      depthType: map['depthType'] as String? ?? 'none',
    );
  }

  Future<void> stopSession() async {
    await _sub?.cancel();
    _sub = null;
    await _channel.invokeMethod('stopSession');
  }

  void listenFrames() {
    _sub?.cancel();
    _sub = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        _controller.add(_parseSnapshot(Map<String, dynamic>.from(event)));
      }
    });
  }

  ArFrameSnapshot _parseSnapshot(Map<String, dynamic> m) {
    return ArFrameSnapshot(
      hitPoint: Vec3(
        (m['x'] as num).toDouble(),
        (m['y'] as num).toDouble(),
        (m['z'] as num).toDouble(),
      ),
      timestamp: (m['t'] as num).toDouble(),
      trackingQuality: (m['tq'] as num?)?.toDouble() ?? 0.5,
      depthQuality: (m['dq'] as num?)?.toDouble() ?? 0.3,
      cameraSpeed: (m['cs'] as num?)?.toDouble() ?? 0,
      featureDensity: (m['fd'] as num?)?.toDouble() ?? 0.5,
      lighting: (m['lt'] as num?)?.toDouble() ?? 0.5,
      hasPlane: m['plane'] as bool? ?? false,
      hasDepth: m['depth'] as bool? ?? false,
    );
  }

  ArTrackingState _parseTracking(String? s) {
    switch (s) {
      case 'normal':
        return ArTrackingState.normal;
      case 'limited':
        return ArTrackingState.limited;
      default:
        return ArTrackingState.notAvailable;
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
