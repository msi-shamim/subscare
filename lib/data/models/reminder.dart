import 'package:hive/hive.dart';
import 'enums.dart';

part 'reminder.g.dart';

@HiveType(typeId: 14)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String subscriptionId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String body;

  @HiveField(4)
  DateTime scheduledAt;

  @HiveField(5)
  bool isTriggered;

  @HiveField(6)
  bool isDismissed;

  @HiveField(7)
  ReminderAction action;

  @HiveField(8)
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.subscriptionId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.isTriggered = false,
    this.isDismissed = false,
    this.action = ReminderAction.none,
    required this.createdAt,
  });

  Reminder copyWith({
    String? subscriptionId,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? isTriggered,
    bool? isDismissed,
    ReminderAction? action,
  }) {
    return Reminder(
      id: id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isTriggered: isTriggered ?? this.isTriggered,
      isDismissed: isDismissed ?? this.isDismissed,
      action: action ?? this.action,
      createdAt: createdAt,
    );
  }
}
