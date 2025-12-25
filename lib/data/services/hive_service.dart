import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../models/models.dart';

/// Service class for Hive database initialization and management
class HiveService extends GetxService {
  // Box references
  late Box<UserProfile> userProfileBox;
  late Box<Category> categoriesBox;
  late Box<Transaction> transactionsBox;
  late Box<Subscription> subscriptionsBox;
  late Box<Reminder> remindersBox;
  late Box<Attachment> attachmentsBox;
  late Box<OCRScan> ocrScansBox;
  late Box<AIPromptHistory> aiPromptsBox;
  late Box<AppSettings> appSettingsBox;
  late Box<AppNotification> notificationsBox;

  /// Initialize Hive and register all adapters
  Future<HiveService> init() async {
    await Hive.initFlutter();

    // Register Enum Adapters (TypeId 0-9, 19, 20)
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(EntryMethodAdapter());
    Hive.registerAdapter(FrequencyAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(ReminderTypeAdapter());
    Hive.registerAdapter(OCRStatusAdapter());
    Hive.registerAdapter(ReminderActionAdapter());
    Hive.registerAdapter(FileTypeAdapter());
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(BackupFrequencyAdapter());
    Hive.registerAdapter(SubscriptionTypeAdapter());
    Hive.registerAdapter(CurrencyAdapter());
    Hive.registerAdapter(NotificationTypeAdapter());

    // Register Model Adapters (TypeId 10-18, 22)
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(AttachmentAdapter());
    Hive.registerAdapter(OCRScanAdapter());
    Hive.registerAdapter(AIPromptHistoryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(AppNotificationAdapter());

    // Open all boxes
    await _openBoxes();

    // Initialize default data if needed
    await _initializeDefaults();

    return this;
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    userProfileBox = await Hive.openBox<UserProfile>(AppStrings.userProfileBox);
    categoriesBox = await Hive.openBox<Category>(AppStrings.categoriesBox);
    transactionsBox = await Hive.openBox<Transaction>(AppStrings.transactionsBox);
    subscriptionsBox = await Hive.openBox<Subscription>(AppStrings.subscriptionsBox);
    remindersBox = await Hive.openBox<Reminder>(AppStrings.remindersBox);
    attachmentsBox = await Hive.openBox<Attachment>(AppStrings.attachmentsBox);
    ocrScansBox = await Hive.openBox<OCRScan>(AppStrings.ocrScansBox);
    aiPromptsBox = await Hive.openBox<AIPromptHistory>(AppStrings.aiPromptsBox);
    appSettingsBox = await Hive.openBox<AppSettings>(AppStrings.appSettingsBox);
    notificationsBox = await Hive.openBox<AppNotification>(AppStrings.notificationsBox);
  }

  /// Initialize default categories and settings
  Future<void> _initializeDefaults() async {
    // Initialize default categories if empty
    if (categoriesBox.isEmpty) {
      await _createDefaultCategories();
    }

    // Initialize app settings if empty
    if (appSettingsBox.isEmpty) {
      await appSettingsBox.put('app_settings', AppSettings.defaults);
    }
  }

  /// Create default expense/income categories
  Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      // Expense Categories (Debit)
      Category(
        id: 'cat_food',
        name: 'Food & Dining',
        icon: 'restaurant',
        color: '#EF4444',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 1,
      ),
      Category(
        id: 'cat_transport',
        name: 'Transport',
        icon: 'directions_car',
        color: '#F59E0B',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 2,
      ),
      Category(
        id: 'cat_shopping',
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '#8B5CF6',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 3,
      ),
      Category(
        id: 'cat_bills',
        name: 'Bills & Utilities',
        icon: 'receipt_long',
        color: '#3B82F6',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 4,
      ),
      Category(
        id: 'cat_entertainment',
        name: 'Entertainment',
        icon: 'movie',
        color: '#EC4899',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 5,
      ),
      Category(
        id: 'cat_health',
        name: 'Health & Medical',
        icon: 'local_hospital',
        color: '#10B981',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 6,
      ),
      Category(
        id: 'cat_education',
        name: 'Education',
        icon: 'school',
        color: '#6366F1',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 7,
      ),
      Category(
        id: 'cat_other_expense',
        name: 'Other Expense',
        icon: 'more_horiz',
        color: '#64748B',
        type: CategoryType.debit,
        isDefault: true,
        sortOrder: 8,
      ),

      // Income Categories (Credit)
      Category(
        id: 'cat_salary',
        name: 'Salary',
        icon: 'payments',
        color: '#10B981',
        type: CategoryType.credit,
        isDefault: true,
        sortOrder: 9,
      ),
      Category(
        id: 'cat_freelance',
        name: 'Freelance',
        icon: 'work',
        color: '#22C55E',
        type: CategoryType.credit,
        isDefault: true,
        sortOrder: 10,
      ),
      Category(
        id: 'cat_investment',
        name: 'Investment',
        icon: 'trending_up',
        color: '#14B8A6',
        type: CategoryType.credit,
        isDefault: true,
        sortOrder: 11,
      ),
      Category(
        id: 'cat_gift',
        name: 'Gift',
        icon: 'card_giftcard',
        color: '#F472B6',
        type: CategoryType.credit,
        isDefault: true,
        sortOrder: 12,
      ),
      Category(
        id: 'cat_other_income',
        name: 'Other Income',
        icon: 'attach_money',
        color: '#84CC16',
        type: CategoryType.credit,
        isDefault: true,
        sortOrder: 13,
      ),

      // Subscription Category (Both)
      Category(
        id: 'cat_subscription',
        name: 'Subscriptions',
        icon: 'subscriptions',
        color: '#6366F1',
        type: CategoryType.both,
        isDefault: true,
        sortOrder: 14,
      ),
    ];

    for (final category in defaultCategories) {
      await categoriesBox.put(category.id, category);
    }
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    await userProfileBox.close();
    await categoriesBox.close();
    await transactionsBox.close();
    await subscriptionsBox.close();
    await remindersBox.close();
    await attachmentsBox.close();
    await ocrScansBox.close();
    await aiPromptsBox.close();
    await appSettingsBox.close();
    await notificationsBox.close();
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    await userProfileBox.clear();
    await categoriesBox.clear();
    await transactionsBox.clear();
    await subscriptionsBox.clear();
    await remindersBox.clear();
    await attachmentsBox.clear();
    await ocrScansBox.clear();
    await aiPromptsBox.clear();
    await appSettingsBox.clear();
    await notificationsBox.clear();

    // Reinitialize defaults
    await _initializeDefaults();
  }

  @override
  void onClose() {
    closeBoxes();
    super.onClose();
  }
}
