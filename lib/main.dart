// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home.dart';
import 'database/banco/usuario_database_helper.dart';
import 'database/models/usuario.dart';
import 'database/banco/categorias_database_helper.dart';
import 'database/models/categorias.dart';
import 'database/database_helper.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseHelper.excluirBancoDeDados(); // <- Apenas para testes
  runApp(MoneyApp());
}


class MoneyApp extends StatefulWidget {
  const MoneyApp({super.key}); 
  @override
  State<MoneyApp> createState() => _MoneyAppState();
}

class _MoneyAppState extends State<MoneyApp> {
 // Construtor da classe, define uma chave opcional (usada para otimização e testes)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money', // Título do aplicativo (pode aparecer na multitarefa do Android)
      debugShowCheckedModeBanner: false, // Remove a faixa de "debug" do canto superior direito

      theme: ThemeData(
        useMaterial3: true, // Habilita o Material Design 3 (versão mais recente com novos componentes e temas)
        brightness: Brightness.light, // Define que este tema é para o modo claro
        colorSchemeSeed: Color(0xFF00B8F4), // Cor base (semente) do esquema de cores no tema claro (azul claro)
      ),

      darkTheme: ThemeData(
        useMaterial3: true, // Também usa Material Design 3 no modo escuro
        brightness: Brightness.dark, // Define que este tema é para o modo escuro
        colorSchemeSeed: Color(0xFF004D92), // Cor base do esquema de cores no tema escuro (azul escuro)
      ),

      themeMode: ThemeMode.system, // Usa o tema de acordo com o modo do sistema (claro ou escuro)

      supportedLocales: const [
        Locale('pt', 'BR'), // Suporte para o idioma português do Brasil
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Suporte à localização de widgets do Material
        GlobalWidgetsLocalizations.delegate,  // Suporte à localização de widgets genéricos
        GlobalCupertinoLocalizations.delegate, // Suporte à localização de widgets estilo iOS
      ],

      home: const LoadingScreenAlt(), // Tela inicial do app (deve ser uma widget chamada HomeScreen)
    );
  }
}

class LoadingScreenAlt extends StatefulWidget {
  const LoadingScreenAlt({super.key});

  @override
  State<LoadingScreenAlt> createState() => _LoadingScreenAltState();
}

class _LoadingScreenAltState extends State<LoadingScreenAlt> {

  @override
  void initState() {
    super.initState();
    startDatabase();
    homeScreen();
  }

  void homeScreen() async {
  Future.delayed(const Duration(seconds: 3), () {
    home();
  });
}


  // Função responsável por navegar para a tela principal (Home)
  home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(index: 0,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo estilizado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF00B8F4) :  Color(0xFF004D92),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(
                Icons.attach_money,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Carregando seu financeiro...',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 30),
            SpinKitFadingCube(
              color: isDark ? Color(0xFF00B8F4) :  Color(0xFF004D92),
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> startDatabase() async {
  final usuarioHelper = UsuarioDatabaseHelper();
  final categoriaHelper = CategoriasDatabaseHelper();

  // Verifica se há usuários no banco; se não, cria um usuário padrão
  final usuarios = await usuarioHelper.consultaUsuario();
  if (usuarios.isEmpty) {
    final novoUsuario = Usuario(
      nomeUsuario: '',
      nomefantazia: '',
      enderecoUsuario: '',
      emailUsuario: '',
      telefoneUsuario: '',
      cpfcnpjUsuario: '',
      mostrarValorTotal: false,
      grafico: 1,
      modoescuro: 2,
    );
    await usuarioHelper.insertUsuario(novoUsuario);
  }

  // Verifica se há categorias no banco; se não, cria categorias padrão
  final categorias = await categoriaHelper.getCategorias();
  if (categorias.isEmpty) {
    // Categoria geral
    final categoriaTodos = Categorias(tipo: 'todos', categoria: 'Outro');
    await categoriaHelper.insertCategoria(categoriaTodos);

    // Categorias de saída (despesas)
    final categoriaSaidaAlimentacao = Categorias(tipo: 'saida', categoria: 'Alimentação');
    final categoriaSaidaTransporte = Categorias(tipo: 'saida', categoria: 'Transporte');
    final categoriaSaidaLazer = Categorias(tipo: 'saida', categoria: 'Lazer');
    await categoriaHelper.insertCategoria(categoriaSaidaAlimentacao);
    await categoriaHelper.insertCategoria(categoriaSaidaTransporte);
    await categoriaHelper.insertCategoria(categoriaSaidaLazer);

    // Categorias de entrada (receitas)
    final categoriaEntradaSalario = Categorias(tipo: 'entrada', categoria: 'Salário');
    final categoriaEntradaFreelance = Categorias(tipo: 'entrada', categoria: 'Freelance');
    await categoriaHelper.insertCategoria(categoriaEntradaSalario);
    await categoriaHelper.insertCategoria(categoriaEntradaFreelance);

    // Categorias de entrada (receitas)
    final categoriaContasAPagarFinanciamento = Categorias(tipo: 'contas', categoria: 'Financiamento');
    final categoriaContasAPagarEmprestimo = Categorias(tipo: 'contas', categoria: 'Emprestimo');
    await categoriaHelper.insertCategoria(categoriaContasAPagarFinanciamento);
    await categoriaHelper.insertCategoria(categoriaContasAPagarEmprestimo);

    // Categorias de investimentos
    final categoriaInvestimentoAcoes = Categorias(tipo: 'investimento', categoria: 'Ações');
    final categoriaInvestimentoRendaFixa = Categorias(tipo: 'investimento', categoria: 'Renda Fixa');
    final categoriaInvestimentoImobiliario = Categorias(tipo: 'investimento', categoria: 'Imobiliário');
    await categoriaHelper.insertCategoria(categoriaInvestimentoAcoes);
    await categoriaHelper.insertCategoria(categoriaInvestimentoRendaFixa);
    await categoriaHelper.insertCategoria(categoriaInvestimentoImobiliario);
  }
}
