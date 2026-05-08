import 'package:flutter/material.dart';
import '../../state/canvas_controller.dart';

enum SwatchTarget { stroke, fill }

class ColorSwatchPicker extends StatelessWidget {
  final CanvasController controller;
  final SwatchTarget target;

  static const _palette = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.white,
  ];

  static String _nameOf(Color c) {
    if (c == Colors.black) return 'Black';
    if (c == Colors.red) return 'Red';
    if (c == Colors.green) return 'Green';
    if (c == Colors.blue) return 'Blue';
    if (c == Colors.orange) return 'Orange';
    if (c == Colors.purple) return 'Purple';
    if (c == Colors.yellow) return 'Yellow';
    if (c == Colors.white) return 'White';
    return '';
  }

  const ColorSwatchPicker({
    super.key,
    required this.controller,
    this.target = SwatchTarget.stroke,
  });

  Color get _selected => target == SwatchTarget.stroke
      ? controller.style.strokeColor
      : controller.style.fillColor;

  void _pick(Color color) {
    final s = controller.style;
    controller.setStyle(
      target == SwatchTarget.stroke
          ? s.copyWith(strokeColor: color)
          : s.copyWith(fillColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in _palette)
          Tooltip(
            message: _nameOf(color),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _pick(color),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selected == color
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: _selected == color ? 3 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
