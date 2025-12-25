import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/notification_service.dart';

/// Controller for the notifications page
class NotificationController extends GetxController {
  late final NotificationRepository _notificationRepo;
  NotificationService? _notificationService;

  // Reactive state
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _notificationRepo = Get.find<NotificationRepository>();
    if (Get.isRegistered<NotificationService>()) {
      _notificationService = Get.find<NotificationService>();
    }
    loadNotifications();
    checkPermissions();
  }

  /// Load all notifications
  Future<void> loadNotifications() async {
    isLoading.value = true;
    notifications.assignAll(_notificationRepo.getAllSorted());
    unreadCount.value = _notificationRepo.getUnreadCount();
    isLoading.value = false;
  }

  /// Check notification permissions
  Future<void> checkPermissions() async {
    if (_notificationService != null) {
      hasPermission.value = await _notificationService!.hasPermissions();
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (_notificationService == null) return false;
    final granted = await _notificationService!.requestPermissions();
    hasPermission.value = granted;
    return granted;
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    await _notificationRepo.markAsRead(id);
    await loadNotifications();
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationRepo.markAllAsRead();
    await loadNotifications();
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    await _notificationRepo.delete(id);
    await loadNotifications();
  }

  /// Delete all notifications
  Future<void> deleteAll() async {
    await _notificationRepo.clear();
    await loadNotifications();
  }

  /// Navigate to related item based on notification type
  void navigateToRelatedItem(AppNotification notification) {
    // Mark as read first
    markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.dailySummary:
        Get.toNamed('/dashboard');
        break;
      case NotificationType.rateUpdate:
        Get.toNamed('/settings');
        break;
      case NotificationType.reminder:
        if (notification.relatedItemId != null) {
          Get.toNamed('/subscriptions/detail',
              arguments: notification.relatedItemId);
        } else {
          Get.toNamed('/subscriptions');
        }
        break;
      case NotificationType.system:
        // Just mark as read, no navigation
        break;
    }
  }

  /// Get notification icon based on type
  String getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.dailySummary:
        return 'summarize';
      case NotificationType.rateUpdate:
        return 'currency_exchange';
      case NotificationType.reminder:
        return 'notifications_active';
      case NotificationType.system:
        return 'info';
    }
  }

  /// Cleanup old notifications
  Future<int> cleanupOld({int daysToKeep = 30}) async {
    final count = await _notificationRepo.cleanupOld(daysToKeep: daysToKeep);
    await loadNotifications();
    return count;
  }

  /// Refresh notifications (for pull-to-refresh)
  @override
  Future<void> refresh() async {
    await loadNotifications();
  }
}
