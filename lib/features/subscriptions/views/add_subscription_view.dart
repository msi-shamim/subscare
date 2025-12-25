import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';
import '../controllers/subscription_controller.dart';

/// View for adding/editing a subscription
class AddSubscriptionView extends GetView<SubscriptionController> {
  const AddSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode ? 'Edit Subscription' : 'Add Subscription',
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
            // Type Selector (Expense/Income)
            _buildTypeSelector(),
            const SizedBox(height: 16),

            // Name Input
            _buildNameInput(),
            const SizedBox(height: 16),

            // Amount Input
            _buildAmountInput(),
            const SizedBox(height: 16),

            // Category Selector
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Frequency Selector
            _buildFrequencySelector(),
            const SizedBox(height: 16),

            // Start Date Picker
            _buildStartDatePicker(context),
            const SizedBox(height: 16),

            // Next Due Date (Read-only)
            _buildNextDueDateInfo(),
            const SizedBox(height: 16),

            // Auto-Pay Toggle
            _buildAutoPayToggle(),
            const SizedBox(height: 16),

            // Reminder Selector
            _buildReminderSelector(),
            const SizedBox(height: 16),

            // Description Input
            _buildDescriptionInput(),
            const SizedBox(height: 16),

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
                type: SubscriptionType.expense,
                label: 'Expense',
                icon: Icons.arrow_upward,
                color: AppColors.debit,
                isSelected: controller.selectedType.value == SubscriptionType.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                type: SubscriptionType.income,
                label: 'Income',
                icon: Icons.arrow_downward,
                color: AppColors.credit,
                isSelected: controller.selectedType.value == SubscriptionType.income,
              ),
            ),
          ],
        ));
  }

  Widget _buildTypeButton({
    required SubscriptionType type,
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

  Widget _buildNameInput() {
    return TextFormField(
      controller: controller.nameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Subscription Name',
        hintText: 'e.g., Netflix, Spotify, Gym',
        prefixIcon: const Icon(Icons.subscriptions),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixText: '৳ ',
        prefixIcon: const Icon(Icons.payments),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final categories = controller.categories;

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

  Widget _buildFrequencySelector() {
    final frequencies = [
      {'value': Frequency.daily, 'label': 'Daily'},
      {'value': Frequency.weekly, 'label': 'Weekly'},
      {'value': Frequency.monthly, 'label': 'Monthly'},
      {'value': Frequency.yearly, 'label': 'Yearly'},
      {'value': Frequency.custom, 'label': 'Custom'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Frequency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: frequencies.map((freq) {
                final isSelected = controller.selectedFrequency.value == freq['value'];

                return ChoiceChip(
                  label: Text(freq['label'] as String),
                  selected: isSelected,
                  onSelected: (_) => controller.changeFrequency(freq['value'] as Frequency),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            )),
        Obx(() {
          if (controller.selectedFrequency.value == Frequency.custom) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Text('Every '),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: controller.customDays.value.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (value) {
                        final days = int.tryParse(value) ?? 30;
                        controller.updateCustomDays(days);
                      },
                    ),
                  ),
                  const Text(' days'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildStartDatePicker(BuildContext context) {
    return Obx(() {
      final dateFormat = DateFormat('EEE, MMM dd, yyyy');
      final date = controller.startDate.value;

      return InkWell(
        onTap: () => controller.selectStartDate(context),
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
                      'Start Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildNextDueDateInfo() {
    return Obx(() {
      final dateFormat = DateFormat('EEE, MMM dd, yyyy');
      final date = controller.nextDueDate.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Due Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    dateFormat.format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAutoPayToggle() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.credit_card, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto-Pay Enabled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Automatically debit when due',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.isAutoPay.value,
                onChanged: controller.toggleAutoPay,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ));
  }

  Widget _buildReminderSelector() {
    final reminders = [
      {'value': ReminderType.none, 'label': 'None'},
      {'value': ReminderType.oneDay, 'label': '1 Day Before'},
      {'value': ReminderType.threeDays, 'label': '3 Days Before'},
      {'value': ReminderType.oneWeek, 'label': '1 Week Before'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            const Text(
              'Reminder',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reminders.map((rem) {
                final isSelected = controller.reminderType.value == rem['value'];

                return ChoiceChip(
                  label: Text(rem['label'] as String),
                  selected: isSelected,
                  onSelected: (_) => controller.changeReminderType(rem['value'] as ReminderType),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: controller.descriptionController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Brief description of the subscription',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: controller.notesController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional details...',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.notes),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : () async {
                    final success = await controller.saveSubscription();
                    if (success) {
                      Get.back(result: true);
                    }
                  },
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
                    controller.isEditMode ? 'Update Subscription' : 'Save Subscription',
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
        title: const Text('Delete Subscription'),
        content: const Text('Are you sure you want to delete this subscription?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (controller.editingSubscription.value != null) {
                final success = await controller.deleteSubscription(
                  controller.editingSubscription.value!.id,
                );
                if (success) {
                  Get.back(result: true);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
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
