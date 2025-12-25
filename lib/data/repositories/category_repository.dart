import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/hive_service.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository<Category> {
  final HiveService _hiveService = Get.find<HiveService>();

  @override
  Box<Category> get box => _hiveService.categoriesBox;

  /// Get all active categories
  List<Category> getActiveCategories() {
    return getAll().where((c) => c.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get categories by type
  List<Category> getByType(CategoryType type) {
    return getActiveCategories()
        .where((c) => c.type == type || c.type == CategoryType.both)
        .toList();
  }

  /// Get debit (expense) categories
  List<Category> getDebitCategories() => getByType(CategoryType.debit);

  /// Get credit (income) categories
  List<Category> getCreditCategories() => getByType(CategoryType.credit);

  /// Get default categories
  List<Category> getDefaultCategories() {
    return getActiveCategories().where((c) => c.isDefault).toList();
  }

  /// Get custom (user-created) categories
  List<Category> getCustomCategories() {
    return getActiveCategories().where((c) => !c.isDefault).toList();
  }

  /// Soft delete category (mark as inactive)
  Future<void> softDelete(String id) async {
    final category = getById(id);
    if (category != null && !category.isDefault) {
      final updated = category.copyWith(isActive: false);
      await save(id, updated);
    }
  }

  /// Restore soft-deleted category
  Future<void> restore(String id) async {
    final category = getById(id);
    if (category != null) {
      final updated = category.copyWith(isActive: true);
      await save(id, updated);
    }
  }

  /// Reorder categories
  Future<void> reorder(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      final category = getById(orderedIds[i]);
      if (category != null) {
        final updated = category.copyWith(sortOrder: i);
        await save(orderedIds[i], updated);
      }
    }
  }
}
