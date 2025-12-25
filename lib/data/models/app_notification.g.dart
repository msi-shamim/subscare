// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 22;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      type: fields[3] as NotificationType,
      relatedItemId: fields[4] as String?,
      isRead: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
      payload: (fields[7] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.relatedItemId)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.payload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
