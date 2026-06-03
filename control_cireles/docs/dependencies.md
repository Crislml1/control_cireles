# Dependencias necesarias

No ejecuto instalaciones automaticamente. Cuando quieras que siga con la implementacion, ejecuta estos comandos y avisame.

## Dependencias de app

```bash
flutter pub add flutter_riverpod riverpod_annotation firebase_core firebase_auth cloud_firestore image_picker image cached_network_image http path_provider local_auth intl uuid
```

## Dependencias de desarrollo

```bash
flutter pub add --dev build_runner riverpod_generator custom_lint riverpod_lint
```

## Generacion de Riverpod

Cada vez que se creen o cambien providers con anotaciones:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Verificacion

Cuando la implementacion este lista:

```bash
flutter analyze
```

```bash
flutter test
```

## Configuracion Cloudinary al correr

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=tu_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=tu_upload_preset
```

## Paquetes y uso

```text
flutter_riverpod
  Estado de la app.

riverpod_annotation
riverpod_generator
build_runner
  Providers con anotaciones y codigo generado.

firebase_core
  Inicializacion Firebase.

firebase_auth
  Login con correo/contrasena.

cloud_firestore
  Inventario compartido.

image_picker
  Tomar o seleccionar fotos.

image
  Redimensionar/comprimir antes de subir.

cached_network_image
  Cache local para reducir descargas de Cloudinary.

http
  Subida unsigned a Cloudinary.

path_provider
  Acceso a carpetas locales para cache/temporales si se necesita.

local_auth
  Desbloqueo con PIN, huella, FaceID o Windows Hello segun plataforma.

intl
  Formato de fechas.

uuid
  IDs locales cuando se necesite crear antes de guardar.

custom_lint
riverpod_lint
  Buenas practicas de Riverpod.
```

## Nota sobre el comando interrumpido

El comando anterior de instalacion fue interrumpido. Antes de seguir programando, conviene revisar si `pubspec.yaml` quedo parcialmente modificado. Si quedo raro, lo ajustamos manualmente.
