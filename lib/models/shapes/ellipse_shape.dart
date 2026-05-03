import 'dart:ui';
import '../shape.dart';

class EllipseShape extends Shape {
  const EllipseShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.ellipse;

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromPoints(start, end);
    final fill = style.fillPaint;
    if (fill != null) canvas.drawOval(rect, fill);
    canvas.drawOval(rect, style.strokePaint);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      EllipseShape(start: start, end: newEnd, style: style);
}
