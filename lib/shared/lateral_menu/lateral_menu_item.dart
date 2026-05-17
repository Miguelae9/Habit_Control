import 'package:flutter/material.dart';

class LateralMenuItem extends StatelessWidget {
  const LateralMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    this.routeName,
    this.replace = true,
    this.clearStack = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;

  final String? routeName;
  final bool replace;
  final bool clearStack;

  final Future<void> Function(BuildContext)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = selected
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color ?? Colors.grey;

    final backgroundColor = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: <Widget>[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!(context);
      return;
    }

    if (routeName == null) return;

    Navigator.of(context).pop();

    if (clearStack) {
      Navigator.pushNamedAndRemoveUntil(context, routeName!, (_) => false);
      return;
    }

    if (replace) {
      Navigator.pushReplacementNamed(context, routeName!);
      return;
    }

    Navigator.pushNamed(context, routeName!);
  }
}
