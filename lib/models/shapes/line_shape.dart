import 'dart:ui';
import '../shape.dart';
import '../shape_style.dart';

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

  @override
  Shape withStyle(ShapeStyle newStyle) =>
      LineShape(start: start, end: end, style: newStyle);

  @override
  bool contains(Offset point) {
    // Lines cannot be filled, so they don't contain points for filling.
    return false;
  }
}
