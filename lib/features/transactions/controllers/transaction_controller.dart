import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/controllers/shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../reports/controllers/reports_controller.dart';
import '../../settings/controllers/settings_controller.dart';

/// Controller for managing transaction operations
class TransactionController extends GetxController {
  // Dependencies
  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;
  late final SubscriptionRepository _subscriptionRepo;
  late final ShellController _shellController;

  // Form state
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // Reactive state
  final Rx<TransactionType> selectedType = TransactionType.debit.obs;
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final Rx<DateTime> selectedDateTime = DateTime.now().obs;
  final RxList<String> attachmentPaths = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Recurring transaction state
  final RxBool isRecurring = false.obs;
  final Rx<Frequency> selectedFrequency = Frequency.monthly.obs;
  final RxInt customDays = 30.obs;
  final RxBool isAutoPay = false.obs;
  final Rx<ReminderType> reminderType = ReminderType.oneDay.obs;

  // Currency state
  final Rx<Currency> selectedCurrency = Currency.BDT.obs;

  // Observable amount for reactive UI updates
  final RxDouble currentAmount = 0.0.obs;

  /// Get preview converted amount based on current exchange rate
  double get previewConvertedAmount {
    final amount = currentAmount.value;
    if (amount <= 0) return 0;

    final settingsController = Get.find<SettingsController>();
    final rate = settingsController.exchangeRate.value;

    if (selectedCurrency.value == Currency.USD) {
      return amount * rate; // USD to BDT
    } else {
      return amount / rate; // BDT to USD
    }
  }

  // Categories
  final RxList<Category> debitCategories = <Category>[].obs;
  final RxList<Category> creditCategories = <Category>[].obs;

  // Transactions list
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxMap<String, Category> categoriesMap = <String, Category>{}.obs;

  // Filter state
  final RxString filterType = 'all'.obs; // 'all', 'one-time', 'recurring'

  // Upcoming recurring subscriptions
  final RxList<Subscription> upcomingSubscriptions = <Subscription>[].obs;

  // Edit mode
  final Rx<Transaction?> editingTransaction = Rx<Transaction?>(null);
  bool get isEditMode => editingTransaction.value != null;

