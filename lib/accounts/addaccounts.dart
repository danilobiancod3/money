import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../desing_funcoes/caixatexto.dart';
import '../../database/banco/bancos_database_helper.dart';
import '../../database/models/bancos.dart';

class AddBancoScreen extends StatefulWidget {
  const AddBancoScreen({super.key, Bancos? bancoParaEditar});

  @override
  State<AddBancoScreen> createState() => _AddBancoScreenState();
}

class _AddBancoScreenState extends State<AddBancoScreen> {
  final bancosHelper = BancosDatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bancoController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _iconeController = TextEditingController();
  final TextEditingController _agenciaController = TextEditingController();
  final TextEditingController _contaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _oculto = false;
  bool _isLoading = false;

  final Map<String, IconData> _iconOptions = {
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
    'wallet': Icons.wallet,
    'attach_money': Icons.attach_money,
    'account_circle': Icons.account_circle,
    'business': Icons.business,
    'account_balance_wallet': Icons.account_balance_wallet,
    'payment': Icons.payment,
    'monetization_on': Icons.monetization_on,
  };

  final List<String> _bancosPopulares = [
    'Banco do Brasil',
    'Caixa Econômica Federal',
    'Itaú',
    'Bradesco',
    'Santander',
    'Nubank',
    'Inter',
    'C6 Bank',
    'PagSeguro',
    'Mercado Pago',
    'Outro'
  ];

  final List<String> _tiposConta = [
    'Conta Corrente',
    'Conta Poupança',
    'Conta Salário',
    'Conta Universitária',
    'Conta Digital',
    'Carteira Digital',
    'Outro'
  ];

  @override
  void dispose() {
    _bancoController.dispose();
    _tipoController.dispose();
    _valorController.dispose();
    _iconeController.dispose();
    _agenciaController.dispose();
    _contaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _formatarValor(String valor) {
    if (valor.isEmpty) return '';
    
    final valorLimpo = valor.replaceAll(RegExp(r'[^\d]'), '');
    if (valorLimpo.isEmpty) return '';
    
    final numero = double.parse(valorLimpo) / 100;
    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _salvarBanco() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final valorLimpo = _valorController.text
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.')
          .trim();

      final banco = Bancos(
        banco: _bancoController.text.trim(),
        tipodeconta: _tipoController.text.trim(),
        valornaconta: double.tryParse(valorLimpo) ?? 0.0,
        icone: _iconeController.text.isNotEmpty ? _iconeController.text : 'account_balance',
        oculto: _oculto,
        agencia: _agenciaController.text.trim().isNotEmpty ? _agenciaController.text.trim() : null,
        numeroConta: _contaController.text.trim().isNotEmpty ? _contaController.text.trim() : null,
        descricao: _descricaoController.text.trim().isNotEmpty ? _descricaoController.text.trim() : null,
      );

      await bancosHelper.insertBanco(banco);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conta salva com sucesso!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar conta: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildIconOption(String iconName, IconData iconData) {
    final isSelected = _iconeController.text == iconName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _iconeController.text = iconName;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 28,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              iconName.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ActionChip(
        label: Text(text),
        onPressed: onTap,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Conta'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ícone da Conta',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _iconOptions.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: _buildIconOption(entry.key, entry.value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações da Conta',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            caixaTexto(
                              true,
                              context,
                              _bancoController,
                              TextInputType.text,
                              50,
                              'Nome do Banco',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nome do banco é obrigatório';
                                }
                                if (value.trim().length < 2) {
                                  return 'Nome deve ter pelo menos 2 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            Wrap(
                              children: _bancosPopulares.map((banco) => 
                                _buildSuggestionChip(banco, () {
                                  setState(() {
                                    _bancoController.text = banco;
                                  });
                                })
                              ).toList(),
                            ),
                            const SizedBox(height: 16),
                            
                            caixaTexto(
                              true,
                              context,
                              _tipoController,
                              TextInputType.text,
                              30,
                              'Tipo de Conta',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tipo de conta é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            Wrap(
                              children: _tiposConta.map((tipo) => 
                                _buildSuggestionChip(tipo, () {
                                  setState(() {
                                    _tipoController.text = tipo;
                                  });
                                })
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações Adicionais',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            caixaTexto(
                              true,
                              context,
                              _agenciaController,
                              TextInputType.number,
                              10,
                              'Agência (opcional)',
                            ),
                            const SizedBox(height: 12),
                            
                            caixaTexto(
                              true,
                              context,
                              _contaController,
                              TextInputType.number,
                              15,
                              'Número da Conta (opcional)',
                            ),
                            const SizedBox(height: 12),
                            
                            caixaTexto(
                              true,
                              context,
                              _descricaoController,
                              TextInputType.text,
                              100,
                              'Descrição (opcional)',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Inicial',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            caixaTextoOnChanged(
                              true,
                              context,
                              _valorController,
                              TextInputType.number,
                              0,
                              'R\$ 0,00',
                              onChanged: (value) {
                                final formatted = _formatarValor(value);
                                if (formatted != value) {
                                  _valorController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Saldo inicial é obrigatório';
                                }
                                final valorLimpo = value
                                    .replaceAll('R\$', '')
                                    .replaceAll(' ', '')
                                    .replaceAll(',', '.')
                                    .trim();
                                if (double.tryParse(valorLimpo) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: const Text('Ocultar da Visão Geral'),
                        subtitle: const Text('Esta conta não aparecerá na tela principal'),
                        value: _oculto,
                        onChanged: (value) => setState(() => _oculto = value),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _salvarBanco,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isLoading ? 'Salvando...' : 'Salvar Conta',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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