import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// Filter period for reports
enum ReportPeriod { week, month, year, custom }

/// Data point for charts
class ChartDataPoint {
  final String label;
  final double income;
  final double expense;
  final DateTime date;

  ChartDataPoint({
    required this.label,
    required this.income,
    required this.expense,
    required this.date,
  });

  double get balance => income - expense;
}

/// Category data for pie chart
class CategoryData {
  final String name;
  final String categoryId;
  final double amount;
  final Color color;
  final double percentage;

  CategoryData({
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

/// Controller for Reports page
class ReportsController extends GetxController {
  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;

  // Filter state
  final Rx<ReportPeriod> selectedPeriod = ReportPeriod.week.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Comparison state
  final RxBool isComparisonMode = false.obs;
  final Rx<DateTime> compareStartDate = DateTime.now().obs;
  final Rx<DateTime> compareEndDate = DateTime.now().obs;

  // Chart data
  final RxList<ChartDataPoint> chartData = <ChartDataPoint>[].obs;
  final RxList<ChartDataPoint> compareChartData = <ChartDataPoint>[].obs;
  final RxList<CategoryData> expenseCategoryData = <CategoryData>[].obs;
  final RxList<CategoryData> incomeCategoryData = <CategoryData>[].obs;

  // Summary data
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble compareTotalIncome = 0.0.obs;
  final RxDouble compareTotalExpense = 0.0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Pie chart view type (expense or income)
  final RxBool showExpensePie = true.obs;

  // Minimum days for custom range
  static const int minCustomDays = 7;

  @override
  void onInit() {
    super.onInit();
    _transactionRepo = Get.find<TransactionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    _initializeDates();
    loadData();
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Default to current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    startDate.value = DateTime(weekStart.year, weekStart.month, weekStart.day);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Comparison defaults to previous week
    compareStartDate.value = startDate.value.subtract(const Duration(days: 7));
    compareEndDate.value = endDate.value.subtract(const Duration(days: 7));
  }

  /// Change report period
  void changePeriod(ReportPeriod period) {
    selectedPeriod.value = period;
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate.value = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        // Compare to previous week
        compareStartDate.value = startDate.value.subtract(const Duration(days: 7));
        compareEndDate.value = endDate.value.subtract(const Duration(days: 7));
        break;

      case ReportPeriod.month:
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        // Compare to previous month
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        compareStartDate.value = prevMonth;
        compareEndDate.value = DateTime(prevMonth.year, prevMonth.month + 1, 0, 23, 59, 59);
        break;

      case ReportPeriod.year:
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        // Compare to previous year
        compareStartDate.value = DateTime(now.year - 1, 1, 1);
        compareEndDate.value = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;

      case ReportPeriod.custom:
        // Keep current dates, user will select
        break;
    }

    loadData();
  }

  /// Set custom date range (validates minimum 7 days)
  bool setCustomDateRange(DateTime start, DateTime end) {
    final daysDiff = end.difference(start).inDays;
    if (daysDiff < minCustomDays) {
      Get.snackbar(
        'error'.tr,
        'min_days_required'.trParams({'days': minCustomDays.toString()}),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    selectedPeriod.value = ReportPeriod.custom;
    startDate.value = DateTime(start.year, start.month, start.day);
    endDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59);
    loadData();
    return true;
  }

  /// Set comparison date range (validates minimum 7 days)
  bool setComparisonDateRange(DateTime start, DateTime end) {
    final daysDiff = end.difference(start).inDays;
    if (daysDiff < minCustomDays) {
      Get.snackbar(
        'error'.tr,
        'min_days_required'.trParams({'days': minCustomDays.toString()}),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    compareStartDate.value = DateTime(start.year, start.month, start.day);
    compareEndDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59);
    if (isComparisonMode.value) {
      loadData();
    }
    return true;
  }

  /// Toggle comparison mode
  void toggleComparisonMode(bool enabled) {
    isComparisonMode.value = enabled;
    loadData();
  }

  /// Toggle pie chart view between expense and income
  void togglePieChartView() {
    showExpensePie.value = !showExpensePie.value;
  }

  /// Load all report data
  Future<void> loadData() async {
    isLoading.value = true;

    // Get transactions for main period
    final transactions = _getTransactionsInRange(startDate.value, endDate.value);

    // Calculate totals
    totalIncome.value = _calculateTotal(transactions, TransactionType.credit);
    totalExpense.value = _calculateTotal(transactions, TransactionType.debit);

    // Generate chart data
    chartData.assignAll(_generateChartData(transactions, startDate.value, endDate.value));

    // Generate category data
    expenseCategoryData.assignAll(_generateCategoryData(transactions, TransactionType.debit));
    incomeCategoryData.assignAll(_generateCategoryData(transactions, TransactionType.credit));

    // Load comparison data if enabled
    if (isComparisonMode.value) {
      final compareTransactions = _getTransactionsInRange(
        compareStartDate.value,
        compareEndDate.value,
      );
      compareTotalIncome.value = _calculateTotal(compareTransactions, TransactionType.credit);
      compareTotalExpense.value = _calculateTotal(compareTransactions, TransactionType.debit);
      compareChartData.assignAll(_generateChartData(
        compareTransactions,
        compareStartDate.value,
        compareEndDate.value,
      ));
    } else {
      compareChartData.clear();
      compareTotalIncome.value = 0;
      compareTotalExpense.value = 0;
    }

    isLoading.value = false;
  }

  List<Transaction> _getTransactionsInRange(DateTime start, DateTime end) {
    return _transactionRepo.getAll().where((t) {
      return t.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.dateTime.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  double _calculateTotal(List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<ChartDataPoint> _generateChartData(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    final daysDiff = end.difference(start).inDays;
    final List<ChartDataPoint> points = [];

    if (daysDiff <= 7) {
      // Daily data for week
      for (int i = 0; i <= daysDiff; i++) {
        final date = start.add(Duration(days: i));
        final dayTransactions = transactions.where((t) =>
            t.dateTime.year == date.year &&
            t.dateTime.month == date.month &&
            t.dateTime.day == date.day);

        points.add(ChartDataPoint(
          label: _getDayLabel(date),
          income: dayTransactions
              .where((t) => t.type == TransactionType.credit)
              .fold(0.0, (sum, t) => sum + t.amount),
          expense: dayTransactions
              .where((t) => t.type == TransactionType.debit)
              .fold(0.0, (sum, t) => sum + t.amount),
          date: date,
        ));
      }
    } else if (daysDiff <= 31) {
      // Daily data for month
      for (int i = 0; i <= daysDiff; i++) {
        final date = start.add(Duration(days: i));
        final dayTransactions = transactions.where((t) =>
            t.dateTime.year == date.year &&
            t.dateTime.month == date.month &&
            t.dateTime.day == date.day);

        points.add(ChartDataPoint(
          label: '${date.day}',
          income: dayTransactions
              .where((t) => t.type == TransactionType.credit)
              .fold(0.0, (sum, t) => sum + t.amount),
          expense: dayTransactions
              .where((t) => t.type == TransactionType.debit)
              .fold(0.0, (sum, t) => sum + t.amount),
          date: date,
        ));
      }
    } else {
      // Monthly data for year
      final months = <int, List<Transaction>>{};
      for (final t in transactions) {
        final key = t.dateTime.month;
        months.putIfAbsent(key, () => []).add(t);
      }

      for (int m = start.month; m <= (start.year == end.year ? end.month : 12); m++) {
        final monthTransactions = months[m] ?? [];
        points.add(ChartDataPoint(
          label: _getMonthLabel(m),
          income: monthTransactions
              .where((t) => t.type == TransactionType.credit)
              .fold(0.0, (sum, t) => sum + t.amount),
          expense: monthTransactions
              .where((t) => t.type == TransactionType.debit)
              .fold(0.0, (sum, t) => sum + t.amount),
          date: DateTime(start.year, m, 1),
        ));
      }
    }

    return points;
  }

  List<CategoryData> _generateCategoryData(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    final filteredTransactions = transactions.where((t) => t.type == type).toList();
    final total = filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

    if (total == 0) return [];

    // Group by category
    final categoryTotals = <String, double>{};
    for (final t in filteredTransactions) {
      final catId = t.categoryId ?? 'uncategorized';
      categoryTotals[catId] = (categoryTotals[catId] ?? 0) + t.amount;
    }

    // Sort by amount descending
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Generate category data with colors
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF607D8B),
    ];

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryId = entry.value.key;
      final amount = entry.value.value;
      final category = _categoryRepo.getById(categoryId);

      return CategoryData(
        name: category?.name ?? 'uncategorized'.tr,
        categoryId: categoryId,
        amount: amount,
        color: category != null
            ? _parseColor(category.color)
            : colors[index % colors.length],
        percentage: (amount / total) * 100,
      );
    }).toList();
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  String _getDayLabel(DateTime date) {
    final days = [
      'day_mon'.tr,
      'day_tue'.tr,
      'day_wed'.tr,
      'day_thu'.tr,
      'day_fri'.tr,
      'day_sat'.tr,
      'day_sun'.tr,
    ];
    return days[date.weekday - 1];
  }

  String _getMonthLabel(int month) {
    final months = [
      'month_jan'.tr,
      'month_feb'.tr,
      'month_mar'.tr,
      'month_apr'.tr,
      'month_may'.tr,
      'month_jun'.tr,
      'month_jul'.tr,
      'month_aug'.tr,
      'month_sep'.tr,
      'month_oct'.tr,
      'month_nov'.tr,
      'month_dec'.tr,
    ];
    return months[month - 1];
  }

  /// Get formatted date range string
  String get formattedDateRange {
    final start = startDate.value;
    final end = endDate.value;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  /// Get formatted comparison date range string
  String get formattedCompareDateRange {
    final start = compareStartDate.value;
    final end = compareEndDate.value;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  /// Calculate percentage change
  double getPercentageChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData();
  }
}
