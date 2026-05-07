import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/shape.dart';
import '../models/shape_style.dart';
import '../models/shapes/circle_shape.dart';
import '../models/shapes/ellipse_shape.dart';
import '../models/shapes/line_shape.dart';
import '../models/shapes/point_shape.dart';
import '../models/shapes/rectangle_shape.dart';
import '../models/shapes/square_shape.dart';

/// The active drawing tool.
enum DrawingTool { point, line, rectangle, square, circle, ellipse, fill }

/// Holds the canvas state and exposes mutation methods.
/// Use ListenableBuilder in the UI to react to changes.
class CanvasController extends ChangeNotifier {
  final List<Shape> _shapes = [];
  Shape? _draftShape;

  DrawingTool tool = DrawingTool.line;
  ShapeStyle style = const ShapeStyle();

  List<Shape> get shapes => List.unmodifiable(_shapes);
  Shape? get draftShape => _draftShape;

  void setTool(DrawingTool t) {
    tool = t;
    notifyListeners();
  }

  void setStyle(ShapeStyle s) {
    style = s;
    notifyListeners();
  }

  // ---- drawing lifecycle ----

  void startDrawing(Offset start) {
    if (tool == DrawingTool.fill) {
      _fillShapeAt(start);
      return;
    }
    _draftShape = _createShape(start, start);
    notifyListeners();
  }

  void updateDrawing(Offset current) {
    if (_draftShape == null) return;
    _draftShape = _draftShape!.withEnd(current);
    notifyListeners();
  }

  void endDrawing() {
    if (_draftShape == null) return;
    _shapes.add(_draftShape!);
    _draftShape = null;
    notifyListeners();
  }

  // ---- file ops ----

  void clear() {
    _shapes.clear();
    _draftShape = null;
    notifyListeners();
  }

  void loadShapes(List<Shape> shapes) {
    _shapes
      ..clear()
      ..addAll(shapes);
    _draftShape = null;
    notifyListeners();
  }

  // ---- internal ----

  void _fillShapeAt(Offset point) {
    // Iterate in reverse to find the topmost shape
    for (int i = _shapes.length - 1; i >= 0; i--) {
      final shape = _shapes[i];
      if (shape.contains(point)) {
        // Create a new shape with updated style
        final newStyle = shape.style.copyWith(
          filled: true,
          strokeColor: style.strokeColor, // Use current selected color
        );
        _shapes[i] = shape.withStyle(newStyle);
        notifyListeners();
        return;
      }
    }
  }

  Shape _createShape(Offset start, Offset end) {
    switch (tool) {
      case DrawingTool.point:
        return PointShape(start: start, end: end, style: style);
      case DrawingTool.line:
        return LineShape(start: start, end: end, style: style);
      case DrawingTool.rectangle:
        return RectangleShape(start: start, end: end, style: style);
      case DrawingTool.square:
        return SquareShape(start: start, end: end, style: style);
      case DrawingTool.circle:
        return CircleShape(start: start, end: end, style: style);
      case DrawingTool.ellipse:
        return EllipseShape(start: start, end: end, style: style);
      case DrawingTool.fill:
        throw StateError('Cannot create a shape for the fill tool.');
    }
  }
}
