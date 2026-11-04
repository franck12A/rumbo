# Prompts para el asistente de IA

Guía de uso:

1. Antes de empezar, `AGENTS.md` tiene que estar en la raíz del repo. Si tu asistente no lo lee solo, pegalo al inicio de la sesión (o copiá su contenido al archivo de contexto que use el asistente).
2. Pegá **un prompt por vez**, en orden. No pases al siguiente hasta que se cumplan los criterios de aceptación.
3. Al terminar cada fase: revisá el diff vos mismo, corré `flutter analyze` y `flutter test`, y hacé commit.
4. Si el asistente se desvía, usá el prompt de corrección del final.

---

## Fase 0 — Crear el proyecto y la base

```
Leé AGENTS.md completo antes de empezar.

Objetivo: crear el esqueleto del proyecto Flutter "rumbo" para Windows desktop.

Tareas:
1. Inicializar el proyecto Flutter habilitando solo la plataforma windows (flutter create --platforms=windows --org com.rumbo .) en la carpeta actual, sin pisar README.md ni AGENTS.md.
2. Instalar dependencias con `flutter pub add` (runtime): flutter_riverpod, riverpod_annotation, go_router, drift, sqlite3_flutter_libs, path_provider, path, freezed_annotation, intl, fl_chart. Dev: build_runner, riverpod_generator, drift_dev, freezed, mocktail, very_good_analysis (o flutter_lints si very_good_analysis da conflictos).
3. Configurar analysis_options.yaml en modo estricto (strict-casts, strict-inference, strict-raw-types) con el set de lints elegido.
4. Crear la estructura de carpetas descrita en AGENTS.md (core/, app/, features/ vacías con .gitkeep).
5. Crear app/app.dart con MaterialApp.router, tema Material 3 (claro y oscuro, siguiendo el sistema), locale es_AR y router con una única ruta "/" que muestre una página placeholder "Rumbo".
6. main.dart con ProviderScope e inicialización de intl para es_AR.
7. .gitignore con *.g.dart y *.freezed.dart además de los defaults de Flutter.

Criterios de aceptación:
- `flutter analyze` sin issues.
- `flutter run -d windows` abre la ventana con el placeholder.

Fuera de alcance: base de datos, features, lógica de negocio.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 1 — Core: dinero, errores y base de datos

```
Leé AGENTS.md completo antes de empezar.

Objetivo: construir las bases transversales en core/.

Tareas:
1. core/utils/money.dart: value object inmutable `Money` basado en `int cents`.
   - Constructores: Money.fromCents, Money.zero, Money.fromDecimalString (acepta "10000", "10.000,50" en formato es_AR y rechaza basura).
   - Operadores: +, -, comparaciones, isPositive, abs.
   - format(): "$ 10.000,00" usando intl es_AR.
   - Sin double en la API pública.
2. core/errors: sealed class `Failure` (DatabaseFailure, ValidationFailure, NotFoundFailure) y un tipo `Result<T>` (Success/Err) simple, sin paquetes externos.
3. core/database/app_database.dart: clase AppDatabase de drift con schemaVersion = 1, foreign keys activadas, y conexión que guarda el archivo `rumbo.sqlite` en el directorio de documentos de la app (path_provider). Constructor alternativo para tests con NativeDatabase.memory().
   - Todavía SIN tablas de negocio (se agregan por feature).
4. Providers de Riverpod para AppDatabase (singleton, con dispose).

Tests obligatorios:
- Money: parseo válido/ inválido, suma/resta, formateo es_AR, igualdad.
- AppDatabase: se abre en memoria sin errores.

Criterios de aceptación: analyze limpio, tests verdes.
Fuera de alcance: tablas, features, UI.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 2 — Fuentes de ingreso y categorías

```
Leé AGENTS.md completo antes de empezar.

Objetivo: implementar completas las features `income_sources` y `categories` (son casi idénticas; evitá duplicar lógica innecesaria pero mantené cada feature independiente).

Para cada una:
DOMAIN
- Entidad inmutable con freezed: id, name, colorValue (int), archivedAt (nullable), createdAt.
- Interfaz de repositorio: watchActive(), getById(), create(), rename/update(), archive(), restore().
- Casos de uso: Create, Update, Archive, Restore, WatchActive. Validaciones: nombre no vacío, máximo 40 caracteres, único (sin distinguir mayúsculas) entre los activos.
DATA
- Tabla drift, DAO, mapper entidad<->fila, implementación del repositorio. Migración: pasar schemaVersion a 2 si ya hay tablas, o definirlas en el onCreate/migration strategy correctamente.
PRESENTATION
- Providers Riverpod (lista reactiva y acciones).
- Página con lista, botón "Agregar", edición en diálogo, archivar con confirmación y deshacer (SnackBar).
- Textos en español (Argentina).
- Rutas en go_router: /income-sources y /categories, con un NavigationRail lateral (shell route) para moverse entre secciones.

Datos iniciales: al crear la base por primera vez, sembrar fuentes "Reparación de pelotas" y "Restaurante", y categorías "Materiales", "Transporte", "Comida", "Otros" (en el onCreate de la migración, no en código de UI).

Tests: casos de uso (con repositorio mockeado), repositorios + DAOs (db en memoria), y la validación de nombre único.

Criterios de aceptación: analyze limpio, tests verdes, se pueden crear/editar/archivar desde la app y los datos persisten al reiniciar.
Fuera de alcance: transacciones, metas, dashboard.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 3 — Transacciones (ingresos y gastos)

```
Leé AGENTS.md completo antes de empezar.

