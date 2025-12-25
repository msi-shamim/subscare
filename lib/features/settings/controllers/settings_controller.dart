import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/app_settings_repository.dart';
import '../../../data/services/exchange_rate_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/settlement_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../reports/controllers/reports_controller.dart';

/// Controller for managing app settings with reactive state
class SettingsController extends GetxController {
  late final AppSettingsRepository _settingsRepo;
  late final ExchangeRateService _exchangeRateService;
  late final SettlementService _settlementService;
  NotificationService? _notificationService;

  // Reactive state
  final RxString language = 'en'.obs;
  final RxString currency = 'BDT'.obs;
  final RxString themeMode = 'light'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool biometricLock = false.obs;

  // Exchange rate state
  final RxDouble exchangeRate = 120.0.obs;
  final RxBool useAutoRate = false.obs;
  final Rx<DateTime?> lastRateUpdate = Rx<DateTime?>(null);
  final RxInt settlementHour = 8.obs;
  final RxInt settlementMinute = 0.obs;
  final RxBool settlementEnabled = true.obs;
  final RxString apiKey = ''.obs;
  final RxBool isLoadingRate = false.obs;
  final RxInt unsettledCount = 0.obs;

  // Notification state
  final RxInt notificationHour = 8.obs;
  final RxInt notificationMinute = 0.obs;
  final RxBool hasNotificationPermission = false.obs;

  // Currency symbols map
  static const Map<String, String> currencySymbols = {
    'BDT': '৳',
    'USD': '\$',
    'INR': '₹',
    'EUR': '€',
    'GBP': '£',
  };

  /// Get currency symbol for current currency
  String get currencySymbol => currencySymbols[currency.value] ?? '৳';

  @override
  void onInit() {
    super.onInit();
    _settingsRepo = Get.find<AppSettingsRepository>();
    _exchangeRateService = ExchangeRateService();
    _settlementService = Get.find<SettlementService>();
    if (Get.isRegistered<NotificationService>()) {
      _notificationService = Get.find<NotificationService>();
    }
    _loadSettings();
    _updateUnsettledCount();
    _checkNotificationPermission();
  }

  /// Load settings from repository
  void _loadSettings() {
    final settings = _settingsRepo.settings;
    language.value = settings.language;
    currency.value = settings.defaultCurrency;
    themeMode.value = settings.themeMode;
    notificationsEnabled.value = settings.notificationsEnabled;
    biometricLock.value = settings.biometricLock;
    exchangeRate.value = settings.exchangeRate;
    useAutoRate.value = settings.useAutoRate;
    lastRateUpdate.value = settings.lastRateUpdate;
    settlementHour.value = settings.settlementHour;
    settlementMinute.value = settings.settlementMinute;
    settlementEnabled.value = settings.settlementEnabled;
    apiKey.value = settings.openExchangeApiKey ?? '';
    notificationHour.value = settings.notificationHour;
    notificationMinute.value = settings.notificationMinute;
  }

  /// Update unsettled count
  void _updateUnsettledCount() {
    unsettledCount.value = _settlementService.getTotalUnsettledCount();
  }

  /// Check notification permission status
  Future<void> _checkNotificationPermission() async {
    if (_notificationService != null) {
      hasNotificationPermission.value =
          await _notificationService!.hasPermissions();
    }
  }

