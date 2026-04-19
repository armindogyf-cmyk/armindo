import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const destinations = <({String label, IconData icon, String route})>[
    (label: 'Dashboard', icon: Icons.dashboard_rounded, route: AppRoutes.dashboard),
    (label: 'Documentos', icon: Icons.folder_copy_rounded, route: AppRoutes.documentos),
    (label: 'Processo', icon: Icons.gavel_rounded, route: AppRoutes.processo),
    (label: 'Entidades', icon: Icons.groups_rounded, route: AppRoutes.entidades),
    (label: 'Relações', icon: Icons.account_tree_rounded, route: AppRoutes.relacoes),
    (label: 'Risco', icon: Icons.warning_amber_rounded, route: AppRoutes.risco),
    (label: 'Conhecimento', icon: Icons.psychology_rounded, route: AppRoutes.conhecimento),
    (label: 'Auditoria', icon: Icons.fact_check_rounded, route: AppRoutes.auditoria),
    (label: 'Configurações', icon: Icons.settings_rounded, route: AppRoutes.configuracoes),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = destinations.indexWhere((item) => item.route == location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) => context.go(destinations[index].route),
            destinations: destinations
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
