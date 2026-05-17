import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    super.key,
    required this.completedHabits,
    required this.totalHabits,
  });

  final int completedHabits;
  final int totalHabits;

  double get _progress {
    if (totalHabits == 0) return 0;
    return completedHabits / totalHabits;
  }

  int get _pendingHabits {
    final pending = totalHabits - completedHabits;
    return pending < 0 ? 0 : pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppSectionTitle(
            title: 'DAILY PROGRESS',
            subtitle: 'Current habit completion',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),
          Text(
            '$completedHabits of $totalHabits habits completed',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('$_pendingHabits remaining', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
