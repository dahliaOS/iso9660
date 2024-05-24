import 'dart:typed_data';
import 'package:iso9660/iso9660.dart';
import 'package:iso9660/io.dart';

void main() {
  String fileName = 'test.iso';
  Uint8List data = openIso(fileName);

  var iso9960 = Iso9960(data);

  for (var entry in iso9960.files.children) {
    saveFile(entry, '/home/quinten/Desktop/iso9660/test/');
  }
}
