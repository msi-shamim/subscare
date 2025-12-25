// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 12;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as TransactionType,
      categoryId: fields[4] as String,
      dateTime: fields[5] as DateTime,
      notes: fields[6] as String?,
      entryMethod: fields[7] as EntryMethod,
      isRecurring: fields[8] as bool,
      subscriptionId: fields[9] as String?,
      ocrScanId: fields[10] as String?,
      aiPromptId: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      originalCurrency:
          fields[14] == null ? Currency.BDT : fields[14] as Currency,
      convertedAmount: fields[15] as double?,
      exchangeRateUsed: fields[16] as double?,
      isSettled: fields[17] == null ? false : fields[17] as bool,
      settledAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.entryMethod)
      ..writeByte(8)
      ..write(obj.isRecurring)
      ..writeByte(9)
      ..write(obj.subscriptionId)
      ..writeByte(10)
      ..write(obj.ocrScanId)
      ..writeByte(11)
      ..write(obj.aiPromptId)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.originalCurrency)
      ..writeByte(15)
      ..write(obj.convertedAmount)
      ..writeByte(16)
      ..write(obj.exchangeRateUsed)
      ..writeByte(17)
      ..write(obj.isSettled)
      ..writeByte(18)
      ..write(obj.settledAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
