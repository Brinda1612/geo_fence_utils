import 'package:flutter/material.dart';

/// Label widget for displaying text below markers
class MarkerLabel extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const MarkerLabel({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: borderRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

/// Factory methods for common label styles
class MarkerLabels {
  /// Default white label with semi-transparent black background
  static const defaultLabel = MarkerLabel(
    label: '',
    backgroundColor: Color(0xB3000000),
    textColor: Colors.white,
  );

  /// Clean white label with no background
  static const clean = MarkerLabel(
    label: '',
    textColor: Colors.white,
    backgroundColor: Colors.transparent,
  );

  /// Dark label for light backgrounds
  static const dark = MarkerLabel(
    label: '',
    backgroundColor: Colors.white,
    textColor: Colors.black,
  );

  /// Small compact label
  static const compact = MarkerLabel(
    label: '',
    backgroundColor: Color(0xB3000000),
    textColor: Colors.white,
    fontSize: 10.0,
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  );

  /// Create a label with custom text
  static MarkerLabel text(
    String text, {
    Color? backgroundColor,
    Color textColor = Colors.white,
  }) {
    return MarkerLabel(
      label: text,
      backgroundColor: backgroundColor ?? const Color(0xB3000000),
      textColor: textColor,
    );
  }
}
