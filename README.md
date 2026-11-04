# Rumbo

App de escritorio para controlar **ingresos, gastos y metas de ahorro**.
Pensada para quien tiene ingresos irregulares (trabajos por encargo, changas, temporadas) y necesita saber, mes a mes, cuánto le falta para llegar a sus metas.

> Proyecto personal de aprendizaje: Flutter + Dart + SQLite, con arquitectura limpia y escalable.

## Funcionalidades

- **Ingresos por fuente**: cada fuente de ingreso se registra por separado (por ejemplo, reparaciones, trabajos en restaurante).
- **Gastos por categoría**: materiales, transporte, comida, etc.
- **Metas de ahorro**: definís un objetivo (auto, casa, terreno, gimnasio, emprendimiento) con monto y fecha estimada, y ves el progreso.
- **Dashboard mensual**: balance, ingresos vs gastos, progreso de metas.
- **Reportes**: evolución por mes y por fuente de ingreso.
- **Datos 100% locales**: todo se guarda en tu PC (SQLite). Sin cuentas ni nube.

## Stack

| Área | Tecnología |
|---|---|
| UI / Framework | Flutter (Windows desktop) |
| Lenguaje | Dart |
| Base de datos | SQLite con [drift](https://pub.dev/packages/drift) |
| Estado / DI | Riverpod |
| Navegación | go_router |
| Modelos inmutables | freezed |
| Gráficos | fl_chart |
| Formato moneda/fecha | intl (`es_AR`) |
| Tests | flutter_test, mocktail |

## Arquitectura

Organización **feature-first** con capas de **Clean Architecture** dentro de cada feature:

```
presentation  →  domain  ←  data
(UI, providers)  (entidades,   (drift, repositorios
                  casos de uso,  implementados)
                  contratos)
```

Regla de dependencias: `domain` no depende de Flutter, drift ni de nadie. `presentation` y `data` dependen de `domain`, nunca entre sí.

### Estructura de carpetas

```
lib/
├── main.dart
├── app/                    # MaterialApp, router, tema
├── core/
│   ├── database/           # AppDatabase (drift), tablas, migraciones
│   ├── errors/             # Failure / Result
│   ├── utils/              # Money, formateadores, extensiones
│   └── widgets/            # Widgets compartidos
└── features/
    ├── income_sources/
    ├── categories/
    ├── transactions/
    ├── goals/
    ├── dashboard/
    └── reports/
        ├── data/           # DAOs, mappers, repositorios (impl)
        ├── domain/         # entidades, contratos, casos de uso
        └── presentation/   # providers, páginas, widgets
test/                       # espeja la estructura de lib/
docs/
├── PROMPTS.md              # prompts por fases para el asistente de IA
└── decisions/              # ADRs (decisiones de arquitectura)
```

### Decisiones clave

- **El dinero se guarda como entero en centavos** (`int`), nunca como `double`, para evitar errores de redondeo. Se formatea solo en la capa de UI.
- **Borrado lógico** en fuentes y categorías (`archivedAt`) para no romper el historial.
- **Migraciones versionadas** desde el día uno (`schemaVersion` en drift).
- **Sin lógica en los widgets**: la UI solo lee providers y dispara acciones.

## Requisitos para desarrollar

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/desktop) (canal stable)
- Visual Studio 2022 con la carga de trabajo **Desarrollo para el escritorio con C++** (necesario para compilar en Windows)
- VS Code con las extensiones *Flutter* y *Dart*

Verificá tu entorno con:

```bash
flutter doctor
```

## Puesta en marcha

```bash
git clone https://github.com/<tu-usuario>/rumbo.git
cd rumbo
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

Durante el desarrollo, para regenerar código automáticamente:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Generar el .exe

```bash
flutter build windows --release
```

El ejecutable queda en `build/windows/x64/runner/Release/`.

## Calidad

```bash
dart format .
flutter analyze
flutter test
```

Estos tres comandos deben pasar sin errores antes de cada commit.

## Convenciones

- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
- **Ramas**: `main` siempre estable; trabajo en `feat/<nombre>` o `fix/<nombre>`.
- **Nombres**: código y comentarios técnicos en inglés; textos visibles al usuario en español (Argentina).

## Roadmap

- [x] Definición de arquitectura y stack
- [ ] **v0.1**: fuentes de ingreso, categorías y transacciones
- [ ] **v0.2**: metas de ahorro con progreso
- [ ] **v0.3**: dashboard mensual y reportes
- [ ] **v0.4**: exportar/importar datos (CSV) y backup
- [ ] **v1.0**: instalador de Windows
- [ ] Futuro: metas a largo plazo con simulaciones (casa, terreno, gimnasio, gallinero), presupuestos por categoría, versión móvil con el mismo código

## Licencia

MIT
