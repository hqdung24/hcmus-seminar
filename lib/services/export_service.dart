import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';

enum ImageFormat { png, jpeg }

class ExportService {
  /// Captures the widget under [repaintKey] and writes it to a user-chosen file.
  Future<String?> export(GlobalKey repaintKey, ImageFormat format) async {
    final boundary = repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(
      format: format == ImageFormat.png
          ? ui.ImageByteFormat.png
          : ui.ImageByteFormat.rawRgba, // JPEG handled below
    );
    if (byteData == null) return null;

    // For JPEG we'd need an extra encoder; for skeleton we write PNG only.
    // (Easiest: stick to PNG, or add `image` package later.)
    final bytes = byteData.buffer.asUint8List();

    final ext = format == ImageFormat.png ? 'png' : 'png';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export image',
      fileName: 'drawing.$ext',
      bytes: bytes,
    );
    if (path == null) return null;
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return path;
  }
}
