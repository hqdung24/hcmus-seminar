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
    return Row(
      children: [
        for (final color in _palette)
          GestureDetector(
            onTap: () => _pick(color),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selected == color ? Colors.blueAccent : Colors.grey,
                  width: _selected == color ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
