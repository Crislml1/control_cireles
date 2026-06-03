// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryFormViewModel)
final inventoryFormViewModelProvider = InventoryFormViewModelProvider._();

final class InventoryFormViewModelProvider
    extends $AsyncNotifierProvider<InventoryFormViewModel, void> {
  InventoryFormViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryFormViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryFormViewModelHash();

  @$internal
  @override
  InventoryFormViewModel create() => InventoryFormViewModel();
}

String _$inventoryFormViewModelHash() =>
    r'3c086aca483e5a1cefc14ea27c8acf72bc3d0dd6';

abstract class _$InventoryFormViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
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
    element.handleCreate(ref, build);
  }
}
