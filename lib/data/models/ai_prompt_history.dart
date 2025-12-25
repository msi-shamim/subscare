import 'package:hive/hive.dart';
import 'enums.dart';

part 'ai_prompt_history.g.dart';

@HiveType(typeId: 17)
class AIPromptHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String userPrompt;

  @HiveField(2)
  String? aiResponse;

  @HiveField(3)
  String? parsedTitle;

  @HiveField(4)
  double? parsedAmount;

  @HiveField(5)
  TransactionType? parsedType;

  @HiveField(6)
  String? parsedCategory;

  @HiveField(7)
  DateTime? parsedDate;

  @HiveField(8)
  bool wasAccepted;

  @HiveField(9)
  bool wasEdited;

  @HiveField(10)
  final DateTime createdAt;

  AIPromptHistory({
    required this.id,
    required this.userPrompt,
    this.aiResponse,
    this.parsedTitle,
    this.parsedAmount,
    this.parsedType,
    this.parsedCategory,
    this.parsedDate,
    this.wasAccepted = false,
    this.wasEdited = false,
    required this.createdAt,
  });

  AIPromptHistory copyWith({
    String? userPrompt,
    String? aiResponse,
    String? parsedTitle,
    double? parsedAmount,
    TransactionType? parsedType,
    String? parsedCategory,
    DateTime? parsedDate,
    bool? wasAccepted,
    bool? wasEdited,
  }) {
    return AIPromptHistory(
      id: id,
      userPrompt: userPrompt ?? this.userPrompt,
      aiResponse: aiResponse ?? this.aiResponse,
      parsedTitle: parsedTitle ?? this.parsedTitle,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      parsedType: parsedType ?? this.parsedType,
      parsedCategory: parsedCategory ?? this.parsedCategory,
      parsedDate: parsedDate ?? this.parsedDate,
      wasAccepted: wasAccepted ?? this.wasAccepted,
      wasEdited: wasEdited ?? this.wasEdited,
      createdAt: createdAt,
    );
  }

  /// Check if AI successfully parsed the prompt
  bool get isParsed => parsedTitle != null && parsedAmount != null && parsedType != null;
}
