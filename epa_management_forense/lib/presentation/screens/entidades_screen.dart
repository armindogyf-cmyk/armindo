import 'package:flutter/material.dart';

import 'base_screen.dart';

class EntidadesScreen extends StatelessWidget {
  const EntidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Entidades',
      subtitle: 'Módulo entidades pronto para evolução funcional, com rastreabilidade integral e vínculo a fontes primárias.',
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Estrutura inicial implementada (offline-first e sync-ready).'),
          ),
        ),
      ],
    );
  }
}
