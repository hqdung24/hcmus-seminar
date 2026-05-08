import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ExportService {
  /// Captures the widget under [repaintKey] and writes it to a user-chosen PNG file.
  Future<String?> exportPng(GlobalKey repaintKey) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export PNG',
      fileName: 'drawing.png',
      bytes: bytes,
    );
    if (path == null) return null;
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return path;
  }
}
