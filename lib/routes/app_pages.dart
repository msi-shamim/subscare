import 'package:get/get.dart';

import '../core/bindings/bindings.dart';
import '../features/ai_settings/views/ai_settings_view.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/profile/views/profile_view.dart';
import '../features/settings/views/settings_view.dart';
import '../features/shell/views/shell_view.dart';
import '../features/transactions/views/add_transaction_view.dart';
import '../features/ledger/views/ledger_book_view.dart';
import '../features/notifications/views/notifications_view.dart';
import '../features/reports/views/reports_view.dart';
import 'app_routes.dart';

/// App pages configuration for GetX routing
class AppPages {
  static const initial = AppRoutes.shell;

  static final routes = [
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.addTransaction,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ledger,
      page: () => const LedgerBookView(),
      binding: LedgerBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.aiPowered,
      page: () => const AISettingsView(),
      binding: AISettingsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
