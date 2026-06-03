// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Estado de la pantalla de lista: guarda la busqueda activa.
///
/// La lista filtrada se deriva en [filteredInventoryItemsProvider].
/// Separar el query del resultado permite que la UI sea reactiva
/// sin recargar Firestore cada vez que el usuario escribe.

@ProviderFor(InventoryListViewModel)
final inventoryListViewModelProvider = InventoryListViewModelProvider._();

/// Estado de la pantalla de lista: guarda la busqueda activa.
///
/// La lista filtrada se deriva en [filteredInventoryItemsProvider].
/// Separar el query del resultado permite que la UI sea reactiva
/// sin recargar Firestore cada vez que el usuario escribe.
final class InventoryListViewModelProvider
    extends $NotifierProvider<InventoryListViewModel, String> {
  /// Estado de la pantalla de lista: guarda la busqueda activa.
  ///
  /// La lista filtrada se deriva en [filteredInventoryItemsProvider].
  /// Separar el query del resultado permite que la UI sea reactiva
  /// sin recargar Firestore cada vez que el usuario escribe.
  InventoryListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryListViewModelHash();

  @$internal
  @override
  InventoryListViewModel create() => InventoryListViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$inventoryListViewModelHash() =>
    r'3efe90ccadcae18ddbf02932047c9e7f09285ac9';

/// Estado de la pantalla de lista: guarda la busqueda activa.
///
/// La lista filtrada se deriva en [filteredInventoryItemsProvider].
/// Separar el query del resultado permite que la UI sea reactiva
/// sin recargar Firestore cada vez que el usuario escribe.

abstract class _$InventoryListViewModel extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
