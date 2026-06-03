# Arquitectura de Control de Cireles

## Objetivo

La app reemplaza el Excel de inventario de cireles por una aplicacion Flutter con:

- inicio de sesion con correo y contrasena;
- inventario compartido entre usuarios autorizados;
- busqueda rapida por cliente, producto, pantone y ubicacion;
- creacion, edicion y eliminacion de cireles;
- foto opcional para identificar cada cirel;
- soporte para Android, iOS y Windows desktop.

## Stack elegido

- Flutter para la aplicacion multiplataforma.
- MVVM como patron de organizacion.
- Riverpod con anotaciones para estado e inyeccion de dependencias.
- Firebase Auth para autenticacion.
- Cloud Firestore para datos del inventario.
- Cloudinary para guardar fotos.
- Cache local de imagenes para reducir descargas repetidas.

## Capas

### Presentation

Contiene paginas y widgets. No habla directamente con Firebase ni Cloudinary.

Responsabilidades:

- renderizar UI;
- leer providers de Riverpod;
- mostrar estados de carga/error;
- enviar acciones del usuario al ViewModel.

Ejemplos:

- `LoginPage`
- `InventoryListPage`
- `InventoryDetailPage`
- `InventoryFormPage`
- `InventorySearchField`
- `InventoryPhotoPicker`

### ViewModel

Contiene estado de pantalla y casos de uso simples. Se implementa con Riverpod annotations.

Responsabilidades:

- cargar inventario;
- aplicar busqueda/filtros;
- validar formularios;
- crear/actualizar/eliminar cireles;
- coordinar subida de fotos;
- exponer `AsyncValue` a la UI.

Ejemplos:

- `AuthViewModel`
- `InventoryListViewModel`
- `InventoryFormViewModel`
- `InventoryDetailViewModel`

### Domain

Define modelos y contratos. No depende de Firebase, Cloudinary ni Flutter UI.

Responsabilidades:

- entidades principales;
- reglas de negocio simples;
- interfaces de repositorios.

Ejemplos:

- `InventoryItem`
- `InventoryRepository`
- `AuthRepository`
- `PhotoStorageRepository`

### Data

Implementa los repositorios usando servicios externos.

Responsabilidades:

- mapear Firestore a modelos Dart;
- subir fotos a Cloudinary;
- manejar errores de red;
- construir queries;
- ocultar detalles de Firebase/Cloudinary al resto de la app.

Ejemplos:

- `FirebaseAuthRepository`
- `FirestoreInventoryRepository`
- `CloudinaryPhotoStorageRepository`

## Estructura propuesta

```text
lib/
  app/
    app.dart
    bootstrap.dart
    firebase_options.dart
    router.dart
    theme.dart

  core/
    config/
      cloudinary_config.dart
    errors/
      app_exception.dart
    utils/
      image_compression.dart

  features/
    auth/
      data/
        firebase_auth_repository.dart
      domain/
        app_user.dart
        auth_repository.dart
      presentation/
        login_page.dart
      view_model/
        auth_view_model.dart

    inventory/
      data/
        firestore_inventory_repository.dart
        cloudinary_photo_storage_repository.dart
      domain/
        inventory_item.dart
        inventory_repository.dart
        photo_storage_repository.dart
      presentation/
        pages/
          inventory_list_page.dart
          inventory_detail_page.dart
          inventory_form_page.dart
        widgets/
          inventory_card.dart
          inventory_photo.dart
          inventory_search_field.dart
      view_model/
        inventory_detail_view_model.dart
        inventory_form_view_model.dart
        inventory_list_view_model.dart

  shared/
    widgets/
      app_error_view.dart
      app_loading_view.dart
```

## Riverpod con anotaciones

Se usara `riverpod_annotation` y archivos generados con `build_runner`.

Ejemplo esperado:

```dart
@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance);
}

@riverpod
class InventoryListViewModel extends _$InventoryListViewModel {
  @override
  Future<List<InventoryItem>> build() {
    return ref.watch(inventoryRepositoryProvider).watchAll().first;
  }
}
```

Los archivos `*.g.dart` no se escriben a mano. Se generan con:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Modelo inicial

```dart
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.cliente,
    required this.producto,
    required this.colores,
    required this.pantone,
    required this.ubicacion,
    this.photoUrl,
    this.photoPublicId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  final String id;
  final String cliente;
  final String producto;
  final int? colores;
  final String? pantone;
  final String ubicacion;
  final String? photoUrl;
  final String? photoPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
}
```

## Busqueda

Firestore no hace busquedas parciales tipo SQL `LIKE` de forma natural. Para esta app se usara una combinacion:

1. Guardar campos normalizados:
   - `clienteLower`
   - `productoLower`
   - `pantoneLower`
   - `ubicacionLower`
   - `searchTokens`
2. Consultar por tokens cuando sea posible.
3. Filtrar localmente los resultados ya cargados cuando el inventario sea pequeno o mediano.

Para el tamano actual del inventario, cargar la lista autorizada y filtrar en memoria es suficiente. Si crece mucho, se puede pasar a Algolia, Meilisearch o una estrategia de tokens mas estricta.

## Importacion inicial desde Excel

El Excel actual tiene 264 registros en la hoja `BACE DE DATOS`.

Columnas:

```text
CLIENTE
PRODUCTO
COLORES
PANTONE
UBICACION
```

Se recomienda limpiar estos valores antes de subirlos:

- `caramelo`, `caramelo `, `caramelos`, `caramelos ` -> elegir un valor unico;
- `caja7` -> `caja 7`;
- revisar registros sin `PANTONE`;
- revisar registro sin `COLORES`.

La carga inicial se puede hacer despues con un script controlado o una pantalla temporal de importacion.
