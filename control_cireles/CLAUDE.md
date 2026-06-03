# Control de Cireles — Guia del proyecto

Aplicacion Flutter para gestionar el inventario de cireles de la empresa.
Reemplaza un Excel de 264 registros con una app movil y desktop compartida por el equipo.

## Que hace la app

- Login con correo y contrasena (Firebase Auth).
- Listado y busqueda del inventario por cliente, producto, pantone o ubicacion.
- Crear, editar y eliminar cireles.
- Foto opcional por cirel (Cloudinary). Toca la foto para verla a pantalla completa con zoom.
- **Importacion masiva desde Excel** (.xlsx): sube cientos de cireles de una vez.
- **Bloqueo automatico con biometria**: tras 5 minutos en background la app se bloquea
  y pide huella digital / Face ID / Windows Hello para volver al inventario.
- Funciona en Android, iOS y Windows.

---

## Setup rapido

### 1. Prerrequisitos

- Flutter SDK (canal stable)
- Cuenta Firebase (proyecto `control-de-cireles` ya creado)
- Cuenta Cloudinary (solo para subir fotos)

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Cloudinary

Las credenciales van en `lib/core/config/app_secrets.dart` (gitignoreado).

```bash
# Copiar la plantilla
copy lib\core\config\app_secrets.example.dart lib\core\config\app_secrets.dart
```

Abrir `app_secrets.dart` y rellenar:

```dart
static const cloudinaryCloudName = 'tu-cloud-name';
static const cloudinaryUploadPreset = 'tu-upload-preset';
```

> Sin Cloudinary la app funciona normal; solo falla si intentas subir una foto.

### 4. Ejecutar

```bash
flutter run
```

### 5. Regenerar codigo generado (solo si cambias providers)

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esto se necesita unicamente cuando agregas o modificas un provider anotado con `@riverpod`.
Los archivos `.g.dart` son generados automaticamente y **no se editan a mano**.

---

## Estructura del proyecto

```
lib/
  app/
    app.dart                  Entry point de widgets. Decide que pantalla mostrar
                              (Login / AppLock / Inventario). Implementa
                              WidgetsBindingObserver para detectar cuando la app
                              vuelve del background y activar el bloqueo.
    bootstrap.dart            Inicializa Firebase y arranca la app.
    firebase_options.dart     Credenciales Firebase por plataforma (Android/iOS/Windows).
    theme.dart                Tema Material 3 de la app.

  core/
    config/
      app_secrets.dart          GITIGNOREADO — credenciales Cloudinary.
      app_secrets.example.dart  Plantilla para nuevos desarrolladores.
      cloudinary_config.dart    Lee credenciales de app_secrets.dart.
    errors/
      app_exception.dart        Excepcion tipada para mostrar mensajes al usuario.
    utils/
      cloudinary_url.dart       Helpers para transformar URLs de Cloudinary (thumbnail/detail).
      image_compression.dart    Comprime imagenes antes de subir a Cloudinary.

  features/
    auth/
      data/
        biometric_auth_service.dart   Verifica disponibilidad biometrica y lanza el
                                      prompt nativo (huella / Face ID / Windows Hello).
        firebase_auth_repository.dart Implementacion real de AuthRepository con Firebase.
      domain/
        app_user.dart           Modelo de usuario autenticado (id, email, displayName).
        auth_repository.dart    Interfaz del repositorio de auth (signIn, signOut, stream).
      presentation/
        app_lock_page.dart      Pantalla de bloqueo. Muestra el prompt biometrico
                                automaticamente al aparecer. Tiene boton de cerrar sesion
                                como alternativa.
        login_page.dart         Pantalla de login con correo y contrasena.
      view_model/
        app_lock_providers.dart   biometricAvailableProvider (FutureProvider<bool>) +
                                  AppLockViewModel (logica del desbloqueo biometrico).
        app_lock_providers.g.dart Generado por build_runner. No editar.
        auth_providers.dart       firebaseAuthProvider, authRepositoryProvider,
                                  authStateProvider, biometricAuthServiceProvider,
                                  AppLock (estado de bloqueo keepAlive),
                                  LoginViewModel (signIn con correo).
        auth_providers.g.dart     Generado por build_runner. No editar.

    inventory/
      data/
        cloudinary_photo_storage_repository.dart  Sube fotos a Cloudinary.
        excel_import_service.dart                 Parsea .xlsx → lista de InventoryItem.
        firestore_inventory_repository.dart       Escribe/lee Firestore.
      domain/
        inventory_item.dart           Modelo principal + logica de busqueda/normalizacion.
        inventory_repository.dart     Interfaz del repositorio de inventario.
        photo_storage_repository.dart Interfaz para subir fotos.
        photo_upload_result.dart      Resultado de una subida (url + publicId).
      presentation/
        pages/
          inventory_detail_page.dart  Detalle de un cirel.
          inventory_form_page.dart    Formulario de crear/editar.
          inventory_import_page.dart  UI del flujo de importacion masiva.
          inventory_list_page.dart    Lista + busqueda.
        widgets/
          inventory_card.dart         Tarjeta de un cirel en la lista.
          inventory_photo.dart        Widget de foto con cache y placeholder.
          inventory_search_field.dart Campo de busqueda.
      view_model/
        inventory_detail_view_model.dart   Accion de eliminar un cirel.
        inventory_form_view_model.dart     Guardar (crear/editar) un cirel.
        inventory_import_view_model.dart   Flujo de importacion masiva (sealed states).
        inventory_list_view_model.dart     Estado de busqueda de la lista.
        inventory_providers.dart           Providers: Firestore, repo, items, filtros.
        *.g.dart                           Generados por build_runner. No editar.

  shared/
    widgets/
      app_empty_state.dart   Widget de "sin datos".
      app_error_view.dart    Widget de error con boton reintentar.
      app_loading_view.dart  Widget de carga.
      app_photo_viewer.dart  Visor de foto a pantalla completa con zoom.
```

