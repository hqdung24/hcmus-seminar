import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

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
          : ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return null;

    Uint8List finalBytes;
    if (format == ImageFormat.png) {
      finalBytes = byteData.buffer.asUint8List();
    } else {
      final rawBytes = byteData.buffer.asUint8List();
      final imgImage = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: rawBytes.buffer,
        order: img.ChannelOrder.rgba,
      );
      finalBytes = img.encodeJpg(imgImage);
    }

    final ext = format == ImageFormat.png ? 'png' : 'jpg';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export image',
      fileName: 'drawing.$ext',
      bytes: finalBytes,
    );
    
    if (path == null) return null;
    
    // FilePicker on desktop (Windows/Linux/macOS) usually returns a path but doesn't write bytes.
    // On web it handles download, but we are targeting Windows/Mobile.
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(finalBytes);
    }
    
    return path;
  }
}
