// File: lib/screens/dre_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DREScreen extends StatelessWidget {
  const DREScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('DRE - Resultado do Período'),
        title: const Text('DRE - ainda não está pronto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Mensal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                          return Text(months[value.toInt() % months.length]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5000, color: Colors.green)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3200, color: Colors.red)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4500, color: Colors.green)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3100, color: Colors.red)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6000, color: Colors.green)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 4000, color: Colors.red)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Saldo Líquido: R\$ 2.000,00',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Text(
              'Receitas: R\$ 15.500,00',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Despesas: R\$ 13.500,00',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
