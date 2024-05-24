import 'dart:io';
import 'dart:typed_data';
import 'package:iso9660/iso9660.dart';

Uint8List openIso(String path) {
  File file = File(path);
  return file.readAsBytesSync();
}

void writeToDisk(Uint8List data, String path, DateTime date) {
  File file = File(path);
  file.writeAsStringSync(String.fromCharCodes(data));
  file.setLastModifiedSync(date);
}

void createDirectory(String path) {
  Directory directory = Directory(path);
  directory.createSync();
}

void saveFile(Entry entry, String path) {
  if (entry.flags == 2) {
    for (var child in entry.children) {
      createDirectory('$path${entry.name}/');
      saveFile(child, '$path${entry.name}/');
    }
  } else {
    Uint8List fileData = entry.data;
    String fileName = '$path${entry.name}';
    DateTime date = entry.recordingDateAndTime;
    writeToDisk(fileData, fileName, date);
  }
}
