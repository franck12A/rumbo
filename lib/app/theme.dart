import 'package:flutter/material.dart';

/// Tema Material 3 de Rumbo, en variante clara y oscura.
///
/// Material 3 es el tema por defecto de `ThemeData`, por eso no hace falta
/// pasar `useMaterial3`.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF00695C);

  static ThemeData light() => _fromBrightness(Brightness.light);

  static ThemeData dark() => _fromBrightness(Brightness.dark);

  static ThemeData _fromBrightness(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
