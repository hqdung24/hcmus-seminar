import 'package:flutter/material.dart';
import '../models/shape.dart';

/// Renders the list of committed shapes plus an in-progress draft.
/// `repaint` is hooked to the controller so the painter only repaints
/// when the controller calls notifyListeners().
class CanvasPainter extends CustomPainter {
  final List<Shape> shapes;
  final Shape? draft;

  CanvasPainter({
    required Listenable repaint,
    required this.shapes,
    required this.draft,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // White background so PNG/JPEG export looks clean.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );
    for (final shape in shapes) {
      shape.draw(canvas);
    }
    draft?.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.shapes != shapes || oldDelegate.draft != draft;
}
