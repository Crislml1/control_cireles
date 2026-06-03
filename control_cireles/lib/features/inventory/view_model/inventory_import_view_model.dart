import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/auth/view_model/auth_providers.dart';
import '../data/excel_import_service.dart';
import '../domain/inventory_item.dart';
import 'inventory_providers.dart';

part 'inventory_import_view_model.g.dart';

// ---------------------------------------------------------------------------
// Estados del flujo de importacion (sealed class = union type exhaustivo)
// ---------------------------------------------------------------------------

/// Estado base. Todos los estados de importacion extienden este.
sealed class ImportState {
  const ImportState();
}

/// Estado inicial: esperando que el usuario seleccione un archivo.
final class ImportIdle extends ImportState {
  const ImportIdle();
}

/// Archivo leido y parseado. Muestra preview antes de confirmar.
final class ImportPreviewing extends ImportState {
  const ImportPreviewing({
    required this.items,
    required this.skipped,
    required this.fileName,
    required this.warnings,
  });

  /// Cireles listos para subir.
  final List<InventoryItem> items;

  /// Filas que se omitieron (faltaban campos requeridos).
  final int skipped;

  /// Nombre del archivo seleccionado.
  final String fileName;

  /// Avisos de filas con problemas (max 20).
  final List<String> warnings;
}

/// Subiendo lotes a Firestore.
final class ImportUploading extends ImportState {
  const ImportUploading({required this.total});

  /// Total de cireles que se van a importar.
  final int total;
}

/// Importacion completada con exito.
final class ImportDone extends ImportState {
  const ImportDone({required this.imported});

  /// Cantidad de cireles que se importaron.
  final int imported;
}

/// Error durante parseo o subida.
final class ImportError extends ImportState {
  const ImportError({required this.message});

  final String message;
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

/// Gestiona el flujo completo de importacion masiva desde un archivo Excel.
///
/// Ciclo de vida:
///   1. [loadFile] → parsea el archivo → estado [ImportPreviewing]
///   2. [confirmImport] → sube a Firestore → estado [ImportDone]
///   3. [reset] → vuelve a [ImportIdle] para otra importacion
///
/// La UI solo llama estos tres metodos y observa el estado con `ref.watch`.
@riverpod
class InventoryImportViewModel extends _$InventoryImportViewModel {
  @override
  ImportState build() => const ImportIdle();

  /// Lee y parsea el archivo Excel. El resultado queda en [ImportPreviewing]
  /// para que el usuario confirme antes de subir a Firestore.
  Future<void> loadFile(Uint8List bytes, String fileName) async {
    final userId = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';

    try {
      final result = ExcelImportService().parse(bytes, userId: userId);

      if (result.items.isEmpty) {
        state = const ImportError(
          message:
              'No se encontraron filas validas. '
              'Revisa que el archivo tenga datos y los encabezados correctos.',
        );
        return;
      }

      state = ImportPreviewing(
        items: result.items,
        skipped: result.skipped,
        fileName: fileName,
        warnings: result.warnings,
      );
    } on FormatException catch (e) {
      state = ImportError(message: e.message);
    } catch (e) {
      state = ImportError(message: 'Error inesperado al leer el archivo: $e');
    }
  }

  /// Sube los cireles del preview a Firestore en lotes.
  Future<void> confirmImport() async {
    final preview = state;
    if (preview is! ImportPreviewing) return;

    state = ImportUploading(total: preview.items.length);

    try {
      await ref.read(inventoryRepositoryProvider).upsertMany(preview.items);
      state = ImportDone(imported: preview.items.length);
    } catch (e) {
      state = ImportError(message: 'Error al guardar en Firebase: $e');
    }
  }

  /// Reinicia el estado para hacer otra importacion.
  void reset() => state = const ImportIdle();
}
