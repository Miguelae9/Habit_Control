import 'package:sqflite/sqflite.dart';

import 'package:habit_control/shared/data/local/app_local_db.dart';

class HabitDayDb {
  HabitDayDb._();

  static final HabitDayDb instance = HabitDayDb._();

  Future<Database> get database => AppLocalDb.instance.database;

  Future<Map<String, Set<String>>> getAllDoneByDay() async {
    final db = await database;

    final rows = await db.query('habit_day_done');

    final result = <String, Set<String>>{};

    for (final row in rows) {
      final dayKey = row['day_key'] as String;
      final habitId = row['habit_id'] as String;

      result.putIfAbsent(dayKey, () => <String>{}).add(habitId);
    }

    return result;
  }

  Future<Set<String>> getDirtyDays() async {
    final db = await database;

    final rows = await db.query(
      'habit_days',
      columns: ['day_key'],
      where: 'dirty = 1',
    );

    return rows.map((row) => row['day_key'] as String).toSet();
  }

  Future<void> replaceDay({
    required String dayKey,
    required Set<String> habitIds,
    required bool dirty,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.insert('habit_days', {
        'day_key': dayKey,
        'updated_at': now,
        'dirty': dirty ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'habit_day_done',
        where: 'day_key = ?',
        whereArgs: [dayKey],
      );

      for (final habitId in habitIds) {
        await txn.insert('habit_day_done', {
          'day_key': dayKey,
          'habit_id': habitId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> markClean(String dayKey) async {
    final db = await database;

    await db.update(
      'habit_days',
      {'dirty': 0},
      where: 'day_key = ?',
      whereArgs: [dayKey],
    );
  }

  Future<void> clearAll() async {
    final db = await database;

    await db.delete('habit_day_done');
    await db.delete('habit_days');
  }
}
