import 'package:habit_control/features/dashboard/data/daily_insight_service.dart';
import 'package:habit_control/features/dashboard/models/insight_metric.dart';
import 'package:habit_control/features/dashboard/viewmodels/weather_view_model.dart';
import 'package:habit_control/features/dashboard/widgets/metrics_summary_card.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';

/// Immutable presenter that derives every value rendered in the dashboard
/// for a given day.
///
/// Built on each frame from the observed VMs. Keeps the view declarative
/// by exposing only formatted, ready-to-render fields.
class DashboardViewModel {
  factory DashboardViewModel({
    required HabitCatalogViewModel habitCatalog,
    required HabitDayViewModel habitDay,
    required MetricsViewModel metrics,
    required WeatherViewModel weather,
    required String dayKey,
    DailyInsightService insightService = const DailyInsightService(),
  }) {
    final activeHabits = habitCatalog.habits;
    final doneIds = habitDay.doneForDay(dayKey);
    final activeDefinitions = metrics.getActiveDefinitions();

    final metricItems = activeDefinitions.take(3).map((definition) {
      final value = metrics.valueForDay(
        metricId: definition.id,
        dayKey: dayKey,
      );
      return MetricSummaryItem(
        label: definition.name,
        value: _formatMetricValue(
          value: value,
          valueType: definition.valueType,
          unit: definition.unit,
        ),
      );
    }).toList();

    final insightInputs = activeDefinitions.map((definition) {
      final value = metrics.valueForDay(
        metricId: definition.id,
        dayKey: dayKey,
      );
      return InsightMetric(
        name: definition.name,
        semanticCategory: definition.semanticCategory,
        value: value,
        interpretation: definition.interpretation,
        unit: definition.unit,
      );
    }).toList();

    final insight = insightService.buildInsight(
      habits: activeHabits,
      completedHabitIds: doneIds,
      metrics: insightInputs,
      weatherContext: weather.weather?.habitContext,
    );

    final completedHabits = activeHabits
        .where((habit) => doneIds.contains(habit.id))
        .length;

    return DashboardViewModel._(
      metricItems: metricItems,
      insight: insight,
      completedHabits: completedHabits,
      totalHabits: activeHabits.length,
    );
  }

  const DashboardViewModel._({
    required this.metricItems,
    required this.insight,
    required this.completedHabits,
    required this.totalHabits,
  });

  final List<MetricSummaryItem> metricItems;
  final String insight;
  final int completedHabits;
  final int totalHabits;
}

String _formatMetricValue({
  required double value,
  required String valueType,
  String? unit,
}) {
  final normalizedType = valueType.trim().toLowerCase();
  final hasUnit = unit != null && unit.trim().isNotEmpty;

  final String textValue;
  if (normalizedType == 'int') {
    textValue = value.toInt().toString();
  } else {
    final isWhole = value == value.roundToDouble();
    textValue = isWhole ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  if (!hasUnit) return textValue;
  return '$textValue ${unit.trim()}';
}
