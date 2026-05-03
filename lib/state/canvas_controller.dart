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

/// The active drawing tool. Maps 1:1 to ShapeType.
enum DrawingTool { point, line, rectangle, square, circle, ellipse }

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
    }
  }
}
