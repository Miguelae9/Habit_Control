import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_control/core/utils/day_key.dart';
import 'package:habit_control/features/habits/data/habit_day_db.dart';

/// Tracks which habits were marked as done on which day.
///
/// Persists locally in SQLite and synchronises with Firestore using a
/// dirty-flag offline-first strategy.
class HabitDayViewModel extends ChangeNotifier {
  HabitDayViewModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    HabitDayDb? db,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _localDb = db ?? HabitDayDb.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final HabitDayDb _localDb;

  final Map<String, Set<String>> _doneByDay = {};
  final Set<String> _pendingDays = <String>{};

  bool _loadedLocal = false;

  bool get loadedLocal => _loadedLocal;

  /// Returns the set of habit IDs marked as done for [dayKey].
  Set<String> doneForDay(String dayKey) {
    return _doneByDay[dayKey] ?? <String>{};
  }

  /// Loads from SQLite the complete map of done habits per day.
  Future<void> loadLocal() async {
    final localDone = await _localDb.getAllDoneByDay();
    final dirtyDays = await _localDb.getDirtyDays();

    _doneByDay
      ..clear()
      ..addAll(localDone);

    _pendingDays
      ..clear()
      ..addAll(dirtyDays);

    _loadedLocal = true;
    notifyListeners();
  }

  /// Replaces the local state for [dayKey] with the server's value.
  Future<void> syncDayFromCloud(String dayKey) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final resolved = await _db
          .collection('users')
          .doc(uid)
          .collection('days')
          .doc(dayKey)
          .get();

      if (!resolved.exists) return;

      final data = resolved.data();
      final list =
          (data?['doneHabitIds'] as List?)?.cast<String>() ?? <String>[];

      final ids = list.toSet();
      _doneByDay[dayKey] = ids;
      _pendingDays.remove(dayKey);

      await _localDb.replaceDay(dayKey: dayKey, habitIds: ids, dirty: false);

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint('Firestore syncDayFromCloud failed: ${e.code}');
    } catch (e) {
      debugPrint('syncDayFromCloud failed: $e');
    }
  }

  /// Toggles a habit on/off for [dayKey] and schedules a remote sync.
  Future<void> toggleHabitForDay({
    required String dayKey,
    required String habitId,
  }) async {
    final set = _doneByDay.putIfAbsent(dayKey, () => <String>{});

    if (set.contains(habitId)) {
      set.remove(habitId);
    } else {
      set.add(habitId);
    }

    _pendingDays.add(dayKey);

    notifyListeners();

    await _localDb.replaceDay(dayKey: dayKey, habitIds: set, dirty: true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _db.collection('users').doc(uid).collection('days').doc(dayKey).set(
        {
          'doneHabitIds': set.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _pendingDays.remove(dayKey);
      await _localDb.markClean(dayKey);
    } on FirebaseException catch (e) {
      debugPrint('Firestore toggle save failed: ${e.code}');
    } catch (e) {
      debugPrint('toggle save failed: $e');
    }
  }

  /// Pushes any locally-modified day records to Firestore.
  Future<void> trySyncPending() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final dirtyDays = await _localDb.getDirtyDays();

    _pendingDays
      ..clear()
      ..addAll(dirtyDays);

    if (_pendingDays.isEmpty) return;

    final days = _pendingDays.toList();

    for (final dayKey in days) {
      final set = _doneByDay[dayKey] ?? <String>{};

      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('days')
            .doc(dayKey)
            .set({
              'doneHabitIds': set.toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        _pendingDays.remove(dayKey);
        await _localDb.markClean(dayKey);
      } on FirebaseException catch (e) {
        debugPrint('trySyncPending habits failed: ${e.code}');
      } catch (e) {
        debugPrint('trySyncPending habits failed: $e');
      }
    }
  }

  /// Wipes both in-memory and local persisted state.
  Future<void> clearAll() async {
    _doneByDay.clear();
    _pendingDays.clear();
    _loadedLocal = false;

    notifyListeners();

    await _localDb.clearAll();
  }

  /// Counts the consecutive days the habit has been done up to [today].
  ///
  /// Stops at the first day where the habit was not done. Days that have
  /// not been synced locally are treated as not done.
  int streakOf(String habitId, {DateTime? today}) {
    final DateTime reference = today ?? DateTime.now();
    DateTime current = DateTime(reference.year, reference.month, reference.day);
    int streak = 0;

    while (true) {
      final String key = dayKeyFromDate(current);
      final Set<String> doneIds = doneForDay(key);
      if (!doneIds.contains(habitId)) {
        break;
      }
      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
