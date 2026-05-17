import 'package:flutter/material.dart';

class StepButton extends StatelessWidget {
  const StepButton({super.key, required this.isPlus, required this.onTap});

  final bool isPlus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = isPlus
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return SizedBox(
      width: 50,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(isPlus ? Icons.add : Icons.remove, size: 22),
      ),
    );
  }
}
