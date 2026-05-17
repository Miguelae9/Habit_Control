import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/features/input_log/models/metric_definition.dart';
import 'package:habit_control/features/input_log/widgets/metric_row.dart';
import 'package:habit_control/features/input_log/widgets/create_metric_dialog.dart';
import 'package:habit_control/features/input_log/widgets/edit_metric_dialog.dart';
import 'package:habit_control/core/state/selected_day_view_model.dart';
import 'package:habit_control/shared/app_top_bar.dart';

class InputLogView extends StatefulWidget {
  const InputLogView({super.key});

  @override
  State<InputLogView> createState() => _InputLogViewState();
}

class _InputLogViewState extends State<InputLogView> {
  String? _loadedDayKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScreenData();
    });
  }

  Future<void> _loadScreenData() async {
    final selectedDayStore = context.read<SelectedDayViewModel>();
    final store = context.read<MetricsViewModel>();

    final dayKey = selectedDayStore.selectedDayKey;

    if (_loadedDayKey == dayKey && !_loading) return;
    _loadedDayKey = dayKey;

    setState(() {
      _loading = true;
    });

    await store.loadLocal();
    await store.trySyncPending();
    await store.syncDefinitionsFromCloud();
    await store.syncDayFromCloud(dayKey);
    await store.loadEntriesForDay(dayKey);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
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
    final metricsStore = context.read<MetricsViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete metric'),
          content: Text('Delete "${definition.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await metricsStore.deleteMetricDefinition(definition.id);

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<MetricsViewModel>();

    final bg = theme.scaffoldBackgroundColor;
    final definitions = store.getActiveDefinitions();

    final selectedDayStore = context.watch<SelectedDayViewModel>();
    final selectedDayKey = selectedDayStore.selectedDayKey;

    if (_loadedDayKey != selectedDayKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadScreenData();
        }
      });
    }

    return Scaffold(
      appBar: const AppTopBar(title: 'INPUT LOG'),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMetricDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                  const AppCard(
                    child: AppSectionTitle(
                      title: 'DAILY METRICS',
                      subtitle: 'Enter context data for your daily analysis',
                      icon: Icons.monitor_heart_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (_loading)
                    const AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (definitions.isEmpty)
                    AppCard(
                      child: Text(
                        'No metrics available.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...definitions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final definition = entry.value;
                      final isProtected = store.isProtectedBaseMetric(
                        definition,
                      );

                      final value = store.valueForDay(
                        metricId: definition.id,
                        dayKey: selectedDayKey,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == definitions.length - 1 ? 0 : 12,
                        ),
                        child: MetricRow(
                          label: store.labelFor(definition),
                          value: store.valueText(definition, value),
                          onMinus: () => store.decrementValue(
                            def: definition,
                            dayKey: selectedDayKey,
                          ),
                          onPlus: () => store.incrementValue(
                            def: definition,
                            dayKey: selectedDayKey,
                          ),
                          onEdit: isProtected
                              ? null
                              : () => _openEditMetricDialog(definition),
                          onDelete: isProtected
                              ? null
                              : () => _confirmDeleteMetric(definition),
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
