import 'package:hive/hive.dart';
import 'enums.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 18)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  bool soundEnabled;

  @HiveField(3)
  bool vibrationEnabled;

  @HiveField(4)
  String defaultCurrency;

  @HiveField(5)
  String dateFormat;

  @HiveField(6)
  bool biometricLock;

  @HiveField(7)
  BackupFrequency backupFrequency;

  @HiveField(8)
  DateTime? lastSyncAt;

  @HiveField(9, defaultValue: 'en')
  String language; // 'en' or 'bn'

  @HiveField(10, defaultValue: 'light')
  String themeMode; // 'light', 'dark', or 'system'

  /// Exchange rate: 1 USD = X BDT
  @HiveField(11, defaultValue: 120.0)
  double exchangeRate;

  /// Whether to use auto rate from API or manual rate
  @HiveField(12, defaultValue: false)
  bool useAutoRate;

  /// Last time the rate was updated (from API or manual)
  @HiveField(13)
  DateTime? lastRateUpdate;

  /// Hour for daily settlement (0-23, default 8)
  @HiveField(14, defaultValue: 8)
  int settlementHour;

  /// Minute for daily settlement (0-59, default 0)
  @HiveField(15, defaultValue: 0)
  int settlementMinute;

  /// Whether auto settlement is enabled
  @HiveField(16, defaultValue: true)
  bool settlementEnabled;

  /// API key for Open Exchange Rates
  @HiveField(17)
  String? openExchangeApiKey;

  /// Hour for daily notification (0-23, default 8)
  @HiveField(18, defaultValue: 8)
  int notificationHour;

  /// Minute for daily notification (0-59, default 0)
  @HiveField(19, defaultValue: 0)
  int notificationMinute;

  /// Selected AI model ID
  @HiveField(20)
  String? selectedAIModelId;

  /// AI API key (encrypted/stored securely)
  @HiveField(21)
  String? aiApiKey;

  AppSettings({
    this.id = 'app_settings',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.defaultCurrency = 'BDT',
    this.dateFormat = 'dd/MM/yyyy',
    this.biometricLock = false,
    this.backupFrequency = BackupFrequency.manual,
    this.lastSyncAt,
    this.language = 'en',
    this.themeMode = 'light',
    this.exchangeRate = 120.0,
    this.useAutoRate = false,
    this.lastRateUpdate,
    this.settlementHour = 8,
    this.settlementMinute = 0,
    this.settlementEnabled = true,
    this.openExchangeApiKey,
    this.notificationHour = 8,
    this.notificationMinute = 0,
    this.selectedAIModelId,
    this.aiApiKey,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? defaultCurrency,
    String? dateFormat,
    bool? biometricLock,
    BackupFrequency? backupFrequency,
    DateTime? lastSyncAt,
    String? language,
    String? themeMode,
    double? exchangeRate,
    bool? useAutoRate,
    DateTime? lastRateUpdate,
    int? settlementHour,
    int? settlementMinute,
    bool? settlementEnabled,
    String? openExchangeApiKey,
    int? notificationHour,
    int? notificationMinute,
    String? selectedAIModelId,
    String? aiApiKey,
  }) {
    return AppSettings(
      id: id,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      dateFormat: dateFormat ?? this.dateFormat,
      biometricLock: biometricLock ?? this.biometricLock,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      useAutoRate: useAutoRate ?? this.useAutoRate,
      lastRateUpdate: lastRateUpdate ?? this.lastRateUpdate,
      settlementHour: settlementHour ?? this.settlementHour,
      settlementMinute: settlementMinute ?? this.settlementMinute,
      settlementEnabled: settlementEnabled ?? this.settlementEnabled,
      openExchangeApiKey: openExchangeApiKey ?? this.openExchangeApiKey,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      selectedAIModelId: selectedAIModelId ?? this.selectedAIModelId,
      aiApiKey: aiApiKey ?? this.aiApiKey,
    );
  }

  /// Get default settings instance
  static AppSettings get defaults => AppSettings();
}
