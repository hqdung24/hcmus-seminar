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
  ];

  const ColorSwatchPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in _palette)
          GestureDetector(
            onTap: () => controller.setStyle(
                controller.style.copyWith(strokeColor: color)),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: controller.style.strokeColor == color
                      ? Colors.white
                      : Colors.grey,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
