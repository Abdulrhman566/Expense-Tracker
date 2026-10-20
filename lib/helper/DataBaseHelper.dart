import 'package:path/path.dart';
import 'package:session_3_10/models/expense_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class Databasehelper {
  static final Databasehelper instance = Databasehelper._init();

  Databasehelper._init();

  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;

    _database = await _initDB('expense.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    if (kIsWeb) {
      return await openDatabase(
        'expense_web.db',
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }

    final databasePath = await getDatabasesPath();
    final dbpath = join(databasePath, path);

    return await openDatabase(
      dbpath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create a new table without the old required date column.
      await db.execute('''
        CREATE TABLE expenses_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT 'other',
          amount REAL NOT NULL
        )
      ''');

      // Copy the existing expenses and preserve their IDs.
      await db.execute('''
        INSERT INTO expenses_new (id, title, amount)
        SELECT id, title, amount FROM expenses
      ''');

      await db.execute('DROP TABLE expenses');

      await db.execute('ALTER TABLE expenses_new RENAME TO expenses');
    }
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final database = await db;

    return database.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getexpense() async {
    final database = await db;

    final result = await database.query('expenses', orderBy: 'id DESC');

    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final database = await db;

    return database.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpense() async {
    final database = await db;

    final result = await database.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses',
    );

    final total = result.first['total'] ?? 0.0;

    return (total as num).toDouble();
  }
  
Future<int> updateExpense(ExpenseModel expense) async {
  final database = await db;

  if (expense.id == null) {
    throw ArgumentError('Expense ID is required for updating.');
  }

  return database.update(
    'expenses',
    {
      'title': expense.title,
      'category': expense.category,
      'amount': expense.amount,
    },
    where: 'id = ?',
    whereArgs: [expense.id],
  );
}

Future<Map<String, double>> getExpensesByCategory() async {
  final database = await db;

  final result = await database.rawQuery('''
    SELECT category, SUM(amount) AS total
    FROM expenses
    GROUP BY category
  ''');

  return {
    for (final row in result)
      row['category'] as String: (row['total'] as num).toDouble(),
  };
}


  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
