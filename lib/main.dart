import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'core/constants/app_constants.dart';
import 'home.dart';
import 'database/banco/usuario_database_helper.dart';
import 'database/models/usuario.dart';
import 'database/banco/categorias_database_helper.dart';
import 'database/models/categorias.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyApp());
}


class MoneyApp extends StatefulWidget {
  const MoneyApp({super.key}); 
  @override
  State<MoneyApp> createState() => _MoneyAppState();
}

class _MoneyAppState extends State<MoneyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF00B8F4),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF00B8F4),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF004D92),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF004D92),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoadingScreenAlt(),
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await startDatabase();
    await Future.delayed(const Duration(seconds: AppConstants.splashScreenDuration));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(index: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF00B8F4) : const Color(0xFF004D92);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(120),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.attach_money,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando seu financeiro...',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              SpinKitFadingCube(
                color: primaryColor,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> startDatabase() async {
  try {
    final usuarioHelper = UsuarioDatabaseHelper();
    final categoriaHelper = CategoriasDatabaseHelper();

    await _initializeDefaultUser(usuarioHelper);
    await _initializeDefaultCategories(categoriaHelper);
  } catch (e) {
    debugPrint('Erro ao inicializar banco de dados: $e');
  }
}

Future<void> _initializeDefaultUser(UsuarioDatabaseHelper usuarioHelper) async {
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
}

Future<void> _initializeDefaultCategories(CategoriasDatabaseHelper categoriaHelper) async {
  final categorias = await categoriaHelper.getCategorias();
  if (categorias.isEmpty) {
    await _insertDefaultCategories(categoriaHelper);
  }
}

Future<void> _insertDefaultCategories(CategoriasDatabaseHelper categoriaHelper) async {
  final defaultCategories = [
    Categorias(tipo: 'todos', categoria: 'Outro'),
    Categorias(tipo: 'saida', categoria: 'Alimentação'),
    Categorias(tipo: 'saida', categoria: 'Transporte'),
    Categorias(tipo: 'saida', categoria: 'Lazer'),
    Categorias(tipo: 'saida', categoria: 'Saúde'),
    Categorias(tipo: 'saida', categoria: 'Educação'),
    Categorias(tipo: 'saida', categoria: 'Moradia'),
    Categorias(tipo: 'saida', categoria: 'Vestuário'),
    Categorias(tipo: 'entrada', categoria: 'Salário'),
    Categorias(tipo: 'entrada', categoria: 'Freelance'),
    Categorias(tipo: 'entrada', categoria: 'Investimentos'),
    Categorias(tipo: 'entrada', categoria: 'Presentes'),
    Categorias(tipo: 'contas', categoria: 'Financiamento'),
    Categorias(tipo: 'contas', categoria: 'Emprestimo'),
    Categorias(tipo: 'investimento', categoria: 'Ações'),
    Categorias(tipo: 'investimento', categoria: 'Renda Fixa'),
    Categorias(tipo: 'investimento', categoria: 'Imobiliário'),
  ];

  for (final categoria in defaultCategories) {
    await categoriaHelper.insertCategoria(categoria);
  }
}
