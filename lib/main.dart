import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/translations/app_translations.dart';
import 'data/repositories/repositories.dart';
import 'data/services/hive_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/settlement_service.dart';
import 'data/services/ai_service.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive service and settings
  await _initServices();

  runApp(const SubsCareApp());
}

/// Initialize all services before app starts
Future<void> _initServices() async {
  // Initialize and register Hive service as permanent
  await Get.putAsync<HiveService>(
    () => HiveService().init(),
    permanent: true,
  );

  // Register repositories (needed by services and controllers)
  Get.put<AppSettingsRepository>(AppSettingsRepository(), permanent: true);
  Get.put<TransactionRepository>(TransactionRepository(), permanent: true);
  Get.put<SubscriptionRepository>(SubscriptionRepository(), permanent: true);
  Get.put<NotificationRepository>(NotificationRepository(), permanent: true);
  Get.put<CategoryRepository>(CategoryRepository(), permanent: true);

  // Register SettlementService (needs repositories)
  Get.put<SettlementService>(SettlementService(), permanent: true);

  // Initialize AIService
  await Get.putAsync<AIService>(
    () => AIService().init(),
    permanent: true,
  );

  // Initialize NotificationService
  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
    permanent: true,
  );

  // Register SettingsController as permanent for global access
  Get.put<SettingsController>(SettingsController(), permanent: true);

  // Schedule daily notification if enabled
  final settings = Get.find<AppSettingsRepository>().settings;
  if (settings.notificationsEnabled) {
    await Get.find<NotificationService>().scheduleDailyNotification(
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
    );
  }
}

class SubsCareApp extends StatelessWidget {
  const SubsCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return GetMaterialApp(
      // App info
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settingsController.getThemeMode(),

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),

      // Translations
      translations: AppTranslations(),
      locale: settingsController.getLocale(),
      fallbackLocale: const Locale('en', 'US'),

      // Error handling
      builder: (context, child) {
        // Apply global error handling or overlays here
        return MediaQuery(
          // Prevent text scaling from system settings
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
