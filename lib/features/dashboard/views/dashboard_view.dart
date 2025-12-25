import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../routes/app_routes.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/dashboard_controller.dart';

/// Dashboard view with analytics and ledger
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

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
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsCards(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildLedgerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildAnalyticsCard(
              title: 'income'.tr,
              amountBDT: controller.totalIncome.value,
              amountUSD: controller.totalIncomeUSD.value,
              icon: Icons.arrow_downward,
              color: AppColors.credit,
            ),
            _buildAnalyticsCard(
              title: 'expense'.tr,
              amountBDT: controller.totalExpense.value,
              amountUSD: controller.totalExpenseUSD.value,
              icon: Icons.arrow_upward,
              color: AppColors.debit,
            ),
            _buildAnalyticsCard(
              title: 'balance'.tr,
              amountBDT: controller.balance.value,
              amountUSD: controller.balanceUSD.value,
              icon: Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
            _buildUpcomingCard(),
          ],
        ));
  }

  Widget _buildAnalyticsCard({
    required String title,
    required double amountBDT,
    required double amountUSD,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳${amountBDT.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '\$${amountUSD.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'upcoming'.tr,
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.schedule, color: AppColors.warning, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '+৳${controller.upcomingIncome.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.credit,
                    ),
                  ),
                  Text(
                    ' (\$${controller.upcomingIncomeUSD.value.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.credit.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '-৳${controller.upcomingExpense.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.debit,
                    ),
                  ),
                  Text(
                    ' (\$${controller.upcomingExpenseUSD.value.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.debit.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'debit', 'label': 'Debit'},
      {'key': 'credit', 'label': 'Credit'},
      {'key': 'today', 'label': 'Today'},
      {'key': 'week', 'label': 'This Week'},
    ];

    return SizedBox(
      height: 40,
      child: Obx(() {
        // Access observable here so GetX can track it
        final currentFilter = controller.currentFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = currentFilter == filter['key'];

            return FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (_) => controller.applyFilter(filter['key']!),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLedgerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.ledger),
              child: Text('see_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.recentItems.isEmpty) {
            return _buildEmptyState();
          }

          return _buildRecentList();
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            onPressed: () {
              Get.toNamed(AppRoutes.addTransaction);
            },
            icon: const Icon(Icons.add),
            label: Text('add_transaction'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.recentItems.length,
      itemBuilder: (context, index) {
        final item = controller.recentItems[index];
        // All items are now transactions (including recurring ones)
        return _buildTransactionTile(item.transaction!, currencyFormat);
      },
    );
  }

  Widget _buildTransactionTile(Transaction transaction, NumberFormat currencyFormat) {
    final category = controller.getCategoryById(transaction.categoryId);
    final isDebit = transaction.type == TransactionType.debit;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Stack(
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
            // Recurring indicator
            if (transaction.isRecurring)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
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
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          category?.name ?? 'uncategorized'.tr,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isDebit ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDebit ? AppColors.debit : AppColors.credit,
              ),
            ),
            Text(
              DateFormat('hh:mm a').format(transaction.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
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
                Text(
                  '${isDebit ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDebit ? AppColors.debit : AppColors.credit,
                  ),
                ),
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
            const SizedBox(height: 20),
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
