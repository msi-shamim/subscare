import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/controllers/shell_controller.dart';
import '../../settings/controllers/settings_controller.dart';

/// Ledger entry model for unified transaction/subscription display
class LedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final String category;
  final double debit;
  final double credit;
  final double balance;
  final String type; // 'transaction' or 'subscription'
  final String? notes;
  // Dual currency support
  final Currency originalCurrency;
  final double? convertedDebit;
  final double? convertedCredit;
  final double? convertedBalance;
  final bool isSettled;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.category,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.type,
    this.notes,
    this.originalCurrency = Currency.BDT,
    this.convertedDebit,
    this.convertedCredit,
    this.convertedBalance,
    this.isSettled = false,
  });
}

/// Controller for Ledger Book view
class LedgerController extends GetxController {
  // Dependencies
  late final TransactionRepository _transactionRepo;
  late final SubscriptionRepository _subscriptionRepo;
  late final CategoryRepository _categoryRepo;
  late final ShellController _shellController;

  // State
  final RxBool isLoading = true.obs;
  final RxList<LedgerEntry> ledgerEntries = <LedgerEntry>[].obs;
  final RxMap<String, Category> categoriesMap = <String, Category>{}.obs;

  // Summary (BDT)
  final RxDouble totalDebit = 0.0.obs;
  final RxDouble totalCredit = 0.0.obs;
  final RxDouble currentBalance = 0.0.obs;

  // Summary (USD)
  final RxDouble totalDebitUSD = 0.0.obs;
  final RxDouble totalCreditUSD = 0.0.obs;
  final RxDouble currentBalanceUSD = 0.0.obs;

  // Filter
  final RxString filterType = 'all'.obs; // 'all', 'transactions', 'subscriptions'
  final Rx<DateTime?> filterStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> filterEndDate = Rx<DateTime?>(null);

