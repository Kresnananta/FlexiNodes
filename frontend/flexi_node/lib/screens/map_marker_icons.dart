import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum FlexiMapMarkerShape { circle, diamond, square }

class FlexiMapMarkerIcon {
  const FlexiMapMarkerIcon._();

  static Future<BitmapDescriptor> build({
    required FlexiMapMarkerShape shape,
    required Color color,
    required IconData icon,
  }) async {
    const double size = 72;
    const double badgeSize = 48;
    const double badgeLeft = 12;
    const double badgeTop = 5;
    const double tipY = 67;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.22);
    final fillPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Path markerPath({Offset offset = Offset.zero}) {
      final center = Offset(size / 2, badgeTop + badgeSize / 2) + offset;
      final tip = Offset(size / 2, tipY) + offset;

      switch (shape) {
        case FlexiMapMarkerShape.circle:
          return Path()
            ..addOval(Rect.fromCircle(center: center, radius: badgeSize / 2))
            ..moveTo(center.dx - 10, center.dy + 19)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(center.dx + 10, center.dy + 19)
            ..close();
        case FlexiMapMarkerShape.diamond:
          return Path()
            ..moveTo(center.dx, badgeTop + offset.dy)
            ..lineTo(badgeLeft + badgeSize + offset.dx, center.dy)
            ..lineTo(center.dx + 12, center.dy + 20)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(center.dx - 12, center.dy + 20)
            ..lineTo(badgeLeft + offset.dx, center.dy)
            ..close();
        case FlexiMapMarkerShape.square:
          return Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  badgeLeft + offset.dx,
                  badgeTop + offset.dy,
                  badgeSize,
                  badgeSize,
                ),
                const Radius.circular(10),
              ),
            )
            ..moveTo(center.dx - 10, center.dy + 22)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(center.dx + 10, center.dy + 22)
            ..close();
      }
    }

    final shadowPath = markerPath(offset: const Offset(0, 3));
    final path = markerPath();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        badgeTop + (badgeSize - iconPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final data = bytes?.buffer.asUint8List() ?? Uint8List(0);

    if (data.isEmpty) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }

    return BitmapDescriptor.bytes(data, width: size, height: size);
  }
}
