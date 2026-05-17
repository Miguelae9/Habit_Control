import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habit_control/shared/app_top_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/features/habits/models/habit.dart';
import 'package:habit_control/features/habits/widgets/habit_tile.dart';
import 'package:habit_control/features/habits/widgets/habit_form_dialog.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';
import 'package:habit_control/core/state/selected_day_view_model.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  String? _loadedDayKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterFirstFrame);
  }

  Future<void> _loadSelectedDayData() async {
    final selectedDayStore = context.read<SelectedDayViewModel>();
    final dayStore = context.read<HabitDayViewModel>();
    final catalogStore = context.read<HabitCatalogViewModel>();

    final dayKey = selectedDayStore.selectedDayKey;

    if (_loadedDayKey == dayKey) return;
    _loadedDayKey = dayKey;

    await catalogStore.trySyncPending();
    await catalogStore.syncFromCloud();

    await dayStore.trySyncPending();
    await dayStore.syncDayFromCloud(dayKey);
  }

  Future<void> _afterFirstFrame(Duration _) async {
    await _loadSelectedDayData();
  }

  Future<void> _showHabitDialog({Habit? habit}) async {
    final HabitCatalogViewModel store = context.read<HabitCatalogViewModel>();

    final HabitDialogResult? result = await showDialog<HabitDialogResult>(
      context: context,
      builder: (dialogContext) {
        return HabitFormDialog(habit: habit);
      },
    );

    if (result == null) return;
    if (!mounted) return;

    if (habit == null) {
      await store.addHabit(title: result.title, category: result.category);
    } else {
      await store.updateHabit(
        original: habit,
        title: result.title,
        category: result.category,
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final HabitCatalogViewModel store = context.read<HabitCatalogViewModel>();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete habit'),
          content: Text('Are you sure you want to delete "${habit.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    unawaited(store.deleteHabit(habit.id));
  }

  List<Widget> _buildHabitTiles({
    required String dayKey,
    required List<Habit> habits,
  }) {
    final HabitDayViewModel habitDay = context.watch<HabitDayViewModel>();
    final Set<String> doneIds = habitDay.doneForDay(dayKey);

    final List<Widget> tiles = <Widget>[];

    for (final Habit habit in habits) {
      final bool isActive = doneIds.contains(habit.id);
      final int streak = habitDay.streakOf(habit.id);

      tiles.add(
        HabitTile(
          title: habit.title,
          streak: streak,
          active: isActive,
          accent: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          onTap: () {
            context.read<HabitDayViewModel>().toggleHabitForDay(
              dayKey: dayKey,
              habitId: habit.id,
            );
          },
          onMenuSelected: (HabitMenuAction action) {
            switch (action) {
              case HabitMenuAction.edit:
                _showHabitDialog(habit: habit);
                break;
              case HabitMenuAction.delete:
                _deleteHabit(habit);
                break;
            }
          },
        ),
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habits = context.watch<HabitCatalogViewModel>().habits;
    final selectedDayStore = context.watch<SelectedDayViewModel>();
    final selectedDayKey = selectedDayStore.selectedDayKey;

    if (_loadedDayKey != selectedDayKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSelectedDayData();
        }
      });
    }

    final doneIds = context.watch<HabitDayViewModel>().doneForDay(
      selectedDayKey,
    );

    final habitIds = habits.map((habit) => habit.id).toSet();
    final completedToday = doneIds.where(habitIds.contains).length;

    final double progresoDecimal = habits.isEmpty
        ? 0.0
        : (completedToday / habits.length).clamp(0.0, 1.0);
    final textMain =
        theme.textTheme.headlineLarge?.color ?? const Color(0xFFE5E7EB);
    final textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(child: LateralMenu()),
      appBar: const AppTopBar(title: 'HABITS'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitDialog(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    children: <Widget>[
                      const AppSectionTitle(
                        title: 'HABITS',
                        subtitle: 'Daily completion overview',
                        icon: Icons.checklist,
                      ),
                      const SizedBox(height: 22),
                      CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 14,
                        percent: progresoDecimal,
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: 600,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        progressColor: theme.colorScheme.primary,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${(progresoDecimal * 100).toInt()}%',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 42,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'COMPLETED',
                              style: theme.textTheme.bodySmall?.copyWith(
                                letterSpacing: 2,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '$completedToday of ${habits.length} habits completed',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AppSectionTitle(
                        title: 'TODAY\'S HABITS',
                        subtitle: 'Tap a habit to mark it as completed',
                        icon: Icons.task_alt,
                      ),
                      const SizedBox(height: 16),
                      if (habits.isEmpty)
                        Text(
                          'No habits created yet.',
                          style: theme.textTheme.bodyMedium,
                        )
                      else
                        ..._buildHabitTiles(
                          dayKey: selectedDayKey,
                          habits: habits,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
