import 'package:sqflite/sqflite.dart';

import 'package:habit_control/screens/habits/models/habit.dart';
import 'package:habit_control/shared/data/local/app_local_db.dart';

class HabitCatalogDb {
  HabitCatalogDb._();

  static final HabitCatalogDb instance = HabitCatalogDb._();

  static const _table = 'habits';

  Future<Database> get database => AppLocalDb.instance.database;

  Future<List<Habit>> getActiveHabits() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'deleted = 0',
      orderBy: 'position ASC',
    );

    return rows.map(Habit.fromMap).toList();
  }

  Future<List<Habit>> getDirtyHabits() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'dirty = 1',
      orderBy: 'position ASC',
    );

    return rows.map(Habit.fromMap).toList();
  }

  Future<void> insertOrReplace(Habit habit, {bool dirty = true}) async {
    final db = await database;
    final map = habit.toMap()..['dirty'] = dirty ? 1 : 0;

    await db.insert(_table, map, conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<void> replaceAllFromCloud(List<Habit> habits) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(_table);

      for (final habit in habits) {
        final map = habit.toMap()..['dirty'] = 0;

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
