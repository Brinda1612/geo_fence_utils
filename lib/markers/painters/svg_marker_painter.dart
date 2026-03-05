import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Painter for custom SVG path markers
class SvgMarkerPainter extends CustomPainter {
  final String svgPath;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;

  const SvgMarkerPainter({
    required this.svgPath,
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Parse SVG path and scale to fit size
    final path = _parseAndScalePath(size);

    if (enableShadow) {
      _drawShadow(canvas, path);
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
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawShadow(Canvas canvas, ui.Path path) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, shadowPaint);
  }

  ui.Path _parseAndScalePath(Size size) {
    // Parse the SVG path
    final parsedPath = _parseSvgPath(svgPath);

    // Get bounds of the parsed path
    final bounds = parsedPath.getBounds();

    // Calculate scale to fit the size
    final scaleX = size.width / bounds.width;
    final scaleY = size.height / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Center the path
    final offsetX = (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final offsetY = (size.height - bounds.height * scale) / 2 - bounds.top * scale;

    // Create transformed path
    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale, scale);

    return parsedPath.transform(matrix.storage);
  }

  /// Simple SVG path parser for common path commands
  ui.Path _parseSvgPath(String pathString) {
    final path = ui.Path();
    final commands = _tokenizePath(pathString);

    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;

    for (final command in commands) {
      switch (command.type) {
        case 'M':
          currentX = command.params[0];
          currentY = command.params[1];
          path.moveTo(currentX, currentY);
          startX = currentX;
          startY = currentY;
          break;
        case 'L':
          currentX = command.params[0];
          currentY = command.params[1];
          path.lineTo(currentX, currentY);
          break;
        case 'H':
          currentX = command.params[0];
          path.lineTo(currentX, currentY);
          break;
        case 'V':
          currentY = command.params[0];
          path.lineTo(currentX, currentY);
          break;
        case 'C':
          path.cubicTo(
            command.params[0], command.params[1],
            command.params[2], command.params[3],
            command.params[4], command.params[5],
          );
          currentX = command.params[4];
          currentY = command.params[5];
          break;
        case 'Q':
          path.quadraticBezierTo(
            command.params[0], command.params[1],
            command.params[2], command.params[3],
          );
          currentX = command.params[2];
          currentY = command.params[3];
          break;
        case 'Z':
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          break;
      }
    }

    return path;
  }

  List<_PathCommand> _tokenizePath(String pathString) {
    final commands = <_PathCommand>[];
    // Updated regex to handle all SVG path commands including lowercase
    final regex = RegExp(r'([a-zA-Z])\s*([^a-zA-Z]*?)(?=[a-zA-Z]|$)');
    final matches = regex.allMatches(pathString);

    for (final match in matches) {
      final type = match.group(1)!.toUpperCase();
      final paramsStr = match.group(2) ?? '';

      // Parse numbers, handling both standard decimals and ones starting with .
      final params = <double>[];
      final numberRegex = RegExp(r'[-+]?\d*\.?\d+');
      final numberMatches = numberRegex.allMatches(paramsStr);

      for (final numMatch in numberMatches) {
        try {
          params.add(double.parse(numMatch.group(0)!));
        } catch (e) {
          // Skip invalid numbers
        }
      }

      commands.add(_PathCommand(type, params));
    }

    return commands;
  }

  @override
  bool shouldRepaint(covariant SvgMarkerPainter oldDelegate) {
    return oldDelegate.svgPath != svgPath ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow;
  }
}

class _PathCommand {
  final String type;
  final List<double> params;

  _PathCommand(this.type, this.params);
}
