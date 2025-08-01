import 'package:sqflite/sqflite.dart';
import '../models/contas_a_pagar.dart';
import '../database_helper.dart';

class ContasAPagarDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertConta(ContasAPagar conta) async {
    final db = await dbHelper.database;
    return await db.insert(
      'contas_a_pagar',
      conta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContasAPagar>> getContas() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('contas_a_pagar');
    return maps.map((map) => ContasAPagar.fromMap(map)).toList();
  }

  Future<int> updateConta(ContasAPagar conta) async {
    final db = await dbHelper.database;
    return await db.update(
      'contas_a_pagar',
      conta.toMap(),
      where: 'id = ?',
      whereArgs: [conta.id],
    );
  }

  Future<int> deleteConta(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'contas_a_pagar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ContasAPagar?> getContaPorId(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'contas_a_pagar',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ContasAPagar.fromMap(maps.first);
    }
    return null;
  }

  Future<double> somarValoresVisiveis() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(valorDaConta AS REAL)) as total FROM contas_a_pagar WHERE oculto = 0',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> somarValoresQuitados() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(valorPago AS REAL)) as total FROM contas_a_pagar WHERE quitado = 1',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<ContasAPagar>> getContasEmAberto() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'contas_a_pagar',
      where: 'quitado = ?',
      whereArgs: [0],
    );
    return maps.map((map) => ContasAPagar.fromMap(map)).toList();
  }
}
