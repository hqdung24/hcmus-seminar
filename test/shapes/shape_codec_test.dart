import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcmus_seminar/models/shape.dart';
import 'package:hcmus_seminar/models/shape_style.dart';
import 'package:hcmus_seminar/models/shapes/rectangle_shape.dart';
import 'package:hcmus_seminar/serialization/shape_codec.dart';

void main() {
  test('encode then decode preserves shapes', () {
    final original = [
      RectangleShape(
        start: const Offset(10, 20),
        end: const Offset(100, 200),
        style: const ShapeStyle(
          strokeColor: Colors.red,
          fillColor: Colors.blue,
          strokeWidth: 3,
          filled: true,
        ),
      ),
    ];

    final bytes = ShapeCodec.encodeAll(original);
    final decoded = ShapeCodec.decodeAll(bytes);

    expect(decoded.length, 1);
    expect(decoded.first.type, ShapeType.rectangle);
    expect(decoded.first.start, original.first.start);
    expect(decoded.first.end, original.first.end);
    expect(decoded.first.style.strokeColor.value,
        original.first.style.strokeColor.value);
  });
}
