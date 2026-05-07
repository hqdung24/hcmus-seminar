import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';

class ColorSwatchPicker extends StatelessWidget {
  final CanvasController controller;

  static const _palette = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.white,
  ];

  static String _colorName(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.red) return 'Red';
    if (color == Colors.green) return 'Green';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.white) return 'White';
    return 'Color 0x${color.value.toRadixString(16).toUpperCase()}';
  }

  const ColorSwatchPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in _palette)
          Tooltip(
            message: _colorName(color),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.setStyle(
                  controller.style.copyWith(strokeColor: color)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.style.strokeColor == color
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.5),
                      width: controller.style.strokeColor == color ? 3 : 1,
                    ),
                    boxShadow: [
                      if (controller.style.strokeColor == color)
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
