import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../desing_funcoes/function.dart';
import '../database/banco/investimentos_database_helper.dart';
import '../database/models/investimentos.dart';
import '../database/banco/bancos_database_helper.dart';
import '../database/models/bancos.dart';
import '../accounts/accountsscreen.dart';
import '../desing_funcoes/caixatexto.dart';

class AddInvestmentScreen extends StatefulWidget {

  const AddInvestmentScreen({super.key, this.investimentoParaEditar});
  final Investimento? investimentoParaEditar;

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final InvestimentoDatabaseHelper _investHelper = InvestimentoDatabaseHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BancosDatabaseHelper _bancosHelper = BancosDatabaseHelper();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  DateTime _data = DateTime.now();
  DateTime? _dataFim;
  bool _recorrente = false;
  String? _recorrencia;
  bool _oculto = false;

  int? _selectedIdBancoOrigem;
  int? _selectedIdContaDestino;
  List<Bancos> _availableBancos = [];
  bool _isLoadingBancos = true;
  bool _isSubmitting = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static const double _maxInvestmentValue = 999999999.99;
  static const int _maxNameLength = 100;
  static const int _maxDescriptionLength = 500;

  @override
  void initState() {
    super.initState();
    _loadBancos();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.investimentoParaEditar != null) {
      final inv = widget.investimentoParaEditar!;
      _nomeController.text = inv.nome;
      _valorController.text = _formatValueForDisplay(inv.valor);
      _descricaoController.text = inv.descricao ?? '';
      _data = inv.data;
      _dataFim = inv.dataFim;
      _recorrente = inv.recorrente;
      _recorrencia = inv.recorrencia;
      _oculto = inv.oculto;
      _selectedIdBancoOrigem = inv.idBanco;
      _selectedIdContaDestino = inv.idconta;
    }
  }

  String _formatValueForDisplay(double valor) {
    if (valor <= 0) return '';
    return NumberFormat('#,##0.00', 'pt_BR').format(valor);
  }

  Future<void> _loadBancos() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingBancos = true;
    });

    try {
      final bancos = await _bancosHelper.getBancos();
      
      if (!mounted) return;
      
      setState(() {
        _availableBancos = bancos;
        if (widget.investimentoParaEditar == null && bancos.isNotEmpty) {
          _selectedIdBancoOrigem ??= bancos.first.id;
          _selectedIdContaDestino ??= bancos.first.id;
        }
        
        if (widget.investimentoParaEditar != null) {
          if (_selectedIdBancoOrigem != null && 
              !bancos.any((b) => b.id == _selectedIdBancoOrigem)) {
            _selectedIdBancoOrigem = null;
          }
          if (_selectedIdContaDestino != null && 
              !bancos.any((b) => b.id == _selectedIdContaDestino)) {
            _selectedIdContaDestino = null;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro ao carregar bancos/contas disponíveis.');
      }
      debugPrint('Erro ao carregar bancos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBancos = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String? _validateInvestmentValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O valor é obrigatório.';
    }

    final cleanValue = corrigeVirgula(value.trim());
    final numericValue = double.tryParse(cleanValue);
    
    if (numericValue == null) {
      return 'Por favor, insira um valor numérico válido.';
    }
    
    if (numericValue <= 0) {
      return 'O valor deve ser maior que zero.';
    }
    
    if (numericValue > _maxInvestmentValue) {
      return 'O valor máximo permitido é R\$ ${_formatValueForDisplay(_maxInvestmentValue)}.';
    }
    
    return null;
  }

  String? _validateInvestmentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome do investimento é obrigatório.';
    }
    
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }
    
    if (value.trim().length > _maxNameLength) {
      return 'O nome deve ter no máximo $_maxNameLength caracteres.';
    }
    
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.trim().length > _maxDescriptionLength) {
      return 'A descrição deve ter no máximo $_maxDescriptionLength caracteres.';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final cleanValue = corrigeVirgula(_valorController.text.trim());
      final valor = double.tryParse(cleanValue) ?? 0.0;

      if (valor <= 0) {
        _showErrorSnackBar('Valor inválido para o investimento.');
        return;
      }

      if (_selectedIdBancoOrigem == null || _selectedIdContaDestino == null) {
        _showErrorSnackBar('Selecione os bancos de origem e destino.');
        return;
      }

      if (_recorrente && (_recorrencia == null || _recorrencia!.isEmpty)) {
        _showErrorSnackBar('Selecione a frequência da recorrência.');
        return;
      }

      final invest = Investimento(
        id: widget.investimentoParaEditar?.id,
        nome: maiusculo(_nomeController.text.trim()),
        valor: valor,
        data: _data,
        dataFim: _dataFim,
        descricao: _descricaoController.text.trim().isEmpty 
            ? null 
            : maiusculo(_descricaoController.text.trim()),
        idBanco: _selectedIdBancoOrigem!,
        idconta: _selectedIdContaDestino!,
        recorrente: _recorrente,
        recorrencia: _recorrencia,
        oculto: _oculto,
      );

      if (widget.investimentoParaEditar == null) {
        await _investHelper.insertInvestimento(invest);
        if (mounted) {
          _showSuccessSnackBar('Investimento salvo com sucesso!');
        }
      } else {
        await _investHelper.updateInvestimento(invest);
        if (mounted) {
          _showSuccessSnackBar('Investimento atualizado com sucesso!');
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro ao salvar investimento. Tente novamente.');
      }
      debugPrint('Erro ao salvar investimento: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _data : (_dataFim ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _data = picked;
          if (_dataFim != null && _data.isAfter(_dataFim!)) {
            _dataFim = null;
          }
        } else {
          if (picked.isBefore(_data)) {
            _showErrorSnackBar('A data final deve ser posterior à data inicial.');
            return;
          }
          _dataFim = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.investimentoParaEditar == null 
              ? 'Novo Investimento' 
              : 'Editar Investimento'
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Ocultar do Saldo Total'),
                subtitle: const Text(
                  'Este investimento não será incluído no cálculo do seu saldo geral.'
                ),
                value: _oculto,
                onChanged: (val) => setState(() => _oculto = val),
                secondary: const Icon(Icons.visibility_off),
              ),

              const Divider(height: 30),

              caixaTexto(
                true,
                context,
                _nomeController,
                TextInputType.text,
                _maxNameLength,
                'Nome do Investimento',
                validator: _validateInvestmentName,
              ),
              const SizedBox(height: 16),

              caixaTextoOnChanged(
                true,
                context,
                _valorController,
                TextInputType.number,
                0,
                'Valor Investido',
                validator: _validateInvestmentValue,
                onChanged: (value) {
                  _valorController.text = valorReal(_valorController.text);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                ],
              ),
              const SizedBox(height: 16),

              _buildBankDropdown(
                label: 'De qual Banco saiu (Origem)',
                hintText: 'Selecione o banco de onde o valor saiu',
                selectedId: _selectedIdBancoOrigem,
                onChanged: (value) => setState(() => _selectedIdBancoOrigem = value),
                validatorMessage: 'Selecione o banco de origem.',
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: 16),

              _buildBankDropdown(
                label: 'Para qual Banco/Conta foi (Destino)',
                hintText: 'Selecione a conta/banco de destino do investimento',
                selectedId: _selectedIdContaDestino,
                onChanged: (value) => setState(() => _selectedIdContaDestino = value),
                validatorMessage: 'Selecione a conta/banco de destino.',
                prefixIcon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),

              caixaTexto(
                true,
                context,
                _descricaoController,
                TextInputType.text,
                _maxDescriptionLength,
                'Observações (opcional)',
                validator: _validateDescription,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text('Data de Início: ${_dateFormat.format(_data)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
                leading: const Icon(Icons.event_note),
                contentPadding: EdgeInsets.zero,
              ),
              
              ListTile(
                title: Text(
                  'Data Final: ${_dataFim != null ? _dateFormat.format(_dataFim!) : 'Não definida'}'
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.redAccent),
                  onPressed: _dataFim == null 
                      ? null 
                      : () => setState(() => _dataFim = null),
                  tooltip: 'Limpar Data Final',
                ),
                onTap: () => _pickDate(context, false),
                leading: const Icon(Icons.event_busy),
                contentPadding: EdgeInsets.zero,
              ),
              
              SwitchListTile(
                title: const Text('Investimento Recorrente?'),
                value: _recorrente,
                onChanged: (val) => setState(() {
                  _recorrente = val;
                  if (!val) {
                    _recorrencia = null;
                  }
                }),
                secondary: const Icon(Icons.repeat),
              ),
              
              if (_recorrente)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Frequência da Recorrência',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                      DropdownMenuItem(value: 'Trimestral', child: Text('Trimestral')),
                      DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                    ],
                    onChanged: (value) => setState(() => _recorrencia = value),
                    value: _recorrencia,
                    validator: (value) => value == null ? 'Selecione uma frequência.' : null,
                  ),
                ),
              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(widget.investimentoParaEditar == null 
                          ? Icons.save 
                          : Icons.update),
                  label: Text(
                    _isSubmitting 
                        ? 'Salvando...'
                        : (widget.investimentoParaEditar == null 
                            ? 'Salvar Investimento' 
                            : 'Atualizar Investimento'),
                    style: const TextStyle(fontSize: 18),
                  ),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDropdown({
    required String label,
    required String hintText,
    required int? selectedId,
    required ValueChanged<int?> onChanged,
    required String validatorMessage,
    required IconData prefixIcon,
  }) {
    if (_isLoadingBancos) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_availableBancos.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                'Nenhuma conta disponível para "$label".',
                style: const TextStyle(
                  color: Colors.red, 
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Por favor, adicione contas em "Minhas Contas" para selecionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                label: const Text(
                  'Adicionar Conta', 
                  style: TextStyle(color: Colors.red)
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsScreen(),
                    ),
                  );
                  _loadBancos();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(prefixIcon),
          ),
          value: selectedId,
          items: _availableBancos.map((banco) {
            return DropdownMenuItem<int>(
              value: banco.id,
              child: Text(
                banco.banco,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return validatorMessage;
            }
            return null;
          },
        ),
      ),
    );
  }
}
