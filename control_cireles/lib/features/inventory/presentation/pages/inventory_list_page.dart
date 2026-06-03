import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../auth/view_model/auth_providers.dart';
import '../../view_model/inventory_list_view_model.dart';
import '../../view_model/inventory_providers.dart';
import '../widgets/inventory_card.dart';
import '../widgets/inventory_search_field.dart';
import 'inventory_detail_page.dart';
import 'inventory_form_page.dart';
import 'inventory_import_page.dart';

class InventoryListPage extends ConsumerWidget {
  const InventoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(inventoryListViewModelProvider);
    final inventoryState = ref.watch(inventoryItemsProvider);
    final filteredItems = ref.watch(filteredInventoryItemsProvider(query));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Cireles'),
        actions: [
          IconButton(
            tooltip: 'Importar desde Excel',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const InventoryImportPage(),
              ),
            ),
            icon: const Icon(LucideIcons.fileUp),
          ),
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(LucideIcons.logOut),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: inventoryState.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return const _EmptyInventory();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: InventorySearchField(
                    value: query,
                    onChanged: ref
                        .read(inventoryListViewModelProvider.notifier)
                        .updateQuery,
                    onClear: ref
                        .read(inventoryListViewModelProvider.notifier)
                        .clearQuery,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          query.isEmpty
                              ? '${allItems.length} cireles'
                              : '${filteredItems.length} resultado${filteredItems.length == 1 ? '' : 's'}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredItems.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: LucideIcons.searchX,
                    title: 'Sin resultados',
                    message:
                        'Prueba con otro cliente, producto o ubicacion.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return InventoryCard(
                        item: item,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => InventoryDetailPage(id: item.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const AppLoadingView(message: 'Cargando inventario...'),
        error: (error, stackTrace) => AppErrorView(
          message: 'No se pudo cargar el inventario.\n$error',
          onRetry: () => ref.invalidate(inventoryItemsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const InventoryFormPage(),
          ),
        ),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nuevo cirel'),
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: LucideIcons.package,
      title: 'Inventario vacio',
      message: 'Cuando crees tu primer cirel aparecera aqui.',
    );
  }
}
