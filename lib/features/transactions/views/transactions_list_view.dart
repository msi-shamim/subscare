import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../routes/app_routes.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/transaction_controller.dart';

/// List view for all transactions
class TransactionsListView extends GetView<TransactionController> {
  const TransactionsListView({super.key});

  /// Get currency format from settings
  NumberFormat get currencyFormat {
    final settings = Get.find<SettingsController>();
    return NumberFormat.currency(
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.transactions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionsList();
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'no_recent_activity'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'start_by_adding'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddTransaction(),
                icon: const Icon(Icons.add),
                label: Text('add_transaction'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Group transactions by date
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in controller.transactions) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(transaction);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final transactions = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...transactions.map((t) => _buildTransactionCard(t, currencyFormat)),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'today'.tr;
    } else if (date == yesterday) {
      return 'yesterday'.tr;
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    }
  }

  Widget _buildTransactionCard(Transaction transaction, NumberFormat currencyFormat) {
    final category = controller.getCategoryById(transaction.categoryId);
    final isDebit = transaction.type == TransactionType.debit;

    // Get next due date for recurring transactions
    String? nextDueText;
    if (transaction.isRecurring && transaction.subscriptionId != null) {
      final subscription = controller.getSubscriptionById(transaction.subscriptionId!);
      if (subscription != null) {
        nextDueText = '${'next'.tr}: ${DateFormat('MMM dd').format(subscription.nextDueDate)}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDebit ? AppColors.debit : AppColors.credit)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category?.icon),
                      color: isDebit ? AppColors.debit : AppColors.credit,
                    ),
                  ),
                  if (transaction.isRecurring)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.repeat,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category?.name ?? 'uncategorized'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (nextDueText != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          Text(
                            nextDueText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDualCurrencyAmount(transaction, isDebit),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('hh:mm a').format(transaction.dateTime),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final category = controller.getCategoryById(transaction.categoryId);
    final isDebit = transaction.type == TransactionType.debit;

    // Get subscription info for recurring
    Subscription? subscription;
    if (transaction.isRecurring && transaction.subscriptionId != null) {
      subscription = controller.getSubscriptionById(transaction.subscriptionId!);
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title and Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category?.icon),
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category?.name ?? 'uncategorized'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDualCurrencyAmountLarge(transaction, isDebit),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            // Date & Time
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'date'.tr,
              value: DateFormat('EEEE, MMM dd, yyyy').format(transaction.dateTime),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'time'.tr,
              value: DateFormat('hh:mm a').format(transaction.dateTime),
            ),
            // Recurring info
            if (transaction.isRecurring && subscription != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.repeat,
                label: 'recurring'.tr,
                value: _getFrequencyText(subscription.frequency),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.event_outlined,
                label: 'next_due'.tr,
                value: DateFormat('MMM dd, yyyy').format(subscription.nextDueDate),
              ),
            ],
            // Notes
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.notes_outlined,
                label: 'notes'.tr,
                value: transaction.notes!,
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.initForEdit(transaction);
                      Get.toNamed(AppRoutes.addTransaction);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text('edit'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _confirmDelete(transaction);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text('delete'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getFrequencyText(Frequency frequency) {
    switch (frequency) {
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

  void _confirmDelete(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_transaction'.tr),
        content: Text('${'delete_confirm'.tr} "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteTransaction(transaction.id);
              controller.refresh();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddTransaction() async {
    controller.resetForm();
    final result = await Get.toNamed(AppRoutes.addTransaction);
    if (result == true) {
      controller.refresh();
    }
  }

  Widget _buildDualCurrencyAmountLarge(Transaction transaction, bool isDebit) {
    final prefix = isDebit ? '-' : '+';
    final color = isDebit ? AppColors.debit : AppColors.credit;

    final primarySymbol = transaction.originalCurrency == Currency.USD ? '\$' : '৳';
    final primaryAmount = '$prefix$primarySymbol${transaction.amount.toStringAsFixed(transaction.originalCurrency == Currency.USD ? 2 : 0)}';

    String secondaryAmount;
    if (transaction.isSettled && transaction.convertedAmount != null) {
      final secondarySymbol = transaction.originalCurrency == Currency.USD ? '৳' : '\$';
      final decimals = transaction.originalCurrency == Currency.USD ? 0 : 2;
      secondaryAmount = '$secondarySymbol${transaction.convertedAmount!.toStringAsFixed(decimals)}';
    } else {
      final settings = Get.find<SettingsController>();
      final rate = settings.exchangeRate.value;
      if (transaction.originalCurrency == Currency.USD) {
        final converted = transaction.amount * rate;
        secondaryAmount = '≈৳${converted.toStringAsFixed(0)}';
      } else {
        final converted = transaction.amount / rate;
        secondaryAmount = '≈\$${converted.toStringAsFixed(2)}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          primaryAmount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          secondaryAmount,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDualCurrencyAmount(Transaction transaction, bool isDebit) {
    final prefix = isDebit ? '-' : '+';
    final color = isDebit ? AppColors.debit : AppColors.credit;

    // Primary amount (original currency)
    final primarySymbol = transaction.originalCurrency == Currency.USD ? '\$' : '৳';
    final primaryAmount = '$prefix$primarySymbol${transaction.amount.toStringAsFixed(transaction.originalCurrency == Currency.USD ? 2 : 0)}';

    // Secondary amount (converted)
    String secondaryAmount;
    if (transaction.isSettled && transaction.convertedAmount != null) {
      final secondarySymbol = transaction.originalCurrency == Currency.USD ? '৳' : '\$';
      final decimals = transaction.originalCurrency == Currency.USD ? 0 : 2;
      secondaryAmount = '$secondarySymbol${transaction.convertedAmount!.toStringAsFixed(decimals)}';
    } else {
      // Show approximate using current rate
      final settings = Get.find<SettingsController>();
      final rate = settings.exchangeRate.value;
      if (transaction.originalCurrency == Currency.USD) {
        final converted = transaction.amount * rate;
        secondaryAmount = '≈৳${converted.toStringAsFixed(0)}';
      } else {
        final converted = transaction.amount / rate;
        secondaryAmount = '≈\$${converted.toStringAsFixed(2)}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          primaryAmount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          secondaryAmount,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
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
