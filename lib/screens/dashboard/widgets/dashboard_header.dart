import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 20) return 'Good afternoon';
    return 'Good evening';
  }

  String _getTodayText() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM d', 'en_US').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            );
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(_getTodayText(), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
