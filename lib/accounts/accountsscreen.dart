import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe para formatação de moeda
import '../desing_funcoes/function.dart'; // Assumindo 'brl' está aqui
import '../database/banco/bancos_database_helper.dart';
import '../database/models/bancos.dart';
import 'addaccounts.dart'; // Importe AddBancoScreen

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late Future<List<Bancos>> _bancosFuture;
  double _totalVisibleBalance = 0.0; // Variável para o saldo total das contas visíveis
  final BancosDatabaseHelper _bancosDatabaseHelper = BancosDatabaseHelper(); // Instância do helper

  // Mapa para mapear nomes de ícones para IconData.
  final Map<String, IconData> _iconMap = {
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
    'account_balance': Icons.account_balance,
    'wallet': Icons.wallet,
    'attach_money': Icons.attach_money,
    'payments': Icons.payments,
    'monetization_on': Icons.monetization_on,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'money_off': Icons.money_off,
    'business': Icons.business,
  };

  @override
  void initState() {
    super.initState();
    _loadBancosAndBalance(); // Inicia o carregamento das contas e do saldo
  }

  // Carrega os bancos e o saldo total visível
  void _loadBancosAndBalance() {
    setState(() {
      _bancosFuture = _bancosDatabaseHelper.getBancos().then((list) {
        // Filtra as contas que não estão ocultas
        final filteredList = list.where((b) => !b.oculto).toList();
        return filteredList;
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar contas: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return <Bancos>[]; // Retorna uma lista vazia em caso de erro
      });

      // Carrega o saldo total visível separadamente para não depender do FutureBuilder da lista
      _bancosDatabaseHelper.somarValoresVisiveis().then((total) {
        if (mounted) {
          setState(() {
            _totalVisibleBalance = total;
          });
        }
      }).catchError((error) {
        debugPrint('Erro ao somar valores visíveis: $error');
        if (mounted) {
          setState(() {
            _totalVisibleBalance = 0.0; // Zera o saldo em caso de erro
          });
        }
      });
    });
  }

  // Obtém o IconData correspondente ao nome do ícone
  IconData _getIconData(String? iconName) {
    if (iconName == null || !_iconMap.containsKey(iconName)) {
      return Icons.account_balance_wallet; // Ícone padrão
    }
    return _iconMap[iconName]!;
  }

  // Navega para a tela de adicionar/editar banco
  void _navigateToAddEditBancoScreen({Bancos? bancoParaEditar}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBancoScreen(bancoParaEditar: bancoParaEditar),
      ),
    );
    if (result == true) {
      _loadBancosAndBalance(); // Recarrega a lista e o saldo
    }
  }

  // Confirmação de exclusão
  void _confirmDelete(Bancos banco) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a conta "${banco.banco}"? Esta ação é irreversível.'),
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
                  await _bancosDatabaseHelper.deleteBanco(banco.id!);
                  _loadBancosAndBalance(); // Recarrega a lista e o saldo
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conta "${banco.banco}" excluída com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir conta: $e')),
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
        title: const Text('Minhas Contas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // Altura para o saldo total
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo Total:',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  brl(_totalVisibleBalance), // Exibe o saldo total visível
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
      body: FutureBuilder<List<Bancos>>(
        future: _bancosFuture,
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
                      onPressed: _loadBancosAndBalance, // Tentar recarregar
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
                    const Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhuma conta cadastrada!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Adicione sua primeira conta bancária ou carteira para gerenciar suas finanças.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddEditBancoScreen(),
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

          final bancos = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bancos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final banco = bancos[index];
              final iconData = _getIconData(banco.icone);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Editar Conta'),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _navigateToAddEditBancoScreen(bancoParaEditar: banco);
                                },
                              ),
                              ListTile(
                                leading: Icon(banco.oculto ? Icons.visibility : Icons.visibility_off),
                                title: Text(banco.oculto ? 'Reexibir Conta' : 'Ocultar Conta'),
                                onTap: () async {
                                  Navigator.pop(bc);
                                  final updatedBanco = banco.copyWith(oculto: !banco.oculto);
                                  await _bancosDatabaseHelper.updateBanco(updatedBanco); // Use a instância
                                  _loadBancosAndBalance(); // Recarrega a lista e o saldo
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${banco.banco} ${banco.oculto ? 'reexibida' : 'ocultada'} com sucesso!')),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever, color: Colors.red),
                                title: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _confirmDelete(banco);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            iconData,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banco.banco,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banco.tipodeconta,
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
                          child: Text(
                            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(banco.valornaconta),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: banco.valornaconta >= 0 ? Colors.green[700] : Colors.red[700],
                                ),
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
        onPressed: () => _navigateToAddEditBancoScreen(),
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