---

## Patron MVVM con Riverpod

```
UI (Page/Widget)
    |  watch/read providers
    v
ViewModel (Riverpod @riverpod class)
    |  llama metodos del repositorio
    v
Repository (interfaz en domain/)
    |  implementado en data/
    v
Firebase / Cloudinary
```

**Regla clave**: la UI nunca llama directamente a Firebase.
La UI habla con el ViewModel; el ViewModel habla con el repositorio.

### Ejemplo: crear un cirel

1. `InventoryFormPage` llama a `ref.read(inventoryFormViewModelProvider.notifier).save(input)`.
2. `InventoryFormViewModel.save()` valida auth, sube foto si hay, llama `repository.create(item)`.
3. `FirestoreInventoryRepository.create()` escribe el documento en Firestore coleccion `cyreles`.
4. Firestore emite el cambio via stream.
5. `inventoryItemsProvider` actualiza su estado.
6. `InventoryListPage` reconstruye automaticamente.

---

## Flujo de navegacion principal

`app.dart` es el unico lugar que decide que pantalla mostrar.
La logica esta en `AppStartupPage` (ConsumerStatefulWidget) y sigue este orden:

```
authStateProvider
      |
      |── usuario == null ──────────────────→ LoginPage
      |
      |── usuario != null
              |
              |── biometricAvailableProvider (AsyncLoading) → Spinner
              |
              |── isLocked == true ──────────────────────── → AppLockPage
              |
              └── isLocked == false ─────────────────────── → InventoryListPage
```

### Cuando se activa el bloqueo (`isLocked = true`)

- **Al arrancar la app** con sesion activa: `AppLock.build()` devuelve `true` siempre.
- **Al volver del background** tras mas de 5 minutos: `WidgetsBindingObserver`
  detecta `AppLifecycleState.resumed` y llama a `appLockProvider.notifier.lock()`.

### Cuando se desbloquea (`isLocked = false`)

- **Biometria exitosa** en `AppLockPage`: `AppLockViewModel.authenticate()` llama a
  `appLockProvider.notifier.unlock()`.
