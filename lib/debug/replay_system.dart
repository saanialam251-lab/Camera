import 'dart:convert';
import '../ar/ar_models.dart';
import '../measure/vec3.dart';

/// Replay system – Section 13.3
/// Record AR sessions (pose, planes, depth) and replay deterministically.
class ReplayFrame {
  final double timestamp;
  final double x, y, z;
  final double trackingQuality;
  final double depthQuality;
  final double cameraSpeed;
  final double featureDensity;
  final double lighting;
  final bool hasPlane;
  final bool hasDepth;

  const ReplayFrame({
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
    this.trackingQuality = 0.9,
    this.depthQuality = 0.8,
    this.cameraSpeed = 0.1,
    this.featureDensity = 0.7,
    this.lighting = 0.8,
    this.hasPlane = true,
    this.hasDepth = true,
  });

  ArFrameSnapshot toSnapshot() => ArFrameSnapshot(
        hitPoint: Vec3(x, y, z),
        timestamp: timestamp,
        trackingQuality: trackingQuality,
        depthQuality: depthQuality,
        cameraSpeed: cameraSpeed,
        featureDensity: featureDensity,
        lighting: lighting,
        hasPlane: hasPlane,
        hasDepth: hasDepth,
      );

  Map<String, dynamic> toJson() => {
        't': timestamp,
        'x': x,
        'y': y,
        'z': z,
        'tq': trackingQuality,
        'dq': depthQuality,
        'cs': cameraSpeed,
        'fd': featureDensity,
        'lt': lighting,
        'plane': hasPlane,
        'depth': hasDepth,
      };

  factory ReplayFrame.fromJson(Map<String, dynamic> j) => ReplayFrame(
        timestamp: (j['t'] as num).toDouble(),
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        z: (j['z'] as num).toDouble(),
        trackingQuality: (j['tq'] as num?)?.toDouble() ?? 0.9,
        depthQuality: (j['dq'] as num?)?.toDouble() ?? 0.8,
        cameraSpeed: (j['cs'] as num?)?.toDouble() ?? 0.1,
        featureDensity: (j['fd'] as num?)?.toDouble() ?? 0.7,
        lighting: (j['lt'] as num?)?.toDouble() ?? 0.8,
        hasPlane: j['plane'] as bool? ?? true,
        hasDepth: j['depth'] as bool? ?? true,
      );
}

class ReplaySession {
  final String id;
  final String name;
  final List<ReplayFrame> frames;
  final Map<String, dynamic> metadata;

  const ReplaySession({
    required this.id,
    required this.name,
    required this.frames,
    this.metadata = const {},
  });

  String toJsonString() => jsonEncode({
        'id': id,
        'name': name,
        'metadata': metadata,
        'frames': frames.map((f) => f.toJson()).toList(),
      });

  factory ReplaySession.fromJsonString(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final frames = (j['frames'] as List<dynamic>)
        .map((e) => ReplayFrame.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ReplaySession(
      id: j['id'] as String? ?? 'unknown',
      name: j['name'] as String? ?? '',
      frames: frames,
      metadata: Map<String, dynamic>.from(j['metadata'] as Map? ?? {}),
    );
  }
}

/// Records frames during a live session.
class ReplayRecorder {
  final List<ReplayFrame> _frames = [];
  bool recording = false;

  void start() {
    _frames.clear();
    recording = true;
  }

  void add(ArFrameSnapshot snap) {
    if (!recording) return;
    _frames.add(ReplayFrame(
      timestamp: snap.timestamp,
      x: snap.hitPoint.x,
      y: snap.hitPoint.y,
      z: snap.hitPoint.z,
      trackingQuality: snap.trackingQuality,
      depthQuality: snap.depthQuality,
      cameraSpeed: snap.cameraSpeed,
      featureDensity: snap.featureDensity,
      lighting: snap.lighting,
      hasPlane: snap.hasPlane,
      hasDepth: snap.hasDepth,
    ));
  }

  ReplaySession stop({required String id, required String name}) {
    recording = false;
    return ReplaySession(id: id, name: name, frames: List.from(_frames));
  }
}

/// Replays a session deterministically into a callback.
class ReplayPlayer {
  final ReplaySession session;
  int index = 0;

  ReplayPlayer(this.session);

  bool get hasMore => index < session.frames.length;

  ArFrameSnapshot? next() {
    if (!hasMore) return null;
    return session.frames[index++].toSnapshot();
  }

  void reset() => index = 0;

  /// Play all frames into [onFrame].
  void playAll(void Function(ArFrameSnapshot) onFrame) {
    reset();
    while (hasMore) {
      final snap = next();
      if (snap != null) onFrame(snap);
    }
  }
}
