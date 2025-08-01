// File: lib/database/bancos_database_helper.dart

import 'package:sqflite/sqflite.dart';
import '../models/bancos.dart';
import '../database_helper.dart';

class BancosDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertBanco(Bancos banco) async {
    final db = await dbHelper.database;
    return await db.insert(
      'bancos',
      banco.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bancos>> getBancos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('bancos');
    return maps.map((map) => Bancos.fromMap(map)).toList();
  }

  Future<int> updateBanco(Bancos banco) async {
    final db = await dbHelper.database;
    return await db.update(
      'bancos',
      banco.toMap(),
      where: 'id = ?',
      whereArgs: [banco.id],
    );
  }

  Future<int> deleteBanco(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'bancos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Bancos?> getBancoPorId(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'bancos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Bancos.fromMap(maps.first);
    }
    return null;
  }

  Future<double> getValorDoBancoPorId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'bancos',
      columns: ['valornaconta'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final valorStr = result.first['valornaconta'].toString();
      return double.tryParse(valorStr) ?? 0.0;
    } else {
      throw Exception('Banco com ID $id não encontrado.');
    }
  }

    // Subtrai um valor do campo 'valornaconta' de um banco específico
Future<void> subtrairValorPorId(int id, double valorASubtrair) async {
  final db = await dbHelper.database;

  // Busca o banco pelo ID
  final List<Map<String, dynamic>> result = await db.query(
    'bancos',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (result.isNotEmpty) {
    final banco = result.first;
    final valorAtual = double.tryParse(banco['valornaconta'].toString()) ?? 0.0;
    final novoValor = valorAtual - valorASubtrair;

    await db.update(
      'bancos',
      {'valornaconta': novoValor.toStringAsFixed(2)},
      where: 'id = ?',
      whereArgs: [id],
    );
  } else {
    throw Exception('Banco com ID $id não encontrado.');
  }
}

// Soma um valor ao campo 'valornaconta' de um banco específico pelo ID
Future<void> somarValorPorId(int id, double valorASomar) async {
  final db = await dbHelper.database;

  // Busca o banco pelo ID
  final List<Map<String, dynamic>> result = await db.query(
    'bancos',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (result.isNotEmpty) {
    final banco = result.first;
    final valorAtual = double.tryParse(banco['valornaconta'].toString()) ?? 0.0;
    final novoValor = valorAtual + valorASomar;

    await db.update(
      'bancos',
      {'valornaconta': novoValor.toStringAsFixed(2)},
      where: 'id = ?',
      whereArgs: [id],
    );
  } else {
    throw Exception('Banco com ID $id não encontrado.');
  }
}

  Future<double> totalBancos() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(CAST(valornaconta AS REAL)) as total FROM bancos
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> totalBancosVisiveis() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(CAST(valornaconta AS REAL)) as total FROM bancos WHERE oculto = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<String?> getNomeBancoPorId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'bancos',
      columns: ['nome'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['nome'] as String;
    }
    return null;
  }

      // Soma todos os valores na conta, convertendo texto para número
  Future<double> somarTodosOsValores() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(CAST(valornaconta AS REAL)) as total FROM bancos
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Soma somente os valores visíveis (oculto = 0)
  Future<double> somarValoresVisiveis() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(CAST(valornaconta AS REAL)) as total FROM bancos WHERE oculto = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
