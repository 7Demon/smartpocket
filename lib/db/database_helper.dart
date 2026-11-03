import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_item.dart';
import '../models/savings_goal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartpocket.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  // --- Transactions CRUD ---
  Future<int> insertTransaction(TransactionItem item) async {
    final db = await database;
    return await db.insert('transactions', item.toMap());
  }

  Future<List<TransactionItem>> getTransactions({String? filterType}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (filterType != null && filterType != 'all') {
      maps = await db.query(
        'transactions',
        where: 'type = ?',
        whereArgs: [filterType],
        orderBy: 'date DESC, id DESC',
      );
    } else {
      maps = await db.query(
        'transactions',
        orderBy: 'date DESC, id DESC',
      );
    }

    return maps.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<List<TransactionItem>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return maps.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    final val = result.first['total'];
    return val != null ? (val as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getExpenseByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense'
      GROUP BY category
      ORDER BY total DESC
    ''');

    final Map<String, double> categoryMap = {};
    for (final row in result) {
      final cat = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      categoryMap[cat] = total;
    }
    return categoryMap;
  }

  // --- Savings Goals CRUD ---
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final db = await database;
    final maps = await db.query('savings_goals', orderBy: 'id DESC');
    return maps.map((e) => SavingsGoal.fromMap(e)).toList();
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    return await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSavingsAmount(int id, double newAmount) async {
    final db = await database;
    return await db.update(
      'savings_goals',
      {'current_amount': newAmount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

