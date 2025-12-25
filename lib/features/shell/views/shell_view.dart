import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/shell_controller.dart';
import '../../../routes/app_routes.dart';
import '../../ai_chat/views/ai_chat_view.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../reports/controllers/reports_controller.dart';
import '../../reports/views/reports_view.dart';
import '../../transactions/views/transactions_list_view.dart';

/// Main shell view with bottom navigation and drawer
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_getTitle(controller.currentIndex.value))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildNotificationButton(),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Obx(() => _buildBody(controller.currentIndex.value)),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNotificationButton() {
    return Obx(() {
      final unreadCount = controller.unreadNotificationCount.value;

      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () async {
              await Get.toNamed(AppRoutes.notifications);
              // Refresh count when returning from notifications page
              controller.updateNotificationCount();
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'dashboard'.tr;
      case 1:
        return 'transactions'.tr;
      case 2:
        return 'ai'.tr;
      case 3:
        return 'reports'.tr;
      default:
        return 'app_name'.tr;
    }
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const TransactionsListView();
      case 2:
        return const AIChatView();
      case 3:
        return const ReportsView();
      default:
        return const DashboardView();
    }
  }

  Widget _buildBottomNav() {
    return ConvexAppBar(
      style: TabStyle.react,
      backgroundColor: AppColors.primary,
      activeColor: Colors.white,
      color: Colors.white70,
      height: 60,
      items: [
        TabItem(icon: Icons.dashboard_outlined, title: 'home'.tr),
        TabItem(icon: Icons.receipt_long_outlined, title: 'transactions'.tr),
        TabItem(icon: Icons.auto_awesome, title: 'ai'.tr),
        TabItem(icon: Icons.pie_chart_outline, title: 'reports'.tr),
      ],
      initialActiveIndex: controller.currentIndex.value,
      onTap: (index) {
        controller.changeTab(index);
        // Refresh reports data when switching to Reports tab
        // This ensures translated labels are up-to-date
        if (index == 3 && Get.isRegistered<ReportsController>()) {
          Get.find<ReportsController>().loadData();
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'app_name'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'app_tagline'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'profile'.tr,
            onTap: () => _navigateFromDrawer(context, AppRoutes.profile),
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'settings'.tr,
            onTap: () => _navigateFromDrawer(context, AppRoutes.settings),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.auto_awesome_outlined,
            title: 'ai_powered'.tr,
            onTap: () => _navigateFromDrawer(context, AppRoutes.aiPowered),
          ),
          _buildDrawerItem(
            icon: Icons.file_download_outlined,
            title: 'export_data'.tr,
            onTap: () => _navigateFromDrawer(context, '/export'),
          ),
          _buildDrawerItem(
            icon: Icons.backup_outlined,
            title: 'backup'.tr,
            onTap: () => _navigateFromDrawer(context, '/backup'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'about'.tr,
            onTap: () => _navigateFromDrawer(context, '/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateFromDrawer(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    Get.toNamed(route);
  }
}
