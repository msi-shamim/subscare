import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class AppSettingsRepository extends BaseRepository<AppSettings> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<AppSettings> get box => _hiveService.appSettingsBox;

  /// Get current app settings (singleton)
  AppSettings get settings => box.get('app_settings') ?? AppSettings.defaults;

  /// Save settings
  Future<void> saveSettings(AppSettings settings) async {
    await save('app_settings', settings);
  }

  /// Update notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    final updated = settings.copyWith(notificationsEnabled: enabled);
    await saveSettings(updated);
  }

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    final updated = settings.copyWith(soundEnabled: enabled);
    await saveSettings(updated);
  }

  /// Update vibration enabled
  Future<void> setVibrationEnabled(bool enabled) async {
    final updated = settings.copyWith(vibrationEnabled: enabled);
    await saveSettings(updated);
  }

  /// Update default currency
  Future<void> setCurrency(String currency) async {
    final updated = settings.copyWith(defaultCurrency: currency);
    await saveSettings(updated);
  }

  /// Update date format
  Future<void> setDateFormat(String format) async {
    final updated = settings.copyWith(dateFormat: format);
    await saveSettings(updated);
  }

  /// Update biometric lock
  Future<void> setBiometricLock(bool enabled) async {
    final updated = settings.copyWith(biometricLock: enabled);
    await saveSettings(updated);
  }

  /// Update backup frequency
  Future<void> setBackupFrequency(BackupFrequency frequency) async {
    final updated = settings.copyWith(backupFrequency: frequency);
    await saveSettings(updated);
  }

  /// Update last sync time
  Future<void> updateLastSync() async {
    final updated = settings.copyWith(lastSyncAt: DateTime.now());
    await saveSettings(updated);
  }

  /// Update language
  Future<void> setLanguage(String language) async {
    final updated = settings.copyWith(language: language);
    await saveSettings(updated);
  }

  /// Update theme mode
  Future<void> setThemeMode(String themeMode) async {
    final updated = settings.copyWith(themeMode: themeMode);
    await saveSettings(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings.defaults);
  }

  /// Update exchange rate (1 USD = X BDT)
  Future<void> setExchangeRate(double rate) async {
    final updated = settings.copyWith(
      exchangeRate: rate,
      lastRateUpdate: DateTime.now(),
    );
    await saveSettings(updated);
  }

  /// Update whether to use auto rate from API
  Future<void> setUseAutoRate(bool useAuto) async {
    final updated = settings.copyWith(useAutoRate: useAuto);
    await saveSettings(updated);
  }

  /// Update API key for Open Exchange Rates
  Future<void> setOpenExchangeApiKey(String? apiKey) async {
    final updated = settings.copyWith(openExchangeApiKey: apiKey);
    await saveSettings(updated);
  }

  /// Update settlement time (hour and minute)
  Future<void> setSettlementTime(int hour, int minute) async {
    final updated = settings.copyWith(
      settlementHour: hour,
      settlementMinute: minute,
    );
    await saveSettings(updated);
  }

  /// Update settlement enabled
  Future<void> setSettlementEnabled(bool enabled) async {
    final updated = settings.copyWith(settlementEnabled: enabled);
    await saveSettings(updated);
  }

  /// Update last rate update time
  Future<void> updateLastRateUpdate() async {
    final updated = settings.copyWith(lastRateUpdate: DateTime.now());
    await saveSettings(updated);
  }

  /// Update notification time (hour and minute)
  Future<void> setNotificationTime(int hour, int minute) async {
    final updated = settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await saveSettings(updated);
  }

  /// Update selected AI model
  Future<void> setSelectedAIModel(String? modelId) async {
    final updated = settings.copyWith(selectedAIModelId: modelId);
    await saveSettings(updated);
  }

  /// Update AI API key
  Future<void> setAIApiKey(String? apiKey) async {
    final updated = settings.copyWith(aiApiKey: apiKey);
    await saveSettings(updated);
  }

  /// Update AI settings (model and API key together)
  Future<void> setAISettings(String? modelId, String? apiKey) async {
    final updated = settings.copyWith(
      selectedAIModelId: modelId,
      aiApiKey: apiKey,
    );
    await saveSettings(updated);
  }
}
