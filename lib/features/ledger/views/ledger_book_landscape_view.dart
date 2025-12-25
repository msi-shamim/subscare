import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/ledger_controller.dart';

/// Landscape layout for Ledger Book
class LedgerBookLandscapeView extends GetView<LedgerController> {
  const LedgerBookLandscapeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('ledger_book'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 48,
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_lock_portrait, size: 20),
            onPressed: () => controller.toggleFullView(),
            tooltip: 'exit_full_view'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.file_download, size: 20),
            onPressed: () => controller.exportToExcel(),
            tooltip: 'export_excel'.tr,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Table
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.ledgerEntries.isEmpty) {
              return Center(
                child: Text('no_entries'.tr, style: const TextStyle(color: Colors.grey)),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: screenWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                      dataRowMinHeight: 36,
                      dataRowMaxHeight: 44,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      headingRowHeight: 40,
                      columns: [
                        DataColumn(label: Text('date'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('description'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('category'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('debit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.debit)), numeric: true),
                        DataColumn(label: Text('credit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.credit)), numeric: true),
                        DataColumn(label: Text('balance'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
                      ],
                      rows: controller.ledgerEntries.map((entry) => _buildDataRow(entry)).toList(),
                    ),
                  ),
                ),
              ),
            );
          }),
          // Bottom summary card
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: _buildBottomSummary(screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(double screenWidth) {
    final cardWidth = screenWidth / 3;
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    return Center(
      child: Obx(() => Container(
        width: cardWidth,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(Icons.arrow_upward, currencyFormat.format(controller.totalDebit.value)),
            Container(width: 1, height: 20, color: Colors.white24),
            _buildSummaryItem(Icons.arrow_downward, currencyFormat.format(controller.totalCredit.value)),
            Container(width: 1, height: 20, color: Colors.white24),
            _buildSummaryItem(Icons.account_balance_wallet, currencyFormat.format(controller.currentBalance.value)),
          ],
        ),
      )),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
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
        DataCell(Text(dateFormat.format(entry.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade700))),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(entry.description, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                if (isSubscription) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                    child: Text('S', style: TextStyle(fontSize: 7, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)),
            child: Text(entry.category, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
          ),
        ),
        DataCell(Text(
          entry.debit > 0 ? currencyFormat.format(entry.debit) : '-',
          style: TextStyle(color: entry.debit > 0 ? AppColors.debit : Colors.grey.shade400, fontSize: 10, fontWeight: entry.debit > 0 ? FontWeight.w600 : FontWeight.normal),
        )),
        DataCell(Text(
          entry.credit > 0 ? currencyFormat.format(entry.credit) : '-',
          style: TextStyle(color: entry.credit > 0 ? AppColors.credit : Colors.grey.shade400, fontSize: 10, fontWeight: entry.credit > 0 ? FontWeight.w600 : FontWeight.normal),
        )),
        DataCell(Text(
          isSubscription ? '-' : currencyFormat.format(entry.balance),
          style: TextStyle(color: isSubscription ? Colors.grey.shade400 : (entry.balance >= 0 ? AppColors.credit : AppColors.debit), fontSize: 10, fontWeight: FontWeight.w600),
        )),
      ],
    );
  }
}
