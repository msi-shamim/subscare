import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/ledger_controller.dart';
import 'ledger_book_landscape_view.dart';

/// Excel-like Ledger Book view
class LedgerBookView extends GetView<LedgerController> {
  const LedgerBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const LedgerBookLandscapeView();
        }
        return _buildPortraitView(context);
      },
    );
  }

  Widget _buildPortraitView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ledger_book'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'filter'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.screen_rotation),
            onPressed: () => controller.toggleFullView(),
            tooltip: 'full_view'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => controller.exportToExcel(),
            tooltip: 'export_excel'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.ledgerEntries.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildLedgerTable();
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSummaryCard(),
    );
  }

  Widget _buildSummaryCard() {
    return SafeArea(
      child: Obx(() => Container(
        height: 100,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'total_debit'.tr,
              '৳${controller.totalDebit.value.toStringAsFixed(0)}',
              '\$${controller.totalDebitUSD.value.toStringAsFixed(2)}',
              Icons.arrow_upward,
            ),
            Container(width: 1, height: 50, color: Colors.white24),
            _buildSummaryItem(
              'total_credit'.tr,
              '৳${controller.totalCredit.value.toStringAsFixed(0)}',
              '\$${controller.totalCreditUSD.value.toStringAsFixed(2)}',
              Icons.arrow_downward,
            ),
            Container(width: 1, height: 50, color: Colors.white24),
            _buildSummaryItem(
              'balance'.tr,
              '৳${controller.currentBalance.value.toStringAsFixed(0)}',
              '\$${controller.currentBalanceUSD.value.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildSummaryItem(String label, String valueBDT, String valueUSD, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(valueBDT, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(valueUSD, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('all_filter'.tr, 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('transactions'.tr, 'transactions'),
          const SizedBox(width: 8),
          _buildFilterChip('recurring'.tr, 'subscriptions'),
          if (controller.filterStartDate.value != null || controller.filterEndDate.value != null) ...[
            const SizedBox(width: 8),
            ActionChip(
              label: Text('clear_dates'.tr),
              avatar: const Icon(Icons.close, size: 16),
              onPressed: () => controller.setDateRange(null, null),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.filterType.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFilterType(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLedgerTable() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: Text('date'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('description'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('category'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('debit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.debit)), numeric: true),
            DataColumn(label: Text('credit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.credit)), numeric: true),
            DataColumn(label: Text('balance'.tr, style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          ],
          rows: controller.ledgerEntries.map((entry) => _buildDataRow(entry)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(LedgerEntry entry) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yy');
    final isSubscription = entry.type == 'subscription';

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (isSubscription) return AppColors.secondary.withValues(alpha: 0.05);
        return null;
      }),
      cells: [
        DataCell(Text(dateFormat.format(entry.date), style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(entry.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    if (isSubscription) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('SUB', style: TextStyle(fontSize: 8, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text(entry.notes!, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(entry.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          ),
        ),
        DataCell(Text(
          entry.debit > 0 ? currencyFormat.format(entry.debit) : '-',
          style: TextStyle(color: entry.debit > 0 ? AppColors.debit : Colors.grey.shade400, fontWeight: entry.debit > 0 ? FontWeight.w600 : FontWeight.normal, fontSize: 13),
        )),
        DataCell(Text(
          entry.credit > 0 ? currencyFormat.format(entry.credit) : '-',
          style: TextStyle(color: entry.credit > 0 ? AppColors.credit : Colors.grey.shade400, fontWeight: entry.credit > 0 ? FontWeight.w600 : FontWeight.normal, fontSize: 13),
        )),
        DataCell(Text(
          isSubscription ? '-' : currencyFormat.format(entry.balance),
          style: TextStyle(color: isSubscription ? Colors.grey.shade400 : (entry.balance >= 0 ? AppColors.credit : AppColors.debit), fontWeight: FontWeight.w600, fontSize: 13),
        )),
      ],
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
              Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('no_entries'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('ledger_empty_desc'.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('filter_by_date'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('start_date'.tr),
              subtitle: Obx(() => Text(
                controller.filterStartDate.value != null ? DateFormat('dd/MM/yyyy').format(controller.filterStartDate.value!) : 'not_set'.tr,
              )),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: controller.filterStartDate.value ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) controller.setDateRange(date, controller.filterEndDate.value);
              },
            ),
            ListTile(
              title: Text('end_date'.tr),
              subtitle: Obx(() => Text(
                controller.filterEndDate.value != null ? DateFormat('dd/MM/yyyy').format(controller.filterEndDate.value!) : 'not_set'.tr,
              )),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: controller.filterEndDate.value ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) controller.setDateRange(controller.filterStartDate.value, date);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () { controller.clearFilters(); Get.back(); }, child: Text('clear_all'.tr)),
          TextButton(onPressed: () => Get.back(), child: Text('done'.tr)),
        ],
      ),
    );
  }
}
