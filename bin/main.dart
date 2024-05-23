import 'dart:typed_data';
import 'package:iso9960/iso9960.dart';
import 'package:iso9960/io.dart';

void main() {
  String fileName = 'test.iso';
  Uint8List data = openIso(fileName);

  var iso9960 = Iso9960(data);

  printFiles(iso9960.files, fileName);
}
