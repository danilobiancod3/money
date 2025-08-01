import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/models/lancamentos.dart';
// Note: 'home.dart' import was removed as it's not directly used in this screen's logic
// and might cause circular dependencies if not handled carefully.
// If you need to navigate to HomeScreen, ensure it's imported where needed.
// import '../home.dart'; // Assumindo que home.dart existe no diretório pai

import '../../database/banco/contas_a_pagar_database_helper.dart';
import '../../database/models/contas_a_pagar.dart';
import '../../database/banco/categorias_database_helper.dart';
import '../../database/models/categorias.dart';
import '../../database/banco/bancos_database_helper.dart';
import '../../database/models/bancos.dart';
import '../../database/banco/lancamentos_database_helper.dart'; // Para lançar a transação

// Assumindo que estas funções estão em desing_funcoes/function.dart
// Você precisará garantir que elas existam e estejam acessíveis.
String corrigeVirgula(String text) {
  return text.replaceAll(',', '.');
}

String maiusculo(String text) {
  if (text.isEmpty) return text;
  return text.toUpperCase();
}

String valorReal(String text) {
  if (text.isEmpty) return '0,00';
  String cleanedText = text.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '');

  if (cleanedText.isEmpty) return '0,00';

  double value = double.parse(cleanedText) / 100;
  return NumberFormat.currency(locale: 'pt_BR', symbol: '').format(value);
}

// Assumindo que estas funções estão em desing_funcoes/caixatexto.dart
// Você precisará garantir que elas existam e estejam acessíveis.
Widget caixaTexto(
  bool enabled,
  BuildContext context,
  TextEditingController controller,
  TextInputType keyboardType,
  int maxLength,
  String label, {
  String? Function(String?)? validator,
}) {
  return TextFormField(
    enabled: enabled,
    controller: controller,
    keyboardType: keyboardType,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    validator: validator,
  );
}

Widget caixaTextoOnChanged(
  bool enabled,
  BuildContext context,
  TextEditingController controller,
  TextInputType keyboardType,
  int maxLength,
  String label, {
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    enabled: enabled,
    controller: controller,
    keyboardType: keyboardType,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    validator: validator,
    onChanged: onChanged,
  );
}


class AddContasAPagarScreen extends StatefulWidget {
  const AddContasAPagarScreen({super.key});

  @override
  State<AddContasAPagarScreen> createState() => _AddContasAPagarScreenState();
}

