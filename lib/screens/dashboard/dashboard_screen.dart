import 'package:flutter/material.dart';
import 'package:habit_control/screens/dashboard/widgets/daily_progress_card.dart';
import 'package:habit_control/screens/dashboard/widgets/dashboard_header.dart';
import 'package:habit_control/screens/dashboard/widgets/insight_card.dart';
import 'package:habit_control/screens/dashboard/widgets/metrics_summary_card.dart';
import 'package:habit_control/screens/dashboard/widgets/weather_card.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final String _todayKey;

  @override
  void initState() {
    super.initState();
    _todayKey = dayKeyFromDate(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final metricsStore = context.read<DailyMetricsStore>();
      await metricsStore.loadEntriesForDay(_todayKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitDayStore = context.watch<HabitDayStore>();
    final metricsStore = context.watch<DailyMetricsStore>();

    // Ajusta esta línea si en tu store el getter no se llama exactamente "habits".
    final habitCatalogStore = context.watch<HabitCatalogStore>();
    final activeHabits = habitCatalogStore.habits;

    final doneToday = habitDayStore.doneForDay(_todayKey);
    final completedHabits = activeHabits
        .where((habit) => doneToday.contains(habit.id))
        .length;
    final totalHabits = activeHabits.length;

    final activeDefinitions = metricsStore.getActiveDefinitions();

    final metrics = activeDefinitions.take(3).map((definition) {
      final rawValue = metricsStore.valueForDay(
        metricId: definition.id,
        dayKey: _todayKey,
      );

      final formattedValue = _formatMetricValue(
        value: rawValue,
        valueType: definition.valueType,
        unit: definition.unit,
      );

      return MetricSummaryItem(label: definition.name, value: formattedValue);
    }).toList();

    return Scaffold(
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),
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
                const WeatherCard(),
                const SizedBox(height: 16),
                const InsightCard(),
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
    return '$textValue ${unit!.trim()}';
  }
}
