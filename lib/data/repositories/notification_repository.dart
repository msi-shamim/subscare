import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

/// Repository for managing app notifications
class NotificationRepository extends BaseRepository<AppNotification> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<AppNotification> get box => _hiveService.notificationsBox;

  /// Get all notifications sorted by date (newest first)
  List<AppNotification> getAllSorted() {
    return getAll()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get unread notifications
  List<AppNotification> getUnread() {
    return getAllSorted().where((n) => !n.isRead).toList();
  }

  /// Get unread notification count
  int getUnreadCount() {
    return getAll().where((n) => !n.isRead).length;
  }

  /// Get notifications by type
  List<AppNotification> getByType(NotificationType type) {
    return getAllSorted().where((n) => n.type == type).toList();
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final notification = getById(id);
    if (notification != null && !notification.isRead) {
      notification.isRead = true;
      await notification.save();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unread = getUnread();
    for (final notification in unread) {
      notification.isRead = true;
      await notification.save();
    }
  }

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    await save(notification.id, notification);
  }

  /// Delete old notifications (older than specified days)
  Future<int> cleanupOld({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final oldNotifications = getAll()
        .where((n) => n.createdAt.isBefore(cutoffDate))
        .toList();

    final ids = oldNotifications.map((n) => n.id).toList();
    await deleteMany(ids);
    return ids.length;
  }

  /// Get notifications from today
  List<AppNotification> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getAllSorted()
        .where((n) => n.createdAt.isAfter(startOfDay))
        .toList();
  }

  /// Get notifications by related item ID
  List<AppNotification> getByRelatedItem(String relatedItemId) {
    return getAllSorted()
        .where((n) => n.relatedItemId == relatedItemId)
        .toList();
  }
}
