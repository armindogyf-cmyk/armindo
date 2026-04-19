import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_routes.dart';
import '../presentation/screens/auditoria_screen.dart';
import '../presentation/screens/configuracoes_screen.dart';
import '../presentation/screens/conhecimento_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/documentos_screen.dart';
import '../presentation/screens/entidades_screen.dart';
import '../presentation/screens/processo_screen.dart';
import '../presentation/screens/relacoes_screen.dart';
import '../presentation/screens/risco_screen.dart';
import '../presentation/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardScreen()),
          GoRoute(path: AppRoutes.documentos, builder: (context, state) => const DocumentosScreen()),
          GoRoute(path: AppRoutes.processo, builder: (context, state) => const ProcessoScreen()),
          GoRoute(path: AppRoutes.entidades, builder: (context, state) => const EntidadesScreen()),
          GoRoute(path: AppRoutes.relacoes, builder: (context, state) => const RelacoesScreen()),
          GoRoute(path: AppRoutes.risco, builder: (context, state) => const RiscoScreen()),
          GoRoute(path: AppRoutes.conhecimento, builder: (context, state) => const ConhecimentoScreen()),
          GoRoute(path: AppRoutes.auditoria, builder: (context, state) => const AuditoriaScreen()),
          GoRoute(path: AppRoutes.configuracoes, builder: (context, state) => const ConfiguracoesScreen()),
        ],
      ),
    ],
  );
});
