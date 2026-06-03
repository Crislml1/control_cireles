import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/cloudinary_config.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/photo_storage_repository.dart';
import '../domain/photo_upload_result.dart';

class CloudinaryPhotoStorageRepository implements PhotoStorageRepository {
  const CloudinaryPhotoStorageRepository({
    required this._config,
    http.Client? client,
  }) : _client = client;

  final CloudinaryConfig _config;
  final http.Client? _client;

  @override
  Future<PhotoUploadResult> uploadInventoryPhoto({
    required Uint8List bytes,
    required String fileName,
    required String inventoryId,
  }) async {
    if (!_config.isConfigured) {
      throw const AppException(
        'Cloudinary no esta configurado. Revisa CLOUDINARY_CLOUD_NAME y CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final client = _client ?? http.Client();
    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/${_config.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _config.uploadPreset
      ..fields['folder'] = 'control-cireles/$inventoryId'
      ..fields['public_id'] = 'main'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final response = await client.send(request);
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('[Cloudinary] HTTP ${response.statusCode}: $body');
      final message = _cloudinaryErrorMessage(body);
      throw AppException('Error Cloudinary (${response.statusCode}): $message');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    final publicId = json['public_id'] as String?;

    if (url == null || publicId == null) {
      throw const AppException('Cloudinary no devolvio la URL de la foto.');
    }

    return PhotoUploadResult(url: url, publicId: publicId);
  }

  // Extrae el mensaje de error del JSON que devuelve Cloudinary:
  //   {"error": {"message": "..."}}
  String _cloudinaryErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      return (error?['message'] as String?) ?? body;
    } catch (_) {
      return body;
    }
  }
}
