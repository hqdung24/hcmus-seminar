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
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toolsRow(),
            const Divider(height: 1),
            _styleRow(),
          ],
        ),
      ),
    );
  }

  Widget _toolsRow() {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                for (final tool in DrawingTool.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.tool == tool
                            ? scheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: controller.tool == tool
                              ? scheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(_iconFor(tool)),
                        color: controller.tool == tool
                            ? scheme.onPrimaryContainer
                            : null,
                        onPressed: () => controller.setTool(tool),
                        tooltip: _tooltipFor(tool),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _styleRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _group(
              label: 'Stroke',
              child: ColorSwatchPicker(
                controller: controller,
                target: SwatchTarget.stroke,
              ),
            ),
            _divider(),
            _group(
              label: 'Fill',
              child: Row(
                children: [
                  ColorSwatchPicker(
                    controller: controller,
                    target: SwatchTarget.fill,
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: controller.style.filled,
                    onChanged: (v) => controller.setStyle(
                      controller.style.copyWith(filled: v),
                    ),
                  ),
                ],
              ),
            ),
            _divider(),
            _group(
              label: 'Width',
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: StrokeWidthSlider(controller: controller),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      controller.style.strokeWidth.toStringAsFixed(0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        child,
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 32,
          child: VerticalDivider(width: 1),
        ),
      );

  IconData _iconFor(DrawingTool t) {
    switch (t) {
      case DrawingTool.point:
        return Icons.fiber_manual_record;
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
      case DrawingTool.eraser:
        return Icons.cleaning_services;
    }
  }

  String _tooltipFor(DrawingTool t) {
    switch (t) {
      case DrawingTool.point:
        return 'Point';
      case DrawingTool.line:
        return 'Line';
      case DrawingTool.rectangle:
        return 'Rectangle';
      case DrawingTool.square:
        return 'Square';
      case DrawingTool.circle:
        return 'Circle';
      case DrawingTool.ellipse:
        return 'Ellipse';
      case DrawingTool.eraser:
        return 'Eraser';
    }
  }
}
