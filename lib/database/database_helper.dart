import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  static const String _dbName = 'app_data.db';
  static const int _dbVersion = 4; // Incrementado para recriar o banco

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Usuario(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeUsuario TEXT,
        nomefantazia TEXT,
        enderecoUsuario TEXT,
        emailUsuario TEXT,
        telefoneUsuario TEXT,
        cpfcnpjUsuario TEXT,
        modoescuro INTEGER,
        mostrarValorTotal INTEGER,
        grafico INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE bancos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        banco TEXT,
        tipodeconta TEXT,
        valornaconta REAL,
        icone TEXT,
        oculto INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE Lancamento(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL,
        entrada INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        descricao TEXT,
        idbanco INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE investimento(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL,
        datafim TEXT,
        descricao TEXT,
        idbanco INTEGER,
        idconta INTEGER,
        recorrente INTEGER,
        recorrencia TEXT,
        oculto INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        categoria TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE contas_a_pagar(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipoDeConta TEXT,
        valorDaConta REAL NOT NULL,
        valorPago REAL NOT NULL,
        dataInicio TEXT NOT NULL,
        dataTermino TEXT,
        parcelas INTEGER NOT NULL,
        frequenciaEmDias INTEGER,
        dataPrimeiraParcela TEXT,
        icone TEXT NOT NULL,
        quitado INTEGER NOT NULL,
        oculto INTEGER NOT NULL
      );
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  static Future<bool> excluirBancoDeDados() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, _dbName);

      if (await File(path).exists()) {
        await deleteDatabase(path);
        _database = null;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
