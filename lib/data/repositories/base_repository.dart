import 'package:hive/hive.dart';

/// Base repository class with common CRUD operations
abstract class BaseRepository<T extends HiveObject> {
  Box<T> get box;

  /// Get all items
  List<T> getAll() => box.values.toList();

  /// Get item by ID
  T? getById(String id) => box.get(id);

  /// Add or update item
  Future<void> save(String id, T item) async {
    await box.put(id, item);
  }

  /// Delete item by ID
  Future<void> delete(String id) async {
    await box.delete(id);
  }

  /// Delete multiple items by IDs
  Future<void> deleteMany(List<String> ids) async {
    await box.deleteAll(ids);
  }

  /// Clear all items
  Future<void> clear() async {
    await box.clear();
  }

  /// Check if item exists
  bool exists(String id) => box.containsKey(id);

  /// Get count of items
  int get count => box.length;

  /// Check if box is empty
  bool get isEmpty => box.isEmpty;

  /// Check if box is not empty
  bool get isNotEmpty => box.isNotEmpty;
}
