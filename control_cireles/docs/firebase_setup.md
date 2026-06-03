# Configuracion de Firebase

## Proyecto

```text
Project ID: control-de-cireles
Android package: com.cireles.control
iOS bundle id recomendado: com.cireles.control
```

## Servicios usados

- Firebase Auth: correo y contrasena.
- Cloud Firestore: datos del inventario.
- Firebase Storage: no se usara por ahora.

Las fotos se guardaran en Cloudinary para evitar depender de Firebase Storage.

## Archivos recibidos

El usuario envio:

```text
C:/Users/cvasco/Downloads/google-services.json
C:/Users/cvasco/Downloads/GoogleService-Info.plist
```

Cuando se configure el proyecto, se deben copiar a:

```text
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

## Configuracion Windows desktop

Windows usara opciones manuales equivalentes a la configuracion web de Firebase.

```dart
FirebaseOptions(
  apiKey: 'AIzaSyDUhB56Mxo3JCbMHbuwZPRbmDcGpVeGm98',
  authDomain: 'control-de-cireles.firebaseapp.com',
  projectId: 'control-de-cireles',
  storageBucket: 'control-de-cireles.firebasestorage.app',
  messagingSenderId: '316236177757',
  appId: '1:316236177757:web:0ffcfde6c1af1fdfbd88b4',
  measurementId: 'G-DBL76T6VFQ',
)
```

Aunque esa configuracion viene de una app Web, se usara solo para inicializar Firebase en Windows. No implica publicar una app web.

## Reglas Firestore iniciales

Version simple: cualquier usuario autenticado puede leer y escribir el inventario compartido.

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    match /cyreles/{cirelId} {
      allow read, create, update, delete: if signedIn();
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Reglas Firestore recomendadas para produccion

Esta version requiere que el usuario exista en `users/{uid}` y tenga `active: true`.

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    function activeUser() {
      return signedIn()
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.active == true;
    }

    match /users/{userId} {
      allow read: if signedIn() && request.auth.uid == userId;
      allow write: if false;
    }

    match /cyreles/{cirelId} {
      allow read, create, update, delete: if activeUser();
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Para desarrollo inicial se puede usar la version simple. Antes de entregar a usuarios reales, conviene pasar a la version con `activeUser`.

## Estructura Firestore

```text
cyreles/{cirelId}
  cliente: string
  clienteLower: string
  producto: string
  productoLower: string
  colores: number | null
  pantone: string | null
  pantoneLower: string | null
  ubicacion: string
  ubicacionLower: string
  searchTokens: array<string>
  photoUrl: string | null
  photoPublicId: string | null
  createdAt: timestamp
  updatedAt: timestamp
  createdBy: string
  updatedBy: string
```

Opcional para autorizacion estricta:

```text
users/{uid}
  email: string
  displayName: string | null
  active: boolean
  role: "admin" | "editor" | "viewer"
  createdAt: timestamp
```

## Indices

Al inicio no se necesitan indices compuestos si se carga y filtra localmente.

Si despues se agregan queries combinadas, Firestore indicara el link para crear el indice necesario.
