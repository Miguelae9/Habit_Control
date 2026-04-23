import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:habit_control/screens/input_log/models/metric_definition.dart';

class MetricDefinitionDb {
  MetricDefinitionDb._();

  static final MetricDefinitionDb instance = MetricDefinitionDb._();

  static const _dbName = 'habit_control.db';
  static const _dbVersion = 2;
  static const _table = 'metric_definitions';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
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
      },
    );
  }

  Future<List<MetricDefinition>> getActiveDefinitions() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'deleted = 0',
      orderBy: 'position ASC',
    );
    return rows.map(MetricDefinition.fromMap).toList();
  }

  Future<void> insertOrReplace(
    MetricDefinition definition, {
    bool dirty = true,
  }) async {
    final db = await database;
    final map = definition.toMap()..['dirty'] = dirty ? 1 : 0;

    await db.insert(_table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MetricDefinition>> getDirtyDefinitions() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'dirty = 1',
      orderBy: 'position ASC',
    );
    return rows.map(MetricDefinition.fromMap).toList();
  }

  Future<void> markDeleted({required String id, required int updatedAt}) async {
    final db = await database;
    await db.update(
      _table,
      {'deleted': 1, 'dirty': 1, 'updated_at': updatedAt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markClean(String id) async {
    final db = await database;
    await db.update(_table, {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> purgeDeleted(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceAllFromCloud(List<MetricDefinition> definitions) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(_table);

      for (final definition in definitions) {
        final map = definition.toMap()..['dirty'] = 0;
        await txn.insert(
          _table,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_table);
  }
}
