import '../../measure/vec3.dart';
import '../../measure/geometry.dart';

/// Object Mode  Section 4.6
/// Pick three edges (length, width, height).
/// Auto-suggest bounding box from detected planes.
/// Live 3D box wireframe, volume, surface area, "fits in" check,
/// Packaging helper (parcel + volumetric weight).
class ObjectModeHandler {
  Vec3? lengthA, lengthB; // first edge
  Vec3? widthA, widthB; // second edge
  Vec3? heightA, heightB; // third edge

  int edgeIndex = 0; // 0=length, 1=width, 2=height

  void setEdgePoint(Vec3 p) {
    switch (edgeIndex) {
      case 0:
        if (lengthA == null) {
          lengthA = p;
        } else {
          lengthB = p;
          edgeIndex = 1;
        }
        break;
      case 1:
        if (widthA == null) {
          widthA = p;
        } else {
          widthB = p;
          edgeIndex = 2;
        }
        break;
      case 2:
        if (heightA == null) {
          heightA = p;
        } else {
          heightB = p;
          edgeIndex = 3;
        }
        break;
    }
  }

  double get length {
    if (lengthA == null || lengthB == null) return 0;
    return Geometry.distance(lengthA!, lengthB!);
  }

  double get width {
    if (widthA == null || widthB == null) return 0;
    return Geometry.distance(widthA!, widthB!);
  }

  double get height {
    if (heightA == null || heightB == null) return 0;
    return Geometry.distance(heightA!, heightB!);
  }

  double get volume => length * width * height;

  double get surfaceArea =>
      2 * (length * width + length * height + width * height);

  bool get isComplete => edgeIndex >= 3;

  String get instruction {
    switch (edgeIndex) {
      case 0:
        return lengthA == null ? 'Tap length start' : 'Tap length end';
      case 1:
        return widthA == null ? 'Tap width start' : 'Tap width end';
      case 2:
        return heightA == null ? 'Tap height start' : 'Tap height end';
      default:
        return 'Object measured';
    }
  }

  /// "Fits in" check  enter container size, see yes/no.
  bool fitsIn({
    required double containerL,
    required double containerW,
    required double containerH,
  }) {
    final dims = [length, width, height]..sort();
    final box = [containerL, containerW, containerH]..sort();
    return dims[0] <= box[0] && dims[1] <= box[1] && dims[2] <= box[2];
  }

  /// Packaging helper  volumetric weight (dim weight).
  /// Standard divisor 5000 for cm ' kg (common carrier rule).
  ({double volumeCm3, double volumetricKg, double actualHint}) packaging({
    double divisor = 5000,
  }) {
    final lCm = length * 100;
    final wCm = width * 100;
    final hCm = height * 100;
    final volCm3 = lCm * wCm * hCm;
    final volKg = volCm3 / divisor;
    return (volumeCm3: volCm3, volumetricKg: volKg, actualHint: volKg);
  }

  void reset() {
    lengthA = lengthB = null;
    widthA = widthB = null;
    heightA = heightB = null;
    edgeIndex = 0;
  }
}
