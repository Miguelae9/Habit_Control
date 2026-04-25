import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

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
          Text('INSIGHT', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Automatic daily summary', style: theme.textTheme.bodySmall),
          const SizedBox(height: 14),
          Text(
            'Today you are showing moderate consistency. You started the day stronger than you are finishing it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
