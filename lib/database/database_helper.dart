import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  static const String _dbName = 'app_data.db';
  static const int _dbVersion = 5;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, _dbName);

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw DatabaseException('Erro ao inicializar banco de dados: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
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
          oculto INTEGER,
          agencia TEXT,
          numero_conta TEXT,
          descricao TEXT
        )
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
        )
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
        )
      ''');

      await db.execute('''
        CREATE TABLE categorias(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT,
          categoria TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE contas_a_pagar(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          tipoDeConta TEXT,
          valorDaConta REAL NOT NULL,
          valorPago REAL DEFAULT 0,
          dataVencimento TEXT NOT NULL,
          dataPagamento TEXT,
          quitado INTEGER DEFAULT 0,
          descricao TEXT,
          idbanco INTEGER
        )
      ''');
    } catch (e) {
      throw DatabaseException('Erro ao criar tabelas: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < newVersion) {
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE bancos ADD COLUMN agencia TEXT');
          await db.execute('ALTER TABLE bancos ADD COLUMN numero_conta TEXT');
          await db.execute('ALTER TABLE bancos ADD COLUMN descricao TEXT');
        }
        
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS contas_a_pagar');
          await db.execute('''
            CREATE TABLE contas_a_pagar(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              tipoDeConta TEXT,
              valorDaConta REAL NOT NULL,
              valorPago REAL DEFAULT 0,
              dataVencimento TEXT NOT NULL,
              dataPagamento TEXT,
              quitado INTEGER DEFAULT 0,
              descricao TEXT,
              idbanco INTEGER
            )
          ''');
        }
      }
    } catch (e) {
      throw DatabaseException('Erro ao atualizar banco de dados: $e');
    }
  }

  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
    } catch (e) {
      throw DatabaseException('Erro ao fechar banco de dados: $e');
    }
  }
}

class DatabaseException implements Exception {
  DatabaseException(this.message);

  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}
