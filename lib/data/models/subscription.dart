import 'package:hive/hive.dart';
import 'enums.dart';

part 'subscription.g.dart';

@HiveType(typeId: 13)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  Frequency frequency;

  @HiveField(6)
  int? customDays;

  @HiveField(7)
  DateTime startDate;

  @HiveField(8)
  DateTime nextDueDate;

  @HiveField(9)
  bool isAutoPay;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  bool isPaused;

  @HiveField(12)
  ReminderType reminderType;

  @HiveField(13)
  String? notes;

  @HiveField(14)
  String? logoUrl;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  SubscriptionType? _type;

  /// Currency in which the subscription amount is set
  @HiveField(17, defaultValue: Currency.BDT)
  Currency originalCurrency;

  /// Amount converted to the other currency (set during settlement)
  @HiveField(18)
  double? convertedAmount;

  /// Exchange rate used for conversion (set during settlement)
  @HiveField(19)
  double? exchangeRateUsed;

  /// Whether currency conversion has been finalized
  @HiveField(20, defaultValue: false)
  bool isSettled;

  /// When the settlement was performed
  @HiveField(21)
  DateTime? settledAt;

  /// Get subscription type (defaults to expense for existing data without type)
  SubscriptionType get type => _type ?? SubscriptionType.expense;
  set type(SubscriptionType value) => _type = value;

  Subscription({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.categoryId,
    this.frequency = Frequency.monthly,
    this.customDays,
    required this.startDate,
    required this.nextDueDate,
    this.isAutoPay = false,
    this.isActive = true,
    this.isPaused = false,
    this.reminderType = ReminderType.oneDay,
    this.notes,
    this.logoUrl,
    required this.createdAt,
    SubscriptionType? type,
    this.originalCurrency = Currency.BDT,
    this.convertedAmount,
    this.exchangeRateUsed,
    this.isSettled = false,
    this.settledAt,
  }) : _type = type ?? SubscriptionType.expense;

  Subscription copyWith({
    String? name,
    String? description,
    double? amount,
    String? categoryId,
    Frequency? frequency,
    int? customDays,
    DateTime? startDate,
    DateTime? nextDueDate,
    bool? isAutoPay,
    bool? isActive,
    bool? isPaused,
    ReminderType? reminderType,
    String? notes,
    String? logoUrl,
    SubscriptionType? type,
    Currency? originalCurrency,
    double? convertedAmount,
    double? exchangeRateUsed,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      reminderType: reminderType ?? this.reminderType,
      notes: notes ?? this.notes,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt,
      type: type ?? _type,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      exchangeRateUsed: exchangeRateUsed ?? this.exchangeRateUsed,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  /// Calculate next due date based on frequency
  DateTime calculateNextDueDate() {
    switch (frequency) {
      case Frequency.daily:
        return nextDueDate.add(const Duration(days: 1));
      case Frequency.weekly:
        return nextDueDate.add(const Duration(days: 7));
      case Frequency.monthly:
        return DateTime(
          nextDueDate.year,
          nextDueDate.month + 1,
          nextDueDate.day,
        );
      case Frequency.yearly:
        return DateTime(
          nextDueDate.year + 1,
          nextDueDate.month,
          nextDueDate.day,
        );
      case Frequency.custom:
        return nextDueDate.add(Duration(days: customDays ?? 30));
    }
  }
}
