import 'package:get/get.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for settling currency conversions on transactions and subscriptions
class SettlementService {
  // Use lazy getters to avoid dependency issues at construction time
  TransactionRepository get _transactionRepo => Get.find<TransactionRepository>();
  SubscriptionRepository get _subscriptionRepo => Get.find<SubscriptionRepository>();

  /// Get count of unsettled transactions
  int getUnsettledTransactionCount() {
    return _transactionRepo.getAll().where((t) => !t.isSettled).length;
  }

  /// Get count of unsettled subscriptions
  int getUnsettledSubscriptionCount() {
    return _subscriptionRepo.getAll().where((s) => !s.isSettled).length;
  }

  /// Get total unsettled count
  int getTotalUnsettledCount() {
    return getUnsettledTransactionCount() + getUnsettledSubscriptionCount();
  }

  /// Settle all unsettled transactions with the given exchange rate
  /// Rate is: 1 USD = rate BDT
  /// Returns the count of settled transactions
  Future<int> settleTransactions(double rate) async {
    final unsettled = _transactionRepo.getAll().where((t) => !t.isSettled).toList();
    final now = DateTime.now();
    int count = 0;

    for (final transaction in unsettled) {
      double convertedAmount;

      if (transaction.originalCurrency == Currency.USD) {
        // USD to BDT: multiply by rate
        convertedAmount = transaction.amount * rate;
      } else {
        // BDT to USD: divide by rate
        convertedAmount = transaction.amount / rate;
      }

      final settled = transaction.copyWith(
        convertedAmount: convertedAmount,
        exchangeRateUsed: rate,
        isSettled: true,
        settledAt: now,
      );

      await _transactionRepo.save(transaction.id, settled);
      count++;
    }

    return count;
  }

  /// Settle all unsettled subscriptions with the given exchange rate
  /// Rate is: 1 USD = rate BDT
  /// Returns the count of settled subscriptions
  Future<int> settleSubscriptions(double rate) async {
    final unsettled = _subscriptionRepo.getAll().where((s) => !s.isSettled).toList();
    final now = DateTime.now();
    int count = 0;

    for (final subscription in unsettled) {
      double convertedAmount;

      if (subscription.originalCurrency == Currency.USD) {
        // USD to BDT: multiply by rate
        convertedAmount = subscription.amount * rate;
      } else {
        // BDT to USD: divide by rate
        convertedAmount = subscription.amount / rate;
      }

      final settled = subscription.copyWith(
        convertedAmount: convertedAmount,
        exchangeRateUsed: rate,
        isSettled: true,
        settledAt: now,
      );

      await _subscriptionRepo.save(subscription.id, settled);
      count++;
    }

    return count;
  }

  /// Settle all unsettled items (transactions + subscriptions)
  /// Returns total count of settled items
  Future<int> settleAll(double rate) async {
    final transactionCount = await settleTransactions(rate);
    final subscriptionCount = await settleSubscriptions(rate);
    return transactionCount + subscriptionCount;
  }

  /// Get settlement summary
  SettlementSummary getSummary() {
    final transactions = _transactionRepo.getAll();
    final subscriptions = _subscriptionRepo.getAll();

    return SettlementSummary(
      totalTransactions: transactions.length,
      settledTransactions: transactions.where((t) => t.isSettled).length,
      unsettledTransactions: transactions.where((t) => !t.isSettled).length,
      totalSubscriptions: subscriptions.length,
      settledSubscriptions: subscriptions.where((s) => s.isSettled).length,
      unsettledSubscriptions: subscriptions.where((s) => !s.isSettled).length,
    );
  }
}

/// Summary of settlement status
class SettlementSummary {
  final int totalTransactions;
  final int settledTransactions;
  final int unsettledTransactions;
  final int totalSubscriptions;
  final int settledSubscriptions;
  final int unsettledSubscriptions;

  SettlementSummary({
    required this.totalTransactions,
    required this.settledTransactions,
    required this.unsettledTransactions,
    required this.totalSubscriptions,
    required this.settledSubscriptions,
    required this.unsettledSubscriptions,
  });

  int get totalSettled => settledTransactions + settledSubscriptions;
  int get totalUnsettled => unsettledTransactions + unsettledSubscriptions;
  int get total => totalTransactions + totalSubscriptions;
}
