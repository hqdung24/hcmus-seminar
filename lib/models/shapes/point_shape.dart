import 'dart:ui';
import '../shape.dart';

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
}
