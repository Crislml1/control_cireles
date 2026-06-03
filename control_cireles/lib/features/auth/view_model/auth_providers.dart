import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/biometric_auth_service.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

part 'auth_providers.g.dart';

// ─── Firebase ────────────────────────────────────────────────────────────────

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
AuthRepository authRepository(Ref ref) =>
    FirebaseAuthRepository(ref.watch(firebaseAuthProvider));

@riverpod
Stream<AppUser?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

// ─── Biometria ───────────────────────────────────────────────────────────────

/// Instancia del servicio biometrico.
@riverpod
BiometricAuthService biometricAuthService(Ref ref) => BiometricAuthService();

// ─── App lock ────────────────────────────────────────────────────────────────

/// Estado de bloqueo de la app.
///
/// Empieza en [true] (bloqueado) en cada inicio de la app.
/// Se desbloquea tras autenticacion biometrica exitosa o login con correo.
/// Se vuelve a bloquear cuando la app lleva mas de 5 minutos en background.
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  @override
  bool build() => true; // Siempre bloqueado al arrancar

  void lock() => state = true;
  void unlock() => state = false;
}

// ─── LoginViewModel ──────────────────────────────────────────────────────────

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  FutureOr<void> build() {}

  /// Inicio de sesion con correo y contrasena.
  /// Tras un login exitoso desbloquea la app para que el usuario
  /// no tenga que pasar por el lock screen inmediatamente.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard<void>(() async {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      // Login con correo equivale a autenticacion completa: desbloquear app
      ref.read(appLockProvider.notifier).unlock();
    });
  }
}
