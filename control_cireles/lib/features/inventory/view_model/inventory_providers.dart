import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/cloudinary_config.dart';
import '../data/cloudinary_photo_storage_repository.dart';
import '../data/firestore_inventory_repository.dart';
import '../domain/inventory_item.dart';
import '../domain/inventory_repository.dart';
import '../domain/photo_storage_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
InventoryRepository inventoryRepository(Ref ref) {
  return FirestoreInventoryRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
CloudinaryConfig cloudinaryConfig(Ref ref) {
  return CloudinaryConfig.current;
}

@riverpod
PhotoStorageRepository photoStorageRepository(Ref ref) {
  return CloudinaryPhotoStorageRepository(
    config: ref.watch(cloudinaryConfigProvider),
  );
}

@riverpod
Stream<List<InventoryItem>> inventoryItems(Ref ref) {
  return ref.watch(inventoryRepositoryProvider).watchAll();
}

@riverpod
Stream<InventoryItem?> inventoryItem(Ref ref, String id) {
  return ref.watch(inventoryRepositoryProvider).watchById(id);
}

@riverpod
List<InventoryItem> filteredInventoryItems(Ref ref, String query) {
  final items = ref.watch(inventoryItemsProvider).value ?? const [];
  final normalizedQuery = normalizeForSearch(query);

  if (normalizedQuery.isEmpty) {
    return items;
  }

  return items.where((item) => item.matches(normalizedQuery)).toList();
}
