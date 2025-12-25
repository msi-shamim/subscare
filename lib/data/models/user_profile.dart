import 'package:hive/hive.dart';
import 'enums.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? avatarUrl;

  @HiveField(4)
  String currency;

  @HiveField(5)
  AppThemeMode theme;

  @HiveField(6)
  bool isOnboarded;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  DateTime? lastBackup;

  @HiveField(9)
  String? phone;

  @HiveField(10)
  String? occupation;

  @HiveField(11)
  String? divisionId;

  @HiveField(12)
  String? districtId;

  @HiveField(13)
  String? address;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.currency = 'BDT',
    this.theme = AppThemeMode.system,
    this.isOnboarded = false,
    required this.createdAt,
    this.lastBackup,
    this.phone,
    this.occupation,
    this.divisionId,
    this.districtId,
    this.address,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? currency,
    AppThemeMode? theme,
    bool? isOnboarded,
    DateTime? lastBackup,
    String? phone,
    String? occupation,
    String? divisionId,
    String? districtId,
    String? address,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt,
      lastBackup: lastBackup ?? this.lastBackup,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      divisionId: divisionId ?? this.divisionId,
      districtId: districtId ?? this.districtId,
      address: address ?? this.address,
    );
  }
}
