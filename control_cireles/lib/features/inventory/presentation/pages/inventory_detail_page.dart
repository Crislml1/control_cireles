import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/cloudinary_url.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_photo_viewer.dart';
import '../../domain/inventory_item.dart';
import '../../view_model/inventory_detail_view_model.dart';
import '../../view_model/inventory_providers.dart';
import '../widgets/inventory_photo.dart';
import 'inventory_form_page.dart';

class InventoryDetailPage extends ConsumerWidget {
  const InventoryDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(inventoryItemProvider(id));

    // Escucha el estado del ViewModel de detalle para reaccionar
    // al resultado de la eliminacion.
    ref.listen(inventoryDetailViewModelProvider(id), (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el cirel.')),
        );
      }

      if (previous?.isLoading == true && next.hasValue && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cirel eliminado.')),
        );
      }
    });

    final isDeleting =
        ref.watch(inventoryDetailViewModelProvider(id)).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: itemState.value == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            InventoryFormPage(item: itemState.value),
                      ),
                    ),
            icon: const Icon(LucideIcons.edit3),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: isDeleting
                ? null
                : () => _confirmDelete(context, ref),
            icon: isDeleting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.trash2),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: itemState.when(
        data: (item) {
          if (item == null) {
            return const AppEmptyState(
              icon: LucideIcons.package,
              title: 'Cirel no encontrado',
              message: 'El registro pudo haber sido eliminado.',
            );
          }

          return _DetailContent(item: item);
        },
        loading: () => const AppLoadingView(message: 'Cargando detalle...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'No se pudo cargar el detalle.\n$error',
          onRetry: () => ref.invalidate(inventoryItemProvider(id)),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cirel'),
        content: const Text(
          'Esta accion elimina el registro de Firestore. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(inventoryDetailViewModelProvider(id).notifier)
        .delete();
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _PhotoHeader(item: item, colorScheme: colorScheme),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.cliente,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.producto,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                colorScheme: colorScheme,
                children: [
                  _InfoRow(
                    icon: LucideIcons.hash,
                    label: 'Colores',
                    value: item.colores ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: LucideIcons.palette,
                    label: 'Pantone',
                    value: item.pantone ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: LucideIcons.package,
                    label: 'Ubicacion',
                    value: item.ubicacion,
                    valueHighlight: true,
                  ),
                ],
              ),
              if (item.createdAt != null || item.createdBy != null) ...[
                const SizedBox(height: 16),
                _InfoCard(
                  colorScheme: colorScheme,
                  children: [
                    if (item.createdAt != null)
                      _InfoRow(
                        icon: LucideIcons.calendar,
                        label: 'Creado',
                        value: _formatDate(item.createdAt!),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.item, required this.colorScheme});

  final InventoryItem item;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final photoUrl = item.photoUrl;
    final hasPhoto = photoUrl != null;

    return Container(
      height: 240,
      color: colorScheme.surfaceContainerHighest,
      child: hasPhoto
          ? _TappablePhoto(
              item: item,
              photoUrl: photoUrl,
              colorScheme: colorScheme,
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.imageOff,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin foto',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TappablePhoto extends StatelessWidget {
  const _TappablePhoto({
    required this.item,
    required this.photoUrl,
    required this.colorScheme,
  });

  final InventoryItem item;
  final String photoUrl;
  final ColorScheme colorScheme;

  // Usamos el id del cirel como Hero tag para que la animacion sea unica.
  Object get _heroTag => 'cirel_photo_${item.id}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppPhotoViewer.route(
          url: cloudinaryDetailUrl(photoUrl),
          heroTag: _heroTag,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto con Hero para animacion suave al abrir el visor.
          Hero(
            tag: _heroTag,
            child: InventoryPhoto(
              url: cloudinaryDetailUrl(photoUrl),
              size: 240,
              borderRadius: 0,
            ),
          ),
          // Indicador sutil en la esquina: "toca para ampliar".
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.zoomIn, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Ampliar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.colorScheme, required this.children});

  final ColorScheme colorScheme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueHighlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool valueHighlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: valueHighlight ? FontWeight.w600 : null,
                        color: valueHighlight
                            ? colorScheme.onSurface
                            : colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