- **Login con correo** exitoso: `LoginViewModel.signIn()` llama a
  `appLockProvider.notifier.unlock()` tras autenticar en Firebase.
- **Sin biometria en el dispositivo**: `biometricAvailableProvider` resuelve a `false`
  y `app.dart` desbloquea automaticamente via `ref.listen`.

### Cambiar el tiempo de bloqueo

Editar la constante en `app.dart`:

```dart
static const _lockTimeout = Duration(minutes: 5); // cambiar aqui
```

---

## Biometria — detalles tecnicos

### Paquete usado

`local_auth: ^3.0.1` — plugin oficial de Flutter para biometria.

### Archivos relevantes

| Archivo | Responsabilidad |
|---|---|
| `biometric_auth_service.dart` | Llama a `LocalAuthentication`. Tiene delay de 350ms en Windows para que el prompt de Windows Hello tome el foco correctamente. |
| `app_lock_providers.dart` | `biometricAvailableProvider` comprueba disponibilidad. `AppLockViewModel` lanza el prompt y desbloquea. |
| `app_lock_page.dart` | UI de la pantalla de bloqueo. Auto-lanza el prompt en `initState`. |

### Icono y texto del boton segun plataforma

| Plataforma | Icono | Texto |
|---|---|---|
| Android | `Icons.fingerprint` | "Desbloquear con huella digital" |
| iOS | `Icons.face_retouching_natural` | "Desbloquear con Face ID / Touch ID" |
| Windows | `Icons.security` | "Desbloquear con Windows Hello" |

### Configuracion nativa requerida (ya hecha)

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

**Android** — `android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
// IMPORTANTE: debe ser FlutterFragmentActivity, no FlutterActivity.
// BiometricPrompt requiere FragmentActivity para funcionar.
class MainActivity : FlutterFragmentActivity()
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>La app usa Face ID para que puedas iniciar sesion rapidamente...</string>
```

**Windows** — `windows/CMakeLists.txt`:
```cmake
# Silencia error del compilador por cabeceras C++ experimentales en local_auth_windows
add_definitions(-D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)
```

---

## Importacion masiva desde Excel

### Como usarla

1. En la pantalla de lista, tocar el icono **📤** (arriba a la derecha).
2. Seleccionar el archivo `.xlsx`.
3. La app muestra un preview: cuantos cireles se importaran y cuantas filas se omitieron.
4. Confirmar → los cireles aparecen en el inventario automaticamente.

### Formato del archivo Excel

| Columna   | Tipo   | Requerido |
|-----------|--------|-----------|
| CLIENTE   | Texto  | Si        |
| PRODUCTO  | Texto  | Si        |
| COLORES   | Numero | No        |
| PANTONE   | Texto  | No        |
| UBICACION | Texto  | Si        |

**Reglas del archivo:**
- Primera fila = encabezado con los nombres exactos (no importan mayusculas ni tildes).
- Filas sin CLIENTE, PRODUCTO o UBICACION se omiten con un aviso.
- Filas completamente vacias se ignoran.
- Solo `.xlsx` (no `.xls` ni `.csv`).
- Importar el mismo archivo dos veces crea duplicados en Firestore (no hay deteccion automatica).

### Flujo tecnico

1. Usuario selecciona el archivo → `FilePicker` devuelve `Uint8List`.
2. `ExcelImportService.parse()` lee el Excel, detecta columnas y convierte filas.
3. `InventoryImportViewModel.loadFile()` muestra el estado `ImportPreviewing`.
4. Al confirmar, `confirmImport()` llama a `repository.upsertMany()`.
5. `upsertMany` escribe en lotes de 400 documentos (limite de Firestore).
6. Estado cambia a `ImportDone`; la lista se actualiza sola via stream de Firestore.

---

## Firebase — datos importantes

- **Proyecto**: `control-de-cireles`
- **Coleccion Firestore**: `cyreles`
- **Auth**: solo correo y contrasena

### Reglas Firestore (configurar en Firebase Console)

