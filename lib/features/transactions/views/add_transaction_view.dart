import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';
import '../controllers/transaction_controller.dart';

/// View for adding/editing a transaction
class AddTransactionView extends GetView<TransactionController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode ? 'edit_transaction'.tr : 'add_transaction'.tr,
            )),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (controller.isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type Selector
            _buildTypeSelector(),
            const SizedBox(height: 16),

            // Currency Selector
            _buildCurrencySelector(),
            const SizedBox(height: 24),

            // Amount Input
            _buildAmountInput(),

            // Converted Amount Preview
            _buildConvertedPreview(),
            const SizedBox(height: 16),

            // Title Input
            _buildTitleInput(),
            const SizedBox(height: 16),

            // Category Selector
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Date/Time Picker
            _buildDateTimePicker(context),
            const SizedBox(height: 16),

            // Make Recurring Toggle (only for new transactions)
            if (!controller.isEditMode) ...[
              _buildRecurringToggle(),
              const SizedBox(height: 16),
            ],

            // Notes Input
            _buildNotesInput(),
            const SizedBox(height: 24),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.debit,
                label: 'expense'.tr,
                icon: Icons.arrow_upward,
                color: AppColors.debit,
                isSelected: controller.selectedType.value == TransactionType.debit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.credit,
                label: 'income'.tr,
                icon: Icons.arrow_downward,
                color: AppColors.credit,
                isSelected: controller.selectedType.value == TransactionType.credit,
              ),
            ),
          ],
        ));
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.changeType(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCurrencyButton(
              currency: Currency.BDT,
              label: '৳ BDT',
              isSelected: controller.selectedCurrency.value == Currency.BDT,
            ),
            const SizedBox(width: 12),
            _buildCurrencyButton(
              currency: Currency.USD,
              label: '\$ USD',
              isSelected: controller.selectedCurrency.value == Currency.USD,
            ),
          ],
        ));
  }

  Widget _buildCurrencyButton({
    required Currency currency,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.selectedCurrency.value = currency,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Obx(() {
      final color = controller.selectedType.value == TransactionType.debit
          ? AppColors.debit
          : AppColors.credit;
      final currencySymbol = controller.selectedCurrency.value == Currency.USD ? '\$ ' : '৳ ';

      return TextFormField(
        controller: controller.amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
          ),
          prefixText: currencySymbol,
          prefixStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'enter_amount'.tr;
          }
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            return 'enter_valid_amount'.tr;
          }
          return null;
        },
      );
    });
  }

  Widget _buildConvertedPreview() {
    return Obx(() {
      final amount = controller.currentAmount.value;
      if (amount <= 0) return const SizedBox.shrink();

      final convertedAmount = controller.previewConvertedAmount;
      final targetCurrency = controller.selectedCurrency.value == Currency.USD ? '৳' : '\$';
      final convertedText = '$targetCurrency${convertedAmount.toStringAsFixed(2)}';

      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '≈ $convertedText',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: controller.titleController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'transaction_title'.tr,
        hintText: 'title_hint'.tr,
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'enter_title'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'category'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final categories = controller.currentCategories;

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = controller.selectedCategoryId.value == category.id;
              final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

              return InkWell(
                onTap: () => controller.selectCategory(category.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category.icon),
                        size: 18,
                        color: isSelected ? color : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? color : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Obx(() {
      final dateFormat = DateFormat('EEE, MMM dd, yyyy');
      final timeFormat = DateFormat('hh:mm a');
      final date = controller.selectedDateTime.value;

      return InkWell(
        onTap: () => controller.selectDateTime(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      timeFormat.format(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecurringToggle() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.isRecurring.value
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: controller.isRecurring.value
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: controller.isRecurring.value
                      ? AppColors.primary
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'make_recurring'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: controller.isRecurring.value
                              ? AppColors.primary
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        'recurring_desc'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.isRecurring.value,
                  onChanged: (value) => controller.isRecurring.value = value,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Recurring options (shown when toggle is ON)
          if (controller.isRecurring.value) ...[
            const SizedBox(height: 16),
            _buildFrequencySelector(),
            const SizedBox(height: 12),
            _buildReminderSelector(),
          ],
        ],
      );
    });
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'frequency'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Frequency.values.map((freq) {
              final isSelected = controller.selectedFrequency.value == freq;
              return InkWell(
                onTap: () => controller.selectedFrequency.value = freq,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _getFrequencyLabel(freq),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),

        // Custom days input
        Obx(() {
          if (controller.selectedFrequency.value == Frequency.custom) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Text('${'every'.tr} '),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: controller.customDays.value.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        final days = int.tryParse(value) ?? 30;
                        controller.customDays.value = days.clamp(1, 365);
                      },
                    ),
                  ),
                  Text(' ${'days'.tr}'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildReminderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'remind_me'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReminderType.values.map((reminder) {
              final isSelected = controller.reminderType.value == reminder;
              return InkWell(
                onTap: () => controller.reminderType.value = reminder,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _getReminderLabel(reminder),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  String _getFrequencyLabel(Frequency freq) {
    switch (freq) {
      case Frequency.daily:
        return 'daily'.tr;
      case Frequency.weekly:
        return 'weekly'.tr;
      case Frequency.monthly:
        return 'monthly'.tr;
      case Frequency.yearly:
        return 'yearly'.tr;
      case Frequency.custom:
        return 'custom'.tr;
    }
  }

  String _getReminderLabel(ReminderType reminder) {
    switch (reminder) {
      case ReminderType.none:
        return 'reminder_none'.tr;
      case ReminderType.oneDay:
        return 'reminder_1day'.tr;
      case ReminderType.threeDays:
        return 'reminder_3days'.tr;
      case ReminderType.oneWeek:
        return 'reminder_1week'.tr;
    }
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: controller.notesController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'notes_optional'.tr,
        hintText: 'notes_hint'.tr,
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Icon(Icons.notes),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveAndGoBack() async {
    final success = await controller.saveTransaction();
    if (success) {
      controller.resetForm();
      if (Get.isRegistered<TransactionController>()) {
        Get.find<TransactionController>().refresh();
      }
      Get.back(result: true);
    }
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : () => _saveAndGoBack(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    controller.isEditMode ? 'update_transaction'.tr : 'save_transaction'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_transaction'.tr),
        content: Text('delete_transaction_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (controller.editingTransaction.value != null) {
                final success = await controller.deleteTransaction(
                  controller.editingTransaction.value!.id,
                );
                if (success) {
                  Get.back(result: true);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    final icons = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'receipt_long': Icons.receipt_long,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'more_horiz': Icons.more_horiz,
      'payments': Icons.payments,
      'work': Icons.work,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'attach_money': Icons.attach_money,
      'subscriptions': Icons.subscriptions,
    };
    return icons[iconName] ?? Icons.category;
  }
}
