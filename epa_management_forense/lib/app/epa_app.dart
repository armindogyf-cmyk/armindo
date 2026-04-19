import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/router_provider.dart';

class EpaApp extends ConsumerWidget {
  const EpaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ePA – Management Forense',
      theme: AppTheme.darkInstitutional(),
      routerConfig: router,
    );
  }
}
