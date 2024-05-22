import 'dart:typed_data';
import 'constants.dart';

// https://dev.lovelyhq.com/libburnia/libisofs/raw/branch/master/doc/boot_sectors.txt

class ValidationEntry {
  Uint8List _data;
  int headerId = 1;
  int platformId = 0;
  Uint8List reserved = Uint8List(2);
  String manufacturerDeveloper = '';
  int checksum = 0;

  ValidationEntry(this._data) {
    headerId = _data[0];
    platformId = _data[1];
    reserved = _data.sublist(2, 4);
    manufacturerDeveloper = String.fromCharCodes(_data.sublist(4, 28));
    checksum = _data[30] + _data[31];

    if (headerId != 1) {
      throw Exception('Invalid header ID');
    }

    if (!elToritoPlatformIds.contains(platformId)) {
      throw Exception('Invalid platform ID');
    }
  }

  @override
  String toString() {
    return 'ValidationEntry\n'
        '---------------\n'
        'headerId: $headerId\n'
        'platformId: $platformId\n'
        'reserved: $reserved\n'
        'manufacturerDeveloper: $manufacturerDeveloper\n'
        'checksum: $checksum';
  }
}

// Initial/Default Entry
class DefaultEntry {
  Uint8List _data;
  int bootIndicator = 0;
  int bootMediaType = 0;
  int loadSegment = 0;
  int systemType = 0;
  int sectorCount = 0;
  int loadRba = 0;

  DefaultEntry(this._data) {
    bootIndicator = _data[0];
    bootMediaType = _data[1];
    loadSegment = _data[2] + _data[3];
    systemType = _data[4];
    sectorCount = _data[6] + _data[7];
    loadRba = _data.buffer.asByteData().getUint32(8, Endian.little);

    if (bootIndicator != elToritoBootable &&
        bootIndicator != elToritoNotBootable) {
      throw Exception('Invalid boot indicator');
    }

    if (!elToritoBootableIds.contains(bootMediaType)) {
      throw Exception('Invalid boot media type');
    }
  }

  @override
  String toString() {
    return 'DefaultEntry\n'
        '---------------\n'
        'bootIndicator: $bootIndicator\n'
        'bootMediaType: $bootMediaType\n'
        'loadSegment: $loadSegment\n'
        'systemType: $systemType\n'
        'sectorCount: $sectorCount\n'
        'loadRba: $loadRba';
  }
}

class SectionHeaderEntry {
  Uint8List _data;
  int headerIndicator = 0;
  int platformId = 0;
  int numberOfEntries = 0;
  String manufacturerDeveloper = '';

  SectionHeaderEntry(this._data) {
    headerIndicator = _data[0];
    platformId = _data[1];
    numberOfEntries = _data[2] + _data[3];
    manufacturerDeveloper = String.fromCharCodes(_data.sublist(4, 32));

    if (headerIndicator != elToritoMoreHeaders &&
        headerIndicator != elToritoFinalHeader) {
      //throw Exception('Invalid header indicator');
    }

    if (!elToritoPlatformIds.contains(platformId)) {
      throw Exception('Invalid platform ID');
    }
  }

  @override
  String toString() {
    return 'SectionHeaderEntry\n'
        '---------------\n'
        'headerIndicator: $headerIndicator\n'
        'platformId: $platformId\n'
        'numberOfEntries: $numberOfEntries\n'
        'manufacturerDeveloper: $manufacturerDeveloper';
  }
}

class SectionEntry {
  Uint8List _data;
  int bootIndicator = 0;
  int bootMediaType = 0;
  int loadSegment = 0;
  int systemType = 0;
  int sectorCount = 0;
  int loadRba = 0;
  Uint8List vendorUniqueSelectionCriteria = Uint8List(20);

  SectionEntry(this._data) {
    bootIndicator = _data[0];
    bootMediaType = _data[1];
    loadSegment = _data[2] + _data[3];
    systemType = _data[4];
    sectorCount = _data[6] + _data[7];
    loadRba = _data.buffer.asByteData().getUint32(8, Endian.little);
    vendorUniqueSelectionCriteria = _data.sublist(12, 32);

    if (bootIndicator != elToritoBootable &&
        bootIndicator != elToritoNotBootable) {
      throw Exception('Invalid boot indicator');
    }

    if (!elToritoBootableIds.contains(bootMediaType)) {
      throw Exception('Invalid boot media type');
    }
  }

  @override
  String toString() {
    return 'SectionEntry\n'
        '---------------\n'
        'bootIndicator: $bootIndicator\n'
        'bootMediaType: $bootMediaType\n'
        'loadSegment: $loadSegment\n'
        'systemType: $systemType\n'
        'sectorCount: $sectorCount\n'
        'loadRba: $loadRba\n'
        'vendorUniqueSelectionCriteria: $vendorUniqueSelectionCriteria';
  }
}

class BootCatalog {
  Uint8List _data;
  late ValidationEntry validationEntry;
  late DefaultEntry defaultEntry;
  late SectionHeaderEntry sectionHeaderEntry;
  late SectionEntry sectionEntry;

  BootCatalog(this._data) {
    validationEntry = ValidationEntry(_data.sublist(0, 32));
    defaultEntry = DefaultEntry(_data.sublist(32, 64));
    sectionHeaderEntry = SectionHeaderEntry(_data.sublist(64, 96));
    sectionEntry = SectionEntry(_data.sublist(96, 128));
  }

  @override
  String toString() {
    return 'BootCatalog\n'
        '---------------\n'
        '$validationEntry\n'
        '$defaultEntry\n'
        '$sectionHeaderEntry\n'
        '$sectionEntry';
  }
}
