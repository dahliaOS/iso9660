import 'dart:typed_data';
import 'package:iso9960/constants.dart';
import 'package:iso9960/el_torito.dart';
import 'package:iso9960/susp.dart';
import 'package:iso9960/rockridge.dart';

void printFiles(Entry entry, fileName) {
  print("Contents of $fileName:");
  printFile(entry);
}

void printFile(Entry entry, {int depth = 0}) {
  print('${' ' * depth}${entry.name} - ${entry.recordingDateAndTime}');

  for (Entry child in entry.children) {
    printFile(child, depth: depth + 2);
  }
}

DateTime primaryVolumeDescriptorDateTime(Uint8List data) {
  int year = data[0] + 1970;
  int month = data[1];
  int day = data[2];
  int hour = data[3];
  int minute = data[4];
  int second = data[5];
  return DateTime(year, month, day, hour, minute, second);
}

DateTime directoryDateTime(Uint8List data) {
  int year = data[0] + 1900;
  int month = data[1];
  int day = data[2];
  int hour = data[3];
  int minute = data[4];
  int second = data[5];
  return DateTime(year, month, day, hour, minute, second);
}

class Iso9960 {
  Uint8List _data;
  late PrimaryVolumeDescriptor primaryVolumeDescriptor;
  late PathTable lPathTable;
  late PathTable mPathTable;
  late BootRecord bootRecord;
  late BootCatalog bootCatalog;
  late Entry files;

  Iso9960(this._data) {
    primaryVolumeDescriptor = PrimaryVolumeDescriptor(
        _data.sublist(pvdOffset, pvdOffset + blockSize));
    lPathTable = PathTable(
        _data.sublist(
            primaryVolumeDescriptor.typeLPathTableLocation * blockSize,
            primaryVolumeDescriptor.typeLPathTableLocation * blockSize +
                primaryVolumeDescriptor.pathTableSize),
        true);

    mPathTable = PathTable(
        _data.sublist(
            primaryVolumeDescriptor.typeMPathTableLocation * blockSize,
            primaryVolumeDescriptor.typeMPathTableLocation * blockSize +
                primaryVolumeDescriptor.pathTableSize),
        false);

    bootRecord =
        BootRecord(_data.sublist(elToritoOffset, elToritoOffset + blockSize));

    bootCatalog = BootCatalog(_data.sublist(bootRecord.cataloglba * blockSize,
        bootRecord.cataloglba * blockSize + blockSize));

    files = Entry(
        _data.sublist(
            primaryVolumeDescriptor.rootDirectoryEntry.locationOfExtent *
                blockSize,
            primaryVolumeDescriptor.rootDirectoryEntry.locationOfExtent *
                    blockSize +
                primaryVolumeDescriptor.rootDirectoryEntry.dataLength),
        _data);
  }
}

class BootRecord {
  Uint8List _data;
  int typeCode = 0x00;
  String standardIdentifier = 'CD001';
  int version = 0x01;
  String bootSystemIdentifier = '';
  String bootIdentifier = '';
  Uint8List bootSystemUse = Uint8List(1977);
  int cataloglba = 0;

  BootRecord(this._data) {
    typeCode = _data[0];

    if (typeCode != 0x00) {
      throw Exception('Invalid Boot Record');
    }

    if (String.fromCharCodes(_data.sublist(1, 6)) != standardIdentifier) {
      throw Exception('Invalid Standard Identifier');
    }

    if (_data[6] != version) {
      throw Exception('Invalid Version');
    }

    bootSystemIdentifier = String.fromCharCodes(_data.sublist(7, 39));
    bootIdentifier = String.fromCharCodes(_data.sublist(39, 71));
    bootSystemUse = _data.sublist(71, blockSize);
    cataloglba = _data.buffer.asByteData().getUint32(71, Endian.little);
  }

