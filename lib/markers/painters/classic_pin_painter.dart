import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Painter for the classic map pin with wider head and sharp point
class ClassicPinPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;

  const ClassicPinPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = _createClassicPinPath(center, radius);

    // Draw shadow
    if (enableShadow) {
      _drawShadow(canvas, center, radius);
    }

    // Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }

    // Inner circle
    _drawInnerCircle(canvas, center, radius);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowOffset = radius * 0.15;
    final shadowBlur = radius * 0.25;

    final shadowPath = _createClassicPinPath(
      center + Offset(0, shadowOffset),
      radius,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _drawInnerCircle(Canvas canvas, Offset center, double radius) {
    final innerCirclePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.2),
      radius * 0.18,
      innerCirclePaint,
    );
  }

  ui.Path _createClassicPinPath(Offset center, double radius) {
    final path = ui.Path();

    // Classic pin has a wider, more circular head
    final headRadius = radius * 0.55;
    final headCenter = Offset(center.dx, center.dy - radius * 0.5);
    final bottomY = center.dy + radius * 0.3;

    // Draw circular head
    path.addOval(Rect.fromCircle(
      center: headCenter,
      radius: headRadius,
    ));

    // Draw sides tapering to point
    final leftShoulder = Offset(center.dx - headRadius, headCenter.dy);
    final rightShoulder = Offset(center.dx + headRadius, headCenter.dy);
    final bottomPoint = Offset(center.dx, bottomY);

    path.moveTo(leftShoulder.dx, leftShoulder.dy);
    // Curved left side
    final leftControlX = center.dx - radius * 0.2;
    final leftControlY = headCenter.dy + radius * 0.3;
    path.quadraticBezierTo(
      leftControlX,
      leftControlY,
      bottomPoint.dx,
      bottomPoint.dy,
    );

    // Curved right side
    path.moveTo(rightShoulder.dx, rightShoulder.dy);
    final rightControlX = center.dx + radius * 0.2;
    final rightControlY = headCenter.dy + radius * 0.3;
    path.quadraticBezierTo(
      rightControlX,
      rightControlY,
      bottomPoint.dx,
      bottomPoint.dy,
    );

    path.close();

    // Close the top circle (creates complete pin shape)
    path.addOval(Rect.fromCircle(
      center: headCenter,
      radius: headRadius,
    ));

    return path;
  }

  @override
  bool shouldRepaint(covariant ClassicPinPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow;
  }
}
