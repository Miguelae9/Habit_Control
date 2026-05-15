import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/screens/habits/models/habit.dart';
import 'package:habit_control/screens/habits/models/habit_category.dart';
import 'package:habit_control/screens/habits/widgets/habit_tile.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/widgets/online_badge.dart';
import 'package:habit_control/shared/widgets/ui/app_card.dart';
import 'package:habit_control/shared/widgets/ui/app_section_title.dart';
import 'package:habit_control/shared/state/selected_day_store.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _loadedDayKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterFirstFrame);
  }

  Future<void> _loadSelectedDayData() async {
    final selectedDayStore = context.read<SelectedDayStore>();
    final dayStore = context.read<HabitDayStore>();
    final catalogStore = context.read<HabitCatalogStore>();

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

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _showHabitDialog({Habit? habit}) async {
    final HabitCatalogStore store = context.read<HabitCatalogStore>();

    final HabitDialogResult? result = await showDialog<HabitDialogResult>(
      context: context,
      builder: (dialogContext) {
        return _HabitDialog(habit: habit);
      },
    );

    if (result == null) return;
    if (!mounted) return;

    if (habit == null) {
      await store.addHabit(
        title: result.title,
        category: result.category,
        streakText: result.streakText,
      );
    } else {
      await store.updateHabit(
        original: habit,
        title: result.title,
        category: result.category,
        streakText: result.streakText,
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final HabitCatalogStore store = context.read<HabitCatalogStore>();

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
    final doneIds = context.watch<HabitDayStore>().doneForDay(dayKey);

    return habits.map((habit) {
      final isActive = doneIds.contains(habit.id);

      return HabitTile(
        title: habit.title,
        streak: habit.streakText,
        active: isActive,
        accent: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
        onTap: () {
          context.read<HabitDayStore>().toggleHabitForDay(
            dayKey: dayKey,
            habitId: habit.id,
          );
        },
        onMenuSelected: (action) {
          switch (action) {
            case HabitMenuAction.edit:
              _showHabitDialog(habit: habit);
              break;
            case HabitMenuAction.delete:
              _deleteHabit(habit);
              break;
          }
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habits = context.watch<HabitCatalogStore>().habits;
    final selectedDayStore = context.watch<SelectedDayStore>();
    final selectedDayKey = selectedDayStore.selectedDayKey;

    if (_loadedDayKey != selectedDayKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSelectedDayData();
        }
      });
    }

    final doneIds = context.watch<HabitDayStore>().doneForDay(selectedDayKey);

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
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(child: LateralMenu()),
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
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu, color: theme.colorScheme.primary),
                      onPressed: _openDrawer,
                    ),
                    const Spacer(),
                    OnlineBadge(textColor: textMain),
                  ],
                ),

                const SizedBox(height: 18),

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
                        backgroundColor: theme.colorScheme.surface,
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

class _HabitDialog extends StatefulWidget {
  const _HabitDialog({required this.habit});

  final Habit? habit;

  @override
  State<_HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<_HabitDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _streakCtrl;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.habit?.title ?? '');
    _streakCtrl = TextEditingController(text: widget.habit?.streakText ?? '');
    _selectedCategory = widget.habit?.category ?? HabitCategory.custom;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _streakCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.habit == null ? 'Create habit' : 'Edit habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Example: Read',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: HabitCategory.values.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(HabitCategory.labelOf(category)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _streakCtrl,
            decoration: const InputDecoration(
              labelText: 'Secondary text',
              hintText: 'Example: STREAK: 0 DAYS',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final streak = _streakCtrl.text.trim();

    if (title.isEmpty) return;

    Navigator.of(context).pop(
      HabitDialogResult(
        title: title,
        streakText: streak,
        category: _selectedCategory,
      ),
    );
  }
}

class HabitDialogResult {
  const HabitDialogResult({
    required this.title,
    required this.streakText,
    required this.category,
  });

  final String title;
  final String streakText;
  final String category;
}
