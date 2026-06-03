import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/inventory_item.dart';
import '../domain/inventory_repository.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  FirestoreInventoryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('cyreles');
  }

  @override
  Stream<List<InventoryItem>> watchAll() {
    return _collection
        .orderBy('clienteLower')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(InventoryItem.fromFirestore)
              .where((item) => item.cliente.trim().isNotEmpty)
              .toList(),
        );
  }

  @override
  Stream<InventoryItem?> watchById(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return InventoryItem.fromFirestore(snapshot);
    });
  }

  @override
  Future<String> create(InventoryItem item) async {
    final document = item.id.isEmpty ? _collection.doc() : _collection.doc(item.id);
    final payload = item.copyWith(id: document.id).toFirestore(
          createdAtValue: FieldValue.serverTimestamp(),
          updatedAtValue: FieldValue.serverTimestamp(),
        );

    await document.set(payload);
    return document.id;
  }

  @override
  Future<void> update(InventoryItem item) {
    final payload = item.toFirestore(updatedAtValue: FieldValue.serverTimestamp())
      ..remove('createdAt')
      ..remove('createdBy');

    return _collection.doc(item.id).set(
          payload,
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }

  @override
  Future<void> upsertMany(List<InventoryItem> items) async {
    const maxBatchSize = 400;

    for (var index = 0; index < items.length; index += maxBatchSize) {
      final batch = _firestore.batch();
      final chunk = items.skip(index).take(maxBatchSize);

      for (final item in chunk) {
        final document = item.id.isEmpty ? _collection.doc() : _collection.doc(item.id);
        final normalizedItem = item.copyWith(id: document.id);

        batch.set(
          document,
          normalizedItem.toFirestore(
            createdAtValue: FieldValue.serverTimestamp(),
            updatedAtValue: FieldValue.serverTimestamp(),
          ),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    }
  }
}
