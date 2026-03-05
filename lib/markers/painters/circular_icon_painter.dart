import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Painter for circular icon markers similar to Geoapify/Google Maps style
///
/// Creates circular markers with customizable:
/// - Background color
/// - Icon (centered)
/// - Border
/// - Shadow
///
/// Example:
/// ```
/// CustomPaint(
///   painter: CircularIconPainter(
///     icon: Icons.restaurant,
///     color: Colors.red,
///     iconColor: Colors.white,
///   ),
/// )
/// ```
class CircularIconPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;
  final double iconSize;

  const CircularIconPainter({
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.enableShadow = true,
    this.iconSize = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - borderWidth) / 2;

    if (enableShadow) {
      _drawShadow(canvas, center, radius);
    }

    // Draw background circle
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw border
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, borderPaint);
    }

    // Draw icon
    _drawIcon(canvas, center);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius, shadowPaint);
  }

  void _drawIcon(Canvas canvas, Offset center) {
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: 'MaterialIcons',
        fontSize: iconSize,
        textAlign: TextAlign.center,
      ),
    );

    // Get the icon code point
    final iconCode = icon.codePoint;
    paragraphBuilder.addText(String.fromCharCode(iconCode));

    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));

    // Center the icon
    final offset = Offset(
      center.dx - paragraph.width / 2,
      center.dy - paragraph.height / 2,
    );

    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(covariant CircularIconPainter oldDelegate) {
    return oldDelegate.icon != icon ||
        oldDelegate.color != color ||
        oldDelegate.iconColor != iconColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow ||
        oldDelegate.iconSize != iconSize;
  }
}