  // Full view mode (landscape)
  final RxBool isFullView = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    loadLedger();
  }

  @override
  void onClose() {
    // Reset to portrait when leaving
    if (isFullView.value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.onClose();
  }

  void _initDependencies() {
    _transactionRepo = Get.find<TransactionRepository>();
    _subscriptionRepo = Get.find<SubscriptionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    _shellController = Get.find<ShellController>();
  }

  /// Load all ledger entries
  Future<void> loadLedger() async {
    isLoading.value = true;
    try {
      // Load categories
      final categories = _categoryRepo.getActiveCategories();
      categoriesMap.value = {for (var c in categories) c.id: c};

      // Get exchange rate for unsettled calculations
      final settings = Get.find<SettingsController>();
      final currentRate = settings.exchangeRate.value;

      // Combine transactions and subscriptions
      final List<LedgerEntry> entries = [];
      double runningBalanceBDT = 0.0;
      double runningBalanceUSD = 0.0;
      double debitSumBDT = 0.0;
      double creditSumBDT = 0.0;
      double debitSumUSD = 0.0;
      double creditSumUSD = 0.0;

      // Get all transactions
      final transactions = _transactionRepo.getAllSorted();

      // Get all paid subscriptions (as transactions)
      final subscriptions = _subscriptionRepo.getAll();

      // Create entries from transactions
      for (final t in transactions) {
        final category = categoriesMap[t.categoryId];
        final isDebit = t.type == TransactionType.debit;

        // Calculate amounts in both currencies
        double amountBDT;
        double amountUSD;

        if (t.isSettled && t.convertedAmount != null) {
          if (t.originalCurrency == Currency.BDT) {
            amountBDT = t.amount;
            amountUSD = t.convertedAmount!;
          } else {
            amountUSD = t.amount;
            amountBDT = t.convertedAmount!;
          }
        } else {
          // Use current rate for unsettled
          if (t.originalCurrency == Currency.BDT) {
            amountBDT = t.amount;
            amountUSD = t.amount / currentRate;
          } else {
            amountUSD = t.amount;
            amountBDT = t.amount * currentRate;
          }
        }

        if (isDebit) {
          debitSumBDT += amountBDT;
          debitSumUSD += amountUSD;
          runningBalanceBDT -= amountBDT;
          runningBalanceUSD -= amountUSD;
        } else {
          creditSumBDT += amountBDT;
          creditSumUSD += amountUSD;
          runningBalanceBDT += amountBDT;
          runningBalanceUSD += amountUSD;
        }

        entries.add(LedgerEntry(
          id: t.id,
          date: t.dateTime,
          description: t.title,
          category: category?.name ?? 'Uncategorized',
          debit: isDebit ? amountBDT : 0,
          credit: isDebit ? 0 : amountBDT,
          balance: runningBalanceBDT,
          type: 'transaction',
          notes: t.notes,
          originalCurrency: t.originalCurrency,
          convertedDebit: isDebit ? amountUSD : 0,
          convertedCredit: isDebit ? 0 : amountUSD,
          convertedBalance: runningBalanceUSD,
          isSettled: t.isSettled,
        ));
      }

      // Create entries from subscriptions (showing as recurring expenses)
      for (final s in subscriptions) {
        if (!s.isActive) continue;

        final category = categoriesMap[s.categoryId];
        final isExpense = s.type == SubscriptionType.expense;

        // Calculate amounts in both currencies
        double amountBDT;
        double amountUSD;

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

        entries.add(LedgerEntry(
          id: s.id,
          date: s.createdAt,
          description: '${s.name} (Subscription)',
          category: category?.name ?? 'Uncategorized',
          debit: isExpense ? amountBDT : 0,
          credit: isExpense ? 0 : amountBDT,
          balance: 0, // Subscriptions are recurring, balance calculated separately
          type: 'subscription',
          notes: 'Next due: ${_formatDate(s.nextDueDate)} • ${_getFrequencyLabel(s.frequency)}',
          originalCurrency: s.originalCurrency,
          convertedDebit: isExpense ? amountUSD : 0,
          convertedCredit: isExpense ? 0 : amountUSD,
          convertedBalance: 0,
          isSettled: s.isSettled,
        ));
      }

      // Sort by date (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));

      // Recalculate running balance in chronological order
      final sortedEntries = entries.reversed.toList();
      runningBalanceBDT = 0.0;
      runningBalanceUSD = 0.0;
      for (var i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        if (entry.type == 'transaction') {
          runningBalanceBDT = runningBalanceBDT - entry.debit + entry.credit;
          runningBalanceUSD = runningBalanceUSD - (entry.convertedDebit ?? 0) + (entry.convertedCredit ?? 0);
          sortedEntries[i] = LedgerEntry(
            id: entry.id,
            date: entry.date,
            description: entry.description,
            category: entry.category,
            debit: entry.debit,
            credit: entry.credit,
            balance: runningBalanceBDT,
            type: entry.type,
            notes: entry.notes,
            originalCurrency: entry.originalCurrency,
            convertedDebit: entry.convertedDebit,
            convertedCredit: entry.convertedCredit,
            convertedBalance: runningBalanceUSD,
            isSettled: entry.isSettled,
          );
        }
      }

      // Apply filters
      var filteredEntries = sortedEntries.reversed.toList();

      if (filterType.value == 'transactions') {
        filteredEntries = filteredEntries.where((e) => e.type == 'transaction').toList();
      } else if (filterType.value == 'subscriptions') {
        filteredEntries = filteredEntries.where((e) => e.type == 'subscription').toList();
      }

      if (filterStartDate.value != null) {
        filteredEntries = filteredEntries.where((e) =>
          e.date.isAfter(filterStartDate.value!) ||
          e.date.isAtSameMomentAs(filterStartDate.value!)
        ).toList();
      }

      if (filterEndDate.value != null) {
        filteredEntries = filteredEntries.where((e) =>
          e.date.isBefore(filterEndDate.value!.add(const Duration(days: 1)))
        ).toList();
      }

      ledgerEntries.value = filteredEntries;
      totalDebit.value = debitSumBDT;
      totalCredit.value = creditSumBDT;
      currentBalance.value = creditSumBDT - debitSumBDT;
      totalDebitUSD.value = debitSumUSD;
      totalCreditUSD.value = creditSumUSD;
      currentBalanceUSD.value = creditSumUSD - debitSumUSD;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh ledger
  @override
  Future<void> refresh() async {
    await loadLedger();
  }

  /// Set filter type
  void setFilterType(String type) {
    filterType.value = type;
    loadLedger();
  }

  /// Set date range filter
  void setDateRange(DateTime? start, DateTime? end) {
    filterStartDate.value = start;
    filterEndDate.value = end;
    loadLedger();
  }

  /// Clear filters
  void clearFilters() {
    filterType.value = 'all';
    filterStartDate.value = null;
    filterEndDate.value = null;
    loadLedger();
  }

  /// Toggle full view mode (landscape)
  void toggleFullView() {
    isFullView.value = !isFullView.value;
    if (isFullView.value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  /// Export ledger to Excel file
  Future<void> exportToExcel() async {
    try {
      _shellController.setLoading(true);

      final excel = Excel.createExcel();
      final sheet = excel['Ledger'];

      // Add headers
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Description'),
        TextCellValue('Category'),
        TextCellValue('Debit'),
        TextCellValue('Credit'),
        TextCellValue('Balance'),
        TextCellValue('Type'),
        TextCellValue('Notes'),
      ]);

      // Style headers
      for (var i = 0; i < 8; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue200,
        );
      }

      // Add data rows
      for (final entry in ledgerEntries) {
        sheet.appendRow([
          TextCellValue(_formatDate(entry.date)),
          TextCellValue(entry.description),
          TextCellValue(entry.category),
          DoubleCellValue(entry.debit),
          DoubleCellValue(entry.credit),
          DoubleCellValue(entry.balance),
          TextCellValue(entry.type),
          TextCellValue(entry.notes ?? ''),
        ]);
      }

      // Add summary row
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('TOTAL'),
        TextCellValue(''),
        TextCellValue(''),
        DoubleCellValue(totalDebit.value),
        DoubleCellValue(totalCredit.value),
        DoubleCellValue(currentBalance.value),
        TextCellValue(''),
        TextCellValue(''),
      ]);

      // Remove default sheet
      excel.delete('Sheet1');

      // Save file
      final bytes = excel.save();
      if (bytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'SubsCare_Ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'SubsCare Ledger Export',
        ),
      );

      _shellController.showSuccess('Ledger exported successfully');
    } catch (e) {
      _shellController.showError('Failed to export: $e');
    } finally {
      _shellController.setLoading(false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
}
