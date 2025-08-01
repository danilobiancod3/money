import 'package:sqflite/sqflite.dart';
import '../models/lancamentos.dart';
import '../database_helper.dart';

class LancamentoDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  // Insere um novo Lançamento
  Future<int> insertLancamento(Lancamento lancamento) async {
    final db = await dbHelper.database;
    return await db.insert(
      'Lancamento',
      lancamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Consulta todos os Lançamentos
  Future<List<Lancamento>> consultaLancamentos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Lancamento');
    return List.generate(maps.length, (i) {
      return Lancamento.fromMap(maps[i]);
    });
  }

  // Retorna o maior ID da tabela Lancamento
  Future<int?> pegarUltimoId() async {
    final db = await dbHelper.database;
    final resultado = await db.rawQuery('SELECT MAX(id) as ultimoId FROM Lancamento');
    if (resultado.isNotEmpty) {
      return resultado.first['ultimoId'] as int?;
    }
    return null;
  }

  // Busca um lançamento pelo ID
  Future<Lancamento?> buscarLancamentoPorId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Lancamento',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Lancamento.fromMap(result.first);
    }
    return null;
  }

  // Atualiza um Lançamento
  Future<int> updateLancamento(Lancamento lancamento) async {
    final db = await dbHelper.database;
    return await db.update(
      'Lancamento',
      lancamento.toMap(),
      where: 'id = ?',
      whereArgs: [lancamento.id],
    );
  }

  // Deleta um Lançamento
  Future<int> deleteLancamento(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Lancamento',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Adiciona valor ao campo "valor" de um lançamento
  Future<void> adicionarValor(int id, double valorParaAdicionar) async {
    final db = await dbHelper.database;
    final resultado = await db.query(
      'Lancamento',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      final lancamento = Lancamento.fromMap(resultado.first);
      final novoValor = lancamento.valor + valorParaAdicionar;

      await db.update(
        'Lancamento',
        {'valor': novoValor},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      throw Exception('Lançamento com id $id não encontrado.');
    }
  }

  // Subtrai valor do campo "valor" de um lançamento
  Future<void> subtrairValor(int id, double valorParaSubtrair) async {
    final db = await dbHelper.database;
    final resultado = await db.query(
      'Lancamento',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      final lancamento = Lancamento.fromMap(resultado.first);
      final novoValor = lancamento.valor - valorParaSubtrair;

      await db.update(
        'Lancamento',
        {'valor': novoValor},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      throw Exception('Lançamento com id $id não encontrado.');
    }
  }
}
