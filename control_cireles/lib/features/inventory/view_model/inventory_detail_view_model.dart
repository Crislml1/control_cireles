import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'inventory_providers.dart';

part 'inventory_detail_view_model.g.dart';

/// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
///
/// Recibe el [id] del documento de Firestore como parametro.
/// El estado es [AsyncValue<void>]: loading mientras elimina,
/// error si falla, y data(null) cuando termina con exito.
@riverpod
class InventoryDetailViewModel extends _$InventoryDetailViewModel {
  @override
  FutureOr<void> build(String id) {}

  Future<void> delete() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(inventoryRepositoryProvider).delete(id),
    );
  }
}