  /// Change language
  Future<void> changeLanguage(String lang) async {
    language.value = lang;
    await _settingsRepo.setLanguage(lang);

    // Update GetX locale
    final locale = lang == 'bn' ? const Locale('bn', 'BD') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  /// Change currency
  Future<void> changeCurrency(String curr) async {
    currency.value = curr;
    await _settingsRepo.setCurrency(curr);
  }

  /// Change theme mode
  Future<void> changeThemeMode(String mode) async {
    themeMode.value = mode;
    await _settingsRepo.setThemeMode(mode);

    // Update GetX theme
    switch (mode) {
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (enabled && _notificationService != null) {
      // Request permission if enabling
      final hasPermission = await _notificationService!.requestPermissions();
      hasNotificationPermission.value = hasPermission;

      if (!hasPermission) {
        Get.snackbar(
          'permission_denied'.tr,
          'notification_permission_required'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Schedule daily notification
      await _notificationService!.scheduleDailyNotification(
        hour: notificationHour.value,
        minute: notificationMinute.value,
      );
    } else if (!enabled && _notificationService != null) {
      // Cancel scheduled notifications
      await _notificationService!.cancelDailyNotification();
    }

    notificationsEnabled.value = enabled;
    await _settingsRepo.setNotificationsEnabled(enabled);
  }

  /// Toggle biometric lock
  Future<void> toggleBiometricLock(bool enabled) async {
    biometricLock.value = enabled;
    await _settingsRepo.setBiometricLock(enabled);
  }

  /// Get ThemeMode from string
  ThemeMode getThemeMode() {
    switch (themeMode.value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// Get Locale from language string
  Locale getLocale() {
    return language.value == 'bn'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
  }

  // ============ Exchange Rate Methods ============

  /// Set manual exchange rate
  Future<void> setManualRate(double rate) async {
    exchangeRate.value = rate;
    lastRateUpdate.value = DateTime.now();
    await _settingsRepo.setExchangeRate(rate);
  }

  /// Enable auto rate with API key
  Future<bool> enableAutoRate(String key) async {
    isLoadingRate.value = true;
    try {
      // Validate API key by fetching rate
      final rate = await _exchangeRateService.fetchUsdToBdtRate(key);
      apiKey.value = key;
      useAutoRate.value = true;
      exchangeRate.value = rate;
      lastRateUpdate.value = DateTime.now();

      await _settingsRepo.setOpenExchangeApiKey(key);
      await _settingsRepo.setUseAutoRate(true);
      await _settingsRepo.setExchangeRate(rate);

      isLoadingRate.value = false;
      return true;
    } on ExchangeRateException catch (e) {
      isLoadingRate.value = false;
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Disable auto rate (switch to manual)
  Future<void> disableAutoRate() async {
    useAutoRate.value = false;
    await _settingsRepo.setUseAutoRate(false);
  }

  /// Fetch latest rate from API (manual check)
  /// Uses free API if no API key is set
  Future<bool> fetchLatestRate() async {
    isLoadingRate.value = true;
    try {
      final rate = apiKey.value.isNotEmpty
          ? await _exchangeRateService.fetchUsdToBdtRate(apiKey.value)
          : await _exchangeRateService.fetchUsdToBdtRateFree();

      exchangeRate.value = rate;
      lastRateUpdate.value = DateTime.now();
      await _settingsRepo.setExchangeRate(rate);

      isLoadingRate.value = false;
      return true;
    } on ExchangeRateException catch (e) {
      isLoadingRate.value = false;
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Fetch rate using free API (no key required)
  Future<bool> fetchRateFree() async {
    isLoadingRate.value = true;
    final oldRate = exchangeRate.value;
    try {
      final rate = await _exchangeRateService.fetchUsdToBdtRateFree();
      exchangeRate.value = rate;
      lastRateUpdate.value = DateTime.now();
      await _settingsRepo.setExchangeRate(rate);

      isLoadingRate.value = false;

      // Send notification if rate changed significantly (> 0.1)
      if ((rate - oldRate).abs() > 0.1) {
        await notifyRateUpdate(oldRate, rate);
      }

      return true;
    } on ExchangeRateException catch (e) {
      isLoadingRate.value = false;
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Set settlement time
  Future<void> setSettlementTime(int hour, int minute) async {
    settlementHour.value = hour;
    settlementMinute.value = minute;
    await _settingsRepo.setSettlementTime(hour, minute);
  }

  /// Toggle settlement enabled
  Future<void> toggleSettlement(bool enabled) async {
    settlementEnabled.value = enabled;
    await _settingsRepo.setSettlementEnabled(enabled);
  }

  /// Trigger manual settlement
  Future<int> triggerSettlement() async {
    final count = await _settlementService.settleAll(exchangeRate.value);
    _updateUnsettledCount();

    // Refresh dashboard and reports after settlement
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }
    if (Get.isRegistered<ReportsController>()) {
      Get.find<ReportsController>().loadData();
    }

    return count;
  }

  /// Get formatted settlement time
  String get formattedSettlementTime {
    final hour = settlementHour.value;
    final minute = settlementMinute.value;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted last rate update
  String get formattedLastRateUpdate {
    final date = lastRateUpdate.value;
    if (date == null) return 'never'.tr;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ============ Notification Methods ============

  /// Set notification time and reschedule
  Future<void> setNotificationTime(int hour, int minute) async {
    notificationHour.value = hour;
    notificationMinute.value = minute;
    await _settingsRepo.setNotificationTime(hour, minute);

    // Reschedule notification if enabled
    if (notificationsEnabled.value && _notificationService != null) {
      await _notificationService!.scheduleDailyNotification(
        hour: hour,
        minute: minute,
      );
    }
  }

  /// Get formatted notification time
  String get formattedNotificationTime {
    final hour = notificationHour.value;
    final minute = notificationMinute.value;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (_notificationService == null) return false;
    final granted = await _notificationService!.requestPermissions();
    hasNotificationPermission.value = granted;
    return granted;
  }

  /// Notify user about rate update
  Future<void> notifyRateUpdate(double oldRate, double newRate) async {
    if (!notificationsEnabled.value) return;
    if (_notificationService == null) return;

    await _notificationService!.showRateUpdateNotification(
      oldRate: oldRate,
      newRate: newRate,
    );
  }
}