  @override
  String toString() {
    return 'Boot Record\n'
        '-----------\n'
        'Type Code: $typeCode\n'
        'Standard Identifier: $standardIdentifier\n'
        'Version: $version\n'
        'Boot System Identifier: $bootSystemIdentifier\n'
        'Boot Identifier: $bootIdentifier\n'
        'cataloglba: $cataloglba\n'
        'Boot System Use: $bootSystemUse';
  }
}

class PrimaryVolumeDescriptor {
  Uint8List _data;
  int typeCode = 0x01;
  String standardIdentifier = 'CD001';
  int version = 0x01;
  int unused = 0x00;
  String systemIdentifier = '';
  String volumeIdentifier = '';
  int volumeSpaceSize = 0;
  int volumeSetSize = 0;
  int volumeSequenceNumber = 0;
  int logicalBlockSize = 0;
  int pathTableSize = 0;
  int typeLPathTableLocation = 0;
  int optionalTypeLPathTableLocation = 0;
  int typeMPathTableLocation = 0;
  int optionalTypeMPathTableLocation = 0;
  late DirectoryEntry rootDirectoryEntry;
  String volumeSetIdentifier = '';
  String publisherIdentifier = '';
  String dataPreparerIdentifier = '';
  String applicationIdentifier = '';
  String copyrightFileIdentifier = '';
  String abstractFileIdentifier = '';
  String bibliographicFileIdentifier = '';
  DateTime volumeCreationDate = DateTime.now();
  DateTime volumeModificationDate = DateTime.now();
  DateTime volumeExpirationDate = DateTime.now();
  DateTime volumeEffectiveDate = DateTime.now();
  int fileStructureVersion = 0;
  Uint8List applicationUsed = Uint8List(512);

  PrimaryVolumeDescriptor(this._data) {
    if (_data[0] != typeCode) {
      throw Exception('Invalid Primary Volume Descriptor');
    }

    if (String.fromCharCodes(_data.sublist(1, 6)) != standardIdentifier) {
      throw Exception('Invalid Standard Identifier');
    }

    if (_data[6] != version) {
      throw Exception('Invalid Version');
    }

    systemIdentifier = String.fromCharCodes(_data.sublist(8, 40));
    volumeIdentifier = String.fromCharCodes(_data.sublist(40, 72));
    volumeSpaceSize = _data.buffer.asByteData().getUint32(80, Endian.little);
    volumeSetSize = _data.buffer.asByteData().getUint16(120, Endian.little);
    volumeSequenceNumber =
        _data.buffer.asByteData().getUint16(124, Endian.little);
    logicalBlockSize = _data.buffer.asByteData().getUint16(128, Endian.little);
    pathTableSize = _data.buffer.asByteData().getUint32(132, Endian.little);
    typeLPathTableLocation =
        _data.buffer.asByteData().getUint32(140, Endian.little);
    optionalTypeLPathTableLocation =
        _data.buffer.asByteData().getUint32(144, Endian.little);
    typeMPathTableLocation =
        _data.buffer.asByteData().getUint32(148, Endian.big);
    optionalTypeMPathTableLocation =
        _data.buffer.asByteData().getUint32(152, Endian.big);

    rootDirectoryEntry = DirectoryEntry(_data.sublist(156, 190));
    volumeSetIdentifier = String.fromCharCodes(_data.sublist(190, 318));
    publisherIdentifier = String.fromCharCodes(_data.sublist(318, 446));
    dataPreparerIdentifier = String.fromCharCodes(_data.sublist(446, 574));
    applicationIdentifier = String.fromCharCodes(_data.sublist(574, 702));
    copyrightFileIdentifier = String.fromCharCodes(_data.sublist(702, 740));
    abstractFileIdentifier = String.fromCharCodes(_data.sublist(740, 776));
    bibliographicFileIdentifier = String.fromCharCodes(_data.sublist(776, 813));

    volumeCreationDate =
        primaryVolumeDescriptorDateTime(_data.sublist(813, 830));
    volumeModificationDate =
        primaryVolumeDescriptorDateTime(_data.sublist(830, 847));
    volumeExpirationDate =
        primaryVolumeDescriptorDateTime(_data.sublist(847, 864));
    volumeEffectiveDate =
        primaryVolumeDescriptorDateTime(_data.sublist(864, 881));

    fileStructureVersion = _data[881];
    applicationUsed = _data.sublist(883, 1395);
  }

