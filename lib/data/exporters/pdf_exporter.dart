import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../measure/models.dart';

/// PDF report exporter – Section 9.3
class PdfExporter {
  static Future<Uint8List> export(Measurement m) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'Measure Reality',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              m.name.isEmpty ? 'Measurement' : m.name,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Mode: ${m.mode.name}'),
            pw.Text('Date: ${m.createdAt.toIso8601String()}'),
            pw.SizedBox(height: 16),
          ];

          if (m.totalDistance != null) {
            widgets.add(pw.Text(
              'Distance: ${m.totalDistance!.toStringAsFixed(m.precision)} m',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
          }
          if (m.totalArea != null) {
            widgets.add(pw.Text(
              'Area: ${m.totalArea!.toStringAsFixed(2)} m2',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
          }
          if (m.totalAngle != null) {
            widgets.add(pw.Text(
              'Angle: ${m.totalAngle!.toStringAsFixed(1)} deg',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
          }
          if (m.totalVolume != null) {
            widgets.add(pw.Text(
              'Volume: ${m.totalVolume!.toStringAsFixed(2)} m3',
            ));
          }

          widgets.addAll([
            pw.SizedBox(height: 12),
            pw.Text(
              'Confidence: ${m.confidence.level.name} '
              '(${m.confidence.score}) +/-'
              '${m.confidence.errorRangeMeters.toStringAsFixed(3)} m',
            ),
          ]);

          if (m.confidence.reasons.isNotEmpty) {
            widgets.add(pw.Text(
              'Reasons: ${m.confidence.reasons.join(", ")}',
            ));
          }

          widgets.addAll([
            pw.SizedBox(height: 20),
            pw.Text(
              'Points',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
          ]);

          for (final p in m.points) {
            widgets.add(pw.Text(
              '${p.label}: (${p.world.x.toStringAsFixed(3)}, '
              '${p.world.y.toStringAsFixed(3)}, '
              '${p.world.z.toStringAsFixed(3)}) conf=${p.confidence}',
              style: const pw.TextStyle(fontSize: 10),
            ));
          }

          widgets.addAll([
            pw.SizedBox(height: 20),
            pw.Text(
              'Device',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Model: ${m.deviceModel.isEmpty ? "-" : m.deviceModel}',
            ),
            pw.Text(
              'AR: ${m.arEngine.isEmpty ? "-" : m.arEngine}',
            ),
            pw.Text('Depth: ${m.depthType}'),
            pw.Text(
              'OS: ${m.osVersion.isEmpty ? "-" : m.osVersion}',
            ),
          ]);

          if (m.notes.isNotEmpty) {
            widgets.addAll([
              pw.SizedBox(height: 16),
              pw.Text(
                'Notes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(m.notes),
            ]);
          }

          widgets.addAll([
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.Text(
              'Phone AR is typically within 1-3% in good conditions. '
              'Not a replacement for certified instruments.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ]);

          return widgets;
        },
      ),
    );

    return doc.save();
  }
}
