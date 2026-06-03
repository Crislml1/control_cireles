// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_import_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gestiona el flujo completo de importacion masiva desde un archivo Excel.
///
/// Ciclo de vida:
///   1. [loadFile] → parsea el archivo → estado [ImportPreviewing]
///   2. [confirmImport] → sube a Firestore → estado [ImportDone]
///   3. [reset] → vuelve a [ImportIdle] para otra importacion
///
/// La UI solo llama estos tres metodos y observa el estado con `ref.watch`.

@ProviderFor(InventoryImportViewModel)
final inventoryImportViewModelProvider = InventoryImportViewModelProvider._();

/// Gestiona el flujo completo de importacion masiva desde un archivo Excel.
///
/// Ciclo de vida:
///   1. [loadFile] → parsea el archivo → estado [ImportPreviewing]
///   2. [confirmImport] → sube a Firestore → estado [ImportDone]
///   3. [reset] → vuelve a [ImportIdle] para otra importacion
///
/// La UI solo llama estos tres metodos y observa el estado con `ref.watch`.
final class InventoryImportViewModelProvider
    extends $NotifierProvider<InventoryImportViewModel, ImportState> {
  /// Gestiona el flujo completo de importacion masiva desde un archivo Excel.
  ///
  /// Ciclo de vida:
  ///   1. [loadFile] → parsea el archivo → estado [ImportPreviewing]
  ///   2. [confirmImport] → sube a Firestore → estado [ImportDone]
  ///   3. [reset] → vuelve a [ImportIdle] para otra importacion
  ///
  /// La UI solo llama estos tres metodos y observa el estado con `ref.watch`.
  InventoryImportViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryImportViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryImportViewModelHash();

  @$internal
  @override
  InventoryImportViewModel create() => InventoryImportViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportState>(value),
    );
  }
}

String _$inventoryImportViewModelHash() =>
    r'7e0a0ba9cdaf936de66646a4100a1792fa159886';

/// Gestiona el flujo completo de importacion masiva desde un archivo Excel.
///
/// Ciclo de vida:
///   1. [loadFile] → parsea el archivo → estado [ImportPreviewing]
///   2. [confirmImport] → sube a Firestore → estado [ImportDone]
///   3. [reset] → vuelve a [ImportIdle] para otra importacion
///
/// La UI solo llama estos tres metodos y observa el estado con `ref.watch`.

abstract class _$InventoryImportViewModel extends $Notifier<ImportState> {
  ImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ImportState, ImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportState, ImportState>,
              ImportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
