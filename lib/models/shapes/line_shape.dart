import 'dart:ui';
import '../shape.dart';

class LineShape extends Shape {
  const LineShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.line;

  @override
  void draw(Canvas canvas) {
    canvas.drawLine(start, end, style.strokePaint);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      LineShape(start: start, end: newEnd, style: style);
}
