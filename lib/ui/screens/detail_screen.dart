import 'package:flutter/material.dart';
import '../../measure/models.dart';
import '../../measure/confidence.dart';
import '../../core/units.dart';
import '../theme.dart';

/// Measurement detail screen  P4
/// Shows full measurement: points, totals, confidence reasons, device info.
class DetailScreen extends StatelessWidget {
  final Measurement measurement;

  const DetailScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    final confColor = switch (m.confidence.level) {
      ConfidenceLevel.high => AppColors.successGreen,
      ConfidenceLevel.medium => AppColors.warningAmber,
      ConfidenceLevel.low => AppColors.errorRed,
    };

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: Text(m.name.isEmpty ? 'Measurement' : m.name),
        backgroundColor: AppColors.nearBlack,
        actions: [
          IconButton(
            icon: Icon(
              m.favorite ? Icons.star : Icons.star_border,
              color: AppColors.warningAmber,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.accentCyan),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Primary value
          if (m.totalDistance != null)
            Text(
              Units.formatStable(
                m.totalDistance!,
                unit: LengthUnit.m,
                decimals: m.precision,
              ),
              style: const TextStyle(
                fontSize: 40,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          if (m.totalArea != null)
            Text(
              '${m.totalArea!.toStringAsFixed(2)} m2',
              style: const TextStyle(fontSize: 40, fontFamily: 'monospace'),
            ),
          if (m.totalAngle != null)
            Text(
              '${m.totalAngle!.toStringAsFixed(1)} deg',
              style: const TextStyle(fontSize: 40, fontFamily: 'monospace'),
            ),
          const SizedBox(height: 8),

          // Confidence badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: confColor.withOpacity(0.4)),
                ),
                child: Text(
                  '${m.confidence.level.name.toUpperCase()}  +/-${m.confidence.errorRangeMeters.toStringAsFixed(2)} m',
                  style: TextStyle(color: confColor, fontSize: 13),
                ),
              ),
            ],
          ),

          if (m.confidence.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              m.confidence.reasons.join(' · '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],

          const Divider(height: 32, color: Colors.white12),

          // Meta
          _row('Mode', m.mode.name),
          _row('Created', _fmt(m.createdAt)),
          _row('Points', '${m.points.length}'),
          if (m.notes.isNotEmpty) _row('Notes', m.notes),
          if (m.tags.isNotEmpty) _row('Tags', m.tags.join(', ')),

          const Divider(height: 32, color: Colors.white12),

          // Device info
          const Text('Device', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _row('Model', m.deviceModel.isEmpty ? '' : m.deviceModel),
          _row('AR Engine', m.arEngine.isEmpty ? '' : m.arEngine),
          _row('Depth', m.depthType),
          _row('OS', m.osVersion.isEmpty ? '' : m.osVersion),
          if (m.scaleFactor != 1.0)
            _row('Scale factor', m.scaleFactor.toStringAsFixed(4)),

          // Points table
          if (m.points.isNotEmpty) ...[
            const Divider(height: 32, color: Colors.white12),
            const Text('Points', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...m.points.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${p.label}: (${p.world.x.toStringAsFixed(3)}, '
                    '${p.world.y.toStringAsFixed(3)}, '
                    '${p.world.z.toStringAsFixed(3)})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
