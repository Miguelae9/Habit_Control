import 'package:sqflite/sqflite.dart';

import 'package:habit_control/screens/input_log/models/metric_entry.dart';
import 'package:habit_control/shared/data/local/app_local_db.dart';

class MetricEntryDb {
  MetricEntryDb._();

  static final MetricEntryDb instance = MetricEntryDb._();

  static const _table = 'metric_entries';

  Future<Database> get database => AppLocalDb.instance.database;

  Future<List<MetricEntry>> getEntriesForDay(String dayKey) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'day_key = ?',
      whereArgs: [dayKey],
      orderBy: 'metric_id ASC',
    );

    return rows.map(MetricEntry.fromMap).toList();
  }

  Future<void> insertOrReplace(MetricEntry entry, {bool dirty = true}) async {
    final db = await database;
    final map = entry.toMap()..['dirty'] = dirty ? 1 : 0;

    await db.insert(_table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MetricEntry>> getDirtyEntries() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'dirty = 1',
      orderBy: 'day_key ASC, metric_id ASC',
    );

    return rows.map(MetricEntry.fromMap).toList();
  }

  Future<void> markClean({
    required String metricId,
    required String dayKey,
  }) async {
    final db = await database;

    await db.update(
      _table,
      {'dirty': 0},
      where: 'metric_id = ? AND day_key = ?',
      whereArgs: [metricId, dayKey],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_table);
  }
}
