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

  @override
  Rect get bounds => Rect.fromPoints(start, end);

  @override
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    final ab = end - start;
    final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lenSq == 0) {
      return (point - start).distance <= tolerance + style.strokeWidth / 2;
    }
    final t =
        ((point.dx - start.dx) * ab.dx + (point.dy - start.dy) * ab.dy) /
            lenSq;
    final tClamped = t.clamp(0.0, 1.0);
    final closest = start + Offset(ab.dx * tClamped, ab.dy * tClamped);
    return (point - closest).distance <= tolerance + style.strokeWidth / 2;
  }
}
