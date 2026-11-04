import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rumbo/app/app.dart';
import 'package:rumbo/core/l10n/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sin esto, DateFormat/NumberFormat con es_AR no encuentran los símbolos.
  await initializeDateFormatting(AppLocale.languageTag);
  runApp(const ProviderScope(child: RumboApp()));
}