  @override
  String toString() {
    return 'Primary Volume Descriptor\n'
        '-------------------------\n'
        'Type Code: $typeCode\n'
        'Standard Identifier: $standardIdentifier\n'
        'Version: $version\n'
        'Unused: $unused\n'
        'System Identifier: $systemIdentifier\n'
        'Volume Identifier: $volumeIdentifier\n'
        'Volume Space Size: $volumeSpaceSize\n'
        'Volume Set Size: $volumeSetSize\n'
        'Volume Sequence Number: $volumeSequenceNumber\n'
        'Logical Block Size: $logicalBlockSize\n'
        'Path Table Size: $pathTableSize\n'
        'Type L Path Table Location: $typeLPathTableLocation\n'
        'Optional Type L Path Table Location: $optionalTypeLPathTableLocation\n'
        'Type M Path Table Location: $typeMPathTableLocation\n'
        'Optional Type M Path Table Location: $optionalTypeMPathTableLocation\n'
        'Root Directory Entry: $rootDirectoryEntry\n'
        'Volume Set Identifier: $volumeSetIdentifier\n'
        'Publisher Identifier: $publisherIdentifier\n'
        'Data Preparer Identifier: $dataPreparerIdentifier\n'
        'Application Identifier: $applicationIdentifier\n'
        'Copyright File Identifier: $copyrightFileIdentifier\n'
        'Abstract File Identifier: $abstractFileIdentifier\n'
        'Bibliographic File Identifier: $bibliographicFileIdentifier\n'
        'Volume Creation Date: $volumeCreationDate\n'
        'Volume Modification Date: $volumeModificationDate\n'
        'Volume Expiration Date: $volumeExpirationDate\n'
        'Volume Effective Date: $volumeEffectiveDate\n'
        'File Structure Version: $fileStructureVersion';
  }
}

class Entry {
  List<Entry> children = [];
  Uint8List data = Uint8List(0);
  String name = '';
  int mode = 0;
  int flags = 0;
  DateTime recordingDateAndTime = DateTime.now();

  Entry(this.data, Uint8List isoData) {
    DirectoryEntry entry = DirectoryEntry(data);
    SystemUseEntry systemUseEntry = SystemUseEntry(entry.systemUse);

    if (systemUseEntry.hasRockRidge()) {
      RockridgeNameEntry rockridgeNameEntry =
          RockridgeNameEntry(systemUseEntry);
      name = rockridgeNameEntry.name;
      mode = rockridgeNameEntry.mode;
      flags = entry.fileFlags;
      recordingDateAndTime = entry.recordingDateAndTime;
      data = isoData.sublist(entry.locationOfExtent * blockSize,
          entry.locationOfExtent * blockSize + entry.dataLength);

      if (isDirectory) {
        Uint8List _data = isoData.sublist(entry.locationOfExtent * blockSize,
            entry.locationOfExtent * blockSize + entry.dataLength);

        List<Uint8List> _entries = [];
        int offset = 0;

        while (offset < _data.length) {
          int length = _data[offset];
          if (length == 0) {
            do {
              offset++;
            } while (offset < _data.length && _data[offset] == 0);

            if (offset >= _data.length) {
              break;
            }

            length = _data[offset];
          }

          var entry = _data.sublist(offset, offset + length);
          _entries.add(entry);
          offset += length;
        }

        _entries.removeRange(0, 2);

        for (Uint8List entry in _entries) {
          Entry child = Entry(entry, isoData);
          children.add(child);
        }
      }
    } else {
      List<Uint8List> _entries = [];
      int offset = 0;

      while (offset < data.length) {
        int length = data[offset];
        if (length == 0) {
          break;
        }

        var entry = data.sublist(offset, offset + length);
        _entries.add(entry);
        offset += length;
      }

      if (_entries.length > 2) {
        _entries.removeRange(0, 2);
      } else {
        throw Exception('Invalid Entry');
      }

      for (Uint8List entry in _entries) {
        Entry child = Entry(entry, isoData);
        children.add(child);
      }
    }
  }

