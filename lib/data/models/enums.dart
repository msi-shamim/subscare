import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Transaction type - debit (expense) or credit (income)
@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  debit,
  @HiveField(1)
  credit,
}

/// Entry method - how the transaction was created
@HiveType(typeId: 1)
enum EntryMethod {
  @HiveField(0)
  manual,
  @HiveField(1)
  ocr,
  @HiveField(2)
  ai,
}

/// Subscription billing frequency
@HiveType(typeId: 2)
enum Frequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
  @HiveField(4)
  custom,
}

/// Category type - which transaction types it applies to
@HiveType(typeId: 3)
enum CategoryType {
  @HiveField(0)
  debit,
  @HiveField(1)
  credit,
  @HiveField(2)
  both,
}

/// Reminder timing before due date
@HiveType(typeId: 4)
enum ReminderType {
  @HiveField(0)
  none,
  @HiveField(1)
  oneDay,
  @HiveField(2)
  threeDays,
  @HiveField(3)
  oneWeek,
}

/// OCR scan processing status
@HiveType(typeId: 5)
enum OCRStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  processed,
  @HiveField(2)
  failed,
}

/// User action on reminder
@HiveType(typeId: 6)
enum ReminderAction {
  @HiveField(0)
  none,
  @HiveField(1)
  paid,
  @HiveField(2)
  snoozed,
}

/// Attachment file type
@HiveType(typeId: 7)
enum FileType {
  @HiveField(0)
  image,
  @HiveField(1)
  pdf,
  @HiveField(2)
  doc,
}

/// App theme mode
@HiveType(typeId: 8)
enum AppThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

/// Backup frequency setting
@HiveType(typeId: 9)
enum BackupFrequency {
  @HiveField(0)
  manual,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
}

/// Subscription type - expense (outgoing) or income (incoming)
@HiveType(typeId: 19)
enum SubscriptionType {
  @HiveField(0)
  expense, // Recurring expense (Netflix, Rent, etc.)
  @HiveField(1)
  income,  // Recurring income (Salary, Rental Income, etc.)
}

/// Currency type for dual-currency support
@HiveType(typeId: 20)
enum Currency {
  @HiveField(0)
  USD,
  @HiveField(1)
  BDT,
}

/// Notification type for local push notifications
@HiveType(typeId: 21)
enum NotificationType {
  @HiveField(0)
  dailySummary,
  @HiveField(1)
  rateUpdate,
  @HiveField(2)
  reminder,
  @HiveField(3)
  system,
}
