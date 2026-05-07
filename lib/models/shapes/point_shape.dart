import 'dart:ui';
import '../shape.dart';
import '../shape_style.dart';

class PointShape extends Shape {
  const PointShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.point;

  @override
  void draw(Canvas canvas) {
    canvas.drawCircle(start, style.strokeWidth / 2, style.strokePaint
      ..style = PaintingStyle.fill);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      PointShape(start: start, end: newEnd, style: style);

  @override
  Shape withStyle(ShapeStyle newStyle) =>
      PointShape(start: start, end: end, style: newStyle);

  @override
  bool contains(Offset point) {
    // Points cannot be filled, but adding hit testing for consistency.
    return (point - start).distance <= (style.strokeWidth / 2) + 5;
  }
}
