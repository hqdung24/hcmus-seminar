import 'package:flutter/material.dart';

class ShapeStyle {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final bool filled;

  const ShapeStyle({
    this.strokeColor = Colors.black,
    this.fillColor = Colors.transparent,
    this.strokeWidth = 2.0,
    this.filled = false,
  });

  ShapeStyle copyWith({
    Color? strokeColor,
    Color? fillColor,
    double? strokeWidth,
    bool? filled,
  }) =>
      ShapeStyle(
        strokeColor: strokeColor ?? this.strokeColor,
        fillColor: fillColor ?? this.fillColor,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        filled: filled ?? this.filled,
      );

  Paint get strokePaint => Paint()
    ..color = strokeColor
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  Paint? get fillPaint => filled
      ? (Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill)
      : null;
}
