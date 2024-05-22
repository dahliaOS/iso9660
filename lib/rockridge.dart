import 'dart:typed_data';
import 'susp.dart';

class RockridgeNameEntry {
  SystemUseEntry systemUseEntry;
  Uint8List _data = Uint8List(0);
  int mode = 0;
  Uint8List flags = Uint8List(0);
  String name = '';

  RockridgeNameEntry(this.systemUseEntry) {
    _data = systemUseEntry.data;

    if (!systemUseEntry.hasRockRidge()) {
      throw Exception('Invalid Rock Ridge entry');
    }

    _getMode();
    _getNameEntry();
  }

  void _getMode() {
    int rrMode = _data.buffer.asByteData().getUint32(0, Endian.little);

    bool S_IFLNK = (rrMode & 0170000) == 0120000;
    bool S_IFDIR = (rrMode & 0170000) == 0040000;

    mode = rrMode & 07777;

    if (S_IFLNK) {
      // Symlink
      mode |= 0xA000;
    } else if (S_IFDIR) {
      // Directory
      mode |= 0x4000;
    }
  }

  void _getNameEntry() {
    flags = _data.sublist(0);
    name = String.fromCharCodes(_data.sublist(1));
    name = name.split('NM')[1].split('PX')[0];
    // regex all whitespace until the first character
    name = name.replaceAll(RegExp(r'^\s+'), '');
    var bytes = Uint8List.fromList(name.codeUnits);
    // remove the first 2 bytes
    bytes = bytes.sublist(2);
    name = String.fromCharCodes(bytes);
  }
}