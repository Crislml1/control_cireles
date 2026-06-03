import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../view_model/app_lock_providers.dart';
import '../view_model/auth_providers.dart';

/// Pantalla de bloqueo que aparece cuando la app lleva mas de 5 minutos
/// en background o al arrancar con una sesion activa.
///
/// El usuario debe autenticarse con biometria para acceder al inventario.
/// Como alternativa puede cerrar sesion.
class AppLockPage extends ConsumerStatefulWidget {
  const AppLockPage({super.key});

  @override
  ConsumerState<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends ConsumerState<AppLockPage> {
  @override
  void initState() {
    super.initState();
    // Auto-lanza el prompt biometrico cuando la pantalla aparece
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(appLockViewModelProvider.notifier).authenticate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Obtiene el email del usuario actual para mostrarlo
    final userEmail = switch (ref.watch(authStateProvider)) {
      AsyncData(:final value) => value?.email ?? '',
      _ => '',
    };

    // Muestra el error en un snackbar (excepto cancelaciones, que son silenciosas)
    ref.listen(appLockViewModelProvider, (_, next) {
      if (!mounted) return;
      final error = next.error;
      if (error == null) return;
      final message =
          error is AppException ? error.message : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () =>
                ref.read(appLockViewModelProvider.notifier).authenticate(),
          ),
        ),
      );
    });

    final isLoading = lockState is AsyncLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icono ───────────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.lock_outlined,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Titulo y email ───────────────────────────────────────
                  Text(
                    'App bloqueada',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: 6),
                  if (userEmail.isNotEmpty)
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  const SizedBox(height: 48),

                  // ── Boton biometrico o indicador de carga ────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? const Padding(
                            key: ValueKey('loading'),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          )
                        : FilledButton.icon(
                            key: const ValueKey('button'),
                            onPressed: () => ref
                                .read(appLockViewModelProvider.notifier)
                                .authenticate(),
                            icon: Icon(_biometricIcon),
                            label: Text(_biometricLabel),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ── Cerrar sesion (escape hatch) ─────────────────────────
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () =>
                            ref.read(authRepositoryProvider).signOut(),
                    child: Text(
                      'Cerrar sesion',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _biometricIcon {
    if (Platform.isWindows) return Icons.security;
    if (Platform.isIOS) return Icons.face_retouching_natural;
    return Icons.fingerprint;
  }

  String get _biometricLabel {
    if (Platform.isWindows) return 'Desbloquear con Windows Hello';
    if (Platform.isIOS) return 'Desbloquear con Face ID / Touch ID';
    return 'Desbloquear con huella digital';
  }
}
