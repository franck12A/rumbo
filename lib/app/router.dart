import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumbo/features/home/presentation/pages/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
}

/// El router vive en un provider para que su ciclo de vida lo maneje Riverpod
/// y no se reconstruya en cada rebuild del widget raíz.
final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  ),
);
