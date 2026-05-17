import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';

enum HabitMenuAction { edit, delete }

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.title,
    required this.streak,
    required this.active,
    required this.accent,
    required this.onTap,
    required this.onMenuSelected,
  });

  final String title;
  final int streak;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final ValueChanged<HabitMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                height: 46,
                width: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'STREAK: $streak DAYS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: active
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active ? theme.colorScheme.primary : accent,
                    width: 1.5,
                  ),
                ),
                child: active
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),

              PopupMenuButton<HabitMenuAction>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                onSelected: onMenuSelected,
                itemBuilder: (context) =>
                    const <PopupMenuEntry<HabitMenuAction>>[
                      PopupMenuItem(
                        value: HabitMenuAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: HabitMenuAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
