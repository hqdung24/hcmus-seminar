import 'package:flutter/material.dart';
import 'ui/pages/canvas_page.dart';

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(useMaterial3: true),
      home: const CanvasPage(),
    );
  }
}
