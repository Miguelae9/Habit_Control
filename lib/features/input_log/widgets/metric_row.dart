import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';
import 'step_button.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.suffix,
    this.onEdit,
    this.onDelete,
  });

  final String label;
  final String value;
  final String? suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSuffix = suffix != null && suffix!.trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit metric',
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete metric',
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              StepButton(isPlus: false, onTap: onMinus),
              const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: value,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 34,
                            letterSpacing: 2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (hasSuffix)
                          TextSpan(
                            text: ' ${suffix!}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              StepButton(isPlus: true, onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }
}
