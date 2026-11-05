# AGENTS.md — Reglas del proyecto Rumbo

Leé este archivo completo antes de escribir o modificar código. Estas reglas tienen prioridad sobre cualquier preferencia por defecto.

## 1. Qué es el proyecto

App de escritorio (Windows) en **Flutter/Dart** para controlar ingresos, gastos y metas de ahorro. Datos locales en **SQLite (drift)**. Usuario único, sin backend.

Dominio:
- **IncomeSource**: de dónde entra plata (ej. reparación de pelotas, restaurante).
- **Category**: categoría de gasto (ej. materiales, transporte).
- **Transaction**: ingreso o gasto, con monto, fecha, nota, y fuente o categoría según el tipo.
- **Goal**: meta de ahorro (nombre, monto objetivo, fecha estimada opcional).
- **GoalContribution**: aporte a una meta (monto, fecha).

## 2. Stack fijo (no cambiar sin pedir permiso)

- Flutter stable, Dart con null safety y `strict` analysis.
- Base de datos: `drift` + `sqlite3` (versión vigente) con `NativeDatabase` de `package:drift/native.dart`.
  Desde drift 2.32 (sqlite3 3.x) SQLite se empaqueta automáticamente en la app vía build hooks, así que **no** se agrega `sqlite3_flutter_libs` (discontinuado) ni hace falta setup extra en Windows desktop.
- Estado y DI: `flutter_riverpod` con `riverpod_annotation` / `riverpod_generator`.
- Navegación: `go_router`.
- Modelos inmutables: `freezed` (+ `json_serializable` solo si hace falta).
- Formato: `intl` con locale `es_AR`.
- Gráficos: `fl_chart`.
- Tests: `flutter_test`, `mocktail`.

**Instalación de dependencias**: usá siempre `flutter pub add <paquete>` (y `--dev` cuando corresponda) para obtener la versión vigente. No escribas versiones de memoria en el `pubspec.yaml`.

## 3. Arquitectura

Feature-first + Clean Architecture:

```
lib/features/<feature>/
  data/          # drift DAOs, mappers, implementaciones de repositorio
  domain/        # entidades, interfaces de repositorio, casos de uso
  presentation/  # providers, pages, widgets
```

Reglas de dependencia:
1. `domain` es Dart puro: **no importa** Flutter, drift, riverpod ni nada de `data`/`presentation`.
2. `presentation` y `data` dependen de `domain`; **nunca entre sí**.
3. Las features no se importan entre sí directamente; si necesitan algo compartido, va a `core/` o se expone vía interfaz de dominio.
4. Los widgets **no contienen lógica de negocio ni acceso a base de datos**. Solo observan providers y disparan acciones.
5. Un caso de uso = una clase con un método `call()` y una sola responsabilidad.

## 4. Reglas de dinero (críticas)

- Todo monto se guarda y maneja como **`int` en centavos**. Prohibido `double` para dinero.
- Existe un value object `Money` en `core/utils` (construido desde centavos) con suma, resta, comparación y formateo `es_AR` (ej. `$ 10.000,00`).
- El formateo ocurre **solo en presentación**. Dominio y datos trabajan con centavos.
- Validar: los montos de transacciones y aportes son estrictamente positivos; el tipo (ingreso/gasto) define el signo.

## 5. Base de datos

- Una sola clase `AppDatabase` en `core/database`.
- `schemaVersion` desde el inicio; todo cambio de esquema implica una migración escrita y testeada.
- Borrado lógico (`archivedAt`) en fuentes y categorías. Las transacciones no se borran en cascada.
- Claves foráneas activadas. Índices en columnas de fecha y claves foráneas usadas en filtros.
- Los DAOs devuelven datos de drift; los **mappers** los convierten a entidades de dominio. Nunca exponer clases de drift fuera de `data/`.
- Toda operación que toque varias tablas va dentro de una transacción de drift.

## 6. Estilo de código

- Archivos y carpetas: `snake_case`. Clases: `PascalCase`. Código en **inglés**; textos visibles al usuario en **español (Argentina)**.
- Todos los textos de UI centralizados (no hardcodeados dentro de widgets de lógica); preparar para l10n futura.
- Preferir `final` y objetos inmutables. Sin `dynamic` ni `!` sin justificación escrita.
- Funciones cortas, nombres que expresen intención. Un widget por archivo cuando supere ~80 líneas; extraer subwidgets en vez de métodos `_buildX`.
- Constructores `const` donde sea posible.
- Comentarios solo para explicar el *por qué*, no el *qué*.
- Manejo de errores explícito: los repositorios devuelven un `Result`/lanzan fallas tipadas definidas en `core/errors`. Nada de `catch (e) {}` vacío.

## 7. Tests

- Todo caso de uso y todo repositorio llevan tests.
- DAOs y migraciones: tests con base de datos en memoria (`NativeDatabase.memory()`).
- `test/` espeja la estructura de `lib/`.
- Convención de nombre: `should <resultado> when <condición>`.
- Nada se da por terminado si `flutter test` falla.

## 8. Forma de trabajo (obligatoria)

1. **Antes de codear**: resumí en pocas líneas qué vas a hacer y qué archivos tocarás. Si algo es ambiguo, preguntá en vez de asumir.
2. **Alcance**: hacé únicamente lo que pide el prompt. Sin features extra, sin refactors no pedidos, sin renombrar cosas ajenas a la tarea.
3. **Incremental**: cambios pequeños y compilables. No dejes el proyecto roto entre pasos.
4. **Al terminar**, ejecutá y reportá el resultado de:
   - `dart run build_runner build --delete-conflicting-outputs` (si tocaste código generado)
   - `dart format .`
   - `flutter analyze` (debe dar 0 issues)
   - `flutter test`
5. **Cierre**: listá archivos creados/modificados, decisiones tomadas y cualquier deuda técnica o duda pendiente.
6. Si una regla de este archivo choca con lo pedido, avisá el conflicto antes de seguir.

## 9. Git

- Commits con Conventional Commits, atómicos y en inglés.
- No hacer commit de código generado salvo que el proyecto lo indique (`*.g.dart` y `*.freezed.dart` van en `.gitignore`).
- No tocar `main` directamente; trabajar en ramas `feat/*` o `fix/*`.

## 10. Prohibido

- Agregar dependencias no listadas sin pedir permiso.
- Usar `double` para dinero.
- Lógica de negocio en widgets.
- Importar `data` desde `presentation` (o al revés).
- Dejar `print()`, TODOs sin contexto o código comentado.
- Hardcodear credenciales, rutas absolutas o datos de ejemplo en código de producción.
