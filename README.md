# Money Manager - Aplicativo de Gestão Financeira

Um aplicativo móvel completo para gerenciamento de finanças pessoais desenvolvido em Flutter, com foco em segurança, usabilidade e funcionalidades avançadas.

## 🚀 Funcionalidades

### 📊 Gestão de Contas
- Cadastro e gerenciamento de contas bancárias
- Diferentes tipos de conta (corrente, poupança, cartão de crédito, etc.)
- Controle de visibilidade das contas
- Saldo total consolidado

### 💰 Transações
- Registro de receitas e despesas
- Categorização automática
- Histórico detalhado
- Transferências entre contas

### 📋 Contas a Pagar
- Controle de contas recorrentes
- Lembretes de vencimento
- Status de pagamento
- Parcelamento

### 📈 Investimentos
- Acompanhamento de investimentos
- Diferentes categorias (ações, renda fixa, imobiliário)
- Rendimentos e perdas
- Portfolio consolidado

### 📊 DRE (Demonstrativo de Resultados)
- Análise financeira completa
- Gráficos interativos
- Relatórios por período
- Exportação em Excel e PDF

### 📋 Relatórios
- Relatórios personalizados
- Filtros por período e categoria
- Exportação de dados
- Análises comparativas

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **SQLite**: Banco de dados local
- **Material Design 3**: Interface moderna
- **Fl Chart**: Gráficos interativos
- **Excel/PDF**: Exportação de relatórios

## 📱 Arquitetura do Projeto

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── services/
│   │   └── export_service.dart
│   ├── utils/
│   │   └── formatters.dart
│   └── widgets/
│       └── custom_bottom_navigation.dart
├── database/
│   ├── banco/
│   │   ├── bancos_database_helper.dart
│   │   ├── categorias_database_helper.dart
│   │   ├── contas_a_pagar_database_helper.dart
│   │   ├── investimentos_database_helper.dart
│   │   ├── lancamentos_database_helper.dart
│   │   └── usuario_database_helper.dart
│   ├── models/
│   │   ├── bancos.dart
│   │   ├── categorias.dart
│   │   ├── contas_a_pagar.dart
│   │   ├── investimentos.dart
│   │   ├── lancamentos.dart
│   │   └── usuario.dart
│   └── database_helper.dart
├── accounts/
│   ├── accountsscreen.dart
│   └── addaccounts.dart
├── contas_a_pagar/
│   ├── addbillscreen.dart
│   └── billscreensscreen.dart
├── investmentos/
│   ├── addInvestment.dart
│   └── investmentsscreen.dart
├── transacoes/
│   ├── AddTransaction.dart
│   ├── transactionsscreen.dart
│   └── transfer_screen.dart
├── desing_funcoes/
│   ├── caixatexto.dart
│   ├── cores.dart
│   └── function.dart
├── drescreen.dart
├── home.dart
├── main.dart
└── reportsscreen.dart
```

## 🔧 Configuração e Instalação

### Pré-requisitos
- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/money-manager.git
cd money-manager
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_localizations:
    sdk: flutter
  flutter_spinkit: ^5.2.1
  salomon_bottom_bar: ^3.3.2
  fl_chart: ^1.0.0
  sqflite: ^2.4.2
  path: ^1.9.1
  path_provider: ^2.1.5
  intl: ^0.19.0
  share_plus: ^7.2.1
  permission_handler: ^11.3.1
  excel: ^2.1.0
  pdf: ^3.10.7
  printing: ^5.11.1
```

## 🔒 Segurança

O aplicativo implementa as seguintes práticas de segurança:

- **Validação de Entrada**: Todos os dados de entrada são validados
- **Sanitização**: Dados são sanitizados antes do processamento
- **Criptografia**: Dados sensíveis são criptografados
- **Permissões**: Controle granular de permissões
- **Auditoria**: Logs de segurança para auditoria

## 📊 Funcionalidades de Exportação

### Excel
- Relatórios completos em formato .xlsx
- Múltiplas abas (lançamentos, contas, investimentos)
- Formatação automática
- Filtros e ordenação

### PDF
- Relatórios profissionais em PDF
- Gráficos e tabelas
- Cabeçalho e rodapé personalizados
- Compartilhamento direto

## 🎨 Interface do Usuário

- **Material Design 3**: Interface moderna e intuitiva
- **Tema Escuro/Claro**: Suporte a ambos os temas
- **Responsivo**: Adaptável a diferentes tamanhos de tela
- **Acessível**: Suporte a acessibilidade
- **Animações**: Transições suaves e fluidas

## 📈 Melhorias Implementadas

### Organização do Código
- Estrutura modular e escalável
- Separação de responsabilidades
- Padrões de projeto consistentes
- Código limpo e bem documentado

### Performance
- Otimização de consultas ao banco
- Lazy loading de dados
- Cache inteligente
- Redução de rebuilds desnecessários

### UX/UI
- Interface mais intuitiva
- Feedback visual melhorado
- Navegação simplificada
- Loading states otimizados

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Desenvolvido por

**Danilo** - Desenvolvedor Full Stack

## 📞 Suporte

Para suporte, envie um email para suporte@moneymanager.com ou abra uma issue no GitHub.

---

**Money Manager** - Gerencie suas finanças de forma inteligente e segura! 💰📱
