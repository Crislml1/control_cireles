// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [true] si el dispositivo tiene biometria disponible y enrolada.
/// Se re-evalua cada vez que se necesita (autoDispose).

@ProviderFor(biometricAvailable)
final biometricAvailableProvider = BiometricAvailableProvider._();

/// [true] si el dispositivo tiene biometria disponible y enrolada.
/// Se re-evalua cada vez que se necesita (autoDispose).

final class BiometricAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// [true] si el dispositivo tiene biometria disponible y enrolada.
  /// Se re-evalua cada vez que se necesita (autoDispose).
  BiometricAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return biometricAvailable(ref);
  }
}

String _$biometricAvailableHash() =>
    r'5c3e877d1ed95a55ac96a16af3e363f089dd654b';

/// ViewModel de la pantalla de bloqueo.
///
/// Lanza el prompt biometrico y, si el usuario se autentica,
/// desbloquea la app actualizando [appLockProvider].

@ProviderFor(AppLockViewModel)
final appLockViewModelProvider = AppLockViewModelProvider._();

/// ViewModel de la pantalla de bloqueo.
///
/// Lanza el prompt biometrico y, si el usuario se autentica,
/// desbloquea la app actualizando [appLockProvider].
final class AppLockViewModelProvider
    extends $AsyncNotifierProvider<AppLockViewModel, void> {
  /// ViewModel de la pantalla de bloqueo.
  ///
  /// Lanza el prompt biometrico y, si el usuario se autentica,
  /// desbloquea la app actualizando [appLockProvider].
  AppLockViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockViewModelHash();

  @$internal
  @override
  AppLockViewModel create() => AppLockViewModel();
}

String _$appLockViewModelHash() => r'8565ca843024bf8904f40a66d212f16e2607724b';

/// ViewModel de la pantalla de bloqueo.
///
/// Lanza el prompt biometrico y, si el usuario se autentica,
/// desbloquea la app actualizando [appLockProvider].

abstract class _$AppLockViewModel extends $AsyncNotifier<void> {
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
