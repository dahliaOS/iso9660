import 'dart:typed_data';
import 'package:iso9660/src/susp.dart';

class RockridgeNameEntry {
  SystemUseEntry systemUseEntry;
  int mode = 0;
  Uint8List flags = Uint8List(0);
  String name = '';

  RockridgeNameEntry(this.systemUseEntry) {
    if (!systemUseEntry.hasRockRidge()) {
      throw Exception('Invalid Rock Ridge entry');
    }

    _getMode(systemUseEntry.data);
    _getNameEntry(systemUseEntry.data);
  }

  void _getMode(Uint8List data) {
    int rrMode = data.buffer.asByteData().getUint32(0, Endian.little);

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

  void _getNameEntry(Uint8List data) {
    flags = data.sublist(0);
    name = String.fromCharCodes(data.sublist(1));
    name = name.split('NM')[1].split('PX')[0];
    // regex all whitespace until the first character
    name = name.replaceAll(RegExp(r'^\s+'), '');
    Uint8List bytes = Uint8List.fromList(name.codeUnits);
    // remove the first 2 bytes
    bytes = bytes.sublist(2);
    // remove non printable characters
    List<int> printableBytes =
        bytes.where((byte) => byte >= 32 && byte <= 126).toList();

    name = String.fromCharCodes(printableBytes);
  }
}
