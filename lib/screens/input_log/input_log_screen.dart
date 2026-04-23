import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/widgets/online_badge.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';
import 'package:habit_control/screens/input_log/models/metric_definition.dart';
import 'package:habit_control/screens/input_log/widgets/metric_row.dart';
import 'package:habit_control/screens/input_log/widgets/create_metric_dialog.dart';
import 'package:habit_control/screens/input_log/widgets/edit_metric_dialog.dart';

/// Pantalla de registro diario de métricas.
///
/// Por ahora usa la fecha de hoy.
/// Más adelante podrá recibir la fecha activa global desde dashboard.
class InputLogScreen extends StatefulWidget {
  const InputLogScreen({super.key});

  @override
  State<InputLogScreen> createState() => _InputLogScreenState();
}

class _InputLogScreenState extends State<InputLogScreen> {
  late final String _dayKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dayKey = dayKeyFromDate(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScreenData();
    });
  }

  Future<void> _loadScreenData() async {
    final store = context.read<DailyMetricsStore>();

    await store.loadEntriesForDay(_dayKey);
    await store.syncDefinitionsFromCloud();
    await store.syncDayFromCloud(_dayKey);
    await store.loadEntriesForDay(_dayKey);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  double _stepFor(MetricDefinition definition) {
    switch (definition.valueType) {
      case 'int':
        return 1.0;
      case 'double':
        return 0.5;
      default:
        return 1.0;
    }
  }

  double _maxFor(MetricDefinition definition) {
    switch (definition.semanticCategory) {
      case 'sleep':
        return 24.0;
      case 'energy':
        return 10.0;
      case 'social':
        return 24.0;
      default:
        return 9999.0;
    }
  }

  double _minFor(MetricDefinition definition) {
    return 0.0;
  }

  String _labelFor(MetricDefinition definition) {
    if (definition.unit == null || definition.unit!.trim().isEmpty) {
      return definition.name;
    }
    return '${definition.name} (${definition.unit})';
  }

  String _valueText(MetricDefinition definition, double value) {
    if (definition.valueType == 'int') {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  Future<void> _changeValue(MetricDefinition definition, bool increase) async {
    final store = context.read<DailyMetricsStore>();

    final current = store.valueForDay(metricId: definition.id, dayKey: _dayKey);

    final step = _stepFor(definition);
    final min = _minFor(definition);
    final max = _maxFor(definition);

    final next = increase
        ? (current + step).clamp(min, max)
        : (current - step).clamp(min, max);

    await store.setMetricValue(
      metricId: definition.id,
      dayKey: _dayKey,
      numericValue: next,
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openCreateMetricDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateMetricDialog(),
    );

    if (created == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _openEditMetricDialog(MetricDefinition definition) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditMetricDialog(definition: definition),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDeleteMetric(MetricDefinition definition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar métrica'),
          content: Text('¿Quieres eliminar "${definition.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await context.read<DailyMetricsStore>().deleteMetricDefinition(
      definition.id,
    );

    if (!mounted) return;
    setState(() {});
  }

  bool _isProtectedBaseMetric(MetricDefinition definition) {
    return definition.id == 'metric_sleep_hours' ||
        definition.id == 'metric_energy';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<DailyMetricsStore>();

    final bg = theme.scaffoldBackgroundColor;
    final textMain = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final textMuted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final accent = theme.primaryColor;

    final definitions = store.getActiveDefinitions();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMetricDialog,
        child: const Icon(Icons.add),
      ),
      backgroundColor: bg,
      drawer: const Drawer(child: LateralMenu()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Builder(
                        builder: (BuildContext ctx) {
                          return IconButton(
                            icon: Icon(Icons.menu, color: textMain),
                            onPressed: () {
                              Scaffold.of(ctx).openDrawer();
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      OnlineBadge(textColor: textMain),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'DAILY METRICS',
                    textAlign: TextAlign.center,
                    style:
                        theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: textMain,
                          fontSize: 26,
                        ) ??
                        TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: textMain,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ENTER DATA FOR CALCULATION',
                    textAlign: TextAlign.center,
                    style:
                        theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 2,
                          color: textMuted,
                          fontSize: 11,
                        ) ??
                        TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: textMuted,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _dayKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textMuted,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (definitions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'NO METRICS AVAILABLE',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textMuted,
                          letterSpacing: 1.4,
                        ),
                      ),
                    )
                  else
                    ...definitions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final definition = entry.value;

                      final value = store.valueForDay(
                        metricId: definition.id,
                        dayKey: _dayKey,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == definitions.length - 1 ? 0 : 28,
                        ),
                        child: MetricRow(
                          label: _labelFor(definition),
                          value: _valueText(definition, value),
                          onMinus: () => _changeValue(definition, false),
                          onPlus: () => _changeValue(definition, true),
                          onEdit: _isProtectedBaseMetric(definition)
                              ? null
                              : () => _openEditMetricDialog(definition),
                          onDelete: _isProtectedBaseMetric(definition)
                              ? null
                              : () => _confirmDeleteMetric(definition),
                          textColor: textMuted,
                          valueColor: textMain,
                          accent: accent,
                          suffix: definition.unit,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