class _AddContasAPagarScreenState extends State<AddContasAPagarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorContaController = TextEditingController();
  final _valorPagoController = TextEditingController(text: '0,00'); // Valor inicial como 0,00

  final _parcelasController = TextEditingController(text: '1');
  final _frequenciaController = TextEditingController(text: '30');

  DateTime _dataInicio = DateTime.now();
  DateTime? _dataTermino;
  DateTime? _dataPrimeiraParcela;
  String _icone = 'receipt_long'; // Ícone padrão

  bool _quitado = false;
  bool _oculto = false;
  bool _shouldRecordInitialPayment = false; // Novo switch para registro de pagamento inicial

  int? _selectedTipoContaId; // ID da categoria de conta selecionada
  List<Categorias> _availableTiposDeConta = [];
  bool _isLoadingTiposDeConta = true;

  int? _selectedBankForPaymentId; // ID do banco para o pagamento inicial
  List<Bancos> _availableBancosForPayment = [];
  bool _isLoadingBancosForPayment = true;

  final CategoriasDatabaseHelper _categoriaHelper = CategoriasDatabaseHelper();
  final BancosDatabaseHelper _bancosHelper = BancosDatabaseHelper();
  final LancamentoDatabaseHelper _lancamentosHelper = LancamentoDatabaseHelper(); // Para lançar a transação

  @override
  void initState() {
    super.initState();
    _loadTiposDeConta();
    _loadBancosForPayment();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorContaController.dispose();
    _valorPagoController.dispose();
    _parcelasController.dispose();
    _frequenciaController.dispose();
    super.dispose();
  }

  // Carrega as categorias com tipo 'contas'
  Future<void> _loadTiposDeConta() async {
    setState(() {
      _isLoadingTiposDeConta = true;
      _selectedTipoContaId = null;
    });
    try {
      final tiposDeConta = await _categoriaHelper.getCategoriasPorTipo('contas'); // Busca categorias do tipo 'contas'
      setState(() {
        _availableTiposDeConta = tiposDeConta;
        if (_availableTiposDeConta.isNotEmpty) {
          _selectedTipoContaId = _availableTiposDeConta.first.id;
        } else {
          _selectedTipoContaId = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar tipos de conta. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao carregar tipos de conta: $e');
    } finally {
      setState(() {
        _isLoadingTiposDeConta = false;
      });
    }
  }

  // Carrega os bancos disponíveis para o pagamento inicial
  Future<void> _loadBancosForPayment() async {
    setState(() {
      _isLoadingBancosForPayment = true;
      _selectedBankForPaymentId = null;
    });
    try {
      final bancos = await _bancosHelper.getBancos();
      setState(() {
        _availableBancosForPayment = bancos;
        if (_availableBancosForPayment.isNotEmpty) {
          _selectedBankForPaymentId = _availableBancosForPayment.first.id;
        } else {
          _selectedBankForPaymentId = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar bancos. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao carregar bancos: $e');
    } finally {
      setState(() {
        _isLoadingBancosForPayment = false;
      });
    }
  }

  Future<void> _salvarConta() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();

    final parsedValorDaConta = double.tryParse(corrigeVirgula(_valorContaController.text)) ?? 0.0;
    final parsedValorPago = double.tryParse(corrigeVirgula(_valorPagoController.text)) ?? 0.0;
    final parsedParcelas = int.tryParse(_parcelasController.text) ?? 1;
    final parsedFrequencia = int.tryParse(_frequenciaController.text) ?? 30;

    // Garante que um tipo de conta foi selecionado
    if (_selectedTipoContaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um tipo de conta.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validação para pagamento inicial
    if (_shouldRecordInitialPayment) {
      if (_selectedBankForPaymentId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione o banco para o pagamento inicial.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      if (parsedValorPago <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('O valor pago inicial deve ser maior que zero.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    final tipoContaNome = _availableTiposDeConta
        .firstWhere((cat) => cat.id == _selectedTipoContaId)
        .categoria;

    final conta = ContasAPagar(
      nome: maiusculo(_nomeController.text),
      tipoDeConta: maiusculo(tipoContaNome),
      valorDaConta: parsedValorDaConta,
      valorPago: parsedValorPago,
      dataInicio: _dataInicio,
      dataTermino: _dataTermino,
      parcelas: parsedParcelas,
      frequenciaEmDias: parsedFrequencia,
      dataPrimeiraParcela: _dataPrimeiraParcela,
      icone: _icone,
      quitado: _quitado || (parsedValorPago >= parsedValorDaConta), // Se já foi pago o total, marca como quitada
      oculto: _oculto,
    );

    try {
      final newContaId = await ContasAPagarDatabaseHelper().insertConta(conta);

      // Se o pagamento inicial deve ser registrado, cria um lançamento de saída
      if (_shouldRecordInitialPayment && parsedValorPago > 0 && _selectedBankForPaymentId != null) {
        // Subtrai o valor do banco
        await _bancosHelper.subtrairValorPorId(_selectedBankForPaymentId!, parsedValorPago);

        // Cria o lançamento
        final lancamento = Lancamento(
          entrada: false, // É uma saída (pagamento de conta)
          nome: 'Pagamento Inicial: ${maiusculo(_nomeController.text)}',
          categoria: 'Contas a Pagar', // Pode ser uma categoria genérica para pagamentos de contas
          valor: parsedValorPago,
          descricao: 'Pagamento inicial para a conta ${maiusculo(_nomeController.text)}',
          data: DateTime.now(), // Data do lançamento é a data atual
          idbanco: _selectedBankForPaymentId!,
        );
        await _lancamentosHelper.insertLancamento(lancamento);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta a pagar salva com sucesso!')),
        );
        // Remove a necessidade de importar 'home.dart' aqui se o pop for o suficiente
        Navigator.pop(context, true); // Retorna para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar conta a pagar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao salvar conta a pagar: $e');
    }
  }

  // Função para abrir o seletor de data
  Future<void> _pickDate(Function(DateTime?) onDateSelected, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Conta a Pagar'),
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
              // Indicador de conta quitada
              if (_quitado)
                Card(
                  color: Colors.green.shade100,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'CONTA QUITADA!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

              // Campo Nome
              caixaTexto(
                true,
                context,
                _nomeController,
                TextInputType.text,
                50,
                'Nome da Conta (Ex: Aluguel, Carro)',
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome da conta.' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown para Tipo de Conta (Categoria)
              _isLoadingTiposDeConta
                  ? const Center(child: CircularProgressIndicator())
                  : _availableTiposDeConta.isEmpty
                      ? Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.orange.shade50,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Nenhum tipo de conta disponível.',
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Crie categorias do tipo "contas" para classificar suas contas a pagar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.orange, fontSize: 13),
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
                                labelText: 'Tipo de Conta',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              value: _selectedTipoContaId,
                              items: _availableTiposDeConta.map((categoria) {
                                return DropdownMenuItem<int>(
                                  value: categoria.id,
                                  child: Text(categoria.categoria),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTipoContaId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecione um tipo de conta.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
              const SizedBox(height: 16),

              // Campo Valor da Conta
              caixaTextoOnChanged(
                true,
                context,
                _valorContaController,
                TextInputType.number,
                20,
                'Valor Total da Conta (Ex: 1200,50)',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor da conta.';
                  if (double.tryParse(corrigeVirgula(v)) == null) return 'Valor inválido.';
                  return null;
                },
                onChanged: (String) {
                  _valorContaController.text = valorReal(_valorContaController.text);
                },
              ),
              const SizedBox(height: 16),

              // Campo Parcelas
              caixaTexto(
                true,
                context,
                _parcelasController,
                TextInputType.number,
                5,
                'Número de Parcelas',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o número de parcelas.';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Parcelas inválidas.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Frequência em Dias
              caixaTexto(
                true,
                context,
                _frequenciaController,
                TextInputType.number,
                5,
                'Frequência de Pagamento (dias)',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a frequência.';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Frequência inválida.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seleção de Data de Início
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('Data de Início'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate((picked) {
                    if (picked != null) setState(() => _dataInicio = picked);
                  }, _dataInicio),
                ),
              ),
              const SizedBox(height: 16),

              // Seleção de Data de Término (Opcional)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('Data de Término (Opcional)'),
                  subtitle: Text(_dataTermino == null
                      ? 'Não definida'
                      : DateFormat('dd/MM/yyyy').format(_dataTermino!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate((picked) {
                    setState(() => _dataTermino = picked);
                  }, _dataTermino),
                ),
              ),
              const SizedBox(height: 16),

              // Seleção de Data da Primeira Parcela (Opcional)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('Data da Primeira Parcela (Opcional)'),
                  subtitle: Text(_dataPrimeiraParcela == null
                      ? 'Não definida'
                      : DateFormat('dd/MM/yyyy').format(_dataPrimeiraParcela!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate((picked) {
                    setState(() => _dataPrimeiraParcela = picked);
                  }, _dataPrimeiraParcela),
                ),
              ),
              const SizedBox(height: 16),

              // Switch para Quitada
              SwitchListTile(
                title: const Text('Conta Quitada'),
                value: _quitado,
                onChanged: (v) => setState(() => _quitado = v),
              ),
              // Switch para Oculto
              SwitchListTile(
                title: const Text('Ocultar Conta'),
                value: _oculto,
                onChanged: (v) => setState(() => _oculto = v),
              ),
              const SizedBox(height: 16),

              // Novo Switch para Registrar Pagamento Inicial
              SwitchListTile(
                title: const Text('Registrar Pagamento Inicial'),
                value: _shouldRecordInitialPayment,
                onChanged: (v) {
                  setState(() {
                    _shouldRecordInitialPayment = v;
                    if (!v) {
                      _valorPagoController.text = '0,00'; // Zera o valor pago se desativar
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campos de Valor Pago e Banco (condicional)
              if (_shouldRecordInitialPayment) ...[
                caixaTextoOnChanged(
                  true,
                  context,
                  _valorPagoController,
                  TextInputType.number,
                  20,
                  'Valor Pago Inicial (Ex: 500,00)',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o valor pago.';
                    if (double.tryParse(corrigeVirgula(v)) == null) return 'Valor inválido.';
                    return null;
                  },
                  onChanged: (String) {
                    _valorPagoController.text = valorReal(_valorPagoController.text);
                  },
                ),
                const SizedBox(height: 16),
                _isLoadingBancosForPayment
                    ? const Center(child: CircularProgressIndicator())
                    : _availableBancosForPayment.isEmpty
                        ? Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.red.shade50,
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Nenhum banco disponível para registrar o pagamento.',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
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
                                  labelText: 'Banco (Pagamento Inicial)',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                value: _selectedBankForPaymentId,
                                items: _availableBancosForPayment.map((banco) {
                                  return DropdownMenuItem<int>(
                                    value: banco.id,
                                    child: Text(banco.banco),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBankForPaymentId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione um banco para o pagamento.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                const SizedBox(height: 16),
              ],

              // Botão Salvar
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _salvarConta,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Conta a Pagar', style: TextStyle(fontSize: 18)),
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
            ],
          ),
        ),
      ),
    );
  }
}
