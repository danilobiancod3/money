import 'package:flutter/material.dart';
import '../database/banco/lancamentos_database_helper.dart';
import '/database/models/lancamentos.dart';
import 'AddTransaction.dart'; // Assumindo que esta tela permite adicionar/editar
import '../desing_funcoes/function.dart'; // Para as funções 'brl' e 'data'

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<Lancamento>> _lancamentosFuture;
  final LancamentoDatabaseHelper _lancamentoDatabaseHelper = LancamentoDatabaseHelper(); // Instância do helper

  @override
  void initState() {
    super.initState();
    _loadLancamentos();
  }

  // Carrega os lançamentos do banco de dados
  void _loadLancamentos() {
    setState(() {
      _lancamentosFuture = _lancamentoDatabaseHelper.consultaLancamentos().catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar lançamentos: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return <Lancamento>[]; // Retorna lista vazia em caso de erro
      });
    });
  }

  // Navega para a tela de adicionar/editar lançamento
  void _navigateToAddEditTransactionScreen({Lancamento? lancamentoParaEditar}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    if (result == true) {
      _loadLancamentos(); // Recarrega a lista após adição/edição
    }
  }

  // Confirmação de exclusão
  void _confirmDelete(Lancamento lancamento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o lançamento "${lancamento.nome}"? Esta ação é irreversível.'),
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
                Navigator.of(context).pop(); // Fecha o diálogo
                try {
                  await _lancamentoDatabaseHelper.deleteLancamento(lancamento.id!);
                  _loadLancamentos(); // Recarrega a lista
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lançamento "${lancamento.nome}" excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir lançamento: $e')),
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
        title: const Text('Lançamentos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Lancamento>>(
        future: _lancamentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Mais detalhado para o usuário
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Ops! Não foi possível carregar seus lançamentos.',
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
                      onPressed: _loadLancamentos,
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
                    const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhum lançamento encontrado.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Adicione seu primeiro lançamento para começar a gerenciar suas transações.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddEditTransactionScreen(),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Novo Lançamento'),
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

          final lancamentos = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lancamentos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lanc = lancamentos[index];
              final icone = lanc.entrada ? Icons.arrow_upward : Icons.arrow_downward;
              final cor = lanc.entrada ? Colors.green : Colors.red;
              final valorFormatado = (lanc.entrada ? '+' : '') + brl(lanc.valor); // Ajuste para o '+' em entradas

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias, // Para garantir que o InkWell respeite a borda
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
                                title: const Text('Editar Lançamento'),
                                onTap: () {
                                  Navigator.pop(bc); // Fecha o bottom sheet
                                  _navigateToAddEditTransactionScreen(lancamentoParaEditar: lanc);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever, color: Colors.red),
                                title: const Text('Excluir Lançamento', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(bc); // Fecha o bottom sheet
                                  _confirmDelete(lanc);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding( // Adicionado Padding para o conteúdo do ListTile
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icone, color: cor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lanc.nome,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data(lanc.data.toString())} • ${lanc.categoria}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              if (lanc.descricao != '' && lanc.descricao.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    lanc.descricao,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[700],
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          valorFormatado,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cor,
                                fontWeight: FontWeight.bold,
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
        onPressed: () => _navigateToAddEditTransactionScreen(),
        label: const Text('Novo Lançamento', style: TextStyle(fontSize: 16)),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}