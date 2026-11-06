import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumbo/app/app_routes.dart';
import 'package:rumbo/app/shell/app_shell.dart';
import 'package:rumbo/features/categories/presentation/pages/categories_page.dart';
import 'package:rumbo/features/home/presentation/pages/home_page.dart';
import 'package:rumbo/features/income_sources/presentation/pages/income_sources_page.dart';
import 'package:rumbo/features/transactions/presentation/pages/transactions_page.dart';

/// El router vive en un provider para que su ciclo de vida lo maneje Riverpod
/// y no se reconstruya en cada rebuild del widget raíz.
final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.incomeSources,
            name: 'incomeSources',
            builder: (context, state) => const IncomeSourcesPage(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            name: 'categories',
            builder: (context, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: 'transactions',
            builder: (context, state) => const TransactionsPage(),
          ),
        ],
      ),
    ],
  ),
);
