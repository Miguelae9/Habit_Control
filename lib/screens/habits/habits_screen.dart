import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/screens/habits/models/habit.dart';
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
    final titleCtrl = TextEditingController(text: habit?.title ?? '');
    final streakCtrl = TextEditingController(text: habit?.streakText ?? '');

    final HabitCatalogStore store = context.read<HabitCatalogStore>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(habit == null ? 'Crear hábito' : 'Editar hábito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Leer',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streakCtrl,
                decoration: const InputDecoration(
                  labelText: 'Texto secundario',
                  hintText: 'Ej: STREAK: 0 DAYS',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final String title = titleCtrl.text.trim();
                final String streak = streakCtrl.text.trim();

                if (title.isEmpty) return;

                Navigator.of(dialogContext).pop();

                if (habit == null) {
                  store.addHabit(title: title, streakText: streak);
                } else {
                  store.updateHabit(
                    original: habit,
                    title: title,
                    streakText: streak,
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
