import 'package:flutter/material.dart';
import '../../measure/calibration.dart';
import '../../measure/vec3.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Calibration + Accuracy Test screen  Section 5.3 + 5.16
/// Reference objects + 1 m accuracy test.
/// Correction is suggested only  never applied silently.
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final engine = CalibrationEngine();
  ReferenceObject selected = ReferenceObject.creditCard;
  CalibrationResult? result;

  // Simulated measured points for demo (real app uses AR hits)
  Vec3? pointA;
  Vec3? pointB;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: const Text('Calibration'),
        backgroundColor: AppColors.nearBlack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Reference Object Scale',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Measure a known object to calibrate scale. '
            'The correction is only applied if you accept it.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Object picker
          ...ReferenceObject.values.where((o) => o != ReferenceObject.custom).map((o) {
            final spec = referenceLibrary[o]!;
            return RadioListTile<ReferenceObject>(
              title: Text(spec.name),
              subtitle: Text(
                '${(spec.lengthMeters * 1000).toStringAsFixed(1)} mm'
                '${spec.widthMeters != null ? ' x ${(spec.widthMeters! * 1000).toStringAsFixed(1)} mm' : ''}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              value: o,
              groupValue: selected,
              activeColor: AppColors.accentCyan,
              onChanged: (v) => setState(() => selected = v!),
            );
          }),

          const SizedBox(height: 16),
          PrimaryButton(
            label: 'RUN WITH LAST MEASUREMENT',
            onPressed: () {
              // Demo: simulate a slightly off measurement
              final trueLen = referenceLibrary[selected]!.lengthMeters;
              final simulated = trueLen * 1.025; // +2.5% error
              pointA = const Vec3(0, 0, 0);
              pointB = Vec3(simulated, 0, 0);
              setState(() {
                result = engine.fromReference(
                  a: pointA!,
                  b: pointB!,
                  object: selected,
                );
              });
            },
          ),

          const Divider(height: 40, color: Colors.white12),

          const Text(
            'Accuracy Test Tool',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Measure a known 1 m reference and see this device\'s error. '
            'Saved as a per-device suggestion only.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'RUN 1 m ACCURACY TEST',
            onPressed: () {
              pointA = const Vec3(0, 0, 0);
              pointB = const Vec3(1.018, 0, 0); // simulated +1.8%
              setState(() {
                result = engine.accuracyTest(a: pointA!, b: pointB!);
              });
            },
          ),

          if (result != null) ...[
            const SizedBox(height: 24),
            Card(
              color: AppColors.glass,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Measured: ${result!.measuredLength.toStringAsFixed(4)} m',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    Text(
                      'True:     ${result!.trueLength.toStringAsFixed(4)} m',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${result!.errorPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: result!.errorPercent < 2
                            ? AppColors.successGreen
                            : AppColors.warningAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Suggested scale: ${result!.scaleFactor.toStringAsFixed(4)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              engine.acceptSuggestion();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Scale factor applied'),
                                ),
                              );
                              setState(() {});
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              engine.resetScale();
                              setState(() => result = null);
                            },
                            child: const Text(
                              'Discard',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (engine.activeScaleFactor != 1.0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Active scale: ${engine.activeScaleFactor.toStringAsFixed(4)}',
                          style: const TextStyle(color: AppColors.accentCyan),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
