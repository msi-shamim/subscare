// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 18;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      id: fields[0] as String,
      notificationsEnabled: fields[1] as bool,
      soundEnabled: fields[2] as bool,
      vibrationEnabled: fields[3] as bool,
      defaultCurrency: fields[4] as String,
      dateFormat: fields[5] as String,
      biometricLock: fields[6] as bool,
      backupFrequency: fields[7] as BackupFrequency,
      lastSyncAt: fields[8] as DateTime?,
      language: fields[9] == null ? 'en' : fields[9] as String,
      themeMode: fields[10] == null ? 'light' : fields[10] as String,
      exchangeRate: fields[11] == null ? 120.0 : fields[11] as double,
      useAutoRate: fields[12] == null ? false : fields[12] as bool,
      lastRateUpdate: fields[13] as DateTime?,
      settlementHour: fields[14] == null ? 8 : fields[14] as int,
      settlementMinute: fields[15] == null ? 0 : fields[15] as int,
      settlementEnabled: fields[16] == null ? true : fields[16] as bool,
      openExchangeApiKey: fields[17] as String?,
      notificationHour: fields[18] == null ? 8 : fields[18] as int,
      notificationMinute: fields[19] == null ? 0 : fields[19] as int,
      selectedAIModelId: fields[20] as String?,
      aiApiKey: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.soundEnabled)
      ..writeByte(3)
      ..write(obj.vibrationEnabled)
      ..writeByte(4)
      ..write(obj.defaultCurrency)
      ..writeByte(5)
      ..write(obj.dateFormat)
      ..writeByte(6)
      ..write(obj.biometricLock)
      ..writeByte(7)
      ..write(obj.backupFrequency)
      ..writeByte(8)
      ..write(obj.lastSyncAt)
      ..writeByte(9)
      ..write(obj.language)
      ..writeByte(10)
      ..write(obj.themeMode)
      ..writeByte(11)
      ..write(obj.exchangeRate)
      ..writeByte(12)
      ..write(obj.useAutoRate)
      ..writeByte(13)
      ..write(obj.lastRateUpdate)
      ..writeByte(14)
      ..write(obj.settlementHour)
      ..writeByte(15)
      ..write(obj.settlementMinute)
      ..writeByte(16)
      ..write(obj.settlementEnabled)
      ..writeByte(17)
      ..write(obj.openExchangeApiKey)
      ..writeByte(18)
      ..write(obj.notificationHour)
      ..writeByte(19)
      ..write(obj.notificationMinute)
      ..writeByte(20)
      ..write(obj.selectedAIModelId)
      ..writeByte(21)
      ..write(obj.aiApiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
