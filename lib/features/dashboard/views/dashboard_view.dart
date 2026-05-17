import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/core/state/selected_day_view_model.dart';
import 'package:habit_control/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:habit_control/features/dashboard/viewmodels/weather_view_model.dart';
import 'package:habit_control/features/dashboard/widgets/daily_progress_card.dart';
import 'package:habit_control/features/dashboard/widgets/dashboard_date_selector_card.dart';
import 'package:habit_control/features/dashboard/widgets/insight_card.dart';
import 'package:habit_control/features/dashboard/widgets/metrics_summary_card.dart';
import 'package:habit_control/features/dashboard/widgets/weather_card.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_top_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSelectedDayData();
    });
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 20) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  Future<void> _loadSelectedDayData() async {
    final selectedDay = context.read<SelectedDayViewModel>();
    final metrics = context.read<MetricsViewModel>();
    final habitDay = context.read<HabitDayViewModel>();

    final dayKey = selectedDay.selectedDayKey;

    await metrics.loadEntriesForDay(dayKey);
    await metrics.syncDayFromCloud(dayKey);
    await habitDay.syncDayFromCloud(dayKey);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.watch<SelectedDayViewModel>();
    final habitCatalog = context.watch<HabitCatalogViewModel>();
    final habitDay = context.watch<HabitDayViewModel>();
    final metrics = context.watch<MetricsViewModel>();
    final weather = context.watch<WeatherViewModel>();

    final viewModel = DashboardViewModel(
      habitCatalog: habitCatalog,
      habitDay: habitDay,
      metrics: metrics,
      weather: weather,
      dayKey: selectedDay.selectedDayKey,
    );

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      drawer: const Drawer(child: LateralMenu()),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const AppTopBar(title: 'DASHBOARD'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_greeting(), style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),

                DashboardDateSelectorCard(
                  selectedDay: selectedDay.selectedDay,
                  isToday: selectedDay.isToday,
                  canGoNextDay: selectedDay.canGoNextDay,
                  onPreviousDay: () async {
                    selectedDay.goPreviousDay();
                    await _loadSelectedDayData();
                  },
                  onNextDay: () async {
                    selectedDay.goNextDay();
                    await _loadSelectedDayData();
                  },
                  onToday: () async {
                    selectedDay.resetToToday();
                    await _loadSelectedDayData();
                  },
                ),
                const SizedBox(height: 16),
                WeatherCard(
                  weather: weather.weather,
                  loading: weather.loading,
                  error: weather.error,
                ),
                const SizedBox(height: 16),
                InsightCard(insight: viewModel.insight),
                const SizedBox(height: 16),
                DailyProgressCard(
                  completedHabits: viewModel.completedHabits,
                  totalHabits: viewModel.totalHabits,
                ),
                const SizedBox(height: 16),
                MetricsSummaryCard(metrics: viewModel.metricItems),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
