import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Painter for the default teardrop pin marker
class MarkerPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;

  const MarkerPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = _createPinPath(center, radius);

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

    // Inner circle (marker hole)
    _drawInnerCircle(canvas, center, radius);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowOffset = radius * 0.15;
    final shadowBlur = radius * 0.2;

    final shadowPath = _createPinPath(
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
      Offset(center.dx, center.dy - radius * 0.15),
      radius * 0.2,
      innerCirclePaint,
    );
  }

  ui.Path _createPinPath(Offset center, double radius) {
    final path = ui.Path();
    final topY = center.dy - radius * 0.7;

    // Outer circle (teardrop top)
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx, topY),
      radius: radius * 0.5,
    ));

    // Pointy bottom - create teardrop shape
    final leftPoint = Offset(center.dx - radius * 0.5, topY);
    final bottomPoint = Offset(center.dx, center.dy + radius * 0.3);
    final rightPoint = Offset(center.dx + radius * 0.5, topY);

    path.moveTo(leftPoint.dx, leftPoint.dy);
    path.lineTo(bottomPoint.dx, bottomPoint.dy);
    path.lineTo(rightPoint.dx, rightPoint.dy);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow;
  }
}
