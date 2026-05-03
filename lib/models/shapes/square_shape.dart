import 'dart:math';
import 'dart:ui';
import '../shape.dart';

class SquareShape extends Shape {
  const SquareShape({
    required super.start,
    required super.end,
    required super.style,
  });

  @override
  ShapeType get type => ShapeType.square;

  Rect _rect() {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final side = max(dx.abs(), dy.abs());
    return Rect.fromLTWH(
      start.dx,
      start.dy,
      dx >= 0 ? side : -side,
      dy >= 0 ? side : -side,
    );
  }

  @override
  void draw(Canvas canvas) {
    final rect = _rect();
    final fill = style.fillPaint;
    if (fill != null) canvas.drawRect(rect, fill);
    canvas.drawRect(rect, style.strokePaint);
  }

  @override
  Shape withEnd(Offset newEnd) =>
      SquareShape(start: start, end: newEnd, style: style);
}
