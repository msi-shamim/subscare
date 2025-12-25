import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';

/// Settings view for app configuration
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Section
          _buildSectionHeader('general'.tr),
          _buildLanguageTile(),
          _buildCurrencyTile(),
          const SizedBox(height: 24),
          // Currency Converter Section
          _buildSectionHeader('currency_converter'.tr),
          _buildExchangeRateTile(),
          _buildRateSourceTile(),
          _buildSettlementTimeTile(),
          _buildSettlementToggleTile(),
          _buildSettleNowTile(),
          const SizedBox(height: 24),
          // Appearance Section
          _buildSectionHeader('appearance'.tr),
          _buildThemeTile(),
          const SizedBox(height: 24),
          // Notifications Section
          _buildSectionHeader('notifications'.tr),
          Obx(() => _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'push_notifications'.tr,
                subtitle: 'receive_payment_reminders'.tr,
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              )),
          _buildNotificationTimeTile(),
          const SizedBox(height: 24),
          // Security Section
          _buildSectionHeader('security'.tr),
          Obx(() => _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'biometric_lock'.tr,
                subtitle: 'use_fingerprint'.tr,
                value: controller.biometricLock.value,
                onChanged: controller.toggleBiometricLock,
              )),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'change_pin'.tr,
            subtitle: 'set_change_pin'.tr,
            onTap: () {
              // TODO: Implement PIN change
            },
          ),
          const SizedBox(height: 24),
          // Data Section
          _buildSectionHeader('data'.tr),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'clear_all_data'.tr,
            subtitle: 'delete_all_warning'.tr,
            onTap: () => _showClearDataDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Obx(() {
      final currentLang = controller.language.value;
      final langDisplay = currentLang == 'bn' ? 'বাংলা' : 'English';

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(Icons.language_outlined, color: AppColors.primary),
          title: Text(
            'language'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            langDisplay,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showLanguageDialog(),
        ),
      );
    });
  }

  Widget _buildCurrencyTile() {
    return Obx(() {
      final currentCurrency = controller.currency.value;
      final currencyDisplay = currentCurrency == 'USD'
          ? '\$ USD'
          : '৳ BDT';

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(Icons.attach_money, color: AppColors.primary),
          title: Text(
            'currency'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            currencyDisplay,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showCurrencyDialog(),
        ),
      );
    });
  }

  Widget _buildThemeTile() {
    return Obx(() {
      final currentTheme = controller.themeMode.value;
      String themeDisplay;
      switch (currentTheme) {
        case 'dark':
          themeDisplay = 'dark_mode_option'.tr;
          break;
        case 'system':
          themeDisplay = 'system_default'.tr;
          break;
        default:
          themeDisplay = 'light_mode'.tr;
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(
            currentTheme == 'dark' ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primary,
          ),
          title: Text(
            'dark_mode'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            themeDisplay,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showThemeDialog(),
        ),
      );
    });
  }

  Widget _buildExchangeRateTile() {
    return Obx(() {
      final rate = controller.exchangeRate.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(Icons.currency_exchange, color: AppColors.primary),
          title: Text(
            'current_rate'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '1 USD = ৳${rate.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: controller.useAutoRate.value
              ? Icon(Icons.lock, color: Colors.grey.shade400, size: 20)
              : Icon(Icons.edit, color: AppColors.primary, size: 20),
          onTap: controller.useAutoRate.value ? null : () => _showEditRateDialog(),
        ),
      );
    });
  }

  Widget _buildRateSourceTile() {
    return Obx(() {
      final lastUpdate = controller.formattedLastRateUpdate;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.sync, color: AppColors.primary),
              title: Text(
                'check_online_rate'.tr,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${'last_updated'.tr}: $lastUpdate',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: controller.isLoadingRate.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: () async {
                        final success = await controller.fetchRateFree();
                        if (success) {
                          Get.snackbar(
                            'success'.tr,
                            'rate_updated'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Text('check_now'.tr),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettlementTimeTile() {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(Icons.schedule, color: AppColors.primary),
          title: Text(
            'settlement_time'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            controller.formattedSettlementTime,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showSettlementTimeDialog(),
        ),
      );
    });
  }

  Widget _buildSettlementToggleTile() {
    return Obx(() => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: SwitchListTile(
            secondary: Icon(Icons.autorenew, color: AppColors.primary),
            title: Text(
              'auto_settlement'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'auto_settlement_desc'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            value: controller.settlementEnabled.value,
            onChanged: controller.toggleSettlement,
            activeColor: AppColors.primary,
          ),
        ));
  }

  Widget _buildSettleNowTile() {
    return Obx(() {
      final unsettled = controller.unsettledCount.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          leading: Icon(Icons.play_circle_outline, color: AppColors.primary),
          title: Text(
            'settle_now'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          subtitle: Text(
            '$unsettled ${'unsettled_items'.tr}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: unsettled > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unsettled.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: unsettled > 0 ? () => _triggerSettlement() : null,
        ),
      );
    });
  }

  void _showEditRateDialog() {
    final textController = TextEditingController(
      text: controller.exchangeRate.value.toStringAsFixed(2),
    );
    Get.dialog(
      AlertDialog(
        title: Text('edit_rate'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'enter_rate_desc'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '1 USD = ? BDT',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: '৳ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              final rate = double.tryParse(textController.text);
              if (rate != null && rate > 0) {
                controller.setManualRate(rate);
                Get.back();
                Get.snackbar(
                  'success'.tr,
                  'rate_updated'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showSettlementTimeDialog() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: controller.settlementHour.value,
        minute: controller.settlementMinute.value,
      ),
    );
    if (time != null) {
      await controller.setSettlementTime(time.hour, time.minute);
    }
  }

  Future<void> _triggerSettlement() async {
    final count = await controller.triggerSettlement();
    Get.snackbar(
      'success'.tr,
      '$count ${'items_settled'.tr}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              'english'.tr,
              controller.language.value == 'en',
              () {
                controller.changeLanguage('en');
                Get.back();
              },
            ),
            _buildOptionTile(
              'bengali'.tr,
              controller.language.value == 'bn',
              () {
                controller.changeLanguage('bn');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('currency'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              'bdt'.tr,
              controller.currency.value == 'BDT',
              () {
                controller.changeCurrency('BDT');
                Get.back();
              },
            ),
            _buildOptionTile(
              'usd'.tr,
              controller.currency.value == 'USD',
              () {
                controller.changeCurrency('USD');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('dark_mode'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              'light_mode'.tr,
              controller.themeMode.value == 'light',
              () {
                controller.changeThemeMode('light');
                Get.back();
              },
            ),
            _buildOptionTile(
              'dark_mode_option'.tr,
              controller.themeMode.value == 'dark',
              () {
                controller.changeThemeMode('dark');
                Get.back();
              },
            ),
            _buildOptionTile(
              'system_default'.tr,
              controller.themeMode.value == 'system',
              () {
                controller.changeThemeMode('system');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTimeTile() {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(Icons.access_time, color: AppColors.primary),
          title: Text(
            'daily_notification_time'.tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            controller.formattedNotificationTime,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showNotificationTimeDialog(),
          enabled: controller.notificationsEnabled.value,
        ),
      );
    });
  }

  void _showNotificationTimeDialog() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: controller.notificationHour.value,
        minute: controller.notificationMinute.value,
      ),
    );
    if (time != null) {
      await controller.setNotificationTime(time.hour, time.minute);
    }
  }

  void _showClearDataDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('clear_all_data'.tr),
        content: Text('clear_data_warning'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear all data
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('clear_all'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}
