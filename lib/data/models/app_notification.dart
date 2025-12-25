import 'package:hive/hive.dart';
import 'enums.dart';

part 'app_notification.g.dart';

/// Model for persisted app notifications
@HiveType(typeId: 22)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  NotificationType type;

  /// Related item ID for navigation (e.g., subscription ID, transaction ID)
  @HiveField(4)
  String? relatedItemId;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  final DateTime createdAt;

  /// Additional payload data (stored as JSON-encodable map)
  @HiveField(7)
  Map<String, dynamic>? payload;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedItemId,
    this.isRead = false,
    DateTime? createdAt,
    this.payload,
  }) : createdAt = createdAt ?? DateTime.now();

  AppNotification copyWith({
    String? title,
    String? body,
    NotificationType? type,
    String? relatedItemId,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      payload: payload ?? this.payload,
    );
  }

  /// Create a daily summary notification
  factory AppNotification.dailySummary({
    required String id,
    required String title,
    required String body,
    int? settledCount,
    int? unsettledCount,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.dailySummary,
      payload: {
        'settledCount': settledCount,
        'unsettledCount': unsettledCount,
      },
    );
  }

  /// Create a rate update notification
  factory AppNotification.rateUpdate({
    required String id,
    required String title,
    required String body,
    double? oldRate,
    double? newRate,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.rateUpdate,
      payload: {
        'oldRate': oldRate,
        'newRate': newRate,
      },
    );
  }

  /// Create a reminder notification
  factory AppNotification.reminder({
    required String id,
    required String title,
    required String body,
    required String subscriptionId,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.reminder,
      relatedItemId: subscriptionId,
    );
  }
}