Objetivo: feature `transactions`.

DOMAIN
- Entidad `Transaction` (freezed): id, type (income | expense), amount (Money, siempre positivo), date, note (opcional), incomeSourceId (solo ingreso), categoryId (solo gasto), createdAt.
- Invariante: un ingreso exige incomeSourceId y no tiene categoryId; un gasto exige categoryId y no tiene incomeSourceId. Validarlo en los casos de uso y reforzarlo con un CHECK en la tabla.
- Repositorio: watchByMonth(year, month), watchFiltered(filtro), getById, create, update, delete.
- Filtro: rango de fechas, tipo, fuente, categoría.
- Casos de uso: AddTransaction, UpdateTransaction, DeleteTransaction, WatchTransactions, GetMonthSummary (total ingresos, total gastos, balance del mes, por fuente y por categoría).
DATA
- Tabla con FK a fuentes y categorías, índices en date y en las FK, migración correspondiente (incrementá schemaVersion y escribí el paso de migración).
PRESENTATION
- Página /transactions: selector de mes (anterior/siguiente), resumen arriba (ingresos, gastos, balance), lista agrupada por día.
- Formulario (diálogo o página) para agregar/editar: tipo con SegmentedButton, monto con validación y formato es_AR, fecha, fuente o categoría según el tipo, nota.
- Eliminar con confirmación y deshacer.
- Atajo: botón flotante "Nuevo ingreso" / "Nuevo gasto".

Tests: invariantes de Transaction, GetMonthSummary con casos borde (mes vacío, solo gastos, montos grandes), repositorio con db en memoria, migración desde el esquema anterior.

Criterios de aceptación: analyze limpio, tests verdes; cargar un ingreso de $10.000 en "Reparación de pelotas" y un gasto de "Materiales" refleja bien el balance del mes y persiste al reiniciar.
Fuera de alcance: metas, gráficos.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 4 — Metas de ahorro

```
Leé AGENTS.md completo antes de empezar.

Objetivo: feature `goals`.

DOMAIN
- Goal (freezed): id, name, targetAmount (Money), targetDate (opcional), colorValue, archivedAt, completedAt (nullable), createdAt.
- GoalContribution: id, goalId, amount (Money positivo), date, note.
- Repositorio: CRUD de metas, agregar/eliminar aportes, watchGoalsWithProgress().
- GoalProgress (calculado en dominio, no guardado): saved, remaining, percent (0..1, tope 1), isCompleted, y si hay targetDate: monthlyNeeded = remaining / meses restantes (mínimo 1 mes). Función pura y 100% testeada.
- Casos de uso: CreateGoal, UpdateGoal, ArchiveGoal, AddContribution, RemoveContribution, WatchGoalsWithProgress. Al llegar al 100% se marca completedAt automáticamente.
DATA
- Tablas goals y goal_contributions con FK, índices y migración (incrementá schemaVersion).
PRESENTATION
- Página /goals: tarjetas por meta con barra de progreso, "Te faltan $X", "Ahorro sugerido por mes: $Y" si hay fecha.
- Diálogo para crear/editar meta y para registrar un aporte.
- Detalle de meta con historial de aportes.

Tests: GoalProgress (0%, parcial, 100%, aporte que excede la meta, fecha vencida, fecha en el mismo mes), casos de uso, repositorio y migración.

Criterios de aceptación: crear la meta "Auto" de $2.000.000, aportar $300.000 y ver 15% con el faltante correcto.
Fuera de alcance: dashboard, reportes, vincular aportes con transacciones.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 5 — Dashboard

```
Leé AGENTS.md completo antes de empezar.

Objetivo: feature `dashboard` como pantalla de inicio (ruta "/").

- Selector de mes.
- Tarjetas: ingresos del mes, gastos del mes, balance, y comparación con el mes anterior (variación en %).
- Gráfico de barras (fl_chart) ingresos vs gastos de los últimos 6 meses.
- Gráfico de torta o barras de ingresos por fuente del mes seleccionado.
- Resumen de metas activas (máx. 3) con su barra de progreso y acceso rápido a /goals.
- Estados vacíos bien resueltos (sin datos, primer uso).

Reglas:
- La agregación vive en casos de uso de dominio (ej. GetMonthlyComparison, GetIncomeBySource), no en widgets. Reutilizá los repositorios existentes; si necesitás consultas nuevas, agregalas a las interfaces de dominio.
- Los gráficos van en widgets separados y reciben datos ya calculados.
- Colores consistentes con los colores de cada fuente/meta.

