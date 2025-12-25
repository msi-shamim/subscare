import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'exchange_rate_service.dart';

/// Background task names
const String dailySettlementTask = 'dailySettlement';
const String dailyNotificationTask = 'dailyNotification';

/// Callback dispatcher for WorkManager
/// This must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Hive for background isolate
      await Hive.initFlutter();

      // Register adapters
      _registerHiveAdapters();

      // Open boxes
      await Future.wait([
        Hive.openBox<Transaction>('transactions'),
        Hive.openBox<Subscription>('subscriptions'),
        Hive.openBox<AppSettings>('app_settings'),
        Hive.openBox<Category>('categories'),
      ]);

      switch (task) {
        case dailySettlementTask:
          await _performDailySettlement();
          break;
      }

      return true;
    } catch (e) {
      return false;
    }
  });
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(EntryMethodAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(FrequencyAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(CategoryTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ReminderTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(BackupFrequencyAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(SubscriptionAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(CategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(18)) {
    Hive.registerAdapter(AppSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(19)) {
    Hive.registerAdapter(SubscriptionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(CurrencyAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(NotificationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(AppNotificationAdapter());
  }
}

Future<void> _performDailySettlement() async {
  final settingsBox = Hive.box<AppSettings>('app_settings');
  final settings = settingsBox.get('app_settings') ?? AppSettings();

  if (!settings.settlementEnabled) return;

  double rate = settings.exchangeRate;

  // Fetch new rate if auto rate is enabled
  if (settings.useAutoRate && settings.openExchangeApiKey != null) {
    try {
      final exchangeService = ExchangeRateService();
      rate = await exchangeService.fetchUsdToBdtRate(settings.openExchangeApiKey!);

      // Save updated rate
      final updated = settings.copyWith(
        exchangeRate: rate,
        lastRateUpdate: DateTime.now(),
      );
      await settingsBox.put('app_settings', updated);
    } catch (e) {
      // Use existing rate if fetch fails
    }
  }

  // Perform settlement
  final transactionBox = Hive.box<Transaction>('transactions');
  final subscriptionBox = Hive.box<Subscription>('subscriptions');
  final now = DateTime.now();

  // Settle transactions
  for (final key in transactionBox.keys) {
    final transaction = transactionBox.get(key);
    if (transaction != null && !transaction.isSettled) {
      double convertedAmount;

      if (transaction.originalCurrency == Currency.USD) {
        convertedAmount = transaction.amount * rate;
      } else {
        convertedAmount = transaction.amount / rate;
      }

      final settled = transaction.copyWith(
        convertedAmount: convertedAmount,
        exchangeRateUsed: rate,
        isSettled: true,
        settledAt: now,
      );

      await transactionBox.put(key, settled);
    }
  }

  // Settle subscriptions
  for (final key in subscriptionBox.keys) {
    final subscription = subscriptionBox.get(key);
    if (subscription != null && !subscription.isSettled) {
      double convertedAmount;

      if (subscription.originalCurrency == Currency.USD) {
        convertedAmount = subscription.amount * rate;
      } else {
        convertedAmount = subscription.amount / rate;
      }

      final settled = subscription.copyWith(
        convertedAmount: convertedAmount,
        exchangeRateUsed: rate,
        isSettled: true,
        settledAt: now,
      );

      await subscriptionBox.put(key, settled);
    }
  }
}

/// Get counts of settled and unsettled items
/// Returns a map with 'settled' and 'unsettled' counts
Map<String, int> getSettlementCounts() {
  final transactionBox = Hive.box<Transaction>('transactions');
  final subscriptionBox = Hive.box<Subscription>('subscriptions');

  int settledCount = 0;
  int unsettledCount = 0;

  for (final transaction in transactionBox.values) {
    if (transaction.isSettled) {
      settledCount++;
    } else {
      unsettledCount++;
    }
  }

  for (final subscription in subscriptionBox.values) {
    if (subscription.isSettled) {
      settledCount++;
    } else {
      unsettledCount++;
    }
  }

  return {
    'settled': settledCount,
    'unsettled': unsettledCount,
  };
}

/// Service for managing background tasks
class BackgroundService {
  /// Initialize WorkManager
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  /// Schedule daily settlement task
  static Future<void> scheduleDailySettlement({
    required int hour,
    required int minute,
  }) async {
    // Cancel existing task first
    await Workmanager().cancelByUniqueName(dailySettlementTask);

    // Calculate initial delay to the next scheduled time
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    // Register periodic task (runs once per day)
    await Workmanager().registerPeriodicTask(
      dailySettlementTask,
      dailySettlementTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Cancel daily settlement task
  static Future<void> cancelDailySettlement() async {
    await Workmanager().cancelByUniqueName(dailySettlementTask);
  }

  /// Run settlement immediately (one-time)
  static Future<void> runSettlementNow() async {
    await Workmanager().registerOneOffTask(
      '${dailySettlementTask}_now',
      dailySettlementTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
