import 'package:flutter/widgets.dart';

/// Locale único de la app y punto de entrada para la futura l10n.
abstract final class AppLocale {
  /// Etiqueta BCP-47 que consumen `intl` y los delegates de Flutter.
  static const languageTag = 'es_AR';

  static const locale = Locale('es', 'AR');

  static const supportedLocales = <Locale>[locale];
}
