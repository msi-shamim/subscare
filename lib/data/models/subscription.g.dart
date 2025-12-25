// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 13;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      amount: fields[3] as double,
      categoryId: fields[4] as String,
      frequency: fields[5] as Frequency,
      customDays: fields[6] as int?,
      startDate: fields[7] as DateTime,
      nextDueDate: fields[8] as DateTime,
      isAutoPay: fields[9] as bool,
      isActive: fields[10] as bool,
      isPaused: fields[11] as bool,
      reminderType: fields[12] as ReminderType,
      notes: fields[13] as String?,
      logoUrl: fields[14] as String?,
      createdAt: fields[15] as DateTime,
      originalCurrency:
          fields[17] == null ? Currency.BDT : fields[17] as Currency,
      convertedAmount: fields[18] as double?,
      exchangeRateUsed: fields[19] as double?,
      isSettled: fields[20] == null ? false : fields[20] as bool,
      settledAt: fields[21] as DateTime?,
    ).._type = fields[16] as SubscriptionType?;
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.customDays)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.nextDueDate)
      ..writeByte(9)
      ..write(obj.isAutoPay)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.isPaused)
      ..writeByte(12)
      ..write(obj.reminderType)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.logoUrl)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj._type)
      ..writeByte(17)
      ..write(obj.originalCurrency)
      ..writeByte(18)
      ..write(obj.convertedAmount)
      ..writeByte(19)
      ..write(obj.exchangeRateUsed)
      ..writeByte(20)
      ..write(obj.isSettled)
      ..writeByte(21)
      ..write(obj.settledAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
