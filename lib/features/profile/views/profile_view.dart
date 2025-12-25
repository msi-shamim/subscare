import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

/// Profile view for user information
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              _buildAvatar(),
              const SizedBox(height: 32),

              // Personal Information Section
              _buildSectionHeader('personal_info'.tr),
              const SizedBox(height: 12),
              _buildProfileField(
                icon: Icons.person_outline,
                label: 'full_name'.tr,
                value: controller.profile.value?.name.isEmpty ?? true
                    ? 'not_set'.tr
                    : controller.profile.value!.name,
                onTap: () => _showEditDialog(
                  context,
                  'full_name'.tr,
                  controller.profile.value?.name ?? '',
                  (value) => controller.updateName(value),
                ),
              ),
              _buildProfileField(
                icon: Icons.email_outlined,
                label: 'email'.tr,
                value: controller.profile.value?.email?.isEmpty ?? true
                    ? 'not_set'.tr
                    : controller.profile.value!.email!,
                onTap: () => _showEditDialog(
                  context,
                  'email'.tr,
                  controller.profile.value?.email ?? '',
                  (value) => controller.updateEmail(value),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              _buildProfileField(
                icon: Icons.phone_outlined,
                label: 'phone'.tr,
                value: controller.profile.value?.phone?.isEmpty ?? true
                    ? 'not_set'.tr
                    : controller.profile.value!.phone!,
                onTap: () => _showEditDialog(
                  context,
                  'phone'.tr,
                  controller.profile.value?.phone ?? '',
                  (value) => controller.updatePhone(value),
                  keyboardType: TextInputType.phone,
                ),
              ),
              _buildProfileField(
                icon: Icons.work_outline,
                label: 'occupation'.tr,
                value: controller.currentOccupationName,
                onTap: () => _showOccupationPicker(context),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Address Section
              _buildSectionHeader('address_info'.tr),
              const SizedBox(height: 12),
              _buildProfileField(
                icon: Icons.location_city_outlined,
                label: 'division'.tr,
                value: controller.currentDivisionName,
                onTap: () => _showDivisionPicker(context),
              ),
              _buildProfileField(
                icon: Icons.map_outlined,
                label: 'district'.tr,
                value: controller.currentDistrictName,
                onTap: controller.selectedDivisionId.value.isEmpty
                    ? () => Get.snackbar(
                          'info'.tr,
                          'select_division_first'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        )
                    : () => _showDistrictPicker(context),
              ),
              _buildProfileField(
                icon: Icons.home_outlined,
                label: 'address'.tr,
                value: controller.profile.value?.address?.isEmpty ?? true
                    ? 'not_set'.tr
                    : controller.profile.value!.address!,
                onTap: () => _showEditDialog(
                  context,
                  'address'.tr,
                  controller.profile.value?.address ?? '',
                  (value) => controller.updateAddress(value),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Stats Section
              _buildSectionHeader('statistics'.tr),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'transactions'.tr,
                      value: controller.transactionCount.value.toString(),
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'recurring'.tr,
                      value: controller.recurringCount.value.toString(),
                      icon: Icons.repeat,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'categories'.tr,
                      value: controller.categoryCount.value.toString(),
                      icon: Icons.category_outlined,
                      color: AppColors.credit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'days_active'.tr,
                      value: controller.daysActive.value.toString(),
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.debit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: value == 'not_set'.tr ? Colors.grey : Colors.black87,
          ),
        ),
        trailing: Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String currentValue,
    Future<void> Function(String) onSave, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final textController = TextEditingController(text: currentValue);
    Get.dialog(
      AlertDialog(
        title: Text('${'edit'.tr} $field'),
        content: TextField(
          controller: textController,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: '${'enter'.tr} $field',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await onSave(textController.text);
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showOccupationPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader('select_occupation'.tr),
            Expanded(
              child: ListView.builder(
                itemCount: controller.occupations.length,
                itemBuilder: (context, index) {
                  final occupation = controller.occupations[index];
                  final isSelected =
                      controller.selectedOccupation.value == occupation;
                  return ListTile(
                    title: Text(controller.getOccupationDisplayName(occupation)),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      controller.selectOccupation(occupation);
                      controller.saveAllChanges();
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDivisionPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader('select_division'.tr),
            Expanded(
              child: ListView.builder(
                itemCount: controller.divisions.length,
                itemBuilder: (context, index) {
                  final division = controller.divisions[index];
                  final isSelected =
                      controller.selectedDivisionId.value == division.id;
                  return ListTile(
                    title: Text(controller.getDivisionDisplayName(division)),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      controller.selectDivision(division.id);
                      controller.saveAllChanges();
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistrictPicker(BuildContext context) {
    Get.bottomSheet(
      Obx(() => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHeader('select_district'.tr),
                Expanded(
                  child: controller.availableDistricts.isEmpty
                      ? Center(
                          child: Text(
                            'no_districts'.tr,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.availableDistricts.length,
                          itemBuilder: (context, index) {
                            final district = controller.availableDistricts[index];
                            final isSelected =
                                controller.selectedDistrictId.value == district.id;
                            return ListTile(
                              title:
                                  Text(controller.getDistrictDisplayName(district)),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                controller.selectDistrict(district.id);
                                controller.saveAllChanges();
                                Get.back();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildBottomSheetHeader(String title) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
