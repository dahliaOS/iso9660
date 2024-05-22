final blockSize = 2048;
final pvdOffset = 16 * blockSize;
final elToritoOffset = 17 * blockSize;

final elToritoPlatformIdx86 = 0;
final elToritoPlatformPowerPc = 1;
final elToritoPlatformMac = 2;
final elToritoPlatformEfi = 0xef;

final elToritoPlatformIds = {
  elToritoPlatformIdx86,
  elToritoPlatformPowerPc,
  elToritoPlatformMac,
  elToritoPlatformEfi
};

final elToritoBootable = 0x88; // 136
final elToritoNotBootable = 0x00;

final elToritoBootableNoEmulation = 0;
final elToritoBootableFloppy1_2MB = 1;
final elToritoBootableFloppy1_44MB = 2;
final elToritoBootableFloppy2_88MB = 3;
final elToritoBootableHardDrive = 4;

final elToritoBootableIds = {
  elToritoBootableNoEmulation,
  elToritoBootableFloppy1_2MB,
  elToritoBootableFloppy1_44MB,
  elToritoBootableFloppy2_88MB,
  elToritoBootableHardDrive
};

final elToritoMoreHeaders = 0x90;
final elToritoFinalHeader = 0x91;

final sueTypeContinuationArea = 'CE';
final sueTypePaddingField = 'PD';
final sueTypeSharingProtocolIndicator = 'SP';
final sueTypeVolumeStructureSetTerminator = 'ST';
final sueTypeExtensionReference = 'ER';
final sueTypeExtensionSelector = 'ES';
