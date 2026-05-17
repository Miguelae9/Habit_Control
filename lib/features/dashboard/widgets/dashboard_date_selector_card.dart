import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:habit_control/shared/app_card.dart';

class DashboardDateSelectorCard extends StatelessWidget {
  const DashboardDateSelectorCard({
    super.key,
    required this.selectedDay,
    required this.isToday,
    required this.canGoNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onToday,
  });

  final DateTime selectedDay;
  final bool isToday;
  final bool canGoNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;

  String get _dateTitle {
    return DateFormat('EEEE, MMMM d', 'en_US').format(selectedDay);
  }

  String get _dateSubtitle {
    if (isToday) return 'Today';
    return DateFormat('yyyy-MM-dd').format(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Previous day',
            onPressed: onPreviousDay,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'SELECTED DAY',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dateTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_dateSubtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: canGoNextDay ? onNextDay : null,
            icon: const Icon(Icons.chevron_right),
          ),
          if (!isToday)
            TextButton(onPressed: onToday, child: const Text('TODAY')),
        ],
      ),
    );
  }
}
