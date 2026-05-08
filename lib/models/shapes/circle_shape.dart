import 'dart:ui';
import '../shape.dart';
import '../shape_style.dart';

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

  @override
  Shape withStyle(ShapeStyle newStyle) =>
      CircleShape(start: start, end: end, style: newStyle);

  @override
  Rect get bounds => Rect.fromCircle(center: start, radius: radius);

  @override
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    final dist = (point - start).distance;
    if (style.filled && dist <= radius + tolerance) return true;
    return (dist - radius).abs() <= tolerance + style.strokeWidth / 2;
  }

  @override
  bool contains(Offset point) => (point - start).distance <= radius;
}
