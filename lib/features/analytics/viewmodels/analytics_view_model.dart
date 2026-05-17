import 'package:habit_control/core/utils/date_range.dart';
import 'package:habit_control/core/utils/day_key.dart';
import 'package:habit_control/features/habits/models/habit.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/models/metric_definition.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';

/// Immutable presenter that derives every value rendered in the analytics
/// screen for the current moment.
///
/// Built on each frame from the observed VMs. Computes weekly/monthly
/// completion data, comparative stats and metric averages.
class AnalyticsViewModel {
  factory AnalyticsViewModel({
    required HabitDayViewModel habitDay,
    required HabitCatalogViewModel habitCatalog,
    required MetricsViewModel metrics,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();

    final weekKeys = weekKeysOf(now);
    final weekToDateKeys = dayKeysBetween(startOfWeek(now), now);
    final previousWeekStart = startOfWeek(
      now,
    ).subtract(const Duration(days: 7));
    final previousWeekKeys = dayKeysBetween(
      previousWeekStart,
      previousWeekStart.add(const Duration(days: 6)),
    );
    final monthKeys = dayKeysBetween(startOfMonth(now), now);

    final activeHabits = habitCatalog.habits;
    final activeHabitIds = activeHabits.map((h) => h.id).toSet();

    final weekData = _completionData(
      habitDay: habitDay,
      keys: weekKeys,
      activeHabitIds: activeHabitIds,
    );

    final weekToDateData = _completionData(
      habitDay: habitDay,
      keys: weekToDateKeys,
      activeHabitIds: activeHabitIds,
    );

    final previousWeekData = _completionData(
      habitDay: habitDay,
      keys: previousWeekKeys,
      activeHabitIds: activeHabitIds,
    );

    final monthData = _completionData(
      habitDay: habitDay,
      keys: monthKeys,
      activeHabitIds: activeHabitIds,
    );

    final doneCounts = _doneCounts(
      habitDay: habitDay,
      keys: weekKeys,
      activeHabitIds: activeHabitIds,
    );

    final definitions = metrics.getActiveDefinitions();
    final sleepDef = _metricByCategory(definitions, 'sleep');
    final energyDef = _metricByCategory(definitions, 'energy');

    return AnalyticsViewModel._(
      weekData: weekData,
      monthData: monthData,
      monthLabels: _dayNumberLabels(monthKeys),
      consistencyPct: _averagePct(weekToDateData),
      monthlyPct: _averagePct(monthData),
      streak: _streakFromToday(keys: weekKeys, doneCounts: doneCounts),
      comparison: _comparisonLabel(
        current: weekToDateData,
        previous: previousWeekData,
      ),
      bestDay: _bestDayLabel(keys: monthKeys, data: monthData),
      topHabit: _topHabitLabel(
        habits: activeHabits,
        habitDay: habitDay,
        keys: monthKeys,
      ),
      avgSleep: _metricAverageLabel(
        metrics: metrics,
        definition: sleepDef,
        keys: monthKeys,
      ),
      avgEnergy: _metricAverageLabel(
        metrics: metrics,
        definition: energyDef,
        keys: monthKeys,
      ),
    );
  }

  const AnalyticsViewModel._({
    required this.weekData,
    required this.monthData,
    required this.monthLabels,
    required this.consistencyPct,
    required this.monthlyPct,
    required this.streak,
    required this.comparison,
    required this.bestDay,
    required this.topHabit,
    required this.avgSleep,
    required this.avgEnergy,
  });

  final List<double> weekData;
  final List<double> monthData;
  final List<String> monthLabels;
  final int consistencyPct;
  final int monthlyPct;
  final int streak;
  final String comparison;
  final String bestDay;
  final String topHabit;
  final String avgSleep;
  final String avgEnergy;
}

List<int> _doneCounts({
  required HabitDayViewModel habitDay,
  required List<String> keys,
  required Set<String> activeHabitIds,
}) {
  final counts = <int>[];
  for (final key in keys) {
    final doneIds = habitDay.doneForDay(key);
    counts.add(doneIds.where(activeHabitIds.contains).length);
  }
  return counts;
}

List<double> _completionData({
  required HabitDayViewModel habitDay,
  required List<String> keys,
  required Set<String> activeHabitIds,
}) {
  final total = activeHabitIds.length;
  if (total == 0) return List<double>.filled(keys.length, 0);

  return _doneCounts(
    habitDay: habitDay,
    keys: keys,
    activeHabitIds: activeHabitIds,
  ).map((count) => count / total).toList();
}

int _averagePct(List<double> data) {
  if (data.isEmpty) return 0;
  final sum = data.fold<double>(0, (total, value) => total + value);
  return ((sum / data.length) * 100).round();
}

int _streakFromToday({
  required List<String> keys,
  required List<int> doneCounts,
}) {
  final todayKey = dayKeyFromDate(DateTime.now());
  final todayIndex = keys.indexOf(todayKey);
  if (todayIndex == -1) return 0;

  int streak = 0;
  for (int i = todayIndex; i >= 0; i--) {
    if (doneCounts[i] > 0) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

String _comparisonLabel({
  required List<double> current,
  required List<double> previous,
}) {
  final diff = _averagePct(current) - _averagePct(previous);
  return diff > 0 ? '+$diff%' : '$diff%';
}

String _bestDayLabel({required List<String> keys, required List<double> data}) {
  if (keys.isEmpty || data.isEmpty) return '--';

  int best = 0;
  for (int i = 1; i < data.length; i++) {
    if (data[i] > data[best]) best = i;
  }

  final pct = (data[best] * 100).round();
  final day = int.tryParse(keys[best].substring(8, 10)) ?? 0;
  return 'Day $day · $pct%';
}

String _topHabitLabel({
  required List<Habit> habits,
  required HabitDayViewModel habitDay,
  required List<String> keys,
}) {
  if (habits.isEmpty) return '--';

  final activeIds = habits.map((h) => h.id).toSet();
  final counts = <String, int>{};

  for (final key in keys) {
    for (final id in habitDay.doneForDay(key)) {
      if (!activeIds.contains(id)) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
  }

  if (counts.isEmpty) return '--';

  String bestId = counts.keys.first;
  for (final id in counts.keys) {
    if ((counts[id] ?? 0) > (counts[bestId] ?? 0)) bestId = id;
  }

  for (final habit in habits) {
    if (habit.id == bestId) return '${habit.title} (${counts[bestId]})';
  }
  return '--';
}

MetricDefinition? _metricByCategory(
  List<MetricDefinition> definitions,
  String category,
) {
  for (final def in definitions) {
    if (def.semanticCategory == category) return def;
  }
  return null;
}

String _metricAverageLabel({
  required MetricsViewModel metrics,
  required MetricDefinition? definition,
  required List<String> keys,
}) {
  if (definition == null) return '--';

  final values = <double>[];
  for (final key in keys) {
    final value = metrics.valueForDay(metricId: definition.id, dayKey: key);
    if (value > 0) values.add(value);
  }

  if (values.isEmpty) return '--';

  final avg = values.fold<double>(0, (sum, v) => sum + v) / values.length;
  final unit = definition.unit ?? '';

  if (definition.valueType == 'int') return '${avg.round()}$unit';
  return '${avg.toStringAsFixed(1)}$unit';
}

List<String> _dayNumberLabels(List<String> keys) {
  return keys
      .map((key) => (int.tryParse(key.substring(8, 10)) ?? 0).toString())
      .toList();
}
