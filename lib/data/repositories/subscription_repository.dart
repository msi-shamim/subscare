import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class SubscriptionRepository extends BaseRepository<Subscription> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<Subscription> get box => _hiveService.subscriptionsBox;

  /// Get all active subscriptions
  List<Subscription> getActive() {
    return getAll().where((s) => s.isActive && !s.isPaused).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  }

  /// Get paused subscriptions
  List<Subscription> getPaused() {
    return getAll().where((s) => s.isPaused).toList();
  }

  /// Get inactive subscriptions
  List<Subscription> getInactive() {
    return getAll().where((s) => !s.isActive).toList();
  }

  /// Get subscriptions due within days
  List<Subscription> getDueWithinDays(int days) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return getActive().where((s) {
      return s.nextDueDate.isAfter(now.subtract(const Duration(days: 1))) &&
          s.nextDueDate.isBefore(future);
    }).toList();
  }

  /// Get subscriptions due today
  List<Subscription> getDueToday() => getDueWithinDays(1);

  /// Get subscriptions due this week
  List<Subscription> getDueThisWeek() => getDueWithinDays(7);

  /// Get overdue subscriptions
  List<Subscription> getOverdue() {
    final now = DateTime.now();
    return getActive().where((s) => s.nextDueDate.isBefore(now)).toList();
  }

  /// Get subscriptions by category
  List<Subscription> getByCategory(String categoryId) {
    return getActive().where((s) => s.categoryId == categoryId).toList();
  }

  /// Get subscriptions with auto-pay enabled
  List<Subscription> getAutoPay() {
    return getActive().where((s) => s.isAutoPay).toList();
  }

  /// Pause subscription
  Future<void> pause(String id) async {
    final sub = getById(id);
    if (sub != null) {
      final updated = sub.copyWith(isPaused: true);
      await save(id, updated);
    }
  }

  /// Resume subscription
  Future<void> resume(String id) async {
    final sub = getById(id);
    if (sub != null) {
      final updated = sub.copyWith(isPaused: false);
      await save(id, updated);
    }
  }

  /// Deactivate subscription
  Future<void> deactivate(String id) async {
    final sub = getById(id);
    if (sub != null) {
      final updated = sub.copyWith(isActive: false);
      await save(id, updated);
    }
  }

  /// Mark subscription as paid and update next due date
  Future<void> markAsPaid(String id) async {
    final sub = getById(id);
    if (sub != null) {
      final nextDue = sub.calculateNextDueDate();
      final updated = sub.copyWith(nextDueDate: nextDue);
      await save(id, updated);
    }
  }

  /// Calculate total monthly cost of active subscriptions
  double getTotalMonthlyCost() {
    return getActive().fold(0.0, (sum, sub) {
      switch (sub.frequency) {
        case Frequency.daily:
          return sum + (sub.amount * 30);
        case Frequency.weekly:
          return sum + (sub.amount * 4);
        case Frequency.monthly:
          return sum + sub.amount;
        case Frequency.yearly:
          return sum + (sub.amount / 12);
        case Frequency.custom:
          final daysInMonth = 30;
          final cycles = daysInMonth / (sub.customDays ?? 30);
          return sum + (sub.amount * cycles);
      }
    });
  }

  /// Calculate total yearly cost of active subscriptions
  double getTotalYearlyCost() => getTotalMonthlyCost() * 12;
}
