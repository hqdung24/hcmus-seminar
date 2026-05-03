import 'dart:ui';
import '../shape.dart';

class CircleShape extends Shape {
  const CircleShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.circle;

  /// Treats start as center and end as a point on the circumference.
  double get radius => (end - start).distance;

  @override
  void draw(Canvas canvas) {
    final fill = style.fillPaint;
    if (fill != null) canvas.drawCircle(start, radius, fill);
    canvas.drawCircle(start, radius, style.strokePaint);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      CircleShape(start: start, end: newEnd, style: style);
}
