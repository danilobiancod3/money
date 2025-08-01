import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de moeda e data
import '../desing_funcoes/function.dart'; // Assumindo corrigeVirgula, maiusculo, valorReal estão aqui
import '../database/banco/investimentos_database_helper.dart';
import '../database/models/investimentos.dart';
import '../../database/banco/bancos_database_helper.dart'; // Import para buscar bancos/contas
import '../../database/models/bancos.dart'; // Modelo de Bancos/Contas
import '../accounts/accountsscreen.dart'; // Para navegar para AccountsScreen
import '../desing_funcoes/caixatexto.dart'; // Import do seu widget caixaTexto

class AddInvestmentScreen extends StatefulWidget {
  final Investimento? investimentoParaEditar; // Parâmetro opcional para edição

  const AddInvestmentScreen({super.key, this.investimentoParaEditar});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final investHelper = InvestimentoDatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final BancosDatabaseHelper _bancosHelper = BancosDatabaseHelper(); // Instância do helper de bancos

  // Controladores para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  // Variáveis de estado para os dados do investimento
  DateTime _data = DateTime.now();
  DateTime? _dataFim;
  bool _recorrente = false;
  String? _recorrencia;
  bool _oculto = false;

  // Variáveis de estado para os IDs dos bancos/contas selecionados nos dropdowns
  int? _selectedIdBancoOrigem;
  int? _selectedIdContaDestino;
  List<Bancos> _availableBancos = []; // Lista de bancos/contas para os dropdowns
  bool _isLoadingBancos = true; // Para mostrar estado de carregamento dos bancos

