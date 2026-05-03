import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';
import 'color_swatch_picker.dart';
import 'stroke_width_slider.dart';

class DrawingToolbar extends StatelessWidget {
  final CanvasController controller;

  const DrawingToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final tool in DrawingTool.values)
                IconButton(
                  isSelected: controller.tool == tool,
                  icon: Icon(_iconFor(tool)),
                  onPressed: () => controller.setTool(tool),
                  tooltip: tool.name,
                ),
              const VerticalDivider(),
              ColorSwatchPicker(controller: controller),
              const VerticalDivider(),
              SizedBox(
                width: 200,
                child: StrokeWidthSlider(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DrawingTool t) {
    switch (t) {
      case DrawingTool.point:
        return Icons.circle;
      case DrawingTool.line:
        return Icons.show_chart;
      case DrawingTool.rectangle:
        return Icons.crop_landscape;
      case DrawingTool.square:
        return Icons.crop_square;
      case DrawingTool.circle:
        return Icons.circle_outlined;
      case DrawingTool.ellipse:
        return Icons.panorama_fish_eye;
    }
  }
}
