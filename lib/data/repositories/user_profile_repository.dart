import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/enums.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class UserProfileRepository extends BaseRepository<UserProfile> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<UserProfile> get box => _hiveService.userProfileBox;

  /// Get current user profile (singleton)
  UserProfile? get currentUser => box.get('current_user');

  /// Check if user is onboarded
  bool get isOnboarded => currentUser?.isOnboarded ?? false;

  /// Save or update current user
  Future<void> saveCurrentUser(UserProfile user) async {
    await save('current_user', user);
  }

  /// Update user profile fields
  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? currency,
    AppThemeMode? theme,
    bool? isOnboarded,
    String? phone,
    String? occupation,
    String? divisionId,
    String? districtId,
    String? address,
  }) async {
    final user = currentUser;
    if (user != null) {
      final updated = user.copyWith(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        currency: currency,
        theme: theme,
        isOnboarded: isOnboarded,
        phone: phone,
        occupation: occupation,
        divisionId: divisionId,
        districtId: districtId,
        address: address,
      );
      await saveCurrentUser(updated);
    }
  }

  /// Mark user as onboarded
  Future<void> completeOnboarding() async {
    await updateProfile(isOnboarded: true);
  }

  /// Update last backup time
  Future<void> updateLastBackup() async {
    final user = currentUser;
    if (user != null) {
      final updated = user.copyWith(lastBackup: DateTime.now());
      await saveCurrentUser(updated);
    }
  }
}
