import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumbo/app/app_routes.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// One entry of the lateral navigation.
class AppShellDestination {
  const AppShellDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Adding a destination only needs a route in the router and an entry here.
const appShellDestinations = <AppShellDestination>[
  AppShellDestination(
    path: AppRoutes.home,
    label: AppStrings.navHome,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppShellDestination(
    path: AppRoutes.incomeSources,
    label: AppStrings.navIncomeSources,
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
];

/// Lateral rail shared by every destination of the app.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _indexForLocation(location),
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) =>
                context.go(appShellDestinations[index].path),
            destinations: [
              for (final destination in appShellDestinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(destination.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _indexForLocation(String location) {
    final index = appShellDestinations.indexWhere(
      (destination) => destination.path == location,
    );
    return index < 0 ? 0 : index;
  }
}
