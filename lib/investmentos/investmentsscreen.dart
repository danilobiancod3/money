import 'package:flutter/material.dart';
import '../database/banco/investimentos_database_helper.dart';
import '../database/models/investimentos.dart';
import 'addInvestment.dart'; // Make sure AddInvestmentScreen can handle editing
import '../../desing_funcoes/function.dart'; // For 'brl' and 'data' functions

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  late Future<List<Investimento>> _investimentosFuture;
  final InvestimentoDatabaseHelper _investimentoDatabaseHelper = InvestimentoDatabaseHelper();
  double _totalInvestedValue = 0.0; // Variable to hold the total investment value

  @override
  void initState() {
    super.initState();
    _loadInvestmentsAndTotal();
  }

  // Load investments and calculate total value
  void _loadInvestmentsAndTotal() {
    setState(() {
      _investimentosFuture = _investimentoDatabaseHelper.getInvestimentos().then((list) {
        // Calculate total invested value from the fetched list
        _totalInvestedValue = list.fold(0.0, (sum, inv) => sum + inv.valor);
        return list;
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar investimentos: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _totalInvestedValue = 0.0; // Reset total on error
        return <Investimento>[]; // Return empty list on error
      });
    });
  }

  // Navigate to add/edit investment screen
  void _navigateToAddEditInvestmentScreen({Investimento? investimentoParaEditar}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddInvestmentScreen(),
      ),
    );
    if (result == true) {
      _loadInvestmentsAndTotal(); // Reload list and total after add/edit
    }
  }

  // Confirmation for deletion
  void _confirmDelete(Investimento investimento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o investimento "${investimento.nome}"? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  await _investimentoDatabaseHelper.deleteInvestimento(investimento.id!);
                  _loadInvestmentsAndTotal(); // Reload list and total
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Investimento "${investimento.nome}" excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir investimento: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Investimentos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // Height for total value
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valor Total Investido:',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  brl(_totalInvestedValue), // Display the total invested value
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Investimento>>(
        future: _investimentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Ops! Não foi possível carregar seus investimentos.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detalhes: ${snapshot.error}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadInvestmentsAndTotal,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.show_chart, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhum investimento cadastrado!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Adicione seus investimentos para acompanhar seu portfólio.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddEditInvestmentScreen(),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Novo Investimento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final investimentos = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: investimentos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inv = investimentos[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Editar Investimento'),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _navigateToAddEditInvestmentScreen(investimentoParaEditar: inv);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever, color: Colors.red),
                                title: const Text('Excluir Investimento', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _confirmDelete(inv);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.trending_up, color: Colors.green, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inv.nome,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          brl(inv.valor),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditInvestmentScreen(),
        label: const Text('Adicionar Investimento', style: TextStyle(fontSize: 16)),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}