import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';
import 'color_swatch_picker.dart';
import 'stroke_width_slider.dart';

/// Two-row toolbar wrapped in an elevated card:
/// row 1 — tool selector (6 shapes + eraser + paint bucket)
/// row 2 — stroke colour + fill colour + fill toggle + stroke width slider
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
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toolsRow(context),
            const Divider(height: 1, indent: 12, endIndent: 12),
            _styleRow(),
          ],
        ),
      ),
    );
  }

  Widget _toolsRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tool in DrawingTool.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Tooltip(
                  message: _tooltipFor(tool),
                  child: IconButton(
                    isSelected: controller.tool == tool,
                    style: IconButton.styleFrom(
                      backgroundColor: controller.tool == tool
                          ? scheme.primaryContainer
                          : null,
                      foregroundColor: controller.tool == tool
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    icon: Icon(_iconFor(tool)),
                    onPressed: () => controller.setTool(tool),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _styleRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                mainAxisSize: MainAxisSize.min,
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
            StrokeWidthSlider(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _group({required String label, required Widget child}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
      case DrawingTool.fill:
        return Icons.format_color_fill;
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
      case DrawingTool.fill:
        return 'Paint bucket';
    }
  }
}
