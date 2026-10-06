import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../measure/models.dart';

/// PNG exporter  renders a simple summary card to image bytes.
class PngExporter {
  static Future<Uint8List?> exportSummaryCard(Measurement m) async {
    const width = 800.0;
    const height = 400.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFF0B0E14);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

    final titlePainter = TextPainter(
      text: TextSpan(
        text: m.name.isEmpty ? 'Measurement' : m.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 40);
    titlePainter.paint(canvas, const Offset(20, 30));

    String value = '';
    if (m.totalDistance != null) {
      value = '${m.totalDistance!.toStringAsFixed(m.precision)} m';
    } else if (m.totalArea != null) {
      value = '${m.totalArea!.toStringAsFixed(2)} m2';
    } else if (m.totalAngle != null) {
      value = '${m.totalAngle!.toStringAsFixed(1)} deg';
    }

    final valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Color(0xFF3DD6F5),
          fontSize: 48,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 40);
    valuePainter.paint(canvas, const Offset(20, 100));

    final confPainter = TextPainter(
      text: TextSpan(
        text:
            '${m.confidence.level.name.toUpperCase()}  +/-${m.confidence.errorRangeMeters.toStringAsFixed(2)} m',
        style: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 40);
    confPainter.paint(canvas, const Offset(20, 170));

    final metaPainter = TextPainter(
      text: TextSpan(
        text: '${m.mode.name}  ·  ${m.createdAt.toIso8601String()}',
        style: const TextStyle(color: Colors.white38, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 40);
    metaPainter.paint(canvas, const Offset(20, 220));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
