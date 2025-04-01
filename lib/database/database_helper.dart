import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "appdatabase.db";
  static const _databaseVersion = 1;
  static const tableUsers = 'users';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnIsLogged = 'is_logged';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnIsLogged INTEGER DEFAULT 0
      )
    ''');
  }

  // CRUD operations
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, row);
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.query(tableUsers);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(
      tableUsers,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableUsers,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> dropTable() async {
    Database db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS $tableUsers');
  }

  Future<void> createTable() async {
    Database db = await instance.database;
    await _onCreate(db, _databaseVersion);
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    Database db = await instance.database;
    try {
      // Usando rawQuery para mais controle
      List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $tableUsers 
      WHERE $columnEmail = ? AND $columnPassword = ?
    ''', [email, password]);

      if (result.isNotEmpty) {
        // Faz logout de todos os usuários primeiro
        await db.rawUpdate('UPDATE $tableUsers SET $columnIsLogged = 0');

        // Atualiza o usuário logado
        int id = result.first[columnId];
        await db.rawUpdate('''
        UPDATE $tableUsers 
        SET $columnIsLogged = 1 
        WHERE $columnId = ?
      ''', [id]);

        // Retorna os dados atualizados
        return (await db.query(
          tableUsers,
          where: '$columnId = ?',
          whereArgs: [id],
        )).first;
      }
      return null;
    } catch (e) {
      print('Erro no authenticateUser: $e');
      throw e;
    }
  }

  Future<void> logoutAllUsers() async {
    Database db = await instance.database;
    await db.rawUpdate('UPDATE $tableUsers SET $columnIsLogged = 0');
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: '$columnIsLogged = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}