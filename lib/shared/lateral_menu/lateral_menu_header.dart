import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_logo.dart';

class LateralMenuHeader extends StatelessWidget {
  const LateralMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        children: <Widget>[
          const AppLogo(size: 130),
          const SizedBox(height: 20),
          Text(
            'HABIT\nCONTROL',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              height: 1.05,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PERSONAL HABIT TRACKER',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
