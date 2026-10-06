/// Imperial fraction display  Section 5.8
/// e.g. 3 5/8 in with selectable denominator (1/8, 1/16, 1/32).
enum FractionDenom { eighth, sixteenth, thirtySecond }

class FractionFormat {
  FractionFormat._();

  static int denomValue(FractionDenom d) {
    switch (d) {
      case FractionDenom.eighth:
        return 8;
      case FractionDenom.sixteenth:
        return 16;
      case FractionDenom.thirtySecond:
        return 32;
    }
  }

  /// Convert meters ' fractional inches string.
  static String metersToFractionInches(
    double meters, {
    FractionDenom denom = FractionDenom.sixteenth,
  }) {
    final totalInches = meters / 0.0254;
    return inchesToFraction(totalInches, denom: denom);
  }

  /// Convert meters ' feet-inches fraction: 5' 3 1/2"
  static String metersToFeetInches(
    double meters, {
    FractionDenom denom = FractionDenom.sixteenth,
  }) {
    final totalInches = meters / 0.0254;
    final feet = totalInches ~/ 12;
    final inches = totalInches - feet * 12;
    final frac = inchesToFraction(inches, denom: denom);
    if (feet == 0) return frac;
    return "$feet' $frac";
  }

  /// Format a decimal-inch value as mixed number.
  static String inchesToFraction(
    double inches, {
    FractionDenom denom = FractionDenom.sixteenth,
  }) {
    final d = denomValue(denom);
    final sign = inches < 0 ? '-' : '';
    final abs = inches.abs();
    final whole = abs.floor();
    final fractional = abs - whole;

    var num = (fractional * d).round();
    var wholeAdj = whole;
    if (num == d) {
      wholeAdj += 1;
      num = 0;
    }

    if (num == 0) {
      return '$sign$wholeAdj in';
    }

    final g = _gcd(num, d);
    final n = num ~/ g;
    final den = d ~/ g;

    if (wholeAdj == 0) {
      return '$sign$n/$den in';
    }
    return '$sign$wholeAdj $n/$den in';
  }

  static int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x == 0 ? 1 : x;
  }

  /// Parse fraction string back to meters (best-effort).
  static double? fractionInchesToMeters(String text) {
    final cleaned = text.replaceAll('in', '').trim();
    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(cleaned);
    if (mixed != null) {
      final whole = int.parse(mixed.group(1)!);
      final n = int.parse(mixed.group(2)!);
      final d = int.parse(mixed.group(3)!);
      if (d == 0) return null;
      return (whole + n / d) * 0.0254;
    }
    final pure = RegExp(r'^(\d+)/(\d+)$').firstMatch(cleaned);
    if (pure != null) {
      final n = int.parse(pure.group(1)!);
      final d = int.parse(pure.group(2)!);
      if (d == 0) return null;
      return (n / d) * 0.0254;
    }
    final decimal = double.tryParse(cleaned);
    if (decimal != null) return decimal * 0.0254;
    return null;
  }
}
