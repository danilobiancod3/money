import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home.dart';
import '../desing_funcoes/function.dart';
import '../desing_funcoes/caixatexto.dart';
import '../../database/banco/lancamentos_database_helper.dart';
import '../../database/models/lancamentos.dart';
import '../../database/banco/categorias_database_helper.dart';
import '../../database/models/categorias.dart';
import '../../database/banco/contas_a_pagar_database_helper.dart';
import '../../database/models/contas_a_pagar.dart';
import '../../database/banco/bancos_database_helper.dart';
import '../../database/models/bancos.dart';
import 'transfer_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final LancamentoDatabaseHelper _lancamentosHelper = LancamentoDatabaseHelper();
  final CategoriasDatabaseHelper _categoriaHelper = CategoriasDatabaseHelper();
  final ContasAPagarDatabaseHelper _contasHelper = ContasAPagarDatabaseHelper();
  final BancosDatabaseHelper _bancosHelper = BancosDatabaseHelper();

  bool _isIncome = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  int? _selectedCategoriaId;
  int? _selectedAccountId;

  List<Categorias> _availableCategorias = [];
  List<Bancos> _availableBancos = [];

  bool _isLoadingCategorias = true;
  bool _isLoadingBancos = true;

  static const int _contaPagarIdOffset = 1000000;

  @override
  void initState() {
    super.initState();
    _loadBancos();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    setState(() {
      _isLoadingCategorias = true;
      _selectedCategoriaId = null;
    });

    try {
      final List<Categorias> categoriasTipo = await _categoriaHelper.getCategoriasPorTipo(_isIncome ? 'entrada' : 'saida');
      final List<Categorias> categoriasList = List<Categorias>.from(categoriasTipo);

      final categoriasTodos = await _categoriaHelper.getCategoriasPorTipo('todos');
      categoriasList.addAll(categoriasTodos);

      if (!_isIncome) {
        final contasEmAberto = await _contasHelper.getContasEmAberto();
        for (var conta in contasEmAberto) {
          categoriasList.add(Categorias(
            id: conta.id! + _contaPagarIdOffset,
            categoria: 'Pagar: ${conta.nome}',
            tipo: 'saida',
          ));
        }
      }

      setState(() {
        _availableCategorias = categoriasList;
        if (_availableCategorias.isNotEmpty) {
          if (_selectedCategoriaId == null ||
              !_availableCategorias.any((cat) => cat.id == _selectedCategoriaId)) {
            _selectedCategoriaId = _availableCategorias.first.id;
          }
        } else {
          _selectedCategoriaId = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar categorias. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao carregar categorias: $e');
    } finally {
      setState(() {
        _isLoadingCategorias = false;
      });
    }
  }

  Future<void> _loadBancos() async {
    setState(() {
      _isLoadingBancos = true;
      _selectedAccountId = null;
    });
    try {
      final bancos = await _bancosHelper.getBancos();
      setState(() {
        _availableBancos = bancos;
        if (_availableBancos.isNotEmpty) {
          if (_selectedAccountId == null ||
              !_availableBancos.any((banco) => banco.id == _selectedAccountId)) {
            _selectedAccountId = _availableBancos.first.id;
          }
        } else {
          _selectedAccountId = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar contas. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao carregar bancos: $e');
    } finally {
      setState(() {
        _isLoadingBancos = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedAccountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma conta.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final double valorDigitado = double.parse(corrigeVirgula(_amountController.text));

    if (!_isIncome) {
      await _validacao(valorDigitado);
    } else {
      await _bancosHelper.somarValorPorId(
        _selectedAccountId!,
        valorDigitado,
      );
      await _submitFormInterno(valorDigitado);
    }
  }

  Future<void> _validacao(final double valorDigitado) async {
    final double saldo = await _bancosHelper.getValorDoBancoPorId(_selectedAccountId!);

    if (saldo >= valorDigitado) {
      await _bancosHelper.subtrairValorPorId(_selectedAccountId!, valorDigitado);
      await _submitFormInterno(valorDigitado);
    } else {
      final bool? continuar = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Saldo insuficiente'),
          content: Text(
                'O saldo da conta selecionada é de R\$${saldo.toStringAsFixed(2)}, '
                'mas o valor digitado é R\$${valorDigitado.toStringAsFixed(2)}.\n\n'
                'Deseja lançar mesmo assim?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Lançar mesmo assim'),
                ),
              ],
            ),
          );

      final bool prosseguir = continuar ?? false;

      if (prosseguir) {
        await _bancosHelper.subtrairValorPorId(_selectedAccountId!, valorDigitado);
        await _submitFormInterno(valorDigitado);
      }
    }
  }

  Future<void> _submitFormInterno(double valorDigitado) async {
    if (_selectedCategoriaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma categoria.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final int categoriaIdSelecionada = _selectedCategoriaId!;
    String categoriaNomeParaLancamento;
    bool isContaPaga = false;

    if (categoriaIdSelecionada >= _contaPagarIdOffset) {
      final originalContaId = categoriaIdSelecionada - _contaPagarIdOffset;
      final ContasAPagar? contaApagar = await _contasHelper.getContaPorId(originalContaId);

      if (contaApagar != null) {
        categoriaNomeParaLancamento = 'Pagamento: ${contaApagar.nome}';
        isContaPaga = true;

        contaApagar.valorPago = contaApagar.valorPago + valorDigitado;

        if (contaApagar.valorPago >= contaApagar.valorDaConta) {
          contaApagar.quitado = true;
        } else {
          contaApagar.quitado = false;
        }

        await _contasHelper.updateConta(contaApagar);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                contaApagar.quitado
                    ? 'Conta "${contaApagar.nome}" marcada como paga!'
                    : 'Pagamento de R\$${valorDigitado.toStringAsFixed(2)} adicionado à conta "${contaApagar.nome}".',
              ),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      } else {
        categoriaNomeParaLancamento = _availableCategorias
            .firstWhere((cat) => cat.id == categoriaIdSelecionada)
            .categoria;
      }
    } else {
      categoriaNomeParaLancamento = _availableCategorias
          .firstWhere((cat) => cat.id == categoriaIdSelecionada)
          .categoria;
    }

    final lancamento = Lancamento(
      entrada: _isIncome,
      nome: maiusculo(_nameController.text),
      categoria: maiusculo(categoriaNomeParaLancamento),
      valor: valorDigitado,
      descricao: maiusculo(_descriptionController.text),
      data: _selectedDate,
      idbanco: _selectedAccountId!,
    );

    try {
      await _lancamentosHelper.insertLancamento(lancamento);
      if (mounted) {
        if (!isContaPaga) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lançamento salvo com sucesso!')),
          );
        }
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar lançamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao salvar lançamento: $e');
    }
  }

  Future<void> _pickDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale('pt', 'BR'),
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).cardColor,
                onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Lançamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: SwitchListTile(
                    title: Text(
                      _isIncome ? 'Receita' : 'Despesa',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_isIncome ? 'Dinheiro entrando' : 'Dinheiro saindo'),
                    value: _isIncome,
                    onChanged: (bool value) {
                      setState(() {
                        _isIncome = value;
                        _selectedCategoriaId = null;
                      });
                      _loadCategorias();
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              caixaTextoOnChanged(
                true,
                context,
                _nameController,
                TextInputType.text,
                50,
                'Nome do Lançamento (Ex: Salário, Aluguel)',
                onChanged: (value) {},
                validator: (value) => value == null || value.isEmpty 
                    ? 'Insira um nome para o lançamento.' 
                    : null,
              ),
              const SizedBox(height: 16),

              _isLoadingCategorias
                  ? const Center(child: CircularProgressIndicator())
                  : _availableCategorias.isEmpty
                      ? Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Nenhuma categoria de ${_isIncome ? 'entrada' : 'saída'} disponível.',
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  'Crie categorias em "Categorias" para classificar seus lançamentos.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.orange, fontSize: 13),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                                  label: const Text('Adicionar Categoria', style: TextStyle(color: Colors.orange)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Funcionalidade de adicionar categoria ainda não implementada.'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Categoria/Despesas',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              value: _selectedCategoriaId,
                              items: _availableCategorias.map((categoria) {
                                return DropdownMenuItem<int>(
                                  value: categoria.id,
                                  child: Text(categoria.categoria),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoriaId = value;
                                });
                              },
                              validator: (value) => value == null 
                                  ? 'Selecione uma categoria para o lançamento.' 
                                  : null,
                            ),
                          ),
                        ),
              const SizedBox(height: 16),

              caixaTextoOnChanged(
                true,
                context,
                _amountController,
                TextInputType.number,
                20,
                'Valor (Ex: 1500,50)',
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira o valor.';
                  }
                  if (double.tryParse(corrigeVirgula(value)) == null) {
                    return 'Insira um valor numérico válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              caixaTextoOnChanged(
                false,
                context,
                _descriptionController,
                TextInputType.text,
                100,
                'Descrição (Opcional)',
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data do Lançamento'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),

              _isLoadingBancos
                  ? const Center(child: CircularProgressIndicator())
                  : _availableBancos.isEmpty
                      ? Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Nenhuma conta disponível.',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  'Crie contas em "Contas" para gerenciar seus lançamentos.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontSize: 13),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                                  label: const Text('Adicionar Conta', style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomeScreen(index: 1),
                                      ),
                                    );
                                    _loadBancos();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Conta',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              value: _selectedAccountId,
                              items: _availableBancos.map((banco) {
                                return DropdownMenuItem<int>(
                                  value: banco.id,
                                  child: Text(banco.banco),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAccountId = value;
                                });
                              },
                              validator: (value) => value == null 
                                  ? 'Selecione uma conta para o lançamento.' 
                                  : null,
                            ),
                          ),
                        ),
              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Salvar Lançamento', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransferScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Transferir entre Contas', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}