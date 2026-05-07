import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';

class StrokeWidthSlider extends StatelessWidget {
  final CanvasController controller;

  const StrokeWidthSlider({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Tooltip(
          message: 'Stroke Width',
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.line_weight, size: 20),
          ),
        ),
        SizedBox(
          width: 150,
          child: Slider(
            value: controller.style.strokeWidth,
            min: 1,
            max: 20,
            divisions: 19,
            label: '${controller.style.strokeWidth.toStringAsFixed(0)} px',
            onChanged: (v) =>
                controller.setStyle(controller.style.copyWith(strokeWidth: v)),
          ),
        ),
      ],
    );
  }
}
