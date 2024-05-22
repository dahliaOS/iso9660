import 'dart:io';
import 'dart:typed_data';

Uint8List openIso(String path) {
  File file = File(path);
  return file.readAsBytesSync();
}

void writeToDisk(Uint8List data, String path, DateTime date) {
  File file = File(path);
  file.writeAsStringSync(String.fromCharCodes(data));
  file.setLastModifiedSync(date);
}
