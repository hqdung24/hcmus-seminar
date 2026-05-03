import 'package:flutter/material.dart';
import '../../painter/canvas_painter.dart';
import '../../state/canvas_controller.dart';

/// Unified gesture handler for both touch (Android) and mouse (Windows).
/// Both platforms emit pan events, so a single GestureDetector handles both.
class DrawingCanvas extends StatelessWidget {
  final CanvasController controller;
  final GlobalKey repaintKey;

  const DrawingCanvas({
    super.key,
    required this.controller,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => controller.startDrawing(d.localPosition),
      onPanUpdate: (d) => controller.updateDrawing(d.localPosition),
      onPanEnd: (_) => controller.endDrawing(),
      // Single-tap = point shape (no drag, immediate commit).
      onTapDown: (d) {
        controller.startDrawing(d.localPosition);
        controller.endDrawing();
      },
      child: RepaintBoundary(
        key: repaintKey,
        child: ListenableBuilder(
          listenable: controller,
          builder: (_, __) => CustomPaint(
            painter: CanvasPainter(
              repaint: controller,
              shapes: controller.shapes,
              draft: controller.draftShape,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