  // Formatador de data
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadBancos(); // Carrega os bancos/contas para os dropdowns
    _initializeFields(); // Inicializa os campos com dados de edição, se houver
  }

  // Inicializa os campos do formulário com os dados do investimento para edição
  void _initializeFields() {
    if (widget.investimentoParaEditar != null) {
      final inv = widget.investimentoParaEditar!;
      _nomeController.text = inv.nome;
      _valorController.text = _formatValueForDisplay(inv.valor); // Formata valor para exibição
      _descricaoController.text = inv.descricao ?? '';
      _data = inv.data;
      _dataFim = inv.dataFim;
      _recorrente = inv.recorrente;
      _recorrencia = inv.recorrencia;
      _oculto = inv.oculto;
      _selectedIdBancoOrigem = inv.idBanco; // Pre-seleciona o banco de origem
      _selectedIdContaDestino = inv.idconta; // Pre-seleciona a conta de destino
    }
  }

  // Helper para formatar o valor monetário para exibição no campo de texto
  String _formatValueForDisplay(double valor) {
    return NumberFormat('#,##0.00', 'pt_BR').format(valor);
  }

  // Carrega a lista de bancos do banco de dados para os dropdowns
  void _loadBancos() async {
    setState(() {
      _isLoadingBancos = true; // Ativa o indicador de carregamento
    });
    try {
      final bancos = await _bancosHelper.getBancos();
      setState(() {
        _availableBancos = bancos;
        // Se for um novo investimento e houver bancos, pré-seleciona o primeiro,
        // mas apenas se ainda não houver uma seleção (para o caso de edição)
        if (widget.investimentoParaEditar == null) {
          if (_availableBancos.isNotEmpty && _selectedIdBancoOrigem == null) {
            _selectedIdBancoOrigem = _availableBancos.first.id;
          }
          if (_availableBancos.isNotEmpty && _selectedIdContaDestino == null) {
            _selectedIdContaDestino = _availableBancos.first.id;
          }
        }
        // Valida se os IDs pré-selecionados (para edição) ainda existem na lista de bancos
        if (widget.investimentoParaEditar != null) {
          if (_selectedIdBancoOrigem != null && !_availableBancos.any((b) => b.id == _selectedIdBancoOrigem)) {
            _selectedIdBancoOrigem = null; // Limpa a seleção se o banco não existir mais
          }
          if (_selectedIdContaDestino != null && !_availableBancos.any((b) => b.id == _selectedIdContaDestino)) {
            _selectedIdContaDestino = null; // Limpa a seleção se a conta não existir mais
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar bancos/contas disponíveis.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro ao carregar bancos: $e');
    } finally {
      setState(() {
        _isLoadingBancos = false; // Desativa o indicador de carregamento
      });
    }
  }

  // Lógica para submeter o formulário e salvar/atualizar o investimento
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Se a validação falhar, não prossegue
    }

    _formKey.currentState!.save(); // Salva o estado atual dos campos

    // Converte o valor de texto para double, tratando vírgula como ponto
    double valor = double.tryParse(corrigeVirgula(_valorController.text)) ?? 0.0;

    // Cria o objeto Investimento com os dados do formulário
    final invest = Investimento(
      id: widget.investimentoParaEditar?.id, // Mantém o ID se for edição, nulo para novo
      nome: maiusculo(_nomeController.text),
      valor: valor,
      data: _data,
      dataFim: _dataFim,
      descricao: _descricaoController.text.isEmpty ? null : maiusculo(_descricaoController.text),
      idBanco: 1, // Usa o ID do dropdown de origem
      idconta: 1, // Usa o ID do dropdown de destino
      recorrente: _recorrente,
      recorrencia: _recorrencia,
      oculto: _oculto, // Usa o estado do switch de ocultar
    );

    try {
      if (widget.investimentoParaEditar == null) {
        // Se não há investimento para editar, insere um novo
        await investHelper.insertInvestimento(invest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investimento salvo com sucesso!')),
          );
        }
      } else {
        // Se há investimento para editar, atualiza o existente
        await investHelper.updateInvestimento(invest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investimento atualizado com sucesso!')),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso e recarregar a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar investimento: $e')),
        );
      }
      debugPrint('Erro ao salvar investimento: $e'); // Para depuração
    }
  }

  // Abre o seletor de data
  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _data : (_dataFim ?? DateTime.now()), // Data inicial
      firstDate: DateTime(2000), // Data mínima permitida
      lastDate: DateTime(2100), // Data máxima permitida
      locale: const Locale('pt', 'BR'), // Localização para português do Brasil
      builder: (context, child) {
        // Personaliza o tema do DatePicker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Cor primária do tema do app
              onPrimary: Colors.white, // Cor do texto sobre a cor primária
              surface: Colors.white, // Cor de fundo da superfície
              onSurface: Colors.black, // Cor do texto na superfície
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, // Cor dos botões de texto no picker
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _data = picked; // Atualiza a data de início
        } else {
          _dataFim = picked; // Atualiza a data de fim
        }
      });
    }
  }

  @override
  void dispose() {
    // Libera os controladores de texto quando o widget é descartado
    _nomeController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.investimentoParaEditar == null ? 'Novo Investimento' : 'Editar Investimento'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // Envolve o formulário para validação
          key: _formKey,
          child: ListView(
            children: [
              // Switch para ocultar o investimento do saldo total
              SwitchListTile(
                title: const Text('Ocultar do Saldo Total'),
                subtitle: const Text('Este investimento não será incluído no cálculo do seu saldo geral.'),
                value: _oculto,
                onChanged: (val) => setState(() => _oculto = val),
                secondary: const Icon(Icons.visibility_off),
              ),

              const Divider(height: 30), // Separador visual

              // Campo para o nome do investimento usando caixaTexto
              caixaTexto(
                true,
                context,
                _nomeController,
                TextInputType.text,
                50,
                'Nome do Investimento',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do investimento é obrigatório.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para o valor investido usando caixaTextoOnChanged
              caixaTextoOnChanged(
                true,
                context,
                _valorController,
                TextInputType.number,
                0, // 0 para tamanho ilimitado ou o tamanho máximo desejado
                'Valor Investido',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O valor é obrigatório.';
                  }
                  if (double.tryParse(corrigeVirgula(value)) == null) {
                    return 'Por favor, insira um valor numérico válido (ex: 1500,00).';
                  }
                  return null;
                },
                onChanged: (String) {
                  // A função valorReal deve estar em function.dart e lidar com a formatação
                  _valorController.text = valorReal(_valorController.text);
                },
              ),
              const SizedBox(height: 16),

              // --- Dropdown para 'De qual Banco saiu (idBanco)' ---
              _buildBankDropdown(
                label: 'De qual Banco saiu (Origem)',
                hintText: 'Selecione o banco de onde o valor saiu',
                selectedId: _selectedIdBancoOrigem,
                onChanged: (value) => setState(() => _selectedIdBancoOrigem = value),
                validatorMessage: 'Selecione o banco de origem.',
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: 16),

              // --- Dropdown para 'Para qual Banco/Conta foi (idconta)' ---
              _buildBankDropdown(
                label: 'Para qual Banco/Conta foi (Destino)',
                hintText: 'Selecione a conta/banco de destino do investimento',
                selectedId: _selectedIdContaDestino,
                onChanged: (value) => setState(() => _selectedIdContaDestino = value),
                validatorMessage: 'Selecione a conta/banco de destino.',
                prefixIcon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),

              // Campo para observações/descrição usando caixaTexto
              caixaTexto(
                true,
                context,
                _descricaoController,
                TextInputType.text,
                200, // Aumentado para 200 caracteres
                'Observações (opcional)',
              ),
              const SizedBox(height: 16),

              // ListTile para selecionar a data de início
              ListTile(
                title: Text('Data de Início: ${_dateFormat.format(_data)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
                leading: const Icon(Icons.event_note),
                contentPadding: EdgeInsets.zero,
              ),
              // ListTile para selecionar a data final (opcional)
              ListTile(
                title: Text('Data Final: ${_dataFim != null ? _dateFormat.format(_dataFim!) : 'Não definida'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.redAccent),
                  onPressed: _dataFim == null ? null : () => setState(() => _dataFim = null),
                  tooltip: 'Limpar Data Final',
                ),
                onTap: () => _pickDate(context, false),
                leading: const Icon(Icons.event_busy),
                contentPadding: EdgeInsets.zero,
              ),
              // Switch para indicar se o investimento é recorrente
              SwitchListTile(
                title: const Text('Investimento Recorrente?'),
                value: _recorrente,
                onChanged: (val) => setState(() {
                  _recorrente = val;
                  if (!val) {
                    _recorrencia = null; // Limpa a frequência se não for recorrente
                  }
                }),
                secondary: const Icon(Icons.repeat),
              ),
              // Dropdown para selecionar a frequência de recorrência (visível apenas se for recorrente)
              if (_recorrente)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // Adicionado para evitar overflow de largura
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

              // Botão para salvar/atualizar o investimento
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(widget.investimentoParaEditar == null ? Icons.save : Icons.update),
                  label: Text(
                    widget.investimentoParaEditar == null ? 'Salvar Investimento' : 'Atualizar Investimento',
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
              const SizedBox(height: 10), // Espaçamento inferior
            ],
          ),
        ),
      ),
    );
  }

  // Método auxiliar para construir os dropdowns de banco/conta
  Widget _buildBankDropdown({
    required String label,
    required String hintText,
    required int? selectedId,
    required ValueChanged<int?> onChanged,
    required String validatorMessage,
    required IconData prefixIcon,
  }) {
    if (_isLoadingBancos) {
      return const Center(child: CircularProgressIndicator()); // Indicador de carregamento
    }

    if (_availableBancos.isEmpty) {
      // Mensagem e botão para adicionar conta se não houver bancos disponíveis
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
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Por favor, adicione contas em "Minhas Contas" para selecionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                label: const Text('Adicionar Conta', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsScreen(),
                    ),
                  );
                  _loadBancos(); // Recarrega os bancos ao retornar da tela de contas
                },
              ),
            ],
          ),
        ),
      );
    }

    // Dropdown padrão se houver bancos disponíveis
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<int>(
          isExpanded: true, // Adicionado para evitar overflow de largura
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: InputBorder.none, // Remove a borda padrão do Dropdown
            contentPadding: EdgeInsets.zero, // Remove padding interno extra
            prefixIcon: Icon(prefixIcon),
          ),
          value: selectedId,
          items: _availableBancos.map((banco) {
            return DropdownMenuItem<int>(
              value: banco.id,
              child: Text(
                banco.banco, // Assumindo que 'banco' é o nome da sua conta
                overflow: TextOverflow.ellipsis, // Lida com nomes longos
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
