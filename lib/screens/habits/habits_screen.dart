import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/screens/habits/models/habit.dart';
import 'package:habit_control/screens/habits/models/habit_category.dart';
import 'package:habit_control/screens/habits/widgets/habit_tile.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/widgets/online_badge.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterFirstFrame);
  }

  Future<void> _afterFirstFrame(Duration _) async {
    final dayStore = context.read<HabitDayStore>();
    final catalogStore = context.read<HabitCatalogStore>();
    final today = dayKeyFromDate(DateTime.now());

    await catalogStore.trySyncPending();
    await catalogStore.syncFromCloud();

    await dayStore.trySyncPending();
    await dayStore.syncDayFromCloud(today);
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
          title: const Text('Eliminar hábito'),
          content: Text('¿Seguro que quieres eliminar "${habit.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    unawaited(store.deleteHabit(habit.id));
  }

  List<Widget> _buildHabitTiles({
    required String todayKey,
    required List<Habit> habits,
  }) {
    final doneIds = context.watch<HabitDayStore>().doneForDay(todayKey);

    return habits.map((habit) {
      final isActive = doneIds.contains(habit.id);

      return HabitTile(
        title: habit.title,
        streak: habit.streakText,
        active: isActive,
        accent: isActive ? const Color(0xFF6CFAFF) : const Color(0xFF93A3B8),
        onTap: () {
          context.read<HabitDayStore>().toggleHabitForDay(
            dayKey: todayKey,
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
    final todayKey = dayKeyFromDate(DateTime.now());
    final doneIds = context.watch<HabitDayStore>().doneForDay(todayKey);

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
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitDialog(),
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
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: textMain),
                      onPressed: _openDrawer,
                    ),
                    const Spacer(),
                    OnlineBadge(textColor: textMain),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircularPercentIndicator(
                    radius: 105,
                    lineWidth: 14,
                    percent: progresoDecimal,
                    animation: true,
                    animateFromLastPercent: true,
                    animationDuration: 600,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: const Color(0xFF1E293B),
                    progressColor: const Color(0xFF6CFAFF),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progresoDecimal * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: _buildHabitTiles(
                    todayKey: todayKey,
                    habits: habits,
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
