/// Paint / Flooring / Volume / Parcel estimators  Section 4.4 + 4.6 + 5
class PaintEstimate {
  final double areaM2;
  final double coveragePerLiter; // m2 per liter
  final double wastePercent;
  final double litersNeeded;
  final int cansRounded; // assuming 1 L cans; adjust as needed

  const PaintEstimate({
    required this.areaM2,
    required this.coveragePerLiter,
    required this.wastePercent,
    required this.litersNeeded,
    required this.cansRounded,
  });
}

class FlooringEstimate {
  final double areaM2;
  final double coveragePerBox; // m2 per box
  final double wastePercent;
  final double boxesNeeded;
  final int boxesRounded;

  const FlooringEstimate({
    required this.areaM2,
    required this.coveragePerBox,
    required this.wastePercent,
    required this.boxesNeeded,
    required this.boxesRounded,
  });
}

class ParcelEstimate {
  final double lengthM;
  final double widthM;
  final double heightM;
  final double volumeM3;
  final double volumeCm3;
  final double volumetricWeightKg;
  final double divisor; // carrier dimensional weight divisor

  const ParcelEstimate({
    required this.lengthM,
    required this.widthM,
    required this.heightM,
    required this.volumeM3,
    required this.volumeCm3,
    required this.volumetricWeightKg,
    required this.divisor,
  });
}

class Estimators {
  Estimators._();

  /// Paint estimator: area + coverage per liter + waste %.
  static PaintEstimate paint({
    required double areaM2,
    double coveragePerLiter = 10.0, // typical wall paint
    double wastePercent = 10.0,
    double canSizeLiters = 1.0,
  }) {
    final withWaste = areaM2 * (1 + wastePercent / 100);
    final liters = coveragePerLiter > 0 ? withWaste / coveragePerLiter : 0.0;
    final cans = canSizeLiters > 0 ? (liters / canSizeLiters).ceil() : 0;
    return PaintEstimate(
      areaM2: areaM2,
      coveragePerLiter: coveragePerLiter,
      wastePercent: wastePercent,
      litersNeeded: liters,
      cansRounded: cans,
    );
  }

  /// Flooring estimator: area + coverage per box + waste %.
  static FlooringEstimate flooring({
    required double areaM2,
    double coveragePerBox = 2.0,
    double wastePercent = 10.0,
  }) {
    final withWaste = areaM2 * (1 + wastePercent / 100);
    final boxes = coveragePerBox > 0 ? withWaste / coveragePerBox : 0.0;
    return FlooringEstimate(
      areaM2: areaM2,
      coveragePerBox: coveragePerBox,
      wastePercent: wastePercent,
      boxesNeeded: boxes,
      boxesRounded: boxes.ceil(),
    );
  }

  /// Parcel / volumetric weight.
  /// Standard divisor 5000 (cm ' kg) used by many carriers.
  static ParcelEstimate parcel({
    required double lengthM,
    required double widthM,
    required double heightM,
    double divisor = 5000,
  }) {
    final lCm = lengthM * 100;
    final wCm = widthM * 100;
    final hCm = heightM * 100;
    final volCm3 = lCm * wCm * hCm;
    final volM3 = lengthM * widthM * heightM;
    final volKg = divisor > 0 ? volCm3 / divisor : 0.0;
    return ParcelEstimate(
      lengthM: lengthM,
      widthM: widthM,
      heightM: heightM,
      volumeM3: volM3,
      volumeCm3: volCm3,
      volumetricWeightKg: volKg,
      divisor: divisor,
    );
  }

  /// Net area after subtract cut-outs (windows, doors).
  static double netArea(double grossM2, List<double> cutoutAreasM2) {
    final cut = cutoutAreasM2.fold(0.0, (a, b) => a + b);
    final net = grossM2 - cut;
    return net < 0 ? 0 : net;
  }
}
