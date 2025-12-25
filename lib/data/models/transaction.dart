import 'package:hive/hive.dart';
import 'enums.dart';

part 'transaction.g.dart';

@HiveType(typeId: 12)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  EntryMethod entryMethod;

  @HiveField(8)
  bool isRecurring;

  @HiveField(9)
  String? subscriptionId;

  @HiveField(10)
  String? ocrScanId;

  @HiveField(11)
  String? aiPromptId;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  /// Currency in which the transaction was originally entered
  @HiveField(14, defaultValue: Currency.BDT)
  Currency originalCurrency;

  /// Amount converted to the other currency (set during settlement)
  @HiveField(15)
  double? convertedAmount;

  /// Exchange rate used for conversion (set during settlement)
  @HiveField(16)
  double? exchangeRateUsed;

  /// Whether currency conversion has been finalized
  @HiveField(17, defaultValue: false)
  bool isSettled;

  /// When the settlement was performed
  @HiveField(18)
  DateTime? settledAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.dateTime,
    this.notes,
    this.entryMethod = EntryMethod.manual,
    this.isRecurring = false,
    this.subscriptionId,
    this.ocrScanId,
    this.aiPromptId,
    required this.createdAt,
    required this.updatedAt,
    this.originalCurrency = Currency.BDT,
    this.convertedAmount,
    this.exchangeRateUsed,
    this.isSettled = false,
    this.settledAt,
  });

  Transaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? dateTime,
    String? notes,
    EntryMethod? entryMethod,
    bool? isRecurring,
    String? subscriptionId,
    String? ocrScanId,
    String? aiPromptId,
    DateTime? updatedAt,
    Currency? originalCurrency,
    double? convertedAmount,
    double? exchangeRateUsed,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      entryMethod: entryMethod ?? this.entryMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      ocrScanId: ocrScanId ?? this.ocrScanId,
      aiPromptId: aiPromptId ?? this.aiPromptId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      originalCurrency: originalCurrency ?? this.originalCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      exchangeRateUsed: exchangeRateUsed ?? this.exchangeRateUsed,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  /// Get amount in BDT (original or converted)
  double get amountInBDT {
    if (originalCurrency == Currency.BDT) {
      return amount;
    }
    return convertedAmount ?? 0;
  }

  /// Get amount in USD (original or converted)
  double get amountInUSD {
    if (originalCurrency == Currency.USD) {
      return amount;
    }
    return convertedAmount ?? 0;
  }
}
