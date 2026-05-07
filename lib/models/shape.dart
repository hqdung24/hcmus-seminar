import 'dart:ui';
import 'shape_style.dart';

/// Stable IDs used in the binary format. Never reuse a number.
enum ShapeType {
  point(1),
  line(2),
  rectangle(3),
  square(4),
  circle(5),
  ellipse(6);

  final int code;
  const ShapeType(this.code);

  static ShapeType fromCode(int code) =>
      ShapeType.values.firstWhere((t) => t.code == code);
}

/// All shapes are defined by two points (start, end) plus a style.
/// Concrete shape classes override how those points are interpreted
/// when drawing.
abstract class Shape {
  final Offset start;
  final Offset end;
  final ShapeStyle style;

  const Shape({
    required this.start,
    required this.end,
    required this.style,
  });

  ShapeType get type;

  /// Draw the shape on the given canvas.
  void draw(Canvas canvas);

  /// Return a copy with updated end point (used while dragging).
  Shape withEnd(Offset newEnd);

  /// Return a copy with an updated style.
  Shape withStyle(ShapeStyle newStyle);

  /// Check if the point is contained within the filled area of the shape.
  bool contains(Offset point);
}
