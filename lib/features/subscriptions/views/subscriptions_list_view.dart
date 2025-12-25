import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../routes/app_routes.dart';
import '../controllers/subscription_controller.dart';

/// List view for all subscriptions
class SubscriptionsListView extends GetView<SubscriptionController> {
  const SubscriptionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.subscriptions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSubscriptionsList();
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSubscription(),
        backgroundColor: AppColors.secondary,
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
                Icons.subscriptions_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No subscriptions yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your recurring payments to track them',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddSubscription(),
                icon: const Icon(Icons.add),
                label: const Text('Add Subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    final currencyFormat = NumberFormat.currency(
      symbol: '৳',
      decimalDigits: 0,
    );

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = controller.subscriptions[index];
        return _buildSubscriptionCard(subscription, currencyFormat);
      },
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription, NumberFormat currencyFormat) {
    final category = controller.getCategoryById(subscription.categoryId);
    final isActive = subscription.isActive && !subscription.isPaused;
    final isPaused = subscription.isPaused;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPaused
              ? AppColors.warning.withValues(alpha: 0.3)
              : isActive
                  ? AppColors.secondary.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: () => _showSubscriptionOptions(subscription),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.subscriptions,
                      color: isPaused ? AppColors.warning : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isPaused)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Paused',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category?.name ?? 'Uncategorized',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(subscription.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        _getFrequencyLabel(subscription.frequency),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      'Next Due',
                      DateFormat('MMM dd, yyyy').format(subscription.nextDueDate),
                      _isDueSoon(subscription.nextDueDate)
                          ? AppColors.warning
                          : Colors.grey.shade700,
                    ),
                    _buildInfoItem(
                      'Auto-Pay',
                      subscription.isAutoPay ? 'On' : 'Off',
                      subscription.isAutoPay ? AppColors.credit : Colors.grey.shade500,
                    ),
                    _buildInfoItem(
                      'Started',
                      DateFormat('MMM dd').format(subscription.startDate),
                      Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  bool _isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff <= 3 && diff >= 0;
  }

  String _getFrequencyLabel(Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.yearly:
        return 'Yearly';
      case Frequency.custom:
        return 'Custom';
    }
  }

  void _showSubscriptionOptions(Subscription subscription) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              subscription.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (!subscription.isPaused)
              _buildOptionTile(
                icon: Icons.check_circle_outline,
                title: 'Mark as Paid',
                color: AppColors.credit,
                onTap: () {
                  Get.back();
                  controller.markAsPaid(subscription.id);
                },
              ),
            _buildOptionTile(
              icon: subscription.isPaused ? Icons.play_arrow : Icons.pause,
              title: subscription.isPaused ? 'Resume' : 'Pause',
              color: AppColors.warning,
              onTap: () {
                Get.back();
                if (subscription.isPaused) {
                  controller.resumeSubscription(subscription.id);
                } else {
                  controller.pauseSubscription(subscription.id);
                }
              },
            ),
            _buildOptionTile(
              icon: Icons.edit_outlined,
              title: 'Edit',
              color: AppColors.primary,
              onTap: () {
                Get.back();
                controller.initForEdit(subscription);
                Get.toNamed(AppRoutes.addSubscription);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Delete',
              color: AppColors.error,
              onTap: () {
                Get.back();
                _confirmDelete(subscription);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _confirmDelete(Subscription subscription) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text('Are you sure you want to delete "${subscription.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSubscription(subscription.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddSubscription() async {
    controller.resetForm();
    final result = await Get.toNamed(AppRoutes.addSubscription);
    if (result == true) {
      controller.refresh();
    }
  }
}
