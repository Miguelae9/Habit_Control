import 'package:flutter/material.dart';

import 'package:habit_control/shared/widgets/online_badge.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 20) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.white;
    final theme = Theme.of(context);

    return Row(
      children: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: iconColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(_getGreeting(), style: theme.textTheme.titleMedium),
        ),

        OnlineBadge(textColor: iconColor),
      ],
    );
  }
}
