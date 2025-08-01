import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import '../database_helper.dart';

class UsuarioDatabaseHelper {
  final dbHelper = DatabaseHelper.instance;

  // Insere um novo Usuario no banco
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert(
      'Usuario',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ Função renomeada: obtém todos os Usuario do banco
  Future<List<Usuario>> consultaUsuario() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Usuario');
    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  // Atualiza um Usuario existente no banco
  Future<int> updateUsuario(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.update(
      'Usuario',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // 🔸 Pega o tema do primeiro usuário cadastrado
// 🔸 Atualiza apenas o tema no banco
Future<int> setTema(int tema) async {
  final db = await dbHelper.database;
  return await db.update(
    'Usuario',
    {'modoescuro': tema},
    where: 'id = (SELECT id FROM Usuario LIMIT 1)',
  );
}

// 🔸 Pega o tema do primeiro usuário cadastrado
Future<int?> getTema() async {
  final db = await dbHelper.database;
  final result = await db.query('Usuario', limit: 1);

  if (result.isNotEmpty) {
    return result.first['modoescuro'] as int;
  }
  return null;
}

// 🔸 Verifica se existe algum usuário cadastrado
Future<bool> usuarioExiste() async {
  final db = await dbHelper.database;
  final result = await db.query('Usuario');
  return result.isNotEmpty;
}


  // Deleta um Usuario do banco
  Future<int> deleteUsuario(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Usuario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}