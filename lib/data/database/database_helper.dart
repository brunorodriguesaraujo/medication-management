import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/medicament.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        times TEXT NOT NULL,
        isChecked INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertMedicament(Medicament medicament) async {
    final db = await instance.database;
    return await db.insert('medications', medicament.toMap());
  }

  Future<List<Medicament>> getAllMedications() async {
    final db = await instance.database;

    final result = await db.query('medications');
    return result.map((map) => Medicament.fromMap(map)).toList();
  }

  Future<int> deleteMedicament(int id) async {
    final db = await instance.database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMedicamentCheckStatus(int id, bool isChecked) async {
    final db = await instance.database;
    await db.update(
      'medications',
      {'isChecked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
