import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Painter for the modern flat design marker with rounded corners
class ModernFlatPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;

  const ModernFlatPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = _createModernFlatPath(center, radius);

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
    final shadowOffset = radius * 0.1;
    final shadowBlur = radius * 0.15;

    final shadowPath = _createModernFlatPath(
      center + Offset(0, shadowOffset),
      radius,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _drawInnerCircle(Canvas canvas, Offset center, double radius) {
    final innerCirclePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      radius * 0.15,
      innerCirclePaint,
    );
  }

  ui.Path _createModernFlatPath(Offset center, double radius) {
    final path = ui.Path();
    final cornerRadius = radius * 0.3;
    final halfWidth = radius;
    final topY = center.dy - radius * 0.5;
    const bottomPointFactor = 0.7; // How far down the point goes
    final bottomY = center.dy + radius * 1.2;

    // Top left corner
    path.moveTo(center.dx - halfWidth + cornerRadius, topY);
    path.lineTo(center.dx + halfWidth - cornerRadius, topY);
    path.quadraticBezierTo(
      center.dx + halfWidth,
      topY,
      center.dx + halfWidth,
      topY + cornerRadius,
    );

    // Right side to point
    path.lineTo(
      center.dx + halfWidth * 0.3,
      center.dy + bottomY * bottomPointFactor,
    );
    path.lineTo(center.dx, bottomY);

    // Left side from point
    path.lineTo(
      center.dx - halfWidth * 0.3,
      center.dy + bottomY * bottomPointFactor,
    );
    path.lineTo(center.dx - halfWidth + cornerRadius, topY + cornerRadius);
    path.quadraticBezierTo(
      center.dx - halfWidth,
      topY,
      center.dx - halfWidth + cornerRadius,
      topY,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant ModernFlatPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow;
  }
}
