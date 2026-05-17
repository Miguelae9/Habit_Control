import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final String insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppSectionTitle(
            title: 'INSIGHT',
            subtitle: 'Automatic daily summary',
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 16),
          Text(
            insight,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
