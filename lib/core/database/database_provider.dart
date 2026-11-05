import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/core/database/app_database.dart';

part 'database_provider.g.dart';

/// One database per process: features share the same connection and it stays
/// open while the app runs.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
