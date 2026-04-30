import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppLocalDb {
  AppLocalDb._();

  static final AppLocalDb instance = AppLocalDb._();

  static const _dbName = 'habit_control.db';
  static const _dbVersion = 3;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'custom',
        streak_text TEXT NOT NULL,
        position INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted INTEGER NOT NULL DEFAULT 0,
        dirty INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE metric_definitions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        semantic_category TEXT NOT NULL,
        value_type TEXT NOT NULL,
        unit TEXT,
        interpretation TEXT NOT NULL,
        position INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted INTEGER NOT NULL DEFAULT 0,
        dirty INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE metric_entries (
        metric_id TEXT NOT NULL,
        day_key TEXT NOT NULL,
        numeric_value REAL NOT NULL,
        updated_at INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (metric_id, day_key)
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_days (
        day_key TEXT PRIMARY KEY,
        updated_at INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_day_done (
        day_key TEXT NOT NULL,
        habit_id TEXT NOT NULL,
        PRIMARY KEY (day_key, habit_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS metric_definitions (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          semantic_category TEXT NOT NULL,
          value_type TEXT NOT NULL,
          unit TEXT,
          interpretation TEXT NOT NULL,
          position INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted INTEGER NOT NULL DEFAULT 0,
          dirty INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS metric_entries (
          metric_id TEXT NOT NULL,
          day_key TEXT NOT NULL,
          numeric_value REAL NOT NULL,
          updated_at INTEGER NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 1,
          PRIMARY KEY (metric_id, day_key)
        )
      ''');
    }

    if (oldVersion < 3) {
      await _addColumnIfMissing(
        db,
        table: 'habits',
        column: 'category',
        definition: "TEXT NOT NULL DEFAULT 'custom'",
      );

      await db.execute('''
        CREATE TABLE IF NOT EXISTS habit_days (
          day_key TEXT PRIMARY KEY,
          updated_at INTEGER NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS habit_day_done (
          day_key TEXT NOT NULL,
          habit_id TEXT NOT NULL,
          PRIMARY KEY (day_key, habit_id)
        )
      ''');
    }
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((item) => item['name'] == column);

    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
