// File: lib/screens/dre_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'core/utils/formatters.dart';
import 'core/services/export_service.dart';
import 'database/banco/lancamentos_database_helper.dart';
import 'database/banco/bancos_database_helper.dart';
import 'database/banco/contas_a_pagar_database_helper.dart';
import 'database/banco/investimentos_database_helper.dart';
import 'database/models/lancamentos.dart';
import 'database/models/bancos.dart';
import 'database/models/contas_a_pagar.dart';
import 'database/models/investimentos.dart';

class DREScreen extends StatefulWidget {
  const DREScreen({super.key});

  @override
  State<DREScreen> createState() => _DREScreenState();
}

class _DREScreenState extends State<DREScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _chartTabController;
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();
  bool _isLoading = false;
  
  List<Lancamento> _lancamentos = [];
  List<Bancos> _bancos = [];
  List<ContasAPagar> _contasAPagar = [];
  List<Investimento> _investimentos = [];
  
  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  double _saldoLiquido = 0.0;
  double _totalInvestimentos = 0.0;
  double _totalContasAPagar = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chartTabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartTabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final lancamentosHelper = LancamentoDatabaseHelper();
      final bancosHelper = BancosDatabaseHelper();
      final contasHelper = ContasAPagarDatabaseHelper();
      final investimentosHelper = InvestimentoDatabaseHelper();

      _lancamentos = await lancamentosHelper.consultaLancamentos();
      _bancos = await bancosHelper.getBancos();
      _contasAPagar = await contasHelper.getContas();
      _investimentos = await investimentosHelper.getInvestimentos();

      _calculateTotals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateTotals() {
    final lancamentosFiltrados = _lancamentos.where((l) => 
      l.data.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
      l.data.isBefore(_selectedEndDate.add(const Duration(days: 1)))
    ).toList();

    _totalReceitas = lancamentosFiltrados
        .where((l) => l.entrada)
        .fold(0.0, (sum, l) => sum + l.valor);
    
    _totalDespesas = lancamentosFiltrados
        .where((l) => !l.entrada)
        .fold(0.0, (sum, l) => sum + l.valor);
    
    _saldoLiquido = _totalReceitas - _totalDespesas;
    
    _totalInvestimentos = _investimentos.fold(0.0, (sum, i) => sum + i.valor);
    _totalContasAPagar = _contasAPagar
        .where((c) => !c.quitado)
        .fold(0.0, (sum, c) => sum + c.valorDaConta);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _calculateTotals();
    }
  }

  Future<void> _exportData(String format) async {
    try {
      setState(() => _isLoading = true);
      
      final hasPermission = await ExportService.requestPermissions();
      if (!hasPermission) {
        throw Exception('Permissão de armazenamento negada');
      }

      String filePath;
      if (format == 'excel') {
        filePath = await ExportService.exportToExcel(
          lancamentos: _lancamentos,
          bancos: _bancos,
          contasAPagar: _contasAPagar,
          investimentos: _investimentos,
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
        );
      } else {
        filePath = await ExportService.exportToPDF(
          lancamentos: _lancamentos,
          bancos: _bancos,
          contasAPagar: _contasAPagar,
          investimentos: _investimentos,
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
        );
      }

      await ExportService.shareFile(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório exportado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRE - Demonstrativo de Resultados'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _exportData,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Exportar Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Exportar PDF'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildDateRangeSelector(),
                  _buildSummaryCards(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChartTab(),
                        _buildDetailsTab(),
                        _buildAnalysisTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Período de Análise',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Selecionar período',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _buildDateChip('Início', _selectedStartDate),
              const Icon(Icons.arrow_forward, size: 16),
              _buildDateChip('Fim', _selectedEndDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, DateTime date) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$label: ${Formatters.formatDate(date)}',
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Receitas', _totalReceitas, Colors.green, Icons.trending_up)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Despesas', _totalDespesas, Colors.red, Icons.trending_down)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Saldo Líquido', _saldoLiquido, _saldoLiquido >= 0 ? Colors.blue : Colors.orange, Icons.account_balance)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Investimentos', _totalInvestimentos, Colors.purple, Icons.area_chart)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatCurrency(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _chartTabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Barras'),
              Tab(text: 'Pizza'),
              Tab(text: 'Linha'),
              Tab(text: 'Radar'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _chartTabController,
            children: [
              _buildBarChart(),
              _buildPieChart(),
              _buildLineChart(),
              _buildRadarChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_totalReceitas + _totalDespesas) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String title = '';
                      switch (group.x) {
                        case 0:
                          title = 'Receitas';
                          break;
                        case 1:
                          title = 'Despesas';
                          break;
                        case 2:
                          title = 'Saldo';
                          break;
                      }
                      return BarTooltipItem(
                        '$title\n${Formatters.formatCurrency(rod.toY)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Receitas', style: TextStyle(fontSize: 12));
                          case 1:
                            return const Text('Despesas', style: TextStyle(fontSize: 12));
                          case 2:
                            return const Text('Saldo', style: TextStyle(fontSize: 12));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          Formatters.formatCurrency(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _totalReceitas,
                        color: Colors.green,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _totalDespesas,
                        color: Colors.red,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _saldoLiquido.abs(),
                        color: _saldoLiquido >= 0 ? Colors.blue : Colors.orange,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final receitas = _lancamentos.where((l) => l.entrada).length;
    final despesas = _lancamentos.where((l) => !l.entrada).length;
    final total = receitas + despesas;

    if (total == 0) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: receitas.toDouble(),
                    title: '${((receitas / total) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: despesas.toDouble(),
                    title: '${((despesas / total) * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Receitas', Colors.green, receitas),
              _buildLegendItem('Despesas', Colors.red, despesas),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label ($count)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLineChart() {
    final lancamentosFiltrados = _lancamentos.where((l) => 
      l.data.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
      l.data.isBefore(_selectedEndDate.add(const Duration(days: 1)))
    ).toList();

    final receitasPorDia = <DateTime, double>{};
    final despesasPorDia = <DateTime, double>{};

    for (final lancamento in lancamentosFiltrados) {
      final data = DateTime(lancamento.data.year, lancamento.data.month, lancamento.data.day);
      if (lancamento.entrada) {
        receitasPorDia[data] = (receitasPorDia[data] ?? 0) + lancamento.valor;
      } else {
        despesasPorDia[data] = (despesasPorDia[data] ?? 0) + lancamento.valor;
      }
    }

    final todasDatas = {...receitasPorDia.keys, ...despesasPorDia.keys}.toList()..sort();

    if (todasDatas.isEmpty) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < todasDatas.length) {
                    return Text(
                      '${todasDatas[value.toInt()].day}/${todasDatas[value.toInt()].month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    Formatters.formatCurrency(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: todasDatas.asMap().entries.map((entry) {
                final data = entry.value;
                final valor = receitasPorDia[data] ?? 0;
                return FlSpot(entry.key.toDouble(), valor);
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
            LineChartBarData(
              spots: todasDatas.asMap().entries.map((entry) {
                final data = entry.value;
                final valor = despesasPorDia[data] ?? 0;
                return FlSpot(entry.key.toDouble(), valor);
              }).toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final lancamentosFiltrados = _lancamentos.where((l) => 
      l.data.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
      l.data.isBefore(_selectedEndDate.add(const Duration(days: 1)))
    ).toList();

    final categorias = <String, double>{};
    for (final lancamento in lancamentosFiltrados) {
      categorias[lancamento.categoria] = (categorias[lancamento.categoria] ?? 0) + lancamento.valor;
    }

    final topCategorias = categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topCategorias.isEmpty) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    final maxValor = topCategorias.first.value;
    final categoriasLimitadas = topCategorias.take(6).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries: categoriasLimitadas.map((entry) {
                return RadarEntry(value: entry.value / maxValor);
              }).toList(),
              fillColor: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              borderWidth: 2,
            ),
          ],
          titleTextStyle: const TextStyle(fontSize: 10),
          getTitle: (index, angle) {
            if (index < categoriasLimitadas.length) {
              return RadarChartTitle(
                text: categoriasLimitadas[index].key,
                angle: angle,
              );
            }
            return const RadarChartTitle(text: '');
          },
                                titlePositionPercentageOffset: 0.2,
           radarTouchData: RadarTouchData(enabled: true),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final lancamentosFiltrados = _lancamentos.where((l) => 
      l.data.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
      l.data.isBefore(_selectedEndDate.add(const Duration(days: 1)))
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Lançamentos do Período'),
        const SizedBox(height: 12),
        ...lancamentosFiltrados.map((l) => _buildLancamentoCard(l)),
        const SizedBox(height: 24),
        _buildSectionTitle('Contas a Pagar'),
        const SizedBox(height: 12),
        ..._contasAPagar.where((c) => !c.quitado).map((c) => _buildContaCard(c)),
        const SizedBox(height: 24),
        _buildSectionTitle('Investimentos Ativos'),
        const SizedBox(height: 12),
        ..._investimentos.map((i) => _buildInvestimentoCard(i)),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    final lancamentosFiltrados = _lancamentos.where((l) => 
      l.data.isAfter(_selectedStartDate.subtract(const Duration(days: 1))) &&
      l.data.isBefore(_selectedEndDate.add(const Duration(days: 1)))
    ).toList();

    final totalLancamentos = lancamentosFiltrados.length;
    final mediaReceitas = totalLancamentos > 0 ? _totalReceitas / totalLancamentos : 0.0;
    final mediaDespesas = totalLancamentos > 0 ? _totalDespesas / totalLancamentos : 0.0;
    final percentualReceitas = _totalReceitas > 0 ? (_totalReceitas / (_totalReceitas + _totalDespesas)) * 100 : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnalysisCard(
          'Total de Lançamentos',
          totalLancamentos.toString(),
          Icons.list_alt,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Média de Receitas',
          Formatters.formatCurrency(mediaReceitas),
          Icons.trending_up,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Média de Despesas',
          Formatters.formatCurrency(mediaDespesas),
          Icons.trending_down,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          '% de Receitas',
          '${percentualReceitas.toStringAsFixed(1)}%',
          Icons.pie_chart,
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Contas Pendentes',
          _contasAPagar.where((c) => !c.quitado).length.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Investimentos Ativos',
          _investimentos.length.toString(),
          Icons.area_chart,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildLancamentoCard(Lancamento lancamento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lancamento.entrada ? Colors.green : Colors.red,
          child: Icon(
            lancamento.entrada ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          lancamento.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${lancamento.categoria} • ${Formatters.formatDate(lancamento.data)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          Formatters.formatCurrency(lancamento.valor),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lancamento.entrada ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildContaCard(ContasAPagar conta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.pending_actions, color: Colors.white),
        ),
        title: Text(
          conta.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${conta.tipoDeConta} • Início: ${Formatters.formatDate(conta.dataInicio)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          Formatters.formatCurrency(conta.valorDaConta),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildInvestimentoCard(Investimento investimento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.trending_up, color: Colors.white),
        ),
        title: Text(
          investimento.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${investimento.descricao ?? 'Sem descrição'} • ${Formatters.formatDate(investimento.data)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.formatCurrency(investimento.valor),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ativo',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
