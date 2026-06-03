# Importacion de Excel desde el celular

Si se puede cargar la base desde el celular. La idea es permitir que el usuario seleccione un archivo `.xlsx` o `.xlsm`, leer la hoja de base de datos y subir los registros a Firestore.

## Paquetes necesarios

Para este paso faltan dos dependencias:

```bash
flutter pub add file_picker excel
```

`file_picker` permite escoger el archivo desde el celular o escritorio.

`excel` permite leer el contenido del archivo. El archivo actual es `.xlsm`; normalmente se puede leer como libro OpenXML porque internamente se parece a `.xlsx`, aunque las macros no se usaran.

## Flujo propuesto

1. Usuario inicia sesion.
2. En inventario toca `Importar Excel`.
3. La app permite elegir el archivo.
4. Se busca una hoja llamada `BACE DE DATOS`.
5. Se leen columnas:

```text
CLIENTE
PRODUCTO
COLORES
PANTONE
UBICACION
```

6. La app muestra una vista previa:
   - cantidad de registros;
   - registros incompletos;
   - valores que se normalizaran.
7. Usuario confirma.
8. Se suben los datos a Firestore con `upsertMany`.

## Normalizacion

Antes de guardar:

- se recortan espacios al inicio/final;
- `caja7` se convierte a `caja 7`;
- `caramelo`, `caramelo `, `caramelos`, `caramelos ` se pueden unificar si el usuario confirma;
- filas sin cliente se ignoran;
- filas incompletas se muestran para revision.

## Importante

No se subiran macros. Solo datos.

Para evitar duplicados, podemos usar un ID derivado de:

```text
cliente + producto + ubicacion
```

O podemos dejar que Firestore genere IDs nuevos. Para la primera carga, recomiendo generar IDs estables para que si importas el mismo Excel dos veces, actualice en lugar de duplicar.
