import 'dart:io';

import 'package:local_auth/local_auth.dart';

/// Servicio de autenticacion biometrica del dispositivo.
///
/// Responsabilidad unica: verificar disponibilidad y lanzar el prompt nativo.
/// Ya no almacena credenciales; el bloqueo de la app es independiente de Firebase.
class BiometricAuthService {
  BiometricAuthService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  // ─── Disponibilidad ──────────────────────────────────────────────────────

  /// [true] si el dispositivo tiene al menos un metodo biometrico enrolado
  /// (huella, Face ID, Windows Hello, etc.).
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  // ─── Autenticacion ───────────────────────────────────────────────────────

  /// Muestra el prompt biometrico del sistema operativo.
  ///
  /// Devuelve [true] si el usuario se autentico correctamente.
  /// Lanza [LocalAuthException] si hay un error de hardware o configuracion.
  Future<bool> authenticate({
    String reason = 'Confirma tu identidad para acceder',
  }) async {
    // En Windows el dialogo de Windows Hello necesita que Flutter termine
    // de renderizar antes de tomar el foco. Sin este delay el sistema
    // cancela el prompt de inmediato.
    if (Platform.isWindows) {
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Las excepciones de LocalAuthException se propagan al ViewModel
    // para mostrar mensajes de error especificos.
    return await _auth.authenticate(localizedReason: reason);
  }
}
