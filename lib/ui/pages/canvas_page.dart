import 'package:flutter/material.dart';
import '../../services/export_service.dart';
import '../../services/file_service.dart';
import '../../state/canvas_controller.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/toolbar.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  final _controller = CanvasController();
  final _repaintKey = GlobalKey();
  final _fileService = FileService();
  final _exportService = ExportService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final path = await _fileService.save(_controller.shapes);
    _toast(path != null ? 'Saved to $path' : 'Save cancelled');
  }

  Future<void> _load() async {
    final shapes = await _fileService.load();
    if (shapes != null) {
      _controller.loadShapes(shapes);
      _toast('Loaded ${shapes.length} shapes');
    }
  }

  Future<void> _exportPng() async {
    final path = await _exportService.export(_repaintKey, ImageFormat.png);
    _toast(path != null ? 'Exported to $path' : 'Export cancelled');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing App'),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: _load),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
          IconButton(icon: const Icon(Icons.image), onPressed: _exportPng),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _controller.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          DrawingToolbar(controller: _controller),
          Expanded(
            child: DrawingCanvas(
              controller: _controller,
              repaintKey: _repaintKey,
            ),
          ),
        ],
      ),
    );
  }
}
