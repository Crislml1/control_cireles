// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider = FirebaseFirestoreProvider._();

final class FirebaseFirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirebaseFirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseFirestoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseFirestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firebaseFirestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firebaseFirestoreHash() => r'963402713bf9b7cc1fb259d619d9b0184d4dcec1';

@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryRepository,
          InventoryRepository,
          InventoryRepository
        >
    with $Provider<InventoryRepository> {
  InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryRepository create(Ref ref) {
    return inventoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryRepository>(value),
    );
  }
}

String _$inventoryRepositoryHash() =>
    r'1d512d364a659baa7766276bd2ff42257169557d';

@ProviderFor(cloudinaryConfig)
final cloudinaryConfigProvider = CloudinaryConfigProvider._();

final class CloudinaryConfigProvider
    extends
        $FunctionalProvider<
          CloudinaryConfig,
          CloudinaryConfig,
          CloudinaryConfig
        >
    with $Provider<CloudinaryConfig> {
  CloudinaryConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudinaryConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudinaryConfigHash();

  @$internal
  @override
  $ProviderElement<CloudinaryConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudinaryConfig create(Ref ref) {
    return cloudinaryConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudinaryConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudinaryConfig>(value),
    );
  }
}

String _$cloudinaryConfigHash() => r'1c9eb848c8f46b9f15b85ce462b4da607ae88ae0';

@ProviderFor(photoStorageRepository)
final photoStorageRepositoryProvider = PhotoStorageRepositoryProvider._();

final class PhotoStorageRepositoryProvider
    extends
        $FunctionalProvider<
          PhotoStorageRepository,
          PhotoStorageRepository,
          PhotoStorageRepository
        >
    with $Provider<PhotoStorageRepository> {
  PhotoStorageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStorageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStorageRepositoryHash();

  @$internal
  @override
  $ProviderElement<PhotoStorageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PhotoStorageRepository create(Ref ref) {
    return photoStorageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoStorageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoStorageRepository>(value),
    );
  }
}

String _$photoStorageRepositoryHash() =>
    r'86d3f8966ddcdbe144393770c4e412bd3acf81ee';

@ProviderFor(inventoryItems)
final inventoryItemsProvider = InventoryItemsProvider._();

final class InventoryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryItem>>,
          List<InventoryItem>,
          Stream<List<InventoryItem>>
        >
    with
        $FutureModifier<List<InventoryItem>>,
        $StreamProvider<List<InventoryItem>> {
  InventoryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InventoryItem>> create(Ref ref) {
    return inventoryItems(ref);
  }
}

String _$inventoryItemsHash() => r'f7b89b7f6111a352f271f1ac104f898b216c143a';

@ProviderFor(inventoryItem)
final inventoryItemProvider = InventoryItemFamily._();

final class InventoryItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryItem?>,
          InventoryItem?,
          Stream<InventoryItem?>
        >
    with $FutureModifier<InventoryItem?>, $StreamProvider<InventoryItem?> {
  InventoryItemProvider._({
    required InventoryItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inventoryItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inventoryItemHash();

  @override
  String toString() {
    return r'inventoryItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<InventoryItem?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<InventoryItem?> create(Ref ref) {
    final argument = this.argument as String;
    return inventoryItem(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inventoryItemHash() => r'd9bf69dceea4546f11ac623de4edc004ce9706cb';

final class InventoryItemFamily extends $Family
    with $FunctionalFamilyOverride<Stream<InventoryItem?>, String> {
  InventoryItemFamily._()
    : super(
        retry: null,
        name: r'inventoryItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InventoryItemProvider call(String id) =>
      InventoryItemProvider._(argument: id, from: this);

  @override
  String toString() => r'inventoryItemProvider';
}

@ProviderFor(filteredInventoryItems)
final filteredInventoryItemsProvider = FilteredInventoryItemsFamily._();

final class FilteredInventoryItemsProvider
    extends
        $FunctionalProvider<
          List<InventoryItem>,
          List<InventoryItem>,
          List<InventoryItem>
        >
    with $Provider<List<InventoryItem>> {
  FilteredInventoryItemsProvider._({
    required FilteredInventoryItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredInventoryItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredInventoryItemsHash();

  @override
  String toString() {
    return r'filteredInventoryItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<InventoryItem> create(Ref ref) {
    final argument = this.argument as String;
    return filteredInventoryItems(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<InventoryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<InventoryItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredInventoryItemsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredInventoryItemsHash() =>
    r'b56df7aa52cc5218283902902ccbe830833a9374';

final class FilteredInventoryItemsFamily extends $Family
    with $FunctionalFamilyOverride<List<InventoryItem>, String> {
  FilteredInventoryItemsFamily._()
    : super(
        retry: null,
        name: r'filteredInventoryItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredInventoryItemsProvider call(String query) =>
      FilteredInventoryItemsProvider._(argument: query, from: this);

  @override
  String toString() => r'filteredInventoryItemsProvider';
}
