import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../view_model/inventory_import_view_model.dart';

class InventoryImportPage extends ConsumerWidget {
  const InventoryImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryImportViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar desde Excel'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          tooltip: 'Cerrar',
          onPressed: () {
            ref.read(inventoryImportViewModelProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _FormatCard(colorScheme: colorScheme),
            const SizedBox(height: 24),
            _buildBody(context, ref, state, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ImportState state,
    ColorScheme colorScheme,
  ) {
    return switch (state) {
      ImportIdle() => _IdleSection(colorScheme: colorScheme),
      ImportPreviewing() => _PreviewSection(state: state, colorScheme: colorScheme),
      ImportUploading() => _UploadingSection(state: state),
      ImportDone() => _DoneSection(state: state),
      ImportError() => _ErrorSection(state: state, colorScheme: colorScheme),
    };
  }
}

// ---------------------------------------------------------------------------
// Seccion: Formato del archivo
// ---------------------------------------------------------------------------

class _FormatCard extends StatelessWidget {
  const _FormatCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sheet,
                  size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'FORMATO DEL EXCEL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ColumnRow(
            name: 'CLIENTE',
            type: 'Texto',
            required: true,
            colorScheme: colorScheme,
          ),
          _ColumnRow(
            name: 'PRODUCTO',
            type: 'Texto',
            required: true,
            colorScheme: colorScheme,
          ),
          _ColumnRow(
            name: 'COLORES',
            type: 'Número',
            required: false,
            colorScheme: colorScheme,
          ),
          _ColumnRow(
            name: 'PANTONE',
            type: 'Texto',
            required: false,
            colorScheme: colorScheme,
          ),
          _ColumnRow(
            name: 'UBICACION',
            type: 'Texto',
            required: true,
            colorScheme: colorScheme,
            isLast: true,
          ),
          const SizedBox(height: 10),
          Text(
            '* La primera fila debe ser el encabezado con los nombres exactos.\n'
            '* Los nombres de columna no distinguen mayusculas ni tildes.\n'
            '* Filas sin CLIENTE, PRODUCTO o UBICACION se omiten.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({
    required this.name,
    required this.type,
    required this.required,
    required this.colorScheme,
    this.isLast = false,
  });

  final String name;
  final String type;
  final bool required;
  final ColorScheme colorScheme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: required
                      ? colorScheme.primaryContainer.withValues(alpha: 0.7)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  required ? 'Requerido' : 'Opcional',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: required
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Seccion: Estado inicial — seleccionar archivo
// ---------------------------------------------------------------------------

class _IdleSection extends ConsumerWidget {
  const _IdleSection({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.fileUp,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Selecciona el archivo Excel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Solo se aceptan archivos .xlsx',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _pickFile(context, ref),
                icon: const Icon(LucideIcons.folder),
                label: const Text('Seleccionar archivo .xlsx'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo leer el archivo.')),
        );
      }
      return;
    }

    await ref
        .read(inventoryImportViewModelProvider.notifier)
        .loadFile(bytes, file.name);
  }
}

// ---------------------------------------------------------------------------
// Seccion: Preview — confirmacion antes de subir
// ---------------------------------------------------------------------------

class _PreviewSection extends ConsumerWidget {
  const _PreviewSection({
    required this.state,
    required this.colorScheme,
  });

  final ImportPreviewing state;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Resumen del archivo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.fileText,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.fileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: LucideIcons.checkCircle2,
                color: Colors.green,
                text:
                    '${state.items.length} cirel${state.items.length == 1 ? '' : 'es'} listos para importar',
              ),
              if (state.skipped > 0) ...[
                const SizedBox(height: 6),
                _SummaryRow(
                  icon: LucideIcons.triangleAlert,
                  color: colorScheme.error,
                  text:
                      '${state.skipped} fila${state.skipped == 1 ? '' : 's'} omitida${state.skipped == 1 ? '' : 's'} (campos requeridos vacios)',
                ),
              ],
            ],
          ),
        ),

        // Avisos detallados (solo si hay)
        if (state.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filas omitidas',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.error,
                      ),
                ),
                const SizedBox(height: 6),
                ...state.warnings.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      w,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ),
                if (state.skipped > state.warnings.length)
                  Text(
                    '... y ${state.skipped - state.warnings.length} mas.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () =>
              ref.read(inventoryImportViewModelProvider.notifier).confirmImport(),
          icon: const Icon(LucideIcons.cloudUpload),
          label: Text('Importar ${state.items.length} cireles a Firebase'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(inventoryImportViewModelProvider.notifier).reset(),
          icon: const Icon(LucideIcons.arrowLeftRight, size: 18),
          label: const Text('Seleccionar otro archivo'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Seccion: Subiendo a Firebase
// ---------------------------------------------------------------------------

class _UploadingSection extends StatelessWidget {
  const _UploadingSection({required this.state});

  final ImportUploading state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Subiendo ${state.total} cireles a Firebase...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No cierres la app mientras termina.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seccion: Importacion completada
// ---------------------------------------------------------------------------

class _DoneSection extends ConsumerWidget {
  const _DoneSection({required this.state});

  final ImportDone state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.checkCircle2, size: 56, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            '¡Importacion completada!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.imported} cirel${state.imported == 1 ? '' : 'es'} guardados en Firebase.\n'
            'Ya aparecen en el inventario.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(inventoryImportViewModelProvider.notifier)
                      .reset(),
                  icon: const Icon(LucideIcons.fileUp, size: 18),
                  label: const Text('Importar otro'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.boxes, size: 18),
                  label: const Text('Ver inventario'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seccion: Error
// ---------------------------------------------------------------------------

class _ErrorSection extends ConsumerWidget {
  const _ErrorSection({
    required this.state,
    required this.colorScheme,
  });

  final ImportError state;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.circleAlert, size: 48, color: colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'No se pudo importar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            onPressed: () =>
                ref.read(inventoryImportViewModelProvider.notifier).reset(),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}