Regla minima para desarrollo (cualquier usuario autenticado puede operar):

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    match /cyreles/{cirelId} {
      allow read, create, update, delete: if signedIn();
    }
    match /{document=**} { allow read, write: if false; }
  }
}
```

> Si al crear un producto aparece el error `[cloud_firestore/permission-denied]`,
> las reglas de Firestore no estan configuradas. Ir a Firebase Console → Firestore → Rules.

### Estructura de un documento Firestore

```
cyreles/{id}
  cliente:        string        "Empresa XYZ"
  clienteLower:   string        "empresa xyz"     (para busqueda case-insensitive)
  producto:       string        "Cirel rojo"
  productoLower:  string        "cirel rojo"
  colores:        string|null   "4"
  pantone:        string|null   "PMS 485 C"
  pantoneLower:   string|null   "pms 485 c"
  ubicacion:      string        "Estante A - Caja 3"
  ubicacionLower: string        "estante a - caja 3"
  searchTokens:   array<string> ["empresa", "xyz", "cirel", "rojo", ...]
  photoUrl:       string|null   URL de Cloudinary
  photoPublicId:  string|null   ID en Cloudinary (para transformaciones)
  createdAt:      timestamp
  updatedAt:      timestamp
  createdBy:      string        UID del usuario
  updatedBy:      string        UID del usuario
```

---

## Cloudinary — datos importantes

Las fotos se guardan en Cloudinary (no en Firebase Storage).
Firestore solo guarda la URL y el publicId.

Flujo al subir una foto:
1. Usuario elige foto desde camara o galeria.
2. La app comprime la imagen (`image_compression.dart`).
3. Se sube a Cloudinary via HTTP multipart (`cloudinary_photo_storage_repository.dart`).
4. Cloudinary devuelve `secure_url` y `public_id`.
5. El documento de Firestore guarda esas dos cadenas.

Para mostrar en lista (miniatura 160x160):
```
/upload/w_160,h_160,c_fill,q_auto,f_auto/<publicId>
```

Para mostrar en detalle:
```
/upload/w_1280,c_limit,q_auto,f_auto/<publicId>
```

---

## Preguntas frecuentes

**¿Puedo crear cireles sin configurar Cloudinary?**
Si. La foto es opcional. El formulario guarda igual sin foto.

**¿Como agrego un nuevo usuario?**
Desde Firebase Console → Authentication → Add user.

**¿Como regenero los archivos .g.dart?**
```bash
dart run build_runner build --delete-conflicting-outputs
```
Esto se necesita solo cuando agregas o modificas un provider `@riverpod`.

**¿Donde esta la busqueda?**
Es local: la app carga todos los cireles desde Firestore en memoria y filtra en el cliente.
Funciona bien hasta ~5000 registros. Si el inventario crece mas, migrar a busqueda por tokens en Firestore.

**¿Por que el MainActivity de Android usa FlutterFragmentActivity?**
Porque `BiometricPrompt` de Android requiere una `FragmentActivity`. `FlutterActivity`
extiende `Activity` (sin soporte de Fragment) y provoca un error al intentar mostrar el
prompt biometrico. `FlutterFragmentActivity` es el reemplazo correcto cuando se usa `local_auth`.

**¿Por que hay un add_definitions en windows/CMakeLists.txt?**
El plugin `local_auth_windows` usa cabeceras C++ experimentales (`<experimental/coroutine>`)
que Visual Studio 2022 convierte en error de compilacion. La definicion
`_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` suprime ese error hasta que
el plugin actualice a las cabeceras C++20 estandar.

**¿Por que hay dos archivos `firebase_options.dart`?**
Solo hay uno: `lib/app/firebase_options.dart`. El generado por FlutterFire CLI fue eliminado
porque la app usa el manual (que soporta macOS y Linux ademas de las plataformas base).

**La biometria no aparece en el dispositivo.**
Ocurre cuando el dispositivo no tiene ningun metodo biometrico enrolado. La app lo detecta
con `canCheckBiometrics` y simplemente no activa el bloqueo automatico. El usuario accede
al inventario directamente tras el login con correo.
