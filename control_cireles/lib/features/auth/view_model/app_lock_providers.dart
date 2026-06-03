import 'dart:async';
import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import 'auth_providers.dart';

part 'app_lock_providers.g.dart';

// ─── Disponibilidad ──────────────────────────────────────────────────────────

/// [true] si el dispositivo tiene biometria disponible y enrolada.
/// Se re-evalua cada vez que se necesita (autoDispose).
@riverpod
Future<bool> biometricAvailable(Ref ref) async {
  return ref.watch(biometricAuthServiceProvider).isAvailable();
}

// ─── AppLockViewModel ────────────────────────────────────────────────────────

/// ViewModel de la pantalla de bloqueo.
///
/// Lanza el prompt biometrico y, si el usuario se autentica,
/// desbloquea la app actualizando [appLockProvider].
@riverpod
class AppLockViewModel extends _$AppLockViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> authenticate() async {
    if (state is AsyncLoading) return; // evitar doble llamada
    state = const AsyncLoading();

    final service = ref.read(biometricAuthServiceProvider);

    bool ok;
    try {
      ok = await service.authenticate();
    } on LocalAuthException catch (e) {
      if (_isCancellation(e.code)) {
        // El usuario cancelo: volver al estado inicial sin mostrar error
        state = const AsyncData(null);
        return;
      }
      state = AsyncError(
        AppException(_hardwareErrorMessage(e)),
        StackTrace.current,
      );
      return;
    } catch (e) {
      state = AsyncError(
        AppException('Error inesperado en autenticacion: $e'),
        StackTrace.current,
      );
      return;
    }

    if (!ok) {
      // authenticate() retorno false (cancelado): reset silencioso
      state = const AsyncData(null);
      return;
    }

    // Autenticacion exitosa: desbloquear la app
    ref.read(appLockProvider.notifier).unlock();
    state = const AsyncData(null);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static bool _isCancellation(LocalAuthExceptionCode code) {
    return switch (code) {
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled ||
      LocalAuthExceptionCode.timeout ||
      LocalAuthExceptionCode.userRequestedFallback =>
        true,
      _ => false,
    };
  }

  static String _hardwareErrorMessage(LocalAuthException e) {
    final isWindows = Platform.isWindows;
    return switch (e.code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'Este dispositivo no tiene sensor biometrico compatible.',
      LocalAuthExceptionCode.noBiometricsEnrolled => isWindows
          ? 'Windows Hello no tiene biometria configurada. '
              'Ve a Configuracion → Cuentas → Opciones de inicio de sesion.'
          : 'No tienes biometria registrada. '
              'Ve a Configuracion → Seguridad → Huella digital / Face ID.',
      LocalAuthExceptionCode.noCredentialsSet => isWindows
          ? 'No hay PIN ni biometria en Windows Hello.'
          : 'No hay metodo de desbloqueo configurado en el dispositivo.',
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
        'El sensor biometrico esta ocupado. Intenta en un momento.',
      LocalAuthExceptionCode.temporaryLockout ||
      LocalAuthExceptionCode.biometricLockout =>
        'Demasiados intentos fallidos. '
            'Desbloquea el dispositivo con tu PIN y vuelve a intentarlo.',
      LocalAuthExceptionCode.uiUnavailable =>
        'No se pudo mostrar el dialogo biometrico. Reinicia la app.',
      LocalAuthExceptionCode.deviceError =>
        'Error del sensor: ${e.description ?? "reinicia el dispositivo"}.',
      LocalAuthExceptionCode.unknownError =>
        'Error inesperado: ${e.description ?? e.code.name}.',
      _ => isWindows
          ? 'Error de Windows Hello (${e.code.name}).'
          : 'Error biometrico (${e.code.name}). Intenta de nuevo.',
    };
  }
}
