import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../domain/inventory_item.dart';

/// Resultado de parsear un archivo Excel.
class ExcelParseResult {
  const ExcelParseResult({
    required this.items,
    required this.skipped,
    required this.warnings,
  });

  /// Cireles listos para subir a Firestore.
  final List<InventoryItem> items;

  /// Cantidad de filas omitidas (faltaban campos requeridos).
  final int skipped;

  /// Mensajes de aviso fila por fila (max 20 para no saturar la UI).
  final List<String> warnings;
}

/// Parsea un archivo .xlsx y lo convierte en una lista de [InventoryItem].
///
/// Formato esperado del Excel:
///   - Primera fila: encabezados con los nombres exactos (sin importar
///     mayusculas ni tildes).
///   - Columnas requeridas: CLIENTE, PRODUCTO, UBICACION.
///   - Columnas opcionales: COLORES, PANTONE.
///   - Filas completamente vacias se ignoran silenciosamente.
///   - Filas con campos requeridos vacios se omiten con un aviso.
class ExcelImportService {
  // Nombres aceptados por columna (en minusculas, sin tildes).
  static const _aliases = {
    'cliente': ['cliente', 'client'],
    'producto': ['producto', 'product', 'descripcion', 'description'],
    'colores': ['colores', 'color', 'colors'],
    'pantone': ['pantone', 'pantones'],
    'ubicacion': ['ubicacion', 'ubicacion', 'location', 'ubicacion'],
  };

  ExcelParseResult parse(Uint8List bytes, {required String userId}) {
    late final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(
        'No se pudo abrir el archivo. Asegurate de que sea un .xlsx valido.',
      );
    }

    if (excel.tables.isEmpty) {
      throw const FormatException('El archivo no tiene hojas de calculo.');
    }

    final sheet = excel.tables.values.first;
    final rows = sheet.rows;

    if (rows.length < 2) {
      throw const FormatException(
        'El archivo no tiene filas de datos. '
        'La primera fila debe ser el encabezado.',
      );
    }

    // --- Mapear columnas por posicion ---
    final columnMap = _buildColumnMap(rows.first);
    _validateRequiredColumns(columnMap);

    // --- Parsear filas de datos ---
    final items = <InventoryItem>[];
    final warnings = <String>[];
    var skipped = 0;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowNum = i + 1; // numero de fila humano (encabezado = 1)

      // Ignorar filas completamente vacias.
      if (_isEmptyRow(row)) continue;

      final result = _parseRow(row, columnMap, userId, rowNum: rowNum);

      if (result == null) {
        skipped++;
        if (warnings.length < 20) {
          warnings.add('Fila $rowNum: faltan CLIENTE, PRODUCTO o UBICACION.');
        }
      } else {
        items.add(result);
      }
    }

    return ExcelParseResult(items: items, skipped: skipped, warnings: warnings);
  }

  // --- Helpers privados ---

  Map<String, int> _buildColumnMap(List<Data?> headerRow) {
    final map = <String, int>{};

    for (var i = 0; i < headerRow.length; i++) {
      final raw = _cellString(headerRow[i]);
      if (raw == null) continue;
      final normalized = _normalize(raw);

      for (final entry in _aliases.entries) {
        if (entry.value.contains(normalized)) {
          map[entry.key] = i;
          break;
        }
      }
    }

    return map;
  }

  void _validateRequiredColumns(Map<String, int> columnMap) {
    const required = ['cliente', 'producto', 'ubicacion'];
    final missing = required
        .where((col) => !columnMap.containsKey(col))
        .map((col) => col.toUpperCase())
        .toList();

    if (missing.isNotEmpty) {
      throw FormatException(
        'Faltan columnas requeridas: ${missing.join(', ')}. '
        'Revisa que el encabezado tenga los nombres exactos.',
      );
    }
  }

  bool _isEmptyRow(List<Data?> row) {
    return row.every(
      (cell) => cell == null || (_cellString(cell) ?? '').isEmpty,
    );
  }

  InventoryItem? _parseRow(
    List<Data?> row,
    Map<String, int> columnMap,
    String userId, {
    required int rowNum,
  }) {
    // Obtiene el string de la celda en la columna indicada.
    String? get(String key) {
      final idx = columnMap[key];
      if (idx == null || idx >= row.length) return null;
      final value = (_cellString(row[idx]) ?? '').trim();
      return value.isEmpty ? null : value;
    }

    final cliente = get('cliente');
    final producto = get('producto');
    final ubicacion = get('ubicacion');

    if (cliente == null || producto == null || ubicacion == null) return null;

    return InventoryItem(
      id: '', // Firestore genera el ID en upsertMany
      cliente: cliente,
      producto: producto,
      colores: get('colores'),
      pantone: get('pantone'),
      ubicacion: ubicacion,
      photoUrl: null,
      photoPublicId: null,
      createdAt: null,
      updatedAt: null,
      createdBy: userId,
      updatedBy: userId,
    );
  }

  /// Convierte el valor de una celda en String, manejando los tipos
  /// numericos de Excel (ej: "4.0" → "4").
  static String? _cellString(Data? cell) {
    final value = cell?.value;
    if (value == null) return null;

    // Numeros enteros almacenados como double en Excel (ej: 4.0 → "4").
    if (value is DoubleCellValue) {
      final d = value.value;
      if (d == d.truncateToDouble()) return d.toInt().toString();
      return d.toString();
    }

    // Para texto, enteros, booleanos y cualquier otro tipo.
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Normaliza texto para comparacion: minusculas y sin tildes.
  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}
