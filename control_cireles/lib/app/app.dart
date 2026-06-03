import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/app_lock_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/view_model/app_lock_providers.dart';
import '../features/auth/view_model/auth_providers.dart';
import '../features/inventory/presentation/pages/inventory_list_page.dart';
import 'theme.dart';

class ControlCirelesApp extends ConsumerWidget {
  const ControlCirelesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Control de Cireles',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: const AppStartupPage(),
    );
  }
}

/// Punto de entrada de la UI. Decide que pantalla mostrar segun:
/// - Estado de autenticacion Firebase
/// - Estado de bloqueo de la app
///
/// Tambien observa el ciclo de vida de la app para bloquearla
/// cuando lleva mas de [_lockTimeout] en background.
class AppStartupPage extends ConsumerStatefulWidget {
  const AppStartupPage({super.key});

  @override
  ConsumerState<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends ConsumerState<AppStartupPage>
    with WidgetsBindingObserver {
  /// Cuanto tiempo en background antes de bloquear la app.
  static const _lockTimeout = Duration(minutes: 5);

  /// Momento en que la app se fue al background (null = en primer plano).
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App fue al background: registrar el momento
        _backgroundTime = DateTime.now();

      case AppLifecycleState.resumed:
        // App volvio al primer plano: verificar si hay que bloquear
        _tryLock();

      default:
        break;
    }
  }

  /// Bloquea la app si el tiempo en background supero el limite
  /// Y el dispositivo tiene biometria disponible (condicion para poder desbloquear).
  void _tryLock() {
    final bg = _backgroundTime;
    _backgroundTime = null;
    if (bg == null) return;

    final elapsed = DateTime.now().difference(bg);
    if (elapsed < _lockTimeout) return;

    // Solo bloquear si hay biometria disponible (para poder desbloquear)
    final biometricState = ref.read(biometricAvailableProvider);
    final hasBiometrics = switch (biometricState) {
      AsyncData(:final value) => value,
      _ => false,
    };

    if (hasBiometrics) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLocked = ref.watch(appLockProvider);
    final biometricAsync = ref.watch(biometricAvailableProvider);

    // Si el dispositivo NO tiene biometria, desbloquear automaticamente
    // (sin biometria no hay forma de desbloquear, asi que no bloqueamos)
    ref.listen(biometricAvailableProvider, (_, next) {
      if (next case AsyncData(:final value) when !value) {
        ref.read(appLockProvider.notifier).unlock();
      }
    });

    return authState.when(
      data: (user) {
        // Sin sesion activa → pantalla de login
        if (user == null) return const LoginPage();

        // Sesion activa pero aun verificando disponibilidad de biometria
        // Mostramos loading en lugar de inventario para no exponer datos
        if (biometricAsync case AsyncLoading()) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sesion activa + app bloqueada → pantalla de bloqueo
        if (isLocked) return const AppLockPage();

        // Sesion activa + desbloqueada → inventario
        return const InventoryListPage();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo iniciar Firebase/Auth.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
