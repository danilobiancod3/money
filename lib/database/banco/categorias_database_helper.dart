import 'package:sqflite/sqflite.dart';
import '../models/categorias.dart';
import '../database_helper.dart';

class CategoriasDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  // Inserir uma nova categoria
  Future<int> insertCategoria(Categorias categoria) async {
    final db = await dbHelper.database;
    return await db.insert(
      'Categorias',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Consultar todas as categorias
  Future<List<Categorias>> getCategorias() async {
    final db = await dbHelper.database;
    final maps = await db.query('Categorias');

    return List.generate(maps.length, (i) {
      return Categorias.fromMap(maps[i]);
    });
  }

  // Consultar categoria por ID
  Future<Categorias?> getCategoriaPorId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Categorias',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Categorias.fromMap(result.first);
    }
    return null;
  }

  // Consultar categorias por tipo (ex: 'Despesa', 'Receita')
  Future<List<Categorias>> getCategoriasPorTipo(String tipo) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Categorias',
      where: 'tipo = ?',
      whereArgs: [tipo],
    );

    return result.map((map) => Categorias.fromMap(map)).toList();
  }

  // Deletar categoria por ID
  Future<int> deleteCategoriaPorId(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletar todas as categorias de um tipo
  Future<int> deleteCategoriasPorTipo(String tipo) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Categorias',
      where: 'tipo = ?',
      whereArgs: [tipo],
    );
  }
}