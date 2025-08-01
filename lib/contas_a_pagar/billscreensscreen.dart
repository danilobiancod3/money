import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/banco/contas_a_pagar_database_helper.dart';
import '../database/models/contas_a_pagar.dart';
import 'addbillscreen.dart'; // Importe a tela AddContasAPagarScreen
import '../desing_funcoes/function.dart'; // Importe para formatação de moeda (assumindo que existe)

class ContasAPagarScreen extends StatefulWidget {
  const ContasAPagarScreen({super.key});

  @override
  State<ContasAPagarScreen> createState() => _ContasAPagarScreenState();
}

class _ContasAPagarScreenState extends State<ContasAPagarScreen> {
  late Future<List<ContasAPagar>> _contasFuture;
  double _totalADever = 0.0;
  final ContasAPagarDatabaseHelper _dbHelper = ContasAPagarDatabaseHelper();

  // Mapeamento de tipos de conta para ícones
  final Map<String, IconData> _tipoContaIcones = {
    'Boleto': Icons.receipt_long,
    'Cartão de Crédito': Icons.credit_card,
    'Financiamento': Icons.house,
    'Aluguel': Icons.home,
    'Serviço': Icons.handyman,
    'Outros': Icons.category,
    // Adicione mais mapeamentos conforme as categorias que você usa
  };

  @override
  void initState() {
    super.initState();
    _loadContas(); // Carrega as contas ao iniciar a tela
  }

  // Carrega as contas do banco de dados e calcula o total a dever
  void _loadContas() {
    setState(() {
      _contasFuture = _dbHelper.getContas().then((list) {
        // Filtra apenas as contas que não estão quitadas para calcular o total a dever
        final naoQuitadas = list.where((c) => !c.quitado).toList();
        _totalADever =
            naoQuitadas.fold(0.0, (s, c) => s + c.valorDaConta - c.valorPago); // Considera valorPago
        return list;
      }).catchError((error) {
        // Exibe um Snackbar em caso de erro ao carregar as contas
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar contas: $error'), backgroundColor: Colors.red),
          );
        }
        return <ContasAPagar>[]; // Retorna uma lista vazia em caso de erro
      });
    });
  }

  // Navega para a tela de adicionar/editar conta
  // Se 'conta' for fornecido, a tela será aberta para edição.
  void _navigateToAddEditConta({ContasAPagar? conta}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddContasAPagarScreen()),
    );
    // Se a tela de adicionar/editar retornar 'true', recarrega as contas
    if (result == true) _loadContas();
  }

  // Confirmação de exclusão de uma conta
  void _confirmDelete(ContasAPagar conta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Text('Tem certeza que deseja excluir "${conta.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o AlertDialog
              await _dbHelper.deleteConta(conta.id!); // Exclui a conta do banco de dados
              _loadContas(); // Recarrega a lista de contas
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Conta "${conta.nome}" excluída.')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Alterna o status 'quitado' de uma conta
  void _toggleQuitado(ContasAPagar conta) async {
    // Cria uma cópia da conta com o status 'quitado' invertido
    final updated = conta.copyWith(
      quitado: !conta.quitado,
      // Se está marcando como quitado, define valorPago como valorDaConta e parcelasPagas como parcelas totais
      valorPago: !conta.quitado ? conta.valorDaConta : 0.0,
      //parcelasPagas: !conta.quitado ? conta.parcelas : 0, // Define parcelasPagas
    );
    await _dbHelper.updateConta(updated); // Atualiza a conta no banco de dados
    _loadContas(); // Recarrega a lista de contas
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              conta.quitado ? 'Conta "${conta.nome}" marcada como PENDENTE.' : 'Conta "${conta.nome}" marcada como PAGA.'),
          backgroundColor: conta.quitado ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total a Dever:',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalADever),
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
      body: FutureBuilder<List<ContasAPagar>>(
        future: _contasFuture,
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
                      'Ops! Não foi possível carregar suas contas.',
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
                      onPressed: _loadContas,
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
                    const Icon(Icons.money_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhuma conta a pagar cadastrada!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Adicione suas despesas para manter o controle.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddEditConta(),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Nova Conta'),
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

          final contas = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conta = contas[index];
              final isQuitado = conta.quitado;
              final Color cardColor = isQuitado ? Colors.green.shade50 : Colors.red.shade50;
              final Color iconColor = isQuitado ? Colors.green.shade700 : Theme.of(context).primaryColor;
              final Color textColor = isQuitado ? Colors.green.shade900 : Colors.black87;
              final double valorRestante = conta.valorDaConta - conta.valorPago;

              return Dismissible(
                key: Key(conta.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    _confirmDelete(conta);
                    return false; // Não remove o item imediatamente, espera a confirmação
                  }
                  return true;
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: cardColor,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Editar Conta'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _navigateToAddEditConta(conta: conta); // Passa a conta para edição
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  isQuitado ? Icons.undo : Icons.check,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(isQuitado ? 'Marcar como Pendente' : 'Marcar como Pago'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _toggleQuitado(conta); // Alterna o status de quitado
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever, color: Colors.red),
                                title: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(context);
                                  _confirmDelete(conta); // Confirma e exclui
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _tipoContaIcones[conta.tipoDeConta] ?? Icons.category,
                              size: 32,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conta.nome,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        decoration: isQuitado ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Subtitle: Tipo e parcelas/data de início
                                Text(
                                  'Tipo: ${conta.tipoDeConta}'
                                  '${conta.dataPrimeiraParcela != null ? ' | Início: ${DateFormat('dd/MM/yyyy').format(conta.dataPrimeiraParcela!)}' : ''}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Always show remaining value if not quitado, otherwise total value
                                Text(
                                  isQuitado
                                      ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(conta.valorDaConta)
                                      : NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valorRestante),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isQuitado ? Colors.green.shade900 : Colors.red.shade900, // Color based on status
                                      ),
                                ),
                                if (isQuitado)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                else if (valorRestante > 0)
                                  Text(
                                    'Pendente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditConta(), // Chama sem 'conta' para adicionar nova
        label: const Text('Adicionar Conta', style: TextStyle(fontSize: 16)),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}