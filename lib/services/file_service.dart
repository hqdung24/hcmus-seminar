import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/shape.dart';
import '../serialization/shape_codec.dart';

/// Cross-platform file IO. Uses file_picker so the same code works on
/// Windows (Win32 file dialog) and Android (Storage Access Framework).
class FileService {
  /// Save shapes to a user-chosen .draw file. Returns the path or null.
  Future<String?> save(List<Shape> shapes) async {
    final bytes = ShapeCodec.encodeAll(shapes);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save drawing',
      fileName: 'drawing.draw',
      bytes: bytes, // Android requires bytes; desktop ignores this and uses path
    );
    if (path == null) return null;
    // On desktop, we still need to write the file ourselves.
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return path;
  }

  /// Open a .draw file and return the parsed shapes, or null if cancelled.
  /// Android's Storage Access Framework rejects custom extensions, so we
  /// fall back to FileType.any there and let the codec validate the bytes.
  Future<List<Shape>?> load() async {
    final useCustomFilter = !Platform.isAndroid && !Platform.isIOS;
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open drawing',
      type: useCustomFilter ? FileType.custom : FileType.any,
      allowedExtensions: useCustomFilter ? ['draw'] : null,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final Uint8List bytes = file.bytes ??
        await File(file.path!).readAsBytes();
    return ShapeCodec.decodeAll(bytes);
  }
}
