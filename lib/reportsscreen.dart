// File: lib/screens/reports_screen.dart

import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios e Exportações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('Exportar DRE em PDF'),
            subtitle: const Text('Resumo financeiro mensal'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em Breve!')),
              );
              // lógica para exportar PDF da DRE
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Exportar Lançamentos'),
            subtitle: const Text('Exportar entradas e saídas em CSV ou Excel'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em Breve!')),
              );
              // lógica para exportar lançamentos
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.orange),
            title: const Text('Alertas e Notificações'),
            subtitle: const Text('Gerenciar lembretes de contas a pagar'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em Breve!')),
              );
              // lógica para configurar notificações
            },
          ),
        ],
      ),
    );
  }
}