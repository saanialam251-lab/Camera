import '../../measure/vec3.dart';
import '../../measure/room_builder.dart';

/// Room Scan mode handler  Section 4.5
/// Guided stages: floor ' walls ' ceiling.
/// Coverage meter, door/window markers, floor plan export ready.
class RoomModeHandler {
  final RoomBuilder builder = RoomBuilder();

  RoomScanStage get stage => builder.stage;
  String get instruction => builder.stageInstruction;
  double get coverage => builder.coveragePercent;

  void onHit(Vec3 point) {
    switch (builder.stage) {
      case RoomScanStage.floor:
        builder.addFloorPoint(point);
        break;
      case RoomScanStage.walls:
        builder.addWallPoint(point);
        break;
      case RoomScanStage.ceiling:
        builder.addCeilingPoint(point);
        break;
      case RoomScanStage.complete:
        break;
    }
  }

  void nextStage() => builder.advanceStage();

  void addDoor(Vec3 pos, {double width = 0.9, double height = 2.1}) {
    builder.addMarker(DoorWindowMarker(
      position: pos,
      width: width,
      height: height,
      isDoor: true,
    ));
  }

  void addWindow(Vec3 pos, {double width = 1.2, double height = 1.0}) {
    builder.addMarker(DoorWindowMarker(
      position: pos,
      width: width,
      height: height,
      isDoor: false,
    ));
  }

  RoomResult? finalize() {
    if (builder.stage != RoomScanStage.complete &&
        builder.floorPoints.length < 3) {
      return null;
    }
    // Force complete if user finishes early with enough floor data
    while (builder.stage != RoomScanStage.complete) {
      builder.advanceStage();
    }
    return builder.build();
  }

  void reset() => builder.reset();
}
