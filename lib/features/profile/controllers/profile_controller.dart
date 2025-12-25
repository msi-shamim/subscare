import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/bangladesh_geocode.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/repositories.dart';

/// Controller for managing user profile
class ProfileController extends GetxController {
  late final UserProfileRepository _userRepo;
  late final TransactionRepository _transactionRepo;
  late final SubscriptionRepository _subscriptionRepo;
  late final CategoryRepository _categoryRepo;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Reactive state
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final RxString selectedOccupation = ''.obs;
  final RxString selectedDivisionId = ''.obs;
  final RxString selectedDistrictId = ''.obs;
  final RxList<District> availableDistricts = <District>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Statistics
  final RxInt transactionCount = 0.obs;
  final RxInt recurringCount = 0.obs;
  final RxInt categoryCount = 0.obs;
  final RxInt daysActive = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await loadProfile();
    loadStatistics();
  }

  void _initDependencies() {
    _userRepo = Get.find<UserProfileRepository>();
    _transactionRepo = Get.find<TransactionRepository>();
    _subscriptionRepo = Get.find<SubscriptionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    var user = _userRepo.currentUser;

    // Create default profile if none exists
    if (user == null) {
      user = UserProfile(
        id: 'current_user',
        name: 'User',
        createdAt: DateTime.now(),
        isOnboarded: true,
      );
      await _userRepo.saveCurrentUser(user);
    }

    profile.value = user;

    nameController.text = user.name;
    emailController.text = user.email ?? '';
    phoneController.text = user.phone ?? '';
    addressController.text = user.address ?? '';
    selectedOccupation.value = user.occupation ?? '';
    selectedDivisionId.value = user.divisionId ?? '';
    selectedDistrictId.value = user.districtId ?? '';

    // Load districts for selected division
    if (selectedDivisionId.value.isNotEmpty) {
      availableDistricts.value =
          BangladeshGeocode.getDistrictsByDivision(selectedDivisionId.value);
    }
  }

  /// Load statistics
  void loadStatistics() {
    transactionCount.value = _transactionRepo.getAll().length;
    recurringCount.value = _subscriptionRepo.getAll().length;
    categoryCount.value = _categoryRepo.getActiveCategories().length;

    final user = _userRepo.currentUser;
    if (user != null) {
      daysActive.value = DateTime.now().difference(user.createdAt).inDays + 1;
    }
  }

  /// Get divisions list
  List<Division> get divisions => BangladeshGeocode.divisions;

  /// Get occupations list
  List<String> get occupations => BangladeshGeocode.occupations;

  /// Get occupation display name based on current language
  String getOccupationDisplayName(String occupation) {
    if (Get.locale?.languageCode == 'bn') {
      return BangladeshGeocode.occupationsBn[occupation] ?? occupation;
    }
    return occupation;
  }

  /// Get division display name based on current language
  String getDivisionDisplayName(Division division) {
    if (Get.locale?.languageCode == 'bn') {
      return division.bnName;
    }
    return division.name;
  }

  /// Get district display name based on current language
  String getDistrictDisplayName(District district) {
    if (Get.locale?.languageCode == 'bn') {
      return district.bnName;
    }
    return district.name;
  }

  /// Get current division name
  String get currentDivisionName {
    if (selectedDivisionId.value.isEmpty) return 'not_set'.tr;
    final division = BangladeshGeocode.getDivisionById(selectedDivisionId.value);
    if (division == null) return 'not_set'.tr;
    return getDivisionDisplayName(division);
  }

  /// Get current district name
  String get currentDistrictName {
    if (selectedDistrictId.value.isEmpty) return 'not_set'.tr;
    final district = BangladeshGeocode.getDistrictById(selectedDistrictId.value);
    if (district == null) return 'not_set'.tr;
    return getDistrictDisplayName(district);
  }

  /// Get current occupation display name
  String get currentOccupationName {
    if (selectedOccupation.value.isEmpty) return 'not_set'.tr;
    return getOccupationDisplayName(selectedOccupation.value);
  }

  /// Select occupation
  void selectOccupation(String occupation) {
    selectedOccupation.value = occupation;
  }

  /// Select division
  void selectDivision(String divisionId) {
    selectedDivisionId.value = divisionId;
    selectedDistrictId.value = ''; // Reset district
    availableDistricts.value =
        BangladeshGeocode.getDistrictsByDivision(divisionId);
  }

  /// Select district
  void selectDistrict(String districtId) {
    selectedDistrictId.value = districtId;
  }

  /// Update name
  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) return;
    nameController.text = name.trim();
    await _saveProfile();
  }

  /// Update email
  Future<void> updateEmail(String email) async {
    emailController.text = email.trim();
    await _saveProfile();
  }

  /// Update phone
  Future<void> updatePhone(String phone) async {
    phoneController.text = phone.trim();
    await _saveProfile();
  }

  /// Update address
  Future<void> updateAddress(String address) async {
    addressController.text = address.trim();
    await _saveProfile();
  }

  /// Save profile
  Future<void> _saveProfile() async {
    isSaving.value = true;
    try {
      final currentProfile = profile.value;
      if (currentProfile == null) {
        isSaving.value = false;
        return;
      }

      // Create updated profile with new values
      final updatedProfile = UserProfile(
        id: currentProfile.id,
        name: nameController.text.trim().isEmpty
            ? currentProfile.name
            : nameController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        occupation: selectedOccupation.value.isEmpty
            ? null
            : selectedOccupation.value,
        divisionId: selectedDivisionId.value.isEmpty
            ? null
            : selectedDivisionId.value,
        districtId: selectedDistrictId.value.isEmpty
            ? null
            : selectedDistrictId.value,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        currency: currentProfile.currency,
        theme: currentProfile.theme,
        isOnboarded: currentProfile.isOnboarded,
        createdAt: currentProfile.createdAt,
        lastBackup: currentProfile.lastBackup,
        avatarUrl: currentProfile.avatarUrl,
      );

      // Save to Hive using repository
      await _userRepo.saveCurrentUser(updatedProfile);

      // Update reactive state and force refresh
      profile.value = updatedProfile;
      profile.refresh();

      Get.snackbar(
        'success'.tr,
        'profile_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      debugPrint('Profile save error: $e');
      Get.snackbar(
        'error'.tr,
        'profile_update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Save all profile changes
  Future<void> saveAllChanges() async {
    await _saveProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
