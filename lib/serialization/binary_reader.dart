import 'dart:typed_data';

class BinaryReader {
  final ByteData _data;
  int _offset = 0;

  BinaryReader(Uint8List bytes)
      : _data = ByteData.sublistView(bytes);

  bool get hasMore => _offset < _data.lengthInBytes;

  int readUint8() {
    final v = _data.getUint8(_offset);
    _offset += 1;
    return v;
  }

  int readUint32() {
    final v = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  double readFloat32() {
    final v = _data.getFloat32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  bool readBool() => readUint8() == 1;
}
