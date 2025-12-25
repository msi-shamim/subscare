// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttachmentAdapter extends TypeAdapter<Attachment> {
  @override
  final int typeId = 15;

  @override
  Attachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attachment(
      id: fields[0] as String,
      transactionId: fields[1] as String?,
      ocrScanId: fields[2] as String?,
      filePath: fields[3] as String,
      fileName: fields[4] as String,
      fileType: fields[5] as FileType,
      fileSize: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Attachment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transactionId)
      ..writeByte(2)
      ..write(obj.ocrScanId)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.fileName)
      ..writeByte(5)
      ..write(obj.fileType)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
