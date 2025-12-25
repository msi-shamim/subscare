import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../repositories/notification_repository.dart';

/// Service for managing local push notifications
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late NotificationRepository _notificationRepo;

  // Notification channel IDs
  static const String _dailySummaryChannelId = 'daily_summary';
  static const String _rateUpdateChannelId = 'rate_update';
  static const String _remindersChannelId = 'reminders';

  // Notification IDs for scheduled notifications
  static const int _dailyNotificationId = 1001;

  /// Initialize the notification service
  Future<NotificationService> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize notification repository
    _notificationRepo = Get.find<NotificationRepository>();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize plugin
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    return this;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Daily summary channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _dailySummaryChannelId,
        'Daily Summary',
        description: 'Daily ledger summary notifications',
        importance: Importance.high,
      ),
    );

    // Rate update channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _rateUpdateChannelId,
        'Rate Updates',
        description: 'Currency rate update notifications',
        importance: Importance.defaultImportance,
      ),
    );

    // Reminders channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _remindersChannelId,
        'Reminders',
        description: 'Payment and subscription reminders',
        importance: Importance.high,
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Navigate based on payload
      // Format: "type:relatedItemId"
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final itemId = parts[1];

        switch (type) {
          case 'dailySummary':
            Get.toNamed('/dashboard');
            break;
          case 'rateUpdate':
            Get.toNamed('/settings');
            break;
          case 'reminder':
            Get.toNamed('/subscriptions/detail', arguments: itemId);
            break;
          default:
            Get.toNamed('/notifications');
        }
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  /// Check if notifications are permitted
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't have a direct check, assume granted if we got here
      return true;
    }
    return false;
  }

  /// Show a notification immediately and persist it
  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? relatedItemId,
    Map<String, dynamic>? payload,
  }) async {
    // Generate unique ID
    final id = const Uuid().v4();
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    // Determine channel based on type
    String channelId;
    switch (type) {
      case NotificationType.dailySummary:
        channelId = _dailySummaryChannelId;
        break;
      case NotificationType.rateUpdate:
        channelId = _rateUpdateChannelId;
        break;
      case NotificationType.reminder:
        channelId = _remindersChannelId;
        break;
      default:
        channelId = _dailySummaryChannelId;
    }

    // Create notification details
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: '${type.name}:${relatedItemId ?? ''}',
    );

    // Persist notification
    final notification = AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      relatedItemId: relatedItemId,
      payload: payload,
    );

    await _notificationRepo.addNotification(notification);
  }

  /// Show daily summary notification
  Future<void> showDailySummaryNotification({
    required int settledCount,
    required int unsettledCount,
  }) async {
    final title = 'daily_summary'.tr;
    final body = unsettledCount > 0
        ? 'unsettled_summary'.trParams({
            'unsettled': unsettledCount.toString(),
            'settled': settledCount.toString(),
          })
        : 'all_settled_summary'.trParams({
            'settled': settledCount.toString(),
          });

    await showNotification(
      title: title,
      body: body,
      type: NotificationType.dailySummary,
      payload: {
        'settledCount': settledCount,
        'unsettledCount': unsettledCount,
      },
    );
  }

  /// Show rate update notification
  Future<void> showRateUpdateNotification({
    required double oldRate,
    required double newRate,
  }) async {
    final title = 'rate_updated'.tr;
    final change = newRate - oldRate;
    final changeStr = change >= 0 ? '+${change.toStringAsFixed(2)}' : change.toStringAsFixed(2);
    final body = 'rate_update_body'.trParams({
      'newRate': newRate.toStringAsFixed(2),
      'change': changeStr,
    });

    await showNotification(
      title: title,
      body: body,
      type: NotificationType.rateUpdate,
      payload: {
        'oldRate': oldRate,
        'newRate': newRate,
      },
    );
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    // Cancel any existing daily notification
    await cancelDailyNotification();

    // Schedule new notification
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _dailySummaryChannelId,
      'Daily Summary',
      channelDescription: 'Daily ledger summary notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _dailyNotificationId,
      'daily_summary'.tr,
      'check_your_ledger'.tr,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dailySummary:',
    );

    if (kDebugMode) {
      print('Daily notification scheduled for $hour:$minute');
    }
  }

  /// Cancel daily notification
  Future<void> cancelDailyNotification() async {
    await _plugin.cancel(_dailyNotificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case _dailySummaryChannelId:
        return 'Daily Summary';
      case _rateUpdateChannelId:
        return 'Rate Updates';
      case _remindersChannelId:
        return 'Reminders';
      default:
        return 'Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _dailySummaryChannelId:
        return 'Daily ledger summary notifications';
      case _rateUpdateChannelId:
        return 'Currency rate update notifications';
      case _remindersChannelId:
        return 'Payment and subscription reminders';
      default:
        return 'App notifications';
    }
  }
}
