import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.cliente,
    required this.producto,
    required this.colores,
    required this.pantone,
    required this.ubicacion,
    required this.photoUrl,
    required this.photoPublicId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  final String id;
  final String cliente;
  final String producto;
  final String? colores;
  final String? pantone;
  final String ubicacion;
  final String? photoUrl;
  final String? photoPublicId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  String get clienteLower => normalizeForSearch(cliente);
  String get productoLower => normalizeForSearch(producto);
  String? get pantoneLower => pantone == null ? null : normalizeForSearch(pantone!);
  String get ubicacionLower => normalizeForSearch(ubicacion);

  List<String> get searchTokens {
    final tokens = <String>{
      ..._tokensFor(cliente),
      ..._tokensFor(producto),
      ..._tokensFor(pantone ?? ''),
      ..._tokensFor(ubicacion),
    };

    return tokens.where((token) => token.length >= 2).toList()..sort();
  }

  bool matches(String query) {
    final normalized = normalizeForSearch(query);
    if (normalized.isEmpty) {
      return true;
    }

    return clienteLower.contains(normalized) ||
        productoLower.contains(normalized) ||
        ubicacionLower.contains(normalized) ||
        (pantoneLower?.contains(normalized) ?? false);
  }

  InventoryItem copyWith({
    String? id,
    String? cliente,
    String? producto,
    String? colores,
    String? pantone,
    String? ubicacion,
    String? photoUrl,
    String? photoPublicId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      producto: producto ?? this.producto,
      colores: colores ?? this.colores,
      pantone: pantone ?? this.pantone,
      ubicacion: ubicacion ?? this.ubicacion,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPublicId: photoPublicId ?? this.photoPublicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  InventoryItem withPhoto({
    required String? photoUrl,
    required String? photoPublicId,
  }) {
    return InventoryItem(
      id: id,
      cliente: cliente,
      producto: producto,
      colores: colores,
      pantone: pantone,
      ubicacion: ubicacion,
      photoUrl: photoUrl,
      photoPublicId: photoPublicId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  Map<String, Object?> toFirestore({
    Object? createdAtValue,
    Object? updatedAtValue,
  }) {
    return {
      'cliente': cliente.trim(),
      'clienteLower': clienteLower,
      'producto': producto.trim(),
      'productoLower': productoLower,
      'colores': _blankToNull(colores),
      'pantone': _blankToNull(pantone),
      'pantoneLower': pantoneLower,
      'ubicacion': ubicacion.trim(),
      'ubicacionLower': ubicacionLower,
      'searchTokens': searchTokens,
      'photoUrl': _blankToNull(photoUrl),
      'photoPublicId': _blankToNull(photoPublicId),
      'createdAt': createdAtValue ?? _timestampOrNull(createdAt),
      'updatedAt': updatedAtValue ?? _timestampOrNull(updatedAt),
      'createdBy': _blankToNull(createdBy),
      'updatedBy': _blankToNull(updatedBy),
    };
  }

  factory InventoryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return InventoryItem(
      id: document.id,
      cliente: (data['cliente'] as String?) ?? '',
      producto: (data['producto'] as String?) ?? '',
      colores: data['colores']?.toString(),
      pantone: data['pantone'] as String?,
      ubicacion: (data['ubicacion'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      photoPublicId: data['photoPublicId'] as String?,
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }
}

String normalizeForSearch(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _tokensFor(String value) {
  return normalizeForSearch(value)
      .split(RegExp(r'[\s,;./\-]+'))
      .where((token) => token.isNotEmpty)
      .toList();
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

Timestamp? _timestampOrNull(DateTime? value) {
  if (value == null) {
    return null;
  }
  return Timestamp.fromDate(value);
}

DateTime? _dateFromFirestore(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
