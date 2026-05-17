import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/core/utils/date_range.dart';
import 'package:habit_control/features/analytics/viewmodels/analytics_view_model.dart';
import 'package:habit_control/features/analytics/viewmodels/quote_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/features/analytics/widgets/stat_card.dart';
import 'package:habit_control/features/analytics/widgets/weekly_bar_chart.dart';
import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';
import 'package:habit_control/shared/app_top_bar.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final QuoteViewModel _quoteVm = QuoteViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAnalyticsRangeIfPossible();
    });
    _quoteVm.load();
  }

  @override
  void dispose() {
    _quoteVm.dispose();
    super.dispose();
  }

  Future<void> _syncAnalyticsRangeIfPossible() async {
    final habitDay = context.read<HabitDayViewModel>();
    final metrics = context.read<MetricsViewModel>();

    await habitDay.trySyncPending();
    await metrics.trySyncPending();

    final now = DateTime.now();
    final previousWeekStart = startOfWeek(
      now,
    ).subtract(const Duration(days: 7));

    final keys = <String>{
      ...dayKeysBetween(startOfMonth(now), now),
      ...weekKeysOf(now),
      ...dayKeysBetween(
        previousWeekStart,
        previousWeekStart.add(const Duration(days: 6)),
      ),
    };

    for (final key in keys) {
      await habitDay.syncDayFromCloud(key);
      await metrics.syncDayFromCloud(key);
      await metrics.loadEntriesForDay(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF94A3B8);
    final accent = theme.colorScheme.primary;
    final gridColor = textMuted.withValues(alpha: 0.18);
    final borderColor = accent.withValues(alpha: 0.35);
    final axisTextColor = textMuted.withValues(alpha: 0.85);

    const weekLabels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final viewModel = AnalyticsViewModel(
      habitDay: context.watch<HabitDayViewModel>(),
      habitCatalog: context.watch<HabitCatalogViewModel>(),
      metrics: context.watch<MetricsViewModel>(),
    );

    return Scaffold(
      appBar: const AppTopBar(title: 'ANALYTICS'),
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(child: LateralMenu()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const AppSectionTitle(
                            title: 'WEEKLY PERFORMANCE',
                            subtitle: 'Habit completion from Monday to Sunday',
                            icon: Icons.bar_chart,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 280,
                            child: WeeklyBarChart(
                              data: viewModel.weekData,
                              labels: weekLabels,
                              accent: accent,
                              gridColor: gridColor,
                              borderColor: borderColor,
                              axisTextColor: axisTextColor,
                              labelTextColor: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            title: 'CONSISTENCY',
                            value: '${viewModel.consistencyPct}%',
                            showUpArrow: viewModel.consistencyPct > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'VS LAST WEEK',
                            value: viewModel.comparison,
                            showUpArrow: viewModel.comparison.startsWith('+'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            title: 'CURRENT STREAK',
                            value: '${viewModel.streak} DAYS',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'BEST DAY',
                            value: viewModel.bestDay,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const AppSectionTitle(
                            title: 'MONTHLY OVERVIEW',
                            subtitle: 'Completion trend for the current month',
                            icon: Icons.calendar_month,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: WeeklyBarChart(
                              data: viewModel.monthData,
                              labels: viewModel.monthLabels,
                              accent: accent,
                              gridColor: gridColor,
                              borderColor: borderColor,
                              axisTextColor: axisTextColor,
                              labelTextColor: textMuted,
                              barWidth: 7,
                              labelStep: 5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            title: 'MONTH AVG',
                            value: '${viewModel.monthlyPct}%',
                            showUpArrow: viewModel.monthlyPct > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'TOP HABIT',
                            value: viewModel.topHabit,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(
                            title: 'AVG SLEEP',
                            value: viewModel.avgSleep,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'AVG ENERGY',
                            value: viewModel.avgEnergy,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    ListenableBuilder(
                      listenable: _quoteVm,
                      builder: (context, _) {
                        if (!_quoteVm.hasQuote) {
                          return const SizedBox.shrink();
                        }
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const AppSectionTitle(
                                title: 'STOIC NOTE',
                                subtitle: 'Short reflection for your progress',
                                icon: Icons.format_quote,
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: Text(
                                  '“${_quoteVm.text}”',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    letterSpacing: 1.2,
                                    color: textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: Text(
                                  _quoteVm.author,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 2.0,
                                    color: textMuted.withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
