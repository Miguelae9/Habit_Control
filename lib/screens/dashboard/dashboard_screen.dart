import 'package:flutter/material.dart';
import 'package:habit_control/screens/dashboard/widgets/daily_progress_card.dart';
import 'package:habit_control/screens/dashboard/widgets/dashboard_header.dart';
import 'package:habit_control/screens/dashboard/widgets/insight_card.dart';
import 'package:habit_control/screens/dashboard/widgets/metrics_summary_card.dart';
import 'package:habit_control/screens/dashboard/widgets/weather_card.dart';
import 'package:habit_control/screens/dashboard/widgets/dashboard_date_selector_card.dart';
import 'package:habit_control/shared/state/weather_store.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';
import 'package:habit_control/screens/dashboard/services/daily_insight_service.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/state/selected_day_store.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSelectedDayData();
    });
  }

  Future<void> _loadSelectedDayData() async {
    final selectedDayStore = context.read<SelectedDayStore>();
    final metricsStore = context.read<DailyMetricsStore>();
    final habitDayStore = context.read<HabitDayStore>();

    final dayKey = selectedDayStore.selectedDayKey;

    await metricsStore.loadEntriesForDay(dayKey);
    await metricsStore.syncDayFromCloud(dayKey);
    await habitDayStore.syncDayFromCloud(dayKey);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayStore = context.watch<SelectedDayStore>();
    final selectedDay = selectedDayStore.selectedDay;
    final selectedDayKey = selectedDayStore.selectedDayKey;

    final habitDayStore = context.watch<HabitDayStore>();
    final metricsStore = context.watch<DailyMetricsStore>();
    final weatherStore = context.watch<WeatherStore>();

    // Ajusta esta línea si en tu store el getter no se llama exactamente "habits".
    final habitCatalogStore = context.watch<HabitCatalogStore>();
    final activeHabits = habitCatalogStore.habits;

    final doneToday = habitDayStore.doneForDay(selectedDayKey);
    final completedHabits = activeHabits
        .where((habit) => doneToday.contains(habit.id))
        .length;
    final totalHabits = activeHabits.length;

    final activeDefinitions = metricsStore.getActiveDefinitions();

    final metrics = activeDefinitions.take(3).map((definition) {
      final rawValue = metricsStore.valueForDay(
        metricId: definition.id,
        dayKey: selectedDayKey,
      );

      final formattedValue = _formatMetricValue(
        value: rawValue,
        valueType: definition.valueType,
        unit: definition.unit,
      );

      return MetricSummaryItem(label: definition.name, value: formattedValue);
    }).toList();

    final insightMetrics = activeDefinitions.map((definition) {
      final value = metricsStore.valueForDay(
        metricId: definition.id,
        dayKey: selectedDayKey,
      );

      return InsightMetric(
        name: definition.name,
        semanticCategory: definition.semanticCategory,
        value: value,
        interpretation: definition.interpretation,
        unit: definition.unit,
      );
    }).toList();

    final insight = const DailyInsightService().buildInsight(
      habits: activeHabits,
      completedHabitIds: doneToday,
      metrics: insightMetrics,
      weatherContext: weatherStore.weather?.habitContext,
    );

    return Scaffold(
      drawer: const Drawer(child: LateralMenu()),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),

                const SizedBox(height: 16),

                DashboardDateSelectorCard(
                  selectedDay: selectedDay,
                  isToday: selectedDayStore.isToday,
                  canGoNextDay: selectedDayStore.canGoNextDay,
                  onPreviousDay: () async {
                    selectedDayStore.goPreviousDay();
                    await _loadSelectedDayData();
                  },
                  onNextDay: () async {
                    selectedDayStore.goNextDay();
                    await _loadSelectedDayData();
                  },
                  onToday: () async {
                    selectedDayStore.resetToToday();
                    await _loadSelectedDayData();
                  },
                ),
                const SizedBox(height: 16),
                WeatherCard(
                  weather: weatherStore.weather,
                  loading: weatherStore.loading,
                  error: weatherStore.error,
                ),
                const SizedBox(height: 16),
                InsightCard(insight: insight),
                const SizedBox(height: 16),
                DailyProgressCard(
                  completedHabits: completedHabits,
                  totalHabits: totalHabits,
                ),
                const SizedBox(height: 16),
                MetricsSummaryCard(metrics: metrics),
              ],
            ),
          ),
        ),
      ),
    );
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
}
