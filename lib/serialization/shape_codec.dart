import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/shape.dart';
import '../models/shape_style.dart';
import '../models/shapes/circle_shape.dart';
import '../models/shapes/ellipse_shape.dart';
import '../models/shapes/line_shape.dart';
import '../models/shapes/point_shape.dart';
import '../models/shapes/rectangle_shape.dart';
import '../models/shapes/square_shape.dart';
import 'binary_reader.dart';
import 'binary_writer.dart';

/// Binary format:
///
/// File header:
///   uint32 magic     = 0x44524157 ("DRAW")
///   uint8  version   = 1
///   uint32 shapeCount
///
/// Each shape (variable-length):
///   uint8   type code (1..6, see ShapeType.code)
///   float32 startX, startY, endX, endY
///   uint32  strokeColor (ARGB)
///   uint32  fillColor (ARGB)
///   float32 strokeWidth
///   uint8   filled (0 or 1)
class ShapeCodec {
  static const int magic = 0x44524157;
  static const int version = 1;

  static Uint8List encodeAll(List<Shape> shapes) {
    final w = BinaryWriter()
      ..writeUint32(magic)
      ..writeUint8(version)
      ..writeUint32(shapes.length);
    for (final s in shapes) {
      _encodeShape(w, s);
    }
    return w.toBytes();
  }

  static List<Shape> decodeAll(Uint8List bytes) {
    final r = BinaryReader(bytes);
    final readMagic = r.readUint32();
    if (readMagic != magic) {
      throw FormatException('Not a valid drawing file (bad magic)');
    }
    final v = r.readUint8();
    if (v != version) {
      throw FormatException('Unsupported version: $v');
    }
    final count = r.readUint32();
    final shapes = <Shape>[];
    for (var i = 0; i < count; i++) {
      shapes.add(_decodeShape(r));
    }
    return shapes;
  }

  // ---- per-shape ----

  static void _encodeShape(BinaryWriter w, Shape s) {
    w.writeUint8(s.type.code);
    w.writeFloat32(s.start.dx);
    w.writeFloat32(s.start.dy);
    w.writeFloat32(s.end.dx);
    w.writeFloat32(s.end.dy);
    w.writeUint32(s.style.strokeColor.value);
    w.writeUint32(s.style.fillColor.value);
    w.writeFloat32(s.style.strokeWidth);
    w.writeBool(s.style.filled);
  }

  static Shape _decodeShape(BinaryReader r) {
    final type = ShapeType.fromCode(r.readUint8());
    final start = Offset(r.readFloat32(), r.readFloat32());
    final end = Offset(r.readFloat32(), r.readFloat32());
    final style = ShapeStyle(
      strokeColor: Color(r.readUint32()),
      fillColor: Color(r.readUint32()),
      strokeWidth: r.readFloat32(),
      filled: r.readBool(),
    );

    switch (type) {
      case ShapeType.point:
        return PointShape(start: start, end: end, style: style);
      case ShapeType.line:
        return LineShape(start: start, end: end, style: style);
      case ShapeType.rectangle:
        return RectangleShape(start: start, end: end, style: style);
      case ShapeType.square:
        return SquareShape(start: start, end: end, style: style);
      case ShapeType.circle:
        return CircleShape(start: start, end: end, style: style);
      case ShapeType.ellipse:
        return EllipseShape(start: start, end: end, style: style);
    }
  }
}
