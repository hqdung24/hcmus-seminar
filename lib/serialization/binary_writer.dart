import 'dart:typed_data';

/// Simple little-endian binary writer.
class BinaryWriter {
  final BytesBuilder _buffer = BytesBuilder();

  void writeUint8(int value) =>
      _buffer.add([value & 0xFF]);

  void writeUint32(int value) {
    final b = ByteData(4)..setUint32(0, value, Endian.little);
    _buffer.add(b.buffer.asUint8List());
  }

  void writeFloat32(double value) {
    final b = ByteData(4)..setFloat32(0, value, Endian.little);
    _buffer.add(b.buffer.asUint8List());
  }

  void writeBool(bool value) => writeUint8(value ? 1 : 0);

  Uint8List toBytes() => _buffer.toBytes();
}
