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
  Rect get bounds =>
      Rect.fromCircle(center: start, radius: style.strokeWidth / 2 + 4);

  @override
  bool hitTest(Offset point, {double tolerance = 10.0}) =>
      (point - start).distance <= tolerance + style.strokeWidth / 2;

  @override
  bool contains(Offset point) =>
      (point - start).distance <= (style.strokeWidth / 2) + 5;
}
