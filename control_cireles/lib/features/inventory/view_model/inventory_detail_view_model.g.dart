// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
///
/// Recibe el [id] del documento de Firestore como parametro.
/// El estado es [AsyncValue<void>]: loading mientras elimina,
/// error si falla, y data(null) cuando termina con exito.

@ProviderFor(InventoryDetailViewModel)
final inventoryDetailViewModelProvider = InventoryDetailViewModelFamily._();

/// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
///
/// Recibe el [id] del documento de Firestore como parametro.
/// El estado es [AsyncValue<void>]: loading mientras elimina,
/// error si falla, y data(null) cuando termina con exito.
final class InventoryDetailViewModelProvider
    extends $AsyncNotifierProvider<InventoryDetailViewModel, void> {
  /// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
  ///
  /// Recibe el [id] del documento de Firestore como parametro.
  /// El estado es [AsyncValue<void>]: loading mientras elimina,
  /// error si falla, y data(null) cuando termina con exito.
  InventoryDetailViewModelProvider._({
    required InventoryDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inventoryDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inventoryDetailViewModelHash();

  @override
  String toString() {
    return r'inventoryDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InventoryDetailViewModel create() => InventoryDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is InventoryDetailViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inventoryDetailViewModelHash() =>
    r'd8abad52b252cec91e60de2ecbf6da0264aeb1f5';

/// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
///
/// Recibe el [id] del documento de Firestore como parametro.
/// El estado es [AsyncValue<void>]: loading mientras elimina,
/// error si falla, y data(null) cuando termina con exito.

final class InventoryDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          InventoryDetailViewModel,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  InventoryDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'inventoryDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
  ///
  /// Recibe el [id] del documento de Firestore como parametro.
  /// El estado es [AsyncValue<void>]: loading mientras elimina,
  /// error si falla, y data(null) cuando termina con exito.

  InventoryDetailViewModelProvider call(String id) =>
      InventoryDetailViewModelProvider._(argument: id, from: this);

  @override
  String toString() => r'inventoryDetailViewModelProvider';
}

/// Maneja las acciones sobre un cirel especifico (actualmente: eliminar).
///
/// Recibe el [id] del documento de Firestore como parametro.
/// El estado es [AsyncValue<void>]: loading mientras elimina,
/// error si falla, y data(null) cuando termina con exito.

abstract class _$InventoryDetailViewModel extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<void> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
