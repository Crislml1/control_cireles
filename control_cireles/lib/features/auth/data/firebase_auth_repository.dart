import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = _mapUser(credential.user);
      if (user == null) {
        throw const AppException('No se pudo leer el usuario autenticado.');
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw AppException(_messageForCode(error.code));
    }
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  String _messageForCode(String code) {
    return switch (code) {
      'invalid-email' => 'El correo no tiene un formato valido.',
      'user-disabled' => 'Este usuario esta deshabilitado.',
      'user-not-found' => 'No existe un usuario con ese correo.',
      'wrong-password' => 'La contrasena no es correcta.',
      'invalid-credential' => 'El correo o la contrasena no son correctos.',
      'too-many-requests' => 'Hay demasiados intentos. Intenta mas tarde.',
      _ => 'No se pudo iniciar sesion. Intenta nuevamente.',
    };
  }
}
