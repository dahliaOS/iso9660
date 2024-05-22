import 'dart:typed_data';

class SystemUseEntry {
  int length = 0;
  Uint8List data = Uint8List(0);
  String type = '';

  SystemUseEntry(this.data) {
    length = data[2];
    type = String.fromCharCodes(data.sublist(0, 2));
  }

  bool hasRockRidge() {
    return type == 'RR' || type == 'PX';
  }

  @override
  String toString() {
    return 'SystemUseEntry\n'
        '==============\n'
        'type: $type\n'
        'length: $length\n'
        'data: $data\n';
  }
}

class ExtensionRecord {
  SystemUseEntry systemUseEntry;
  Uint8List _data = Uint8List(0);
  int version = 0;
  String identifier = '';
  String descriptor = '';
  String source = '';

  ExtensionRecord(this.systemUseEntry) {
    _data = systemUseEntry.data;

    if (systemUseEntry.type != 'ER') {
      throw Exception('Invalid extension record type');
    }

    if (systemUseEntry.length < 5) {
      throw Exception('Invalid extension record length');
    }

    int identifierLength = _data[4];
    int descriptorLength = _data[5];
    int sourceLength = _data[6];

    if (systemUseEntry.length <
        8 + identifierLength + descriptorLength + sourceLength) {
      throw Exception('Invalid extension record length');
    }

    version = _data[7];
    identifier = String.fromCharCodes(_data.sublist(8, 8 + identifierLength));
    descriptor = String.fromCharCodes(_data.sublist(
        8 + identifierLength, 8 + identifierLength + descriptorLength));
    source = String.fromCharCodes(_data.sublist(
        8 + identifierLength + descriptorLength,
        8 + identifierLength + descriptorLength + sourceLength));
  }
}
