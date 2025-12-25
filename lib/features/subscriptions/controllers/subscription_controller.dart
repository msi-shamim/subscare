import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/controllers/shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

/// Controller for managing subscription operations
class SubscriptionController extends GetxController {
  // Dependencies
  late final SubscriptionRepository _subscriptionRepo;
  late final CategoryRepository _categoryRepo;
  late final ReminderRepository _reminderRepo;
  late final ShellController _shellController;

  // Form state
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  // Reactive state
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final Rx<Frequency> selectedFrequency = Frequency.monthly.obs;
  final RxInt customDays = 30.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> nextDueDate = DateTime.now().obs;
  final RxBool isAutoPay = false.obs;
  final Rx<ReminderType> reminderType = ReminderType.oneDay.obs;
  final Rx<SubscriptionType> selectedType = SubscriptionType.expense.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Categories
  final RxList<Category> categories = <Category>[].obs;

  // Subscriptions list
  final RxList<Subscription> subscriptions = <Subscription>[].obs;
  final RxList<Subscription> activeSubscriptions = <Subscription>[].obs;
  final RxList<Subscription> upcomingSubscriptions = <Subscription>[].obs;

  // Edit mode
  final Rx<Subscription?> editingSubscription = Rx<Subscription?>(null);
  bool get isEditMode => editingSubscription.value != null;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _loadData();
  }

  void _initDependencies() {
    _subscriptionRepo = Get.find<SubscriptionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    _reminderRepo = Get.find<ReminderRepository>();
    _shellController = Get.find<ShellController>();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadCategories(),
        _loadSubscriptions(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCategories() async {
    _loadCategoriesForType();
  }

  Future<void> _loadSubscriptions() async {
    subscriptions.value = _subscriptionRepo.getAll();
    activeSubscriptions.value = _subscriptionRepo.getActive();
    upcomingSubscriptions.value = _subscriptionRepo.getDueWithinDays(7);
  }

  /// Refresh subscriptions list
  @override
  Future<void> refresh() async {
    await _loadSubscriptions();
  }

  /// Select category
  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  /// Change subscription type (expense/income)
  void changeType(SubscriptionType type) {
    selectedType.value = type;
    // Reload categories based on type
    _loadCategoriesForType();
  }

  /// Load categories based on selected subscription type
  void _loadCategoriesForType() {
    if (selectedType.value == SubscriptionType.income) {
      categories.value = _categoryRepo.getCreditCategories();
    } else {
      categories.value = _categoryRepo.getDebitCategories();
    }

    // Reset category selection if current selection doesn't match new type
    if (categories.isNotEmpty) {
      final categoryExists = categories.any((c) => c.id == selectedCategoryId.value);
      if (!categoryExists) {
        selectedCategoryId.value = categories.first.id;
      }
    } else {
      selectedCategoryId.value = null;
    }
  }

  /// Change frequency
  void changeFrequency(Frequency frequency) {
    selectedFrequency.value = frequency;
    _updateNextDueDate();
  }

  /// Update custom days
  void updateCustomDays(int days) {
    customDays.value = days;
    if (selectedFrequency.value == Frequency.custom) {
      _updateNextDueDate();
    }
  }

  /// Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      startDate.value = date;
      _updateNextDueDate();
    }
  }

  /// Calculate and update next due date based on frequency
  void _updateNextDueDate() {
    final start = startDate.value;
    final now = DateTime.now();

    DateTime next = start;

    // Calculate next due date that is in the future
    while (next.isBefore(now)) {
      switch (selectedFrequency.value) {
        case Frequency.daily:
          next = next.add(const Duration(days: 1));
          break;
        case Frequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case Frequency.monthly:
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case Frequency.yearly:
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        case Frequency.custom:
          next = next.add(Duration(days: customDays.value));
          break;
      }
    }

    nextDueDate.value = next;
  }

  /// Toggle auto-pay
  void toggleAutoPay(bool value) {
    isAutoPay.value = value;
  }

  /// Change reminder type
  void changeReminderType(ReminderType type) {
    reminderType.value = type;
  }

  /// Initialize for editing existing subscription
  void initForEdit(Subscription subscription) {
    editingSubscription.value = subscription;
    nameController.text = subscription.name;
    amountController.text = subscription.amount.toString();
    descriptionController.text = subscription.description ?? '';
    notesController.text = subscription.notes ?? '';
    selectedType.value = subscription.type;
    _loadCategoriesForType(); // Load appropriate categories for this type
    selectedCategoryId.value = subscription.categoryId;
    selectedFrequency.value = subscription.frequency;
    customDays.value = subscription.customDays ?? 30;
    startDate.value = subscription.startDate;
    nextDueDate.value = subscription.nextDueDate;
    isAutoPay.value = subscription.isAutoPay;
    reminderType.value = subscription.reminderType;
  }

  /// Reset form
  void resetForm() {
    editingSubscription.value = null;
    nameController.clear();
    amountController.clear();
    descriptionController.clear();
    notesController.clear();
    selectedType.value = SubscriptionType.expense;
    selectedFrequency.value = Frequency.monthly;
    customDays.value = 30;
    startDate.value = DateTime.now();
    isAutoPay.value = false;
    reminderType.value = ReminderType.oneDay;
    _loadCategories();
    _updateNextDueDate();
  }

  /// Validate and save subscription
  Future<bool> saveSubscription() async {
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
        // Update existing subscription
        final updated = editingSubscription.value!.copyWith(
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          amount: amount,
          categoryId: selectedCategoryId.value,
          frequency: selectedFrequency.value,
          customDays: selectedFrequency.value == Frequency.custom ? customDays.value : null,
          startDate: startDate.value,
          nextDueDate: nextDueDate.value,
          isAutoPay: isAutoPay.value,
          reminderType: reminderType.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          type: selectedType.value,
        );
        await _subscriptionRepo.save(updated.id, updated);

        // Update reminder if needed
        if (reminderType.value != ReminderType.none) {
          await _scheduleReminder(updated);
        }

        _shellController.showSuccess('Subscription updated successfully');
      } else {
        // Create new subscription
        final subscription = Subscription(
          id: const Uuid().v4(),
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          amount: amount,
          categoryId: selectedCategoryId.value!,
          frequency: selectedFrequency.value,
          customDays: selectedFrequency.value == Frequency.custom ? customDays.value : null,
          startDate: startDate.value,
          nextDueDate: nextDueDate.value,
          isAutoPay: isAutoPay.value,
          reminderType: reminderType.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          createdAt: now,
          type: selectedType.value,
        );
        await _subscriptionRepo.save(subscription.id, subscription);

        // Schedule reminder if needed
        if (reminderType.value != ReminderType.none) {
          await _scheduleReminder(subscription);
        }

        _shellController.showSuccess('Subscription added successfully');
      }

      await refresh();

      // Refresh dashboard if it exists
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadData();
      }

      return true;
    } catch (e) {
      _shellController.showError('Failed to save subscription: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Schedule reminder for subscription
  Future<void> _scheduleReminder(Subscription subscription) async {
    // Calculate reminder date based on type
    DateTime reminderDate;
    switch (subscription.reminderType) {
      case ReminderType.oneDay:
        reminderDate = subscription.nextDueDate.subtract(const Duration(days: 1));
        break;
      case ReminderType.threeDays:
        reminderDate = subscription.nextDueDate.subtract(const Duration(days: 3));
        break;
      case ReminderType.oneWeek:
        reminderDate = subscription.nextDueDate.subtract(const Duration(days: 7));
        break;
      case ReminderType.none:
        return;
    }

    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    final reminder = Reminder(
      id: const Uuid().v4(),
      subscriptionId: subscription.id,
      title: '${subscription.name} Due Soon',
      body: 'Your subscription of ৳${subscription.amount.toStringAsFixed(0)} is due on ${_formatDate(subscription.nextDueDate)}',
      scheduledAt: reminderDate,
      createdAt: DateTime.now(),
    );

    await _reminderRepo.save(reminder.id, reminder);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Refresh dashboard helper
  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
  }

  /// Delete subscription
  Future<bool> deleteSubscription(String id) async {
    try {
      await _subscriptionRepo.delete(id);
      await refresh();
      _refreshDashboard();
      _shellController.showSuccess('Subscription deleted');
      return true;
    } catch (e) {
      _shellController.showError('Failed to delete subscription');
      return false;
    }
  }

  /// Pause subscription
  Future<void> pauseSubscription(String id) async {
    await _subscriptionRepo.pause(id);
    await refresh();
    _refreshDashboard();
    _shellController.showSuccess('Subscription paused');
  }

  /// Resume subscription
  Future<void> resumeSubscription(String id) async {
    await _subscriptionRepo.resume(id);
    await refresh();
    _refreshDashboard();
    _shellController.showSuccess('Subscription resumed');
  }

  /// Mark subscription as paid
  Future<void> markAsPaid(String id) async {
    await _subscriptionRepo.markAsPaid(id);
    await refresh();
    _refreshDashboard();
    _shellController.showSuccess('Marked as paid');
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get total monthly cost
  double get totalMonthlyCost => _subscriptionRepo.getTotalMonthlyCost();

  /// Get total yearly cost
  double get totalYearlyCost => _subscriptionRepo.getTotalYearlyCost();

  @override
  void onClose() {
    nameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
