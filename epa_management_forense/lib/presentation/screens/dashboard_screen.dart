import 'package:flutter/material.dart';

import '../widgets/info_card.dart';
import 'base_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Dashboard',
      subtitle: 'Visão executiva da plataforma documental, probatória e jurídica.',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 280, child: InfoCard(title: 'Documentos Ingeridos', value: '1.284')),
            SizedBox(width: 280, child: InfoCard(title: 'Processos Ativos', value: '147')),
            SizedBox(width: 280, child: InfoCard(title: 'Riscos Críticos', value: '12')),
            SizedBox(width: 280, child: InfoCard(title: 'Entidades Relacionadas', value: '356')),
          ],
        ),
      ],
    );
  }
}
