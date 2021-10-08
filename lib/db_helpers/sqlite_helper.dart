import 'dart:io';

import '../models/countdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CountdownProvider {
  static final _dbName = 'Countdown.db';
  static final _dbVersion = 1;

  CountdownProvider._privateConstructor();
  static final CountdownProvider instance =
      CountdownProvider._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    return _database = await _initDatabase();
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnCount INTEGER NOT NULL,
      $columnGoal INTEGER NOT NULL,
      $columnType TEXT NOT NULL,
      $columnDescription TEXT
    )
    ''');
  }

  // Get all the countdown in the db
  // or and empty list to avoid check null values
  Future<List<Countdown>> getAll() async {
    Database? db = await database;
    List<Map<String, Object?>>? maps = await db.query(tableName);
    List<Countdown> countdowns = [];
    if (maps != null && maps.length > 0) {
      countdowns = maps.map((map) => Countdown.fromMap(map: map)).toList();
    }
    return countdowns;
  }

  // Insert a countdown in the db
  Future<void> add(Countdown countdown) async {
    Database? db = await database;
    await db.insert(
      tableName,
      countdown.toMap(),
    );
  }

  Future<Countdown?> find(int? id) async {
    Database? db = await database;
    List<Map<String, Object?>>? maps =
        await db.query(tableName, where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Countdown.fromMap(map: maps.first);
    }
    return null;
  }

  Future<void> update(Countdown? countdown) async {
    final db = await database;
    db.update(
      tableName,
      countdown?.toMap() ?? {},
      where: 'id = ?',
      whereArgs: [countdown?.id],
    );
  }
}