  bool get isDirectory => flags == 2;

  @override
  String toString() {
    return name;
  }
}

class DirectoryEntry {
  Uint8List _data;
  int length = 0;
  int extendedAttributeRecordLength = 0;
  int locationOfExtent = 0;
  int dataLength = 0;
  DateTime recordingDateAndTime = DateTime.now();
  int fileFlags = 0;
  int fileUnitSize = 0;
  int interleaveGapSize = 0;
  int volumeSequenceNumber = 0;
  int fileLength = 0;
  String fileIdentifier = '';
  Uint8List systemUse = Uint8List(0);

  DirectoryEntry(this._data) {
    length = _data[0];
    extendedAttributeRecordLength = _data[1];
    locationOfExtent = _data.buffer.asByteData().getUint32(2, Endian.little);
    dataLength = _data.buffer.asByteData().getUint32(10, Endian.little);
    recordingDateAndTime = directoryDateTime(_data.sublist(18, 25));
    fileFlags = _data[25];
    fileUnitSize = _data[26];
    interleaveGapSize = _data[27];
    volumeSequenceNumber =
        _data.buffer.asByteData().getUint16(28, Endian.little);
    fileLength = _data[32];
    fileIdentifier = String.fromCharCodes(_data.sublist(33, 33 + fileLength));

    int idPaddingLen = (fileLength + 1) % 2;

    systemUse = _data.sublist(33 + fileLength + idPaddingLen, length);
  }

  @override
  String toString() {
    return 'Directory Entry\n'
        '---------------\n'
        'Length: $length\n'
        'Extended Attribute Record Length: $extendedAttributeRecordLength\n'
        'Location of Extent: $locationOfExtent\n'
        'Data Length: $dataLength\n'
        'Recording Date and Time: $recordingDateAndTime\n'
        'File Flags: $fileFlags\n'
        'File Unit Size: $fileUnitSize\n'
        'Interleave Gap Size: $interleaveGapSize\n'
        'Volume Sequence Number: $volumeSequenceNumber\n'
        'File Length: $fileLength\n'
        'File Identifier: $fileIdentifier\n'
        'System Use: $systemUse';
  }
}

class PathTable {
  Uint8List _data;
  bool lTable = false;
  int length = 0;
  int extendedAttributeRecordLength = 0;
  int locationOfExtent = 0;
  int parentDirectoryNumber = 0;
  String directoryIdentifier = '';

  PathTable(this._data, this.lTable) {
    length = _data[0];
    extendedAttributeRecordLength = _data[1];

    if (lTable) {
      locationOfExtent = _data.buffer.asByteData().getUint32(2, Endian.little);
      parentDirectoryNumber =
          _data.buffer.asByteData().getUint16(8, Endian.little);
    } else {
      locationOfExtent = _data.buffer.asByteData().getUint32(2, Endian.big);
      parentDirectoryNumber =
          _data.buffer.asByteData().getUint16(6, Endian.big);
    }

    directoryIdentifier = String.fromCharCodes(_data.sublist(33, 33 + length));
  }

  @override
  String toString() {
    return 'Path Table\n'
        '----------\n'
        'Length: $length\n'
        'Extended Attribute Record Length: $extendedAttributeRecordLength\n'
        'Location of Extent: $locationOfExtent\n'
        'Parent Directory Number: $parentDirectoryNumber\n'
        'Directory Identifier: $directoryIdentifier';
  }
}
