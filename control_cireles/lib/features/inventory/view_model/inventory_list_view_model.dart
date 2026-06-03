import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_list_view_model.g.dart';

/// Estado de la pantalla de lista: guarda la busqueda activa.
///
/// La lista filtrada se deriva en [filteredInventoryItemsProvider].
/// Separar el query del resultado permite que la UI sea reactiva
/// sin recargar Firestore cada vez que el usuario escribe.
@riverpod
class InventoryListViewModel extends _$InventoryListViewModel {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;

  void clearQuery() => state = '';
}
