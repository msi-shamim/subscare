import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class TransactionRepository extends BaseRepository<Transaction> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<Transaction> get box => _hiveService.transactionsBox;

  /// Get all transactions sorted by date (newest first)
  List<Transaction> getAllSorted() {
    return getAll()..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Get transactions by type
  List<Transaction> getByType(TransactionType type) {
    return getAllSorted().where((t) => t.type == type).toList();
  }

  /// Get debit transactions
  List<Transaction> getDebits() => getByType(TransactionType.debit);

  /// Get credit transactions
  List<Transaction> getCredits() => getByType(TransactionType.credit);

  /// Get transactions by category
  List<Transaction> getByCategory(String categoryId) {
    return getAllSorted().where((t) => t.categoryId == categoryId).toList();
  }

  /// Get transactions by date range
  List<Transaction> getByDateRange(DateTime start, DateTime end) {
    return getAllSorted().where((t) {
      return t.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          t.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get today's transactions
  List<Transaction> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get this week's transactions
  List<Transaction> getThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getByDateRange(start, now);
  }

  /// Get this month's transactions
  List<Transaction> getThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return getByDateRange(start, now);
  }

  /// Get transactions by subscription
  List<Transaction> getBySubscription(String subscriptionId) {
    return getAllSorted()
        .where((t) => t.subscriptionId == subscriptionId)
        .toList();
  }

  /// Get transactions by entry method
  List<Transaction> getByEntryMethod(EntryMethod method) {
    return getAllSorted().where((t) => t.entryMethod == method).toList();
  }

  /// Calculate total by type
  double getTotalByType(TransactionType type, {DateTime? start, DateTime? end}) {
    var transactions = getByType(type);
    if (start != null && end != null) {
      transactions = transactions.where((t) {
        return t.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
            t.dateTime.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total income
  double getTotalIncome({DateTime? start, DateTime? end}) {
    return getTotalByType(TransactionType.credit, start: start, end: end);
  }

  /// Get total expense
  double getTotalExpense({DateTime? start, DateTime? end}) {
    return getTotalByType(TransactionType.debit, start: start, end: end);
  }

  /// Get balance (income - expense)
  double getBalance({DateTime? start, DateTime? end}) {
    return getTotalIncome(start: start, end: end) -
        getTotalExpense(start: start, end: end);
  }

  /// Search transactions by title
  List<Transaction> search(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllSorted()
        .where((t) => t.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Group transactions by date
  Map<DateTime, List<Transaction>> groupByDate() {
    final transactions = getAllSorted();
    final grouped = <DateTime, List<Transaction>>{};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(transaction);
    }

    return grouped;
  }
}
