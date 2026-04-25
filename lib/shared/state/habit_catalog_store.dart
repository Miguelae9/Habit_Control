import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:habit_control/screens/habits/models/habit.dart';
import 'package:habit_control/shared/data/local/habit_catalog_db.dart';

class HabitCatalogStore extends ChangeNotifier {
  HabitCatalogStore({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    HabitCatalogDb? db,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _localDb = db ?? HabitCatalogDb.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final HabitCatalogDb _localDb;

  final List<Habit> _habits = <Habit>[];
  bool _loadedLocal = false;

  List<Habit> get habits => List.unmodifiable(_habits);

  bool get loadedLocal => _loadedLocal;

  Future<void> loadLocal() async {
    final items = await _localDb.getActiveHabits();

    _habits
      ..clear()
      ..addAll(items);

    _loadedLocal = true;
    notifyListeners();
  }

  Future<void> addHabit({
    required String title,
    required String streakText,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'habit_$now';

    final habit = Habit(
      id: id,
      title: title.trim().toUpperCase(),
      streakText: streakText.trim().isEmpty
          ? 'STREAK: 0 DAYS'
          : streakText.trim().toUpperCase(),
      position: _habits.length,
      updatedAt: now,
    );

    _habits.add(habit);
    notifyListeners();

    await _localDb.insertOrReplace(habit, dirty: true);
    unawaited(trySyncPending());
  }

  Future<void> updateHabit({
    required Habit original,
    required String title,
    required String streakText,
  }) async {
    final index = _habits.indexWhere((h) => h.id == original.id);
    if (index == -1) return;

    final updated = original.copyWith(
      title: title.trim().toUpperCase(),
      streakText: streakText.trim().isEmpty
          ? original.streakText
          : streakText.trim().toUpperCase(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _habits[index] = updated;
    notifyListeners();

    await _localDb.insertOrReplace(updated, dirty: true);
    unawaited(trySyncPending());
  }

  Future<void> deleteHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    _habits.removeAt(index);

    for (int i = 0; i < _habits.length; i++) {
      final updated = _habits[i].copyWith(position: i);
      _habits[i] = updated;
      await _localDb.insertOrReplace(updated, dirty: true);
    }

    notifyListeners();

    await _localDb.markDeleted(
      id: id,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    unawaited(trySyncPending());
  }

  Future<void> syncFromCloud() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('habits')
          .orderBy('position')
          .get();

      final habits = snapshot.docs.map((doc) {
        final data = doc.data();
        return Habit(
          id: doc.id,
          title: (data['title'] as String?) ?? '',
          streakText: (data['streakText'] as String?) ?? 'STREAK: 0 DAYS',
          position: (data['position'] as num?)?.toInt() ?? 0,
          updatedAt: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
          deleted: false,
        );
      }).toList();

      await _localDb.replaceAllFromCloud(habits);

      _habits
        ..clear()
        ..addAll(habits);

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint('HabitCatalog syncFromCloud failed: ${e.code}');
    } catch (e) {
      debugPrint('HabitCatalog syncFromCloud failed: $e');
    }
  }

  Future<void> trySyncPending() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final dirtyHabits = await _localDb.getDirtyHabits();
    if (dirtyHabits.isEmpty) return;

    for (final habit in dirtyHabits) {
      try {
        final ref = _db
            .collection('users')
            .doc(uid)
            .collection('habits')
            .doc(habit.id);

        if (habit.deleted) {
          await ref.delete();
          await _localDb.purgeDeleted(habit.id);
        } else {
          await ref.set({
            'title': habit.title,
            'streakText': habit.streakText,
            'position': habit.position,
            'updatedAtMs': habit.updatedAt,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await _localDb.markClean(habit.id);
        }
      } on FirebaseException catch (e) {
        debugPrint('HabitCatalog trySyncPending failed: ${e.code}');
      } catch (e) {
        debugPrint('HabitCatalog trySyncPending failed: $e');
      }
    }
  }

  Future<void> clearAll() async {
    _habits.clear();
    _loadedLocal = false;
    notifyListeners();
    await _localDb.clearAll();
  }
}
