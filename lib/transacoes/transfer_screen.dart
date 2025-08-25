import 'package:flutter/material.dart';
import '../../database/banco/bancos_database_helper.dart'; // Ajuste o caminho conforme necessário
import '../../database/models/bancos.dart'; // Ajuste o caminho conforme necessário
import '../../database/banco/lancamentos_database_helper.dart';
import '../../database/models/lancamentos.dart';
import '../desing_funcoes/function.dart'; // Para `corrigeVirgula` e `valorReal`
import '../desing_funcoes/caixatexto.dart'; // Para `caixaTextoOnChanged`

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final BancosDatabaseHelper _bancosHelper = BancosDatabaseHelper();
  final LancamentoDatabaseHelper _lancamentosHelper = LancamentoDatabaseHelper();

  int? _selectedOriginAccountId;
  int? _selectedDestinationAccountId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Bancos> _availableBancos = [];
  bool _isLoadingBancos = true;

  @override
  void initState() {
    super.initState();
    _loadBancos();
  }

  Future<void> _loadBancos() async {
    setState(() {
      _isLoadingBancos = true;
    });
    try {
      final bancos = await _bancosHelper.getBancos();
      setState(() {
        _availableBancos = bancos;
        // Opcional: pré-selecionar as primeiras contas se houverem
        if (_availableBancos.isNotEmpty) {
          _selectedOriginAccountId = _availableBancos.first.id;
          if (_availableBancos.length > 1) {
            _selectedDestinationAccountId = _availableBancos[1].id;
          } else {
            _selectedDestinationAccountId = null; // Se só houver uma conta, não há destino possível
          }
        } else {
          _selectedOriginAccountId = null;
          _selectedDestinationAccountId = null;
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

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedOriginAccountId == null || _selectedDestinationAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione as contas de origem e destino.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedOriginAccountId == _selectedDestinationAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As contas de origem e destino não podem ser as mesmas.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final double transferAmount = double.parse(corrigeVirgula(_amountController.text));

    try {
      final double originBalance = await _bancosHelper.getValorDoBancoPorId(_selectedOriginAccountId!);

      if (originBalance < transferAmount) {
        final bool? continuar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Saldo insuficiente'),
            content: Text(
              'O saldo da conta de origem é de R\$${originBalance.toStringAsFixed(2)}, '
              'mas o valor da transferência é R\$${transferAmount.toStringAsFixed(2)}.\n\n'
              'Deseja continuar mesmo assim (saldo ficará negativo)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
        if (continuar == false) {
          return;
        }
      }

      await _bancosHelper.subtrairValorPorId(_selectedOriginAccountId!, double.parse(corrigeVirgula(_amountController.text)),);
      await _bancosHelper.somarValorPorId(_selectedDestinationAccountId!, double.parse(corrigeVirgula(_amountController.text)),);

      await _lancamentosHelper.insertLancamento(
        Lancamento(
          entrada: false,
          nome: 'Transferência para ${_bancosHelper.getValorDoBancoPorId(_selectedDestinationAccountId!)}',
          categoria: 'Transferência Saída',
          valor: double.parse(corrigeVirgula(_amountController.text)),
          descricao: _descriptionController.text.isNotEmpty
    ? maiusculo(_descriptionController.text)
    : 'Transferência entre contas ${_bancosHelper.getNomeBancoPorId(_selectedOriginAccountId!)} e ${_bancosHelper.getNomeBancoPorId(_selectedDestinationAccountId!)}',
          data: DateTime.now(),
          idbanco: _selectedOriginAccountId!,
        ),
      );

      // Lçamento Entrada
      await _lancamentosHelper.insertLancamento(
        Lancamento(
          entrada: true,
          nome: 'Transferência de ${_bancosHelper.getValorDoBancoPorId(_selectedOriginAccountId!)}',
          categoria: 'Transferência Entrada',
          valor: double.parse(corrigeVirgula(_amountController.text)),
          descricao: _descriptionController.text.isNotEmpty
    ? maiusculo(_descriptionController.text)
    : 'Transferência entre contas ${_bancosHelper.getNomeBancoPorId(_selectedOriginAccountId!)} e ${_bancosHelper.getNomeBancoPorId(_selectedDestinationAccountId!)}',
          data: DateTime.now(),
          idbanco: _selectedDestinationAccountId!,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transferência realizada com sucesso!')),
        );
        Navigator.pop(context, true); // Retorna e indica sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao realizar transferência: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao realizar transferência: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transferir Dinheiro',
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
              Text(
                'Mova dinheiro entre suas contas para manter o controle financeiro!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Campo de Conta de Origem
              _buildAccountDropdown(
                label: 'Conta de Origem',
                value: _selectedOriginAccountId,
                onChanged: (value) {
                  setState(() {
                    _selectedOriginAccountId = value;
                  });
                },
                errorMessage: 'Selecione a conta de origem.',
              ),
              const SizedBox(height: 16),

              // Ícone de Seta para Baixo (ou para o lado, indicando a direção)
              const Center(
                child: Icon(
                  Icons.arrow_downward,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Conta de Destino
              _buildAccountDropdown(
                label: 'Conta de Destino',
                value: _selectedDestinationAccountId,
                onChanged: (value) {
                  setState(() {
                    _selectedDestinationAccountId = value;
                  });
                },
                errorMessage: 'Selecione a conta de destino.',
              ),
              const SizedBox(height: 24),

              // Campo de Valor
              caixaTextoOnChanged(
                true,
                context,
                _amountController,
                TextInputType.number,
                20,
                'Valor da Transferência',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira o valor da transferência.';
                  }
                  if (double.tryParse(corrigeVirgula(value)) == null ||
                      double.parse(corrigeVirgula(value)) <= 0) {
                    return 'Insira um valor numérico válido maior que zero.';
                  }
                  return null;
                },
                onChanged: (value) {
                  _amountController.text = valorReal(_amountController.text);
                },
              ),
              const SizedBox(height: 16),

              // Campo de Descrição (Opcional)
              caixaTexto(
                true,
                context,
                _descriptionController,
                TextInputType.multiline,
                100,
                'Descrição (Ex: "Transferência para poupança")',
              ),
              const SizedBox(height: 30),

              // Botão de Transferir
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitTransfer,
                  icon: const Icon(Icons.send),
                  label: const Text('Confirmar Transferência', style: TextStyle(fontSize: 18)),
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

  Widget _buildAccountDropdown({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
    required String errorMessage,
  }) {
    return _isLoadingBancos
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
                      Text(
                        'Nenhuma conta disponível para $label.',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Adicione contas em "Minhas Contas" para realizar transferências.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 13),
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
                    decoration: InputDecoration(
                      labelText: label,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    value: value,
                    items: _availableBancos.map((banco) {
                      return DropdownMenuItem<int>(
                        value: banco.id,
                        child: Text(banco.banco),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    validator: (val) => val == null ? errorMessage : null,
                  ),
                ),
              );
  }
}