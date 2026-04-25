import 'package:flutter/material.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101826),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY PROGRESS', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            '$completedHabits of $totalHabits habits completed',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF64F6FF),
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
