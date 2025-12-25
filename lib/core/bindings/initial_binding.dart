import 'package:get/get.dart';

import '../../data/repositories/repositories.dart';
import '../../data/services/settlement_service.dart';
import '../../features/ai_chat/controllers/ai_chat_controller.dart';
import '../../features/ai_settings/controllers/ai_settings_controller.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/transactions/controllers/transaction_controller.dart';
import '../../features/subscriptions/controllers/subscription_controller.dart';
import '../../features/ledger/controllers/ledger_controller.dart';
import '../../features/notifications/controllers/notification_controller.dart';
import '../../features/profile/controllers/profile_controller.dart';
import '../../features/reports/controllers/reports_controller.dart';
import '../controllers/shell_controller.dart';

/// Initial binding that loads when app starts
/// Registers all global dependencies
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register repositories (lazy singletons)
    Get.lazyPut<UserProfileRepository>(() => UserProfileRepository(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<TransactionRepository>(() => TransactionRepository(), fenix: true);
    Get.lazyPut<SubscriptionRepository>(() => SubscriptionRepository(), fenix: true);
    Get.lazyPut<ReminderRepository>(() => ReminderRepository(), fenix: true);
    Get.lazyPut<AppSettingsRepository>(() => AppSettingsRepository(), fenix: true);

    // Register services
    Get.lazyPut<SettlementService>(() => SettlementService(), fenix: true);

    // Register shell controller (permanent)
    Get.put<ShellController>(ShellController(), permanent: true);

    // Register dashboard controller (permanent - needs to persist for cross-controller updates)
    Get.put<DashboardController>(DashboardController(), permanent: true);

    // Register transaction controller (permanent - needs to persist for auto-refresh)
    Get.put<TransactionController>(TransactionController(), permanent: true);

    // Register subscription controller (permanent - needs to persist for auto-refresh)
    Get.put<SubscriptionController>(SubscriptionController(), permanent: true);

    // Register reports controller (permanent - embedded in shell)
    Get.put<ReportsController>(ReportsController(), permanent: true);

    // Register AI chat controller (permanent - embedded in shell)
    Get.put<AIChatController>(AIChatController(), permanent: true);
  }
}

/// Dashboard screen binding
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already registered in InitialBinding as permanent
  }
}

/// Add Transaction binding
class AddTransactionBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already registered in InitialBinding as permanent
  }
}

/// Transactions list screen binding
class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already registered in InitialBinding as permanent
  }
}

/// Reports screen binding
class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsController>(() => ReportsController());
  }
}

/// Settings screen binding
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Will be implemented later
  }
}

/// Ledger book screen binding
class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerController>(() => LedgerController());
  }
}

/// Notifications screen binding
class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

/// Profile screen binding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

/// AI Settings screen binding
class AISettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AISettingsController>(() => AISettingsController());
  }
}
