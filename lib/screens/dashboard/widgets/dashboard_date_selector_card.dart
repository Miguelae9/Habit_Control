import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    return Card(
      color: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFF64F6FF).withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous day',
              onPressed: onPreviousDay,
              icon: const Icon(Icons.chevron_left),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      color: const Color(0xFFF8FAFC),
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
      ),
    );
  }
}
