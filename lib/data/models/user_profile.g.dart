// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 10;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String?,
      avatarUrl: fields[3] as String?,
      currency: fields[4] as String,
      theme: fields[5] as AppThemeMode,
      isOnboarded: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      lastBackup: fields[8] as DateTime?,
      phone: fields[9] as String?,
      occupation: fields[10] as String?,
      divisionId: fields[11] as String?,
      districtId: fields[12] as String?,
      address: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.theme)
      ..writeByte(6)
      ..write(obj.isOnboarded)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastBackup)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.occupation)
      ..writeByte(11)
      ..write(obj.divisionId)
      ..writeByte(12)
      ..write(obj.districtId)
      ..writeByte(13)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
