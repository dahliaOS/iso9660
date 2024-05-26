import 'dart:typed_data';
import 'package:iso9660/iso9660.dart';
import 'package:iso9660/io.dart';

void main() {
  String fileName = 'linuxmint-21.3-cinnamon-64bit.iso';
  Uint8List data = openIso(fileName);

  var iso9660 = Iso9660(data);

  saveFiles(iso9660.files, 'test/', verbose: true);
}
