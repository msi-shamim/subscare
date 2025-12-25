import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_profile.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/repositories.dart';
import '../../routes/app_routes.dart';
import '../constants/app_colors.dart';

/// Main shell controller that manages app-wide state
/// Handles navigation, theme, and global app state
class ShellController extends GetxController {
  // Dependencies
  late final AppSettingsRepository _settingsRepo;
  late final UserProfileRepository _userRepo;

  // Navigation state
  final RxInt currentIndex = 0.obs;
  final RxBool isDrawerOpen = false.obs;

  // Theme state (using Flutter's ThemeMode)
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Notification unread count
  final RxInt unreadNotificationCount = 0.obs;

  // User state
  final Rx<UserProfile?> currentUser = Rx<UserProfile?>(null);

  // App settings
  final Rx<AppSettings?> settings = Rx<AppSettings?>(null);

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _loadInitialData();
  }

  void _initDependencies() {
    _settingsRepo = Get.find<AppSettingsRepository>();
    _userRepo = Get.find<UserProfileRepository>();
  }

  void _loadInitialData() {
    // Load app settings
    settings.value = _settingsRepo.settings;

    // Load user profile
    currentUser.value = _userRepo.currentUser;

    // Update notification count
    updateNotificationCount();
  }

  /// Update unread notification count
  void updateNotificationCount() {
    if (Get.isRegistered<NotificationRepository>()) {
      final notificationRepo = Get.find<NotificationRepository>();
      unreadNotificationCount.value = notificationRepo.getUnreadCount();
    }
  }

  /// Change bottom navigation tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Toggle drawer
  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  /// Open drawer
  void openDrawer() {
    isDrawerOpen.value = true;
  }

  /// Close drawer
  void closeDrawer() {
    isDrawerOpen.value = false;
  }

  /// Update theme mode
  Future<void> updateTheme(ThemeMode mode) async {
    themeMode.value = mode;
  }

  /// Check if user is onboarded
  bool get isOnboarded => currentUser.value?.isOnboarded ?? false;

  /// Refresh user data
  void refreshUser() {
    currentUser.value = _userRepo.currentUser;
  }

  /// Refresh settings
  void refreshSettings() {
    settings.value = _settingsRepo.settings;
  }

  /// Set loading state
  void setLoading(bool value) {
    isLoading.value = value;
  }

  /// Show snackbar message
  void showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show error message
  void showError(String message) => showMessage(message, isError: true);

  /// Show success message
  void showSuccess(String message) => showMessage(message);

  /// Show add options bottom sheet (Transaction or Subscription)
  void showAddOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAddOption(
              icon: Icons.receipt_long,
              title: 'Transaction',
              subtitle: 'Record an expense or income',
              color: AppColors.primary,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.addTransaction);
              },
            ),
            const SizedBox(height: 12),
            _buildAddOption(
              icon: Icons.subscriptions,
              title: 'Subscription',
              subtitle: 'Add a recurring payment',
              color: AppColors.secondary,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.addSubscription);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
