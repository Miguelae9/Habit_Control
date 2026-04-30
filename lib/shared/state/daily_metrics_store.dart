import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:habit_control/screens/input_log/models/metric_definition.dart';
import 'package:habit_control/screens/input_log/models/metric_entry.dart';
import 'package:habit_control/shared/data/local/metric_definition_db.dart';
import 'package:habit_control/shared/data/local/metric_entry_db.dart';

/// Store de métricas diarias basado en:
/// - definiciones de métricas (qué es cada métrica)
/// - registros diarios por fecha (qué valor tuvo cada día)
///
/// Persistencia local:
/// - SQLite mediante [MetricDefinitionDb] y [MetricEntryDb]
///
/// Sincronización remota:
/// - Firestore en `users/{uid}/metric_definitions/{metricId}`
/// - Firestore en `users/{uid}/metric_entries/{metricId_dayKey}`
class DailyMetricsStore extends ChangeNotifier {
  DailyMetricsStore({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    MetricDefinitionDb? definitionsDb,
    MetricEntryDb? entriesDb,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _definitionsDb = definitionsDb ?? MetricDefinitionDb.instance,
       _entriesDb = entriesDb ?? MetricEntryDb.instance;

  static const String sleepMetricId = 'metric_sleep_hours';
  static const String energyMetricId = 'metric_energy';

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final MetricDefinitionDb _definitionsDb;
  final MetricEntryDb _entriesDb;

  final List<MetricDefinition> _definitions = <MetricDefinition>[];
  final Map<String, MetricEntry> _entriesByCompositeKey =
      <String, MetricEntry>{};

  bool _loadedLocal = false;

  List<MetricDefinition> get definitions => List.unmodifiable(_definitions);

  bool get loadedLocal => _loadedLocal;

  String _entryKey(String metricId, String dayKey) => '$metricId|$dayKey';

  /// Devuelve las definiciones activas ordenadas por posición.
  List<MetricDefinition> getActiveDefinitions() {
    final items = _definitions.where((item) => !item.deleted).toList();
    items.sort((a, b) => a.position.compareTo(b.position));
    return items;
  }

  /// Devuelve el valor numérico de una métrica para un día.
  /// Si no existe, devuelve 0.
  double valueForDay({required String metricId, required String dayKey}) {
    return _entriesByCompositeKey[_entryKey(metricId, dayKey)]?.numericValue ??
        0.0;
  }

  bool _isProtectedBaseMetricId(String id) {
    return id == sleepMetricId || id == energyMetricId;
  }

  /// Carga SQLite y si no hay definiciones, crea unas métricas base iniciales.
  Future<void> loadLocal() async {
    final localDefinitions = await _definitionsDb.getActiveDefinitions();

    _definitions
      ..clear()
      ..addAll(localDefinitions);

    await _ensureBaseDefinitions();

    _loadedLocal = true;
    notifyListeners();
  }

  Future<void> _ensureBaseDefinitions() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final baseDefinitions = <MetricDefinition>[
      MetricDefinition(
        id: sleepMetricId,
        name: 'SLEEP HOURS',
        semanticCategory: 'sleep',
        valueType: 'double',
        unit: 'h',
        interpretation: 'higher_better',
        position: 0,
        updatedAt: now,
      ),
      MetricDefinition(
        id: energyMetricId,
        name: 'ENERGY',
        semanticCategory: 'energy',
        valueType: 'int',
        unit: '/10',
        interpretation: 'higher_better',
        position: 1,
        updatedAt: now,
      ),
    ];

    var changed = false;

    for (final baseDefinition in baseDefinitions) {
      final index = _definitions.indexWhere(
        (item) => item.id == baseDefinition.id,
      );

      if (index == -1) {
        _definitions.add(baseDefinition);
        await _definitionsDb.insertOrReplace(baseDefinition, dirty: true);
        changed = true;
        continue;
      }

      final current = _definitions[index];

      if (current.deleted ||
          current.name != baseDefinition.name ||
          current.semanticCategory != baseDefinition.semanticCategory ||
          current.valueType != baseDefinition.valueType ||
          current.unit != baseDefinition.unit ||
          current.interpretation != baseDefinition.interpretation) {
        _definitions[index] = baseDefinition;
        await _definitionsDb.insertOrReplace(baseDefinition, dirty: true);
        changed = true;
      }
    }

    _definitions.sort((a, b) => a.position.compareTo(b.position));

    if (changed) {
      notifyListeners();
      unawaited(trySyncPending());
    }
  }

  /// Carga todos los registros de un día concreto desde SQLite.
  Future<void> loadEntriesForDay(String dayKey) async {
    final entries = await _entriesDb.getEntriesForDay(dayKey);

    for (final entry in entries) {
      _entriesByCompositeKey[_entryKey(entry.metricId, entry.dayKey)] = entry;
    }

    notifyListeners();
  }

  /// Guarda localmente el valor de una métrica para un día y marca pendiente de sync.
  Future<void> setMetricValue({
    required String metricId,
    required String dayKey,
    required double numericValue,
  }) async {
    final entry = MetricEntry(
      metricId: metricId,
      dayKey: dayKey,
      numericValue: numericValue,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _entriesByCompositeKey[_entryKey(metricId, dayKey)] = entry;
    notifyListeners();

    await _entriesDb.insertOrReplace(entry, dirty: true);
    unawaited(trySyncPending());
  }

  /// Permite crear una métrica personalizada estructurada.
  Future<void> addMetricDefinition({
    required String name,
    required String semanticCategory,
    required String valueType,
    required String interpretation,
    String? unit,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final definition = MetricDefinition(
      id: 'metric_$now',
      name: name.trim().toUpperCase(),
      semanticCategory: semanticCategory.trim(),
      valueType: valueType.trim(),
      unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
      interpretation: interpretation.trim(),
      position: _definitions.length,
      updatedAt: now,
    );

    _definitions.add(definition);
    notifyListeners();

    await _definitionsDb.insertOrReplace(definition, dirty: true);
    unawaited(trySyncPending());
  }

  /// Sincroniza pendientes locales a Firestore.
  Future<void> trySyncPending() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _syncDirtyDefinitions(uid);
    await _syncDirtyEntries(uid);
  }

  Future<void> _syncDirtyDefinitions(String uid) async {
    final dirtyDefinitions = await _definitionsDb.getDirtyDefinitions();
    if (dirtyDefinitions.isEmpty) return;

    for (final definition in dirtyDefinitions) {
      try {
        final ref = _db
            .collection('users')
            .doc(uid)
            .collection('metric_definitions')
            .doc(definition.id);

        if (definition.deleted) {
          await ref.delete();
          await _definitionsDb.purgeDeleted(definition.id);
        } else {
          await ref.set({
            'name': definition.name,
            'semanticCategory': definition.semanticCategory,
            'valueType': definition.valueType,
            'unit': definition.unit,
            'interpretation': definition.interpretation,
            'position': definition.position,
            'updatedAtMs': definition.updatedAt,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await _definitionsDb.markClean(definition.id);
        }
      } on FirebaseException catch (e) {
        debugPrint('DailyMetricsStore _syncDirtyDefinitions failed: ${e.code}');
      } catch (e) {
        debugPrint('DailyMetricsStore _syncDirtyDefinitions failed: $e');
      }
    }
  }

  Future<void> _syncDirtyEntries(String uid) async {
    final dirtyEntries = await _entriesDb.getDirtyEntries();
    if (dirtyEntries.isEmpty) return;

    for (final entry in dirtyEntries) {
      try {
        final docId = '${entry.metricId}_${entry.dayKey}';

        await _db
            .collection('users')
            .doc(uid)
            .collection('metric_entries')
            .doc(docId)
            .set({
              'metricId': entry.metricId,
              'dayKey': entry.dayKey,
              'numericValue': entry.numericValue,
              'updatedAtMs': entry.updatedAt,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        await _entriesDb.markClean(
          metricId: entry.metricId,
          dayKey: entry.dayKey,
        );
      } on FirebaseException catch (e) {
        debugPrint('DailyMetricsStore _syncDirtyEntries failed: ${e.code}');
      } catch (e) {
        debugPrint('DailyMetricsStore _syncDirtyEntries failed: $e');
      }
    }
  }

  /// Trae de Firestore las definiciones del usuario y sustituye las locales.
  Future<void> syncDefinitionsFromCloud() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('metric_definitions')
          .orderBy('position')
          .get();

      final definitions = snapshot.docs.map((doc) {
        final data = doc.data();

        return MetricDefinition(
          id: doc.id,
          name: (data['name'] as String?) ?? '',
          semanticCategory: (data['semanticCategory'] as String?) ?? '',
          valueType: (data['valueType'] as String?) ?? 'double',
          unit: data['unit'] as String?,
          interpretation: (data['interpretation'] as String?) ?? 'neutral',
          position: (data['position'] as num?)?.toInt() ?? 0,
          updatedAt: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
          deleted: false,
        );
      }).toList();

      await _definitionsDb.replaceAllFromCloud(definitions);

      _definitions
        ..clear()
        ..addAll(definitions);

      await _ensureBaseDefinitions();

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint(
        'DailyMetricsStore syncDefinitionsFromCloud failed: ${e.code}',
      );
    } catch (e) {
      debugPrint('DailyMetricsStore syncDefinitionsFromCloud failed: $e');
    }
  }

  /// Trae de Firestore los registros diarios del día indicado y los guarda en SQLite.
  Future<void> syncDayFromCloud(String dayKey) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('metric_entries')
          .where('dayKey', isEqualTo: dayKey)
          .get();

      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        final raw = data['numericValue'];

        return MetricEntry(
          metricId: (data['metricId'] as String?) ?? '',
          dayKey: (data['dayKey'] as String?) ?? dayKey,
          numericValue: raw is int ? raw.toDouble() : (raw as double? ?? 0.0),
          updatedAt: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      for (final entry in entries) {
        await _entriesDb.insertOrReplace(entry, dirty: false);
        _entriesByCompositeKey[_entryKey(entry.metricId, entry.dayKey)] = entry;
      }

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint('DailyMetricsStore syncDayFromCloud failed: ${e.code}');
    } catch (e) {
      debugPrint('DailyMetricsStore syncDayFromCloud failed: $e');
    }
  }

  Future<void> clearAll() async {
    _definitions.clear();
    _entriesByCompositeKey.clear();
    _loadedLocal = false;

    notifyListeners();

    await _definitionsDb.clearAll();
    await _entriesDb.clearAll();
  }

  Future<void> updateMetricDefinition({
    required String id,
    required String name,
    required String semanticCategory,
    required String valueType,
    required String interpretation,
    String? unit,
  }) async {
    if (_isProtectedBaseMetricId(id)) return;
    final index = _definitions.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = _definitions[index];
    final updated = current.copyWith(
      name: name.trim().toUpperCase(),
      semanticCategory: semanticCategory.trim(),
      valueType: valueType.trim(),
      interpretation: interpretation.trim(),
      unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _definitions[index] = updated;
    notifyListeners();

    await _definitionsDb.insertOrReplace(updated, dirty: true);
    unawaited(trySyncPending());
  }

  Future<void> deleteMetricDefinition(String id) async {
    if (_isProtectedBaseMetricId(id)) return;
    final index = _definitions.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = _definitions[index];
    final deleted = current.copyWith(
      deleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _definitions[index] = deleted;
    notifyListeners();

    await _definitionsDb.markDeleted(id: id, updatedAt: deleted.updatedAt);

    _definitions.removeWhere((item) => item.id == id);
    notifyListeners();

    unawaited(trySyncPending());
  }
}
