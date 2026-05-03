import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';

class StrokeWidthSlider extends StatelessWidget {
  final CanvasController controller;

  const StrokeWidthSlider({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: controller.style.strokeWidth,
      min: 1,
      max: 20,
      divisions: 19,
      label: controller.style.strokeWidth.toStringAsFixed(0),
      onChanged: (v) =>
          controller.setStyle(controller.style.copyWith(strokeWidth: v)),
    );
  }
}
