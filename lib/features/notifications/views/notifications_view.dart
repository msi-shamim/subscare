import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/models.dart';
import '../controllers/notification_controller.dart';

/// View for displaying notification history
class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notification_history'.tr),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, size: 20),
                    const SizedBox(width: 8),
                    Text('mark_all_read'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'delete_all_notifications'.tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () => controller.navigateToRelatedItem(notification),
                onMarkRead: () => controller.markAsRead(notification.id),
                onDelete: () => controller.deleteNotification(notification.id),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        controller.markAllAsRead();
        break;
      case 'delete_all':
        _showDeleteAllDialog();
        break;
    }
  }

  void _showDeleteAllDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('delete_all_notifications'.tr),
        content: Text('delete_all_notifications_warning'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}

/// Individual notification tile widget
class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: isRead ? 0 : 2,
        color: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: _getIconColor(notification.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight:
                                    isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'mark_read') {
                      onMarkRead();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isRead)
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 18),
                            const SizedBox(width: 8),
                            Text('mark_as_read'.tr),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'delete'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.dailySummary:
        return Icons.summarize;
      case NotificationType.rateUpdate:
        return Icons.currency_exchange;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.dailySummary:
        return Colors.blue;
      case NotificationType.rateUpdate:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.system:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${'minutes_ago'.tr}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${'hours_ago'.tr}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days_ago'.tr}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}
