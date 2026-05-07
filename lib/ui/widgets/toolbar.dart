import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';
import 'color_swatch_picker.dart';
import 'stroke_width_slider.dart';

class DrawingToolbar extends StatelessWidget {
  final CanvasController controller;

  const DrawingToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final tool in DrawingTool.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Tooltip(
                        message: tool.name.toUpperCase(),
                        child: IconButton(
                          isSelected: controller.tool == tool,
                          style: IconButton.styleFrom(
                            backgroundColor: controller.tool == tool 
                                ? Theme.of(context).colorScheme.primaryContainer 
                                : null,
                            foregroundColor: controller.tool == tool
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          icon: Icon(_iconFor(tool)),
                          onPressed: () => controller.setTool(tool),
                        ),
                      ),
                    ),
                  const VerticalDivider(width: 32, indent: 4, endIndent: 4),
                  ColorSwatchPicker(controller: controller),
                  const VerticalDivider(width: 32, indent: 4, endIndent: 4),
                  StrokeWidthSlider(controller: controller),
                ],
              ),
            ),
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
      case DrawingTool.fill:
        return Icons.format_color_fill;
    }
  }
}
