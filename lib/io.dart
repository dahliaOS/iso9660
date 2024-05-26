import 'dart:io';
import 'dart:typed_data';
import 'package:iso9660/iso9660.dart';

Uint8List openIso(String path) {
  File file = File(path);
  return file.readAsBytesSync();
}

void writeToDisk(Uint8List data, String path, DateTime date) {
  File file = File(path);
  file.createSync(recursive: true);
  file.writeAsStringSync(String.fromCharCodes(data));
  file.setLastModifiedSync(date);
  file.setLastAccessedSync(date);
}

void saveFiles(Entry entry, String path, {bool verbose = false}) {
  if (!path.endsWith('/')) {
    path += '/';
  }
  Stopwatch stopwatch = Stopwatch()..start();

  for (Entry child in entry.children) {
    saveFile(child, path, verbose);
  }

  if (verbose) {
    print('saving files took ${stopwatch.elapsed}');
  }
}

void saveFile(Entry entry, String path, bool verbose) {
  if (entry.isDirectory) {
    for (Entry child in entry.children) {
      saveFile(child, '$path${entry.name}/', verbose);
    }
  } else {
    Uint8List fileData = entry.data;
    String fileName = '$path${entry.name}';
    DateTime fileDate = entry.recordingDateAndTime;
    writeToDisk(fileData, fileName, fileDate);
    print('saved $path${entry.name}');
  }
}