Tests: casos de uso de agregación con datos de varios meses (incluyendo meses sin movimientos y cruce de año).

Criterios de aceptación: analyze limpio, tests verdes, dashboard fluido con datos de 12 meses.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 6 — Reportes, exportación y backup

```
Leé AGENTS.md completo antes de empezar.

Objetivo: feature `reports` + utilidades de datos.

1. Reportes: evolución mensual por fuente de ingreso, gastos por categoría, filtro por rango de fechas.
2. Exportar transacciones a CSV (rango elegible) usando un servicio detrás de una interfaz de dominio (ExportService), con la implementación en data/. Separador y formato numérico compatibles con Excel en español.
3. Backup y restauración: copiar/restaurar el archivo rumbo.sqlite mediante selector de archivos. Antes de restaurar, validar que el archivo es una base de Rumbo y que su schemaVersion es compatible; hacer copia de seguridad automática de la actual.
4. Instalar solo las dependencias estrictamente necesarias (ej. file_picker) con `flutter pub add` y justificá cada una.

Tests: generación de CSV (escapado de comas, comillas y saltos de línea en notas), validación de backup inválido.

Criterios de aceptación: exporto un mes a CSV y abre bien en Excel; restauro un backup y los datos vuelven.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Fase 7 — Pulido y release

```
Leé AGENTS.md completo antes de empezar.

Objetivo: dejar la app lista para uso real y para mostrar en el repositorio.

1. Revisión de UX: atajos de teclado (Ctrl+N nueva transacción), foco correcto en formularios, tamaños mínimos de ventana, tema claro/oscuro consistente, accesibilidad básica (tooltips, contraste, Semantics en gráficos).
2. Rendimiento: revisar rebuilds innecesarios, usar select en providers donde corresponda, índices de la base.
3. Ícono de la app y nombre de ventana "Rumbo" (configuración de Windows runner).
4. Pipeline de CI en GitHub Actions: format check, analyze y test en cada push y pull request.
5. CHANGELOG.md (Keep a Changelog) y versión 0.1.0 en pubspec.
6. Actualizar README con capturas (dejar placeholders si no hay) y tabla de funcionalidades real.
7. Documentar en docs/decisions/ tres ADRs breves: dinero en centavos, drift como persistencia, feature-first + clean architecture.

Criterios de aceptación: CI verde, `flutter build windows --release` genera el .exe y funciona en otra carpeta.
Al terminar, seguí el punto 8 de AGENTS.md.
```

---

## Prompts de apoyo

### Plantilla para features nuevas (casa, terreno, gym, gallinero...)

```
Leé AGENTS.md completo antes de empezar.

Objetivo: <describí la funcionalidad en 2-3 frases>.

Contexto de negocio: <por qué existe, quién la usa, ejemplo concreto>.

Requisitos:
- Domain: <entidades, reglas, casos de uso>
- Data: <tablas, migración (subir schemaVersion), índices>
- Presentation: <pantallas, estados vacíos/error/carga>

Casos borde a cubrir: <lista>.
Tests requeridos: <lista>.
Criterios de aceptación: <comportamiento verificable>.
Fuera de alcance: <qué NO hacer>.

Antes de codear, resumime el plan y los archivos que vas a tocar.
Al terminar, seguí el punto 8 de AGENTS.md.
```

### Revisión de código (usarlo antes de cada commit)

```
Actuá como revisor senior de Flutter/Dart. Revisá los cambios del último trabajo contra AGENTS.md.

Buscá y reportá, ordenado por gravedad:
1. Violaciones de la regla de dependencias entre capas.
2. Uso de double para dinero o pérdida de precisión.
3. Lógica de negocio en widgets.
4. Falta de manejo de errores, null unsafe, uso de `!`.
5. Migraciones ausentes o incorrectas, consultas sin índices.
6. Tests faltantes o que no prueban comportamiento real.
7. Rebuilds innecesarios y fugas (listeners, controllers sin dispose).
8. Cualquier cosa fuera del alcance pedido.

No modifiques nada: devolvé una lista con archivo, línea, problema y arreglo sugerido.
```

### Corrección cuando el asistente se desvía

```
Frená. Te desviaste de AGENTS.md y del alcance del prompt anterior: <describí qué hizo mal>.

Revertí lo que quedó fuera de alcance, volvé a leer AGENTS.md y rehacé únicamente lo pedido.
Confirmame primero qué vas a revertir y qué vas a mantener.
```

### Depuración

```
Tengo este error al ejecutar <comando o acción>:

<pegar el error completo>

Contexto: <qué estaba haciendo>.

Primero explicame la causa raíz en lenguaje simple y mostrame cómo la comprobaste. Después proponé el arreglo mínimo, sin refactors adicionales, y agregá un test que hubiera detectado el problema.
```
