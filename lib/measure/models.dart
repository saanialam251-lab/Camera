import 'vec3.dart';
import 'confidence.dart';

/// Measurement modes supported by the app.
enum MeasureMode {
  distance,
  path,
  height,
  area,
  angle,
  level,
  room,
  object,
  land, // outdoor plot / parcel – high precision perimeter + area
}

/// Single 3D point with optional AR anchor references.
class MeasurePoint {
  final String id;
  final String label;
  final Vec3 world;
  final String? anchorRef;
  final String? planeRef;
  final int confidence;

  const MeasurePoint({
    required this.id,
    required this.label,
    required this.world,
    this.anchorRef,
    this.planeRef,
    this.confidence = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'x': world.x,
        'y': world.y,
        'z': world.z,
        'anchorRef': anchorRef,
        'planeRef': planeRef,
        'confidence': confidence,
      };

  factory MeasurePoint.fromJson(Map<String, dynamic> j) => MeasurePoint(
        id: j['id'] as String,
        label: j['label'] as String,
        world: Vec3(
          (j['x'] as num).toDouble(),
          (j['y'] as num).toDouble(),
          (j['z'] as num).toDouble(),
        ),
        anchorRef: j['anchorRef'] as String?,
        planeRef: j['planeRef'] as String?,
        confidence: j['confidence'] as int? ?? 0,
      );
}

/// Full measurement record – Section 9.1
class Measurement {
  final String id;
  final String name;
  final MeasureMode mode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MeasurePoint> points;
  final List<double> segments; // segment lengths in meters
  final double? totalDistance;
  final double? totalArea;
  final double? totalPerimeter;
  final double? totalVolume;
  final double? totalAngle;
  final String displayUnit;
  final int precision; // decimals
  final ConfidenceResult confidence;
  final String deviceModel;
  final String arEngine;
  final String depthType;
  final String osVersion;
  final double scaleFactor;
  final String scaleSource;
  final String? thumbnailPath;
  final String? screenshotPath;
  final String notes;
  final List<String> tags;
  final String? projectId;
  final bool favorite;
  final bool isDraft;

  const Measurement({
    required this.id,
    required this.name,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
    required this.points,
    this.segments = const [],
    this.totalDistance,
    this.totalArea,
    this.totalPerimeter,
    this.totalVolume,
    this.totalAngle,
    this.displayUnit = 'm',
    this.precision = 2,
    required this.confidence,
    this.deviceModel = '',
    this.arEngine = '',
    this.depthType = 'none',
    this.osVersion = '',
    this.scaleFactor = 1.0,
    this.scaleSource = 'none',
    this.thumbnailPath,
    this.screenshotPath,
    this.notes = '',
    this.tags = const [],
    this.projectId,
    this.favorite = false,
    this.isDraft = false,
  });
}

/// Live preview data pushed to UI (never auto-locks endpoint).
class LiveMeasurement {
  final Vec3? start;
  final Vec3? current;
  final double distanceMeters;
  final ConfidenceResult confidence;
  final MeasureWorkflowState state;
  final String instruction;
  final String primaryLabel;
  final bool primaryEnabled;
  final bool showProgress;

  const LiveMeasurement({
    this.start,
    this.current,
    this.distanceMeters = 0,
    required this.confidence,
    required this.state,
    required this.instruction,
    required this.primaryLabel,
    this.primaryEnabled = true,
    this.showProgress = false,
  });
}

/// State machine – Section 3.5
enum MeasureWorkflowState {
  idle,
  scanning,
  ready,
  startLocked,
  stretching,
  endPreview,
  complete,
  editing,
  saved,
  trackingLost,
  paused,
  error,
}
