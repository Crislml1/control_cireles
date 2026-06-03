# Fotos con Cloudinary

## Decision

Las fotos de los cireles se guardaran en Cloudinary. Firestore solo guardara la URL y el `publicId`.

```text
Cloudinary
  imagen real

Firestore
  photoUrl
  photoPublicId
```

Esto evita guardar fotos como datos pesados en Firestore y evita usar Firebase Storage.

## Datos necesarios de Cloudinary

Para completar la configuracion necesito:

```text
cloudName
uploadPreset
```

Recomendacion:

- crear un `upload preset` unsigned para la app;
- limitar formatos permitidos a `jpg`, `jpeg`, `png`, `webp`;
- definir carpeta base, por ejemplo `control-cireles`;
- activar transformaciones de calidad/tamano si tu plan lo permite.

## Configuracion en Flutter

Se pasara por `--dart-define` para no quemarlo en codigo:

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=tu_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=tu_upload_preset
```

Para build:

```bash
flutter build apk --dart-define=CLOUDINARY_CLOUD_NAME=tu_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=tu_upload_preset
```

## Subida de fotos

Flujo:

1. Usuario toma o selecciona una foto.
2. La app redimensiona/comprime la imagen.
3. Se sube a Cloudinary.
4. Cloudinary devuelve `secure_url` y `public_id`.
5. Firestore guarda `photoUrl` y `photoPublicId`.

## Truco para reducir solicitudes

Se aplicaran estas medidas:

1. Cache local de imagenes con `cached_network_image`.
   - Si el usuario ya vio una foto, Flutter la reutiliza desde cache.
   - Evita descargar la misma imagen repetidamente.

2. Thumbnails en listas.
   - En el listado se pedira una version pequena de la imagen.
   - En detalle se carga la version grande solo cuando se abre el registro.

3. URLs transformadas de Cloudinary.
   - Lista:
     ```text
     w_160,h_160,c_fill,q_auto,f_auto
     ```
   - Detalle:
     ```text
     w_1280,c_limit,q_auto,f_auto
     ```

4. Guardar solo una foto principal por cirel al inicio.
   - Menos archivos.
   - Menos consultas.
   - UI mas simple.

5. Evitar recargar inventario completo despues de cada cambio.
   - Firestore streams actualizan solo cambios.
   - Riverpod mantiene estado reactivo.

## Ejemplo de transformacion de URL

Cloudinary permite insertar transformaciones en la URL:

```text
https://res.cloudinary.com/<cloudName>/image/upload/w_160,h_160,c_fill,q_auto,f_auto/<publicId>.jpg
```

La app tendra un helper para generar:

- `thumbnailUrl`
- `detailUrl`

## Eliminacion de fotos

Importante: eliminar imagenes de Cloudinary de forma segura normalmente requiere una API firmada con `apiSecret`, y eso no debe ir dentro de la app.

Para la primera version:

- al cambiar una foto, se sube la nueva;
- Firestore apunta a la nueva foto;
- la foto anterior puede quedar en Cloudinary hasta limpieza manual.

Para una version mas avanzada:

- usar una funcion backend pequena para borrar imagenes antiguas;
- o borrar manualmente desde Cloudinary cuando sea necesario.

## Campos en Firestore

```text
photoUrl: string | null
photoPublicId: string | null
```

`photoUrl` se usa para mostrar rapidamente.

`photoPublicId` se usa para generar transformaciones y para posible limpieza futura.
