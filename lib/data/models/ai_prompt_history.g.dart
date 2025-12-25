// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_prompt_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIPromptHistoryAdapter extends TypeAdapter<AIPromptHistory> {
  @override
  final int typeId = 17;

  @override
  AIPromptHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIPromptHistory(
      id: fields[0] as String,
      userPrompt: fields[1] as String,
      aiResponse: fields[2] as String?,
      parsedTitle: fields[3] as String?,
      parsedAmount: fields[4] as double?,
      parsedType: fields[5] as TransactionType?,
      parsedCategory: fields[6] as String?,
      parsedDate: fields[7] as DateTime?,
      wasAccepted: fields[8] as bool,
      wasEdited: fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AIPromptHistory obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userPrompt)
      ..writeByte(2)
      ..write(obj.aiResponse)
      ..writeByte(3)
      ..write(obj.parsedTitle)
      ..writeByte(4)
      ..write(obj.parsedAmount)
      ..writeByte(5)
      ..write(obj.parsedType)
      ..writeByte(6)
      ..write(obj.parsedCategory)
      ..writeByte(7)
      ..write(obj.parsedDate)
      ..writeByte(8)
      ..write(obj.wasAccepted)
      ..writeByte(9)
      ..write(obj.wasEdited)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIPromptHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
