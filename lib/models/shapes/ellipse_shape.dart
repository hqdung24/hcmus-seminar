import 'dart:math';
import 'dart:ui';
import '../shape.dart';
import '../shape_style.dart';

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

  @override
  Shape withStyle(ShapeStyle newStyle) =>
      EllipseShape(start: start, end: end, style: newStyle);

  @override
  Rect get bounds => Rect.fromPoints(start, end);

  @override
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    final rect = Rect.fromPoints(start, end);
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    if (rx == 0 || ry == 0) return false;
    final cx = rect.center.dx;
    final cy = rect.center.dy;

    // Normalized squared distance: 1 = on the boundary, <1 inside, >1 outside.
    final nx = (point.dx - cx) / rx;
    final ny = (point.dy - cy) / ry;
    final value = nx * nx + ny * ny;

    final scale = (rx + ry) / 2;
    final tolNorm = tolerance / scale;
    final strokeNorm = (style.strokeWidth / 2) / scale;

    if (style.filled && value <= 1 + tolNorm) return true;
    return (value - 1).abs() <= 2 * (tolNorm + strokeNorm);
  }

  @override
  bool contains(Offset point) {
    final rect = Rect.fromPoints(start, end);
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final a = rect.width / 2;
    final b = rect.height / 2;
    if (a == 0 || b == 0) return false;
    final dx = point.dx - cx;
    final dy = point.dy - cy;
    return (pow(dx, 2) / pow(a, 2)) + (pow(dy, 2) / pow(b, 2)) <= 1;
  }
}
