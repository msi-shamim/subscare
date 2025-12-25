import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class ReminderRepository extends BaseRepository<Reminder> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<Reminder> get box => _hiveService.remindersBox;

  /// Get pending reminders (not triggered yet)
  List<Reminder> getPending() {
    return getAll()
        .where((r) => !r.isTriggered && !r.isDismissed)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Get reminders due now or overdue
  List<Reminder> getDue() {
    final now = DateTime.now();
    return getPending().where((r) => r.scheduledAt.isBefore(now)).toList();
  }

  /// Get reminders by subscription
  List<Reminder> getBySubscription(String subscriptionId) {
    return getAll()
        .where((r) => r.subscriptionId == subscriptionId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Mark reminder as triggered
  Future<void> markAsTriggered(String id) async {
    final reminder = getById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(isTriggered: true);
      await save(id, updated);
    }
  }

  /// Dismiss reminder
  Future<void> dismiss(String id) async {
    final reminder = getById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(isDismissed: true);
      await save(id, updated);
    }
  }

  /// Mark reminder action as paid
  Future<void> markAsPaid(String id) async {
    final reminder = getById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(
        action: ReminderAction.paid,
        isDismissed: true,
      );
      await save(id, updated);
    }
  }

  /// Snooze reminder
  Future<void> snooze(String id, Duration duration) async {
    final reminder = getById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(
        scheduledAt: DateTime.now().add(duration),
        action: ReminderAction.snoozed,
        isTriggered: false,
      );
      await save(id, updated);
    }
  }

  /// Delete old dismissed reminders (cleanup)
  Future<void> cleanupOld({int daysOld = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final oldReminders = getAll()
        .where((r) => r.isDismissed && r.createdAt.isBefore(cutoff))
        .map((r) => r.id)
        .toList();
    await deleteMany(oldReminders);
  }
}
