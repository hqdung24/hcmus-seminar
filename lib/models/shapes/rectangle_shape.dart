import 'dart:ui';
import '../shape.dart';
import '../shape_style.dart';

class RectangleShape extends Shape {
  const RectangleShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.rectangle;

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromPoints(start, end);
    final fill = style.fillPaint;
    if (fill != null) canvas.drawRect(rect, fill);
    canvas.drawRect(rect, style.strokePaint);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      RectangleShape(start: start, end: newEnd, style: style);

  @override
  Rect get bounds => Rect.fromPoints(start, end);

  @override
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    final rect = Rect.fromPoints(start, end);
    if (style.filled && rect.inflate(tolerance).contains(point)) return true;
    return Shape.distanceToRectBorder(point, rect) <=
        tolerance + style.strokeWidth / 2;
  }
}