  // Filtered transactions based on filterType
  List<Transaction> get filteredTransactions {
    switch (filterType.value) {
      case 'one-time':
        return transactions.where((t) => !t.isRecurring).toList();
      case 'recurring':
        return transactions.where((t) => t.isRecurring).toList();
      default:
        return transactions.toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      _loadCategories();
      await _loadTransactions();
      _loadUpcomingSubscriptions();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTransactions() async {
    transactions.value = _transactionRepo.getAllSorted();
  }

  void _loadUpcomingSubscriptions() {
    // Get subscriptions due within next 7 days
    upcomingSubscriptions.value = _subscriptionRepo.getDueWithinDays(7);
  }

  /// Refresh transactions list
  @override
  Future<void> refresh() async {
    await _loadTransactions();
    _loadUpcomingSubscriptions();
  }

  /// Change filter type
  void changeFilter(String filter) {
    filterType.value = filter;
  }

  /// Mark a recurring subscription as paid - creates new transaction
  Future<bool> markRecurringAsPaid(String subscriptionId, {DateTime? paymentDate}) async {
    try {
      final subscription = _subscriptionRepo.getById(subscriptionId);
      if (subscription == null) return false;

      final now = DateTime.now();
      final actualPaymentDate = paymentDate ?? now;

      // Create transaction for this payment
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: subscription.name,
        amount: subscription.amount,
        type: subscription.type == SubscriptionType.income
            ? TransactionType.credit
            : TransactionType.debit,
        categoryId: subscription.categoryId,
        dateTime: actualPaymentDate,
        notes: subscription.notes,
        entryMethod: EntryMethod.manual,
        isRecurring: true,
        subscriptionId: subscriptionId,
        createdAt: now,
        updatedAt: now,
        originalCurrency: subscription.originalCurrency,
        isSettled: false,
      );
      await _transactionRepo.save(transaction.id, transaction);

      // Update subscription's next due date
      await _subscriptionRepo.markAsPaid(subscriptionId);

      // Refresh data
      await _loadTransactions();
      _loadUpcomingSubscriptions();

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      // Refresh reports
      if (Get.isRegistered<ReportsController>()) {
        Get.find<ReportsController>().loadData();
      }

      _shellController.showSuccess('Payment recorded successfully');
      return true;
    } catch (e) {
      _shellController.showError('Failed to record payment: $e');
      return false;
    }
  }

  /// Get category by ID
  Category? getCategoryById(String id) => categoriesMap[id];

  /// Get subscription by ID
  Subscription? getSubscriptionById(String id) => _subscriptionRepo.getById(id);

  void _initDependencies() {
    _transactionRepo = Get.find<TransactionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    _subscriptionRepo = Get.find<SubscriptionRepository>();
    _shellController = Get.find<ShellController>();

    // Listen to amount changes for reactive UI updates
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    currentAmount.value = double.tryParse(amountController.text) ?? 0.0;
  }

  void _loadCategories() {
    debitCategories.value = _categoryRepo.getDebitCategories();
    creditCategories.value = _categoryRepo.getCreditCategories();

    // Build categories map for lookup
    final allCategories = _categoryRepo.getActiveCategories();
    categoriesMap.value = {for (var c in allCategories) c.id: c};

    // Set default category
    if (selectedType.value == TransactionType.debit && debitCategories.isNotEmpty) {
      selectedCategoryId.value = debitCategories.first.id;
    } else if (creditCategories.isNotEmpty) {
      selectedCategoryId.value = creditCategories.first.id;
    }
  }

  /// Get categories based on selected type
  List<Category> get currentCategories {
    return selectedType.value == TransactionType.debit
        ? debitCategories
        : creditCategories;
  }

  /// Change transaction type
  void changeType(TransactionType type) {
    selectedType.value = type;
    // Reset category when type changes
    final categories = type == TransactionType.debit ? debitCategories : creditCategories;
    if (categories.isNotEmpty) {
      selectedCategoryId.value = categories.first.id;
    }
  }

  /// Select category
  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  /// Select date and time
  Future<void> selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime.value),
      );

      if (time != null) {
        selectedDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      } else {
        selectedDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          selectedDateTime.value.hour,
          selectedDateTime.value.minute,
        );
      }
    }
  }

  /// Add attachment path
  void addAttachment(String path) {
    attachmentPaths.add(path);
  }

  /// Remove attachment
  void removeAttachment(int index) {
    attachmentPaths.removeAt(index);
  }

  /// Initialize for editing existing transaction
  void initForEdit(Transaction transaction) {
    editingTransaction.value = transaction;
    titleController.text = transaction.title;
    amountController.text = transaction.amount.toString();
    notesController.text = transaction.notes ?? '';
    selectedType.value = transaction.type;
    selectedCategoryId.value = transaction.categoryId;
    selectedDateTime.value = transaction.dateTime;
    selectedCurrency.value = transaction.originalCurrency;
  }

  /// Reset form
  void resetForm() {
    editingTransaction.value = null;
    titleController.clear();
    amountController.clear();
    notesController.clear();
    selectedType.value = TransactionType.debit;
    selectedDateTime.value = DateTime.now();
    attachmentPaths.clear();
    // Reset recurring state
    isRecurring.value = false;
    selectedFrequency.value = Frequency.monthly;
    customDays.value = 30;
    isAutoPay.value = false;
    reminderType.value = ReminderType.oneDay;
    // Reset currency
    selectedCurrency.value = Currency.BDT;
    _loadCategories();
  }

  /// Validate and save transaction
  Future<bool> saveTransaction() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedCategoryId.value == null) {
      _shellController.showError('Please select a category');
      return false;
    }

    isSaving.value = true;

    try {
      final now = DateTime.now();
      final amount = double.parse(amountController.text.trim());

      if (isEditMode) {
        // Update existing transaction
        final updated = editingTransaction.value!.copyWith(
          title: titleController.text.trim(),
          amount: amount,
          type: selectedType.value,
          categoryId: selectedCategoryId.value,
          dateTime: selectedDateTime.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          updatedAt: now,
          originalCurrency: selectedCurrency.value,
          // Reset settlement status on edit (will be re-settled)
          isSettled: false,
          convertedAmount: null,
          exchangeRateUsed: null,
          settledAt: null,
        );
        await _transactionRepo.save(updated.id, updated);
        _shellController.showSuccess('Transaction updated successfully');
      } else {
        String? subscriptionId;

        // If recurring, create subscription first
        if (isRecurring.value) {
          final subscription = Subscription(
            id: const Uuid().v4(),
            name: titleController.text.trim(),
            description: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            amount: amount,
            categoryId: selectedCategoryId.value!,
            frequency: selectedFrequency.value,
            customDays: selectedFrequency.value == Frequency.custom ? customDays.value : null,
            startDate: selectedDateTime.value,
            nextDueDate: _calculateNextDueDate(selectedDateTime.value),
            isAutoPay: isAutoPay.value,
            isActive: true,
            isPaused: false,
            reminderType: reminderType.value,
            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            createdAt: now,
            type: selectedType.value == TransactionType.debit
                ? SubscriptionType.expense
                : SubscriptionType.income,
            originalCurrency: selectedCurrency.value,
            isSettled: false,
          );
          await _subscriptionRepo.save(subscription.id, subscription);
          subscriptionId = subscription.id;
        }

        // Create new transaction
        final transaction = Transaction(
          id: const Uuid().v4(),
          title: titleController.text.trim(),
          amount: amount,
          type: selectedType.value,
          categoryId: selectedCategoryId.value!,
          dateTime: selectedDateTime.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          entryMethod: EntryMethod.manual,
          isRecurring: isRecurring.value,
          subscriptionId: subscriptionId,
          createdAt: now,
          updatedAt: now,
          originalCurrency: selectedCurrency.value,
          isSettled: false,
        );
        await _transactionRepo.save(transaction.id, transaction);
        _shellController.showSuccess(isRecurring.value
            ? 'Recurring transaction added successfully'
            : 'Transaction added successfully');
      }

      // Refresh transactions list
      await _loadTransactions();

      // Refresh dashboard if it exists
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      // Refresh reports if it exists
      if (Get.isRegistered<ReportsController>()) {
        Get.find<ReportsController>().loadData();
      }

      return true;
    } catch (e) {
      _shellController.showError('Failed to save transaction: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Calculate next due date based on frequency
  DateTime _calculateNextDueDate(DateTime fromDate) {
    switch (selectedFrequency.value) {
      case Frequency.daily:
        return fromDate.add(const Duration(days: 1));
      case Frequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case Frequency.monthly:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case Frequency.yearly:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
      case Frequency.custom:
        return fromDate.add(Duration(days: customDays.value));
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String id) async {
    try {
      await _transactionRepo.delete(id);
      _shellController.showSuccess('Transaction deleted');

      // Refresh transactions list
      await _loadTransactions();

      // Refresh dashboard if it exists
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      // Refresh reports if it exists
      if (Get.isRegistered<ReportsController>()) {
        Get.find<ReportsController>().loadData();
      }

      return true;
    } catch (e) {
      _shellController.showError('Failed to delete transaction');
      return false;
    }
  }

  @override
  void onClose() {
    amountController.removeListener(_onAmountChanged);
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
