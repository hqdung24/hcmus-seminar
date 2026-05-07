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
    try {
      final shapes = await _fileService.load();
      if (shapes != null) {
        _controller.loadShapes(shapes);
        _toast('Loaded ${shapes.length} shapes');
      }
    } on FormatException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid File'),
            content: const Text('The selected file is not a valid drawing file or is corrupted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _toast('Error loading file: $e');
    }
  }

  Future<void> _exportPng() async {
    final path = await _exportService.export(_repaintKey, ImageFormat.png);
    _toast(path != null ? 'Exported to $path' : 'Export cancelled');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing App'),
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Load'),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _save,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Export'),
            onPressed: _exportPng,
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
            onPressed: _controller.clear,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: DrawingCanvas(
                    controller: _controller,
                    repaintKey: _repaintKey,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: DrawingToolbar(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
