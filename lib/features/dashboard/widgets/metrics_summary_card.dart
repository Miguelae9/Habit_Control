import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';

class MetricSummaryItem {
  const MetricSummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class MetricsSummaryCard extends StatelessWidget {
  const MetricsSummaryCard({super.key, required this.metrics});

  final List<MetricSummaryItem> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppSectionTitle(
            title: 'TODAY\'S METRICS',
            subtitle: 'Main context values for the selected day',
            icon: Icons.monitor_heart_outlined,
          ),
          const SizedBox(height: 16),
          if (metrics.isEmpty)
            Text(
              'No metrics registered for this day.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...metrics.map(
              (metric) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        metric.label.toUpperCase(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      metric.value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
