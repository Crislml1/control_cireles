import 'inventory_item.dart';

abstract interface class InventoryRepository {
  Stream<List<InventoryItem>> watchAll();

  Stream<InventoryItem?> watchById(String id);

  Future<String> create(InventoryItem item);

  Future<void> update(InventoryItem item);

  Future<void> delete(String id);

  Future<void> upsertMany(List<InventoryItem> items);
}
