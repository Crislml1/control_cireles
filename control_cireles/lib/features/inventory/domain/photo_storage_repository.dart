import 'dart:typed_data';

import 'photo_upload_result.dart';

abstract interface class PhotoStorageRepository {
  Future<PhotoUploadResult> uploadInventoryPhoto({
    required Uint8List bytes,
    required String fileName,
    required String inventoryId,
  });
}
