// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_scan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OCRScanAdapter extends TypeAdapter<OCRScan> {
  @override
  final int typeId = 16;

  @override
  OCRScan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OCRScan(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      extractedText: fields[2] as String?,
      parsedVendor: fields[3] as String?,
      parsedAmount: fields[4] as double?,
      parsedDate: fields[5] as DateTime?,
      status: fields[6] as OCRStatus,
      confidence: fields[7] as double?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OCRScan obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.extractedText)
      ..writeByte(3)
      ..write(obj.parsedVendor)
      ..writeByte(4)
      ..write(obj.parsedAmount)
      ..writeByte(5)
      ..write(obj.parsedDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OCRScanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
