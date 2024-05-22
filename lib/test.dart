import 'dart:io';

void main() {
  // create a new file
  var file = File('test.txt');
  // write to the file
  file.writeAsStringSync('Hello, World!');
}
