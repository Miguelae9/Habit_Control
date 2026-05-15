import 'package:flutter/material.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/widgets/ui/app_card.dart';
import 'package:habit_control/shared/widgets/ui/app_section_title.dart';

import 'widgets/stat_card.dart';
import 'widgets/weekly_bar_chart.dart';

import 'package:provider/provider.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/screens/input_log/models/metric_definition.dart';

import 'package:habit_control/shared/services/stoic_quote_service.dart';

/// Analytics screen displaying weekly habit completion and summary stats.
///
/// Visible data sources:
/// - Weekly habit completion from [HabitDayStore]
/// - A random quote fetched via [StoicQuoteService]
class AnalyticsScreen extends StatefulWidget {
  /// Creates the analytics screen.
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _quoteText = '';
  String _quoteAuthor = '';

  StoicQuote? _nextQuote;

  DateTime _startOfWeek(DateTime d) {
    final DateTime date = DateTime(d.year, d.month, d.day);
    final int delta = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: delta));
  }

  DateTime _startOfMonth(DateTime d) {
    return DateTime(d.year, d.month, 1);
  }

  List<String> _dayKeysBetween(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    final keys = <String>[];
    DateTime current = normalizedStart;

    while (!current.isAfter(normalizedEnd)) {
      keys.add(dayKeyFromDate(current));
      current = current.add(const Duration(days: 1));
    }

    return keys;
  }

  List<String> _weekKeys(DateTime now) {
    final DateTime start = _startOfWeek(now);
    return _dayKeysBetween(start, start.add(const Duration(days: 6)));
  }

  List<String> _weekToDateKeys(DateTime now) {
    return _dayKeysBetween(_startOfWeek(now), now);
  }

  List<String> _previousWeekKeys(DateTime now) {
    final DateTime start = _startOfWeek(now).subtract(const Duration(days: 7));
    return _dayKeysBetween(start, start.add(const Duration(days: 6)));
  }

  List<String> _monthToDateKeys(DateTime now) {
    return _dayKeysBetween(_startOfMonth(now), now);
  }

  List<String> _dayNumberLabels(List<String> keys) {
    return keys.map((key) {
      final day = int.tryParse(key.substring(8, 10)) ?? 0;
      return day.toString();
    }).toList();
  }

  Future<void> _syncAnalyticsRangeIfPossible() async {
    final HabitDayStore habitStore = context.read<HabitDayStore>();
    final DailyMetricsStore metricsStore = context.read<DailyMetricsStore>();

    await habitStore.trySyncPending();
    await metricsStore.trySyncPending();

    final now = DateTime.now();

    final keys = <String>{
      ..._monthToDateKeys(now),
      ..._weekKeys(now),
      ..._previousWeekKeys(now),
    };

    for (final key in keys) {
      await habitStore.syncDayFromCloud(key);
      await metricsStore.syncDayFromCloud(key);
      await metricsStore.loadEntriesForDay(key);
    }
  }

  void _afterFirstFrame(Duration _) {
    _syncAnalyticsRangeIfPossible();
  }

  void _openDrawer() {
    final ScaffoldState? st = _scaffoldKey.currentState;
    if (st != null) {
      st.openDrawer();
    }
  }

  void _clearQuote() {
    _quoteText = '';
    _quoteAuthor = '';
    _nextQuote = null;
  }

  void _applyNextQuote() {
    if (_nextQuote == null) return;

    _quoteText = _nextQuote!.text.toUpperCase();
    _quoteAuthor = _nextQuote!.author.toUpperCase();
  }

  Future<void> _loadStoicQuote() async {
    try {
      final StoicQuoteService service = StoicQuoteService();
      final StoicQuote q = await service.fetchShortRandomQuote(maxWords: 20);

      _nextQuote = q;
      if (!mounted) return;

      setState(_applyNextQuote);
    } catch (_) {
      if (!mounted) return;
      // Failure is rendered as an empty quote section (see [_buildQuoteSection]).
      setState(_clearQuote);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterFirstFrame);
    _loadStoicQuote();
  }

  List<int> _computeDoneCounts({
    required HabitDayStore store,
    required List<String> keys,
    required Set<String> activeHabitIds,
  }) {
    final counts = <int>[];

    for (final dayKey in keys) {
      final doneIds = store.doneForDay(dayKey);
      final activeDoneCount = doneIds.where(activeHabitIds.contains).length;
      counts.add(activeDoneCount);
    }

    return counts;
  }

  List<double> _computeCompletionData({
    required HabitDayStore store,
    required List<String> keys,
    required Set<String> activeHabitIds,
  }) {
    final totalHabits = activeHabitIds.length;

    if (totalHabits == 0) {
      return List<double>.filled(keys.length, 0);
    }

    final doneCounts = _computeDoneCounts(
      store: store,
      keys: keys,
      activeHabitIds: activeHabitIds,
    );

    return doneCounts.map((count) => count / totalHabits).toList();
  }

  int _averagePct(List<double> data) {
    if (data.isEmpty) return 0;

    final sum = data.fold<double>(0, (total, value) => total + value);
    return ((sum / data.length) * 100).round();
  }

  int _computeStreak({
    required List<String> keys,
    required List<int> doneCounts,
  }) {
    int streak = 0;

    final String todayKey = dayKeyFromDate(DateTime.now());
    final int todayIndex = keys.indexOf(todayKey);

    if (todayIndex == -1) return 0;

    for (int i = todayIndex; i >= 0; i--) {
      if (doneCounts[i] > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  String _bestDayLabel({
    required List<String> keys,
    required List<double> data,
  }) {
    if (keys.isEmpty || data.isEmpty) return '--';

    int bestIndex = 0;

    for (int i = 1; i < data.length; i++) {
      if (data[i] > data[bestIndex]) {
        bestIndex = i;
      }
    }

    final pct = (data[bestIndex] * 100).round();
    final day = int.tryParse(keys[bestIndex].substring(8, 10)) ?? 0;

    return 'Day $day · $pct%';
  }

  String _comparisonLabel({
    required List<double> current,
    required List<double> previous,
  }) {
    final currentPct = _averagePct(current);
    final previousPct = _averagePct(previous);
    final diff = currentPct - previousPct;

    if (diff > 0) return '+$diff%';
    return '$diff%';
  }

  MetricDefinition? _findMetricByCategory({
    required List<MetricDefinition> definitions,
    required String category,
  }) {
    for (final definition in definitions) {
      if (definition.semanticCategory == category) {
        return definition;
      }
    }

    return null;
  }

  double? _averageMetricValue({
    required DailyMetricsStore store,
    required MetricDefinition? definition,
    required List<String> keys,
  }) {
    if (definition == null) return null;

    final values = <double>[];

    for (final key in keys) {
      final value = store.valueForDay(metricId: definition.id, dayKey: key);

      if (value > 0) {
        values.add(value);
      }
    }

    if (values.isEmpty) return null;

    final sum = values.fold<double>(0, (total, value) => total + value);
    return sum / values.length;
  }

  String _metricAverageLabel({
    required DailyMetricsStore store,
    required MetricDefinition? definition,
    required List<String> keys,
  }) {
    final avg = _averageMetricValue(
      store: store,
      definition: definition,
      keys: keys,
    );

    if (avg == null || definition == null) return '--';

    final unit = definition.unit ?? '';

    if (definition.valueType == 'int') {
      return '${avg.round()}$unit';
    }

    return '${avg.toStringAsFixed(1)}$unit';
  }

  String _topHabitLabel({
    required HabitCatalogStore catalogStore,
    required HabitDayStore store,
    required List<String> keys,
  }) {
    final habits = catalogStore.habits;
    if (habits.isEmpty) return '--';

    final activeIds = habits.map((habit) => habit.id).toSet();
    final counts = <String, int>{};

    for (final key in keys) {
      final doneIds = store.doneForDay(key);

      for (final id in doneIds) {
        if (!activeIds.contains(id)) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return '--';

    String bestId = counts.keys.first;

    for (final id in counts.keys) {
      if ((counts[id] ?? 0) > (counts[bestId] ?? 0)) {
        bestId = id;
      }
    }

    for (final habit in habits) {
      if (habit.id == bestId) {
        return '${habit.title} (${counts[bestId]})';
      }
    }

    return '--';
  }

  Widget _buildMenuButton(Color iconColor) {
    return IconButton(
      icon: Icon(Icons.menu, color: iconColor),
      onPressed: _openDrawer,
    );
  }

  Widget _buildQuoteSection(TextStyle quoteStyle, TextStyle authorStyle) {
    if (_quoteText.isEmpty || _quoteAuthor.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        Text('“$_quoteText”', textAlign: TextAlign.center, style: quoteStyle),
        const SizedBox(height: 18),
        Text(_quoteAuthor, textAlign: TextAlign.center, style: authorStyle),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color bg = theme.scaffoldBackgroundColor;

    final Color textMain =
        theme.textTheme.headlineLarge?.color ?? const Color(0xFFF8FAFC);

    final Color textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF94A3B8);

    final Color accent = theme.colorScheme.primary;
    final Color gridColor = textMuted.withValues(alpha: 0.18);
    final Color borderColor = accent.withValues(alpha: 0.35);
    final Color axisTextColor = textMuted.withValues(alpha: 0.85);
    final Color authorColor = textMuted.withValues(alpha: 0.75);

    final TextStyle quoteStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: 1.2,
      color: textMuted,
    );

    final TextStyle authorStyle = TextStyle(
      fontSize: 12,
      letterSpacing: 2.0,
      color: authorColor,
    );

    final List<String> weekLabels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final HabitDayStore store = context.watch<HabitDayStore>();
    final HabitCatalogStore catalogStore = context.watch<HabitCatalogStore>();
    final DailyMetricsStore metricsStore = context.watch<DailyMetricsStore>();

    final now = DateTime.now();

    final weekKeys = _weekKeys(now);
    final weekToDateKeys = _weekToDateKeys(now);
    final previousWeekKeys = _previousWeekKeys(now);
    final monthKeys = _monthToDateKeys(now);

    final monthLabels = _dayNumberLabels(monthKeys);

    final activeHabitIds = catalogStore.habits.map((habit) => habit.id).toSet();

    final weekData = _computeCompletionData(
      store: store,
      keys: weekKeys,
      activeHabitIds: activeHabitIds,
    );

    final weekToDateData = _computeCompletionData(
      store: store,
      keys: weekToDateKeys,
      activeHabitIds: activeHabitIds,
    );

    final previousWeekData = _computeCompletionData(
      store: store,
      keys: previousWeekKeys,
      activeHabitIds: activeHabitIds,
    );

    final monthData = _computeCompletionData(
      store: store,
      keys: monthKeys,
      activeHabitIds: activeHabitIds,
    );

    final doneCounts = _computeDoneCounts(
      store: store,
      keys: weekKeys,
      activeHabitIds: activeHabitIds,
    );

    final consistencyPct = _averagePct(weekToDateData);
    final monthlyPct = _averagePct(monthData);

    final streak = _computeStreak(keys: weekKeys, doneCounts: doneCounts);

    final comparison = _comparisonLabel(
      current: weekToDateData,
      previous: previousWeekData,
    );

    final bestDay = _bestDayLabel(keys: monthKeys, data: monthData);

    final topHabit = _topHabitLabel(
      catalogStore: catalogStore,
      store: store,
      keys: monthKeys,
    );

    final sleepMetric = _findMetricByCategory(
      definitions: metricsStore.getActiveDefinitions(),
      category: 'sleep',
    );

    final energyMetric = _findMetricByCategory(
      definitions: metricsStore.getActiveDefinitions(),
      category: 'energy',
    );

    final avgSleep = _metricAverageLabel(
      store: metricsStore,
      definition: sleepMetric,
      keys: monthKeys,
    );

    final avgEnergy = _metricAverageLabel(
      store: metricsStore,
      definition: energyMetric,
      keys: monthKeys,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
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
                    Row(
                      children: <Widget>[
                        _buildMenuButton(theme.colorScheme.primary),
                        const Spacer(),
                        Text(
                          'ANALYTICS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

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
                              data: weekData,
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
                            value: '$consistencyPct%',
                            showUpArrow: consistencyPct > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'VS LAST WEEK',
                            value: comparison,
                            showUpArrow: comparison.startsWith('+'),
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
                            value: '$streak DAYS',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(title: 'BEST DAY', value: bestDay),
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
                              data: monthData,
                              labels: monthLabels,
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
                            value: '$monthlyPct%',
                            showUpArrow: monthlyPct > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(title: 'TOP HABIT', value: topHabit),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: StatCard(title: 'AVG SLEEP', value: avgSleep),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'AVG ENERGY',
                            value: avgEnergy,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    if (_quoteText.isNotEmpty && _quoteAuthor.isNotEmpty)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const AppSectionTitle(
                              title: 'STOIC NOTE',
                              subtitle: 'Short reflection for your progress',
                              icon: Icons.format_quote,
                            ),
                            const SizedBox(height: 18),
                            _buildQuoteSection(quoteStyle, authorStyle),
                          ],
                        ),
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
