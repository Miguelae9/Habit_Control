import 'package:flutter/material.dart';

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
          Text('TODAY\'S METRICS', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          ...metrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      metric.label.toUpperCase(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    metric.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
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
