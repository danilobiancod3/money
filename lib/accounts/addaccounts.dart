import 'package:flutter/material.dart';
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
  bool _oculto = false;

  final Map<String, IconData> _iconOptions = {
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
    'wallet': Icons.wallet, // Added a new icon option
    'attach_money': Icons.attach_money, // Another new icon option
  };

  @override
  void dispose() {
    _bancoController.dispose();
    _tipoController.dispose();
    _valorController.dispose();
    _iconeController.dispose();
    super.dispose();
  }

  void _salvarBanco() async {
    if (_formKey.currentState!.validate()) {
      final banco = Bancos(
        banco: _bancoController.text.trim(),
        tipodeconta: _tipoController.text.trim(),
        valornaconta: double.tryParse(_valorController.text.trim()) ?? 0.0,
        icone: _iconeController.text,
        oculto: _oculto,
      );
      await bancosHelper.insertBanco(banco);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banco salvo com sucesso!')),
        );
        Navigator.pop(context); // Go back after saving
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            child: Icon(
              iconData,
              size: 30,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            const Icon(Icons.check_circle, size: 20, color: Colors.green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Banco'),
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
                'Escolha um Ícone para o Banco:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90, // Adjust height to fit icons and text
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _iconOptions.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildIconOption(entry.key, entry.value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              caixaTexto(
                true,
                context,
                _bancoController,
                TextInputType.text,
                0,
                'Nome do Banco',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do banco.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              caixaTexto(
                true,
                context,
                _tipoController,
                TextInputType.text,
                0,
                'Tipo de Conta (ex: Corrente, Poupança)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tipo de conta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              caixaTexto(
                true,
                context,
                _valorController,
                TextInputType.number,
                0,
                'Valor Inicial na Conta',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor inicial.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Ocultar Banco da Visão Geral'),
                subtitle: const Text('Se ativado, este banco não aparecerá na lista principal.'),
                value: _oculto,
                onChanged: (value) => setState(() => _oculto = value),
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _salvarBanco,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Salvar Banco',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}