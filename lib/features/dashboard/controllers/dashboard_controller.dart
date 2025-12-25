import 'package:get/get.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../reports/controllers/reports_controller.dart';
import '../../settings/controllers/settings_controller.dart';

/// Wrapper class for recent items (either Transaction or Subscription)
class RecentItem {
  final dynamic item;
  final DateTime dateTime;
  final bool isTransaction;

  RecentItem({
    required this.item,
    required this.dateTime,
    required this.isTransaction,
  });

  Transaction? get transaction => isTransaction ? item as Transaction : null;
  Subscription? get subscription => !isTransaction ? item as Subscription : null;
}

/// Dashboard controller for home screen analytics and ledger
class DashboardController extends GetxController {
  // Dependencies
  late final TransactionRepository _transactionRepo;
  late final SubscriptionRepository _subscriptionRepo;
  late final CategoryRepository _categoryRepo;

  // Loading state
  final RxBool isLoading = true.obs;

  // Analytics data (BDT)
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  final RxDouble upcomingIncome = 0.0.obs;
  final RxDouble upcomingExpense = 0.0.obs;

  // Analytics data (USD)
  final RxDouble totalIncomeUSD = 0.0.obs;
  final RxDouble totalExpenseUSD = 0.0.obs;
  final RxDouble balanceUSD = 0.0.obs;
  final RxDouble upcomingIncomeUSD = 0.0.obs;
  final RxDouble upcomingExpenseUSD = 0.0.obs;

  // Recent items (transactions + subscriptions combined)
  final RxList<RecentItem> recentItems = <RecentItem>[].obs;

  // Filter state
  final RxString currentFilter = 'all'.obs;

  // Categories cache
  final RxMap<String, Category> categoriesMap = <String, Category>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    loadData();
  }

  void _initDependencies() {
    _transactionRepo = Get.find<TransactionRepository>();
    _subscriptionRepo = Get.find<SubscriptionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
  }

  /// Load all dashboard data
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadCategories(),
        _loadAnalytics(),
        _loadRecentItems(),
        _loadUpcomingBills(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data (pull to refresh)
  @override
  Future<void> refresh() async {
    await loadData();
  }

  Future<void> _loadCategories() async {
    final categories = _categoryRepo.getActiveCategories();
    categoriesMap.value = {for (var c in categories) c.id: c};
  }

  Future<void> _loadAnalytics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final settings = Get.find<SettingsController>();
    final currentRate = settings.exchangeRate.value;

    // Get all transactions for this month
    final transactions = _transactionRepo.getAllSorted().where((t) {
      return t.dateTime.isAfter(startOfMonth) ||
          t.dateTime.isAtSameMomentAs(startOfMonth);
    }).toList();

    double incomeBDT = 0, expenseBDT = 0, incomeUSD = 0, expenseUSD = 0;

    for (final t in transactions) {
      double amountBDT, amountUSD;

      if (t.isSettled && t.convertedAmount != null) {
        if (t.originalCurrency == Currency.BDT) {
          amountBDT = t.amount;
          amountUSD = t.convertedAmount!;
        } else {
          amountUSD = t.amount;
          amountBDT = t.convertedAmount!;
        }
      } else {
        if (t.originalCurrency == Currency.BDT) {
          amountBDT = t.amount;
          amountUSD = t.amount / currentRate;
        } else {
          amountUSD = t.amount;
          amountBDT = t.amount * currentRate;
        }
      }

      if (t.type == TransactionType.credit) {
        incomeBDT += amountBDT;
        incomeUSD += amountUSD;
      } else {
        expenseBDT += amountBDT;
        expenseUSD += amountUSD;
      }
    }

    totalIncome.value = incomeBDT;
    totalExpense.value = expenseBDT;
    balance.value = incomeBDT - expenseBDT;
    totalIncomeUSD.value = incomeUSD;
    totalExpenseUSD.value = expenseUSD;
    balanceUSD.value = incomeUSD - expenseUSD;
  }

  /// Load recent items (transactions only - subscriptions are now part of transactions)
  Future<void> _loadRecentItems() async {
    final List<RecentItem> items = [];

    // Get all transactions (includes recurring transactions)
    final transactions = _transactionRepo.getAllSorted();
    for (final t in transactions) {
      items.add(RecentItem(
        item: t,
        dateTime: t.dateTime,
        isTransaction: true,
      ));
    }

    // Limit to 10 most recent
    recentItems.value = items.take(10).toList();
  }

  Future<void> _loadUpcomingBills() async {
    final upcoming = _subscriptionRepo.getDueWithinDays(7);
    final settings = Get.find<SettingsController>();
    final currentRate = settings.exchangeRate.value;

    double incomeBDT = 0, expenseBDT = 0, incomeUSD = 0, expenseUSD = 0;

    for (final s in upcoming) {
      double amountBDT, amountUSD;

      if (s.isSettled && s.convertedAmount != null) {
        if (s.originalCurrency == Currency.BDT) {
          amountBDT = s.amount;
          amountUSD = s.convertedAmount!;
        } else {
          amountUSD = s.amount;
          amountBDT = s.convertedAmount!;
        }
      } else {
        if (s.originalCurrency == Currency.BDT) {
          amountBDT = s.amount;
          amountUSD = s.amount / currentRate;
        } else {
          amountUSD = s.amount;
          amountBDT = s.amount * currentRate;
        }
      }

      if (s.type == SubscriptionType.income) {
        incomeBDT += amountBDT;
        incomeUSD += amountUSD;
      } else {
        expenseBDT += amountBDT;
        expenseUSD += amountUSD;
      }
    }

    upcomingIncome.value = incomeBDT;
    upcomingExpense.value = expenseBDT;
    upcomingIncomeUSD.value = incomeUSD;
    upcomingExpenseUSD.value = expenseUSD;
  }

  /// Apply filter to recent items
  void applyFilter(String filter) {
    currentFilter.value = filter;
    _loadRecentItems();
  }

  /// Get category by ID
  Category? getCategoryById(String id) => categoriesMap[id];

  /// Get subscription by ID
  Subscription? getSubscriptionById(String id) => _subscriptionRepo.getById(id);

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionRepo.delete(id);
    await loadData();

    // Refresh reports if it exists
    if (Get.isRegistered<ReportsController>()) {
      Get.find<ReportsController>().loadData();
    }
  }

  /// Delete subscription
  Future<void> deleteSubscription(String id) async {
    await _subscriptionRepo.delete(id);
    await loadData();

    // Refresh reports if it exists
    if (Get.isRegistered<ReportsController>()) {
      Get.find<ReportsController>().loadData();
    }
  }
}
