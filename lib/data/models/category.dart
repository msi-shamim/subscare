import 'package:hive/hive.dart';
import 'enums.dart';

part 'category.g.dart';

@HiveType(typeId: 11)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String color;

  @HiveField(4)
  CategoryType type;

  @HiveField(5)
  final bool isDefault;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  int sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = CategoryType.both,
    this.isDefault = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Category copyWith({
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
    bool? isActive,
    int? sortOrder,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
