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

  /// Return a copy with an updated style. Used by the paint-bucket tool to
  /// change a shape's fill / stroke without recreating its geometry.
  Shape withStyle(ShapeStyle newStyle);

  /// Axis-aligned bounding rect of the shape as rendered.
  Rect get bounds;

  /// True if [point] is within [tolerance] pixels of this shape's actual
  /// geometry (not its bounding box). Used by the eraser tool.
  /// Each shape overrides this with its own distance math; the default
  /// falls back to bbox.
  bool hitTest(Offset point, {double tolerance = 10.0}) =>
      bounds.inflate(tolerance).contains(point);

  /// True if [point] is inside the closed area of this shape (no tolerance).
  /// Used by the paint-bucket tool to fill a shape on click.
  /// Open shapes (point, line) return false since they have no closed area.
  bool contains(Offset point);

  /// Shortest distance from [p] to the border of axis-aligned rect [r].
  /// Used by RectangleShape and SquareShape for outline hit-testing.
  static double distanceToRectBorder(Offset p, Rect r) {
    if (r.contains(p)) {
      final inside = [
        p.dx - r.left,
        r.right - p.dx,
        p.dy - r.top,
        r.bottom - p.dy,
      ];
      return inside.reduce((a, b) => a < b ? a : b);
    }
    final closest = Offset(
      p.dx.clamp(r.left, r.right),
      p.dy.clamp(r.top, r.bottom),
    );
    return (p - closest).distance;
  }
}
