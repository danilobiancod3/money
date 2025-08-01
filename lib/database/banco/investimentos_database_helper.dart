import 'package:sqflite/sqflite.dart';
import '../models/investimentos.dart';
import '../database_helper.dart';

class InvestimentoDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  // Insere um novo investimento
  Future<int> insertInvestimento(Investimento investimento) async {
    final db = await dbHelper.database;
    return await db.insert(
      'Investimento',
      investimento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca todos os investimentos
  Future<List<Investimento>> getInvestimentos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Investimento');
    return maps.map((map) => Investimento.fromMap(map)).toList();
  }

  // Atualiza um investimento
  Future<int> updateInvestimento(Investimento investimento) async {
    final db = await dbHelper.database;
    return await db.update(
      'Investimento',
      investimento.toMap(),
      where: 'id = ?',
      whereArgs: [investimento.id],
    );
  }

  // Exclui um investimento
  Future<int> deleteInvestimento(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Investimento',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Busca um investimento por ID
  Future<Investimento?> getInvestimentoPorId(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Investimento',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Investimento.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Total de investimentos ativos (ativo = 1)
  Future<double> totalInvestimentosAtivos() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(valor) as total FROM Investimento WHERE ativo = 1
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Total de investimentos encerrados (ativo = 0)
  Future<double> totalInvestimentosEncerrados() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(valor) as total FROM Investimento WHERE ativo = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

    // Soma de todos os investimentos (ativos e encerrados)
  Future<double> totalInvestimentos() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(valor) as total FROM Investimento
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Soma apenas dos investimentos visíveis (oculto = 0)
  Future<double> totalInvestimentosVisiveis() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(valor) as total FROM Investimento WHERE oculto = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

}
