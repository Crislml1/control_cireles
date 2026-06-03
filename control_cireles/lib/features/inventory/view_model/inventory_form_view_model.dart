import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/image_compression.dart';
import '../../auth/view_model/auth_providers.dart';
import '../domain/inventory_item.dart';
import 'inventory_providers.dart';

part 'inventory_form_view_model.g.dart';

class InventoryFormInput {
  const InventoryFormInput({
    required this.id,
    required this.cliente,
    required this.producto,
    required this.colores,
    required this.pantone,
    required this.ubicacion,
    required this.existingPhotoUrl,
    required this.existingPhotoPublicId,
    required this.newPhotoBytes,
    required this.newPhotoFileName,
    required this.removePhoto,
  });

  final String? id;
  final String cliente;
  final String producto;
  final String? colores;
  final String? pantone;
  final String ubicacion;
  final String? existingPhotoUrl;
  final String? existingPhotoPublicId;
  final Uint8List? newPhotoBytes;
  final String? newPhotoFileName;
  final bool removePhoto;
}

@riverpod
class InventoryFormViewModel extends _$InventoryFormViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> save(InventoryFormInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard<void>(() async {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) {

        throw FirebaseAuthException(
          code: 'not-authenticated',
          message: 'Debes iniciar sesion para guardar.',
        );
      }

      final repository = ref.read(inventoryRepositoryProvider);
      final id = input.id?.isNotEmpty == true ? input.id! : const Uuid().v4();
      var photoUrl = input.removePhoto ? null : input.existingPhotoUrl;
      var photoPublicId =
          input.removePhoto ? null : input.existingPhotoPublicId;

      if (input.newPhotoBytes != null) {
        final compressed = await compressImageForUpload(input.newPhotoBytes!);
        final upload = await ref
            .read(photoStorageRepositoryProvider)
            .uploadInventoryPhoto(
              bytes: compressed,
              fileName: input.newPhotoFileName ?? '$id.jpg',
              inventoryId: id,
            );

        photoUrl = upload.url;
        photoPublicId = upload.publicId;
      }

      final item = InventoryItem(
        id: id,
        cliente: input.cliente,
        producto: input.producto,
        colores: input.colores,
        pantone: input.pantone,
        ubicacion: input.ubicacion,
        photoUrl: photoUrl,
        photoPublicId: photoPublicId,
        createdAt: null,
        updatedAt: null,
        createdBy: user.uid,
        updatedBy: user.uid,
      );

      if (input.id == null || input.id!.isEmpty) {
        await repository.create(item);
      } else {
        await repository.update(item);
      }
    });
  }
}
