import 'package:sqflite/sqflite.dart';

import 'package:habit_control/screens/input_log/models/metric_definition.dart';
import 'package:habit_control/shared/data/local/app_local_db.dart';

class MetricDefinitionDb {
  MetricDefinitionDb._();

  static final MetricDefinitionDb instance = MetricDefinitionDb._();

  static const _table = 'metric_definitions';

  Future<Database> get database => AppLocalDb.instance.database;

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
