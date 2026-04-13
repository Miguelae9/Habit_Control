import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';

import 'lateral_menu_header.dart';
import 'lateral_menu_item.dart';

/// Lateral drawer navigation menu.
///
/// Visible actions:
/// - Navigates to the routes defined in [AppRoutes]
/// - Signs out via [FirebaseAuth.signOut] and clears local stores on logout
class LateralMenu extends StatelessWidget {
  const LateralMenu({super.key});

  static bool _removeAll(Route<dynamic> route) {
    return false;
  }

  static const Color _border = Color(0xFF1F2A37);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = theme.scaffoldBackgroundColor;
    final accent = theme.primaryColor;

    final textMain =
        theme.textTheme.headlineLarge?.color ?? const Color(0xFFF8FAFC);
    final textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF94A3B8);

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            LateralMenuHeader(textMain: textMain),
            const SizedBox(height: 20),
            Container(height: 1, color: _border),

            LateralMenuItem(
              label: 'DASHBOARD',
              selected: currentRoute == AppRoutes.dashboard,
              accent: accent,
              textMuted: textMuted,
              routeName: AppRoutes.dashboard,
              replace: true,
            ),
            LateralMenuItem(
              label: 'INPUT LOG',
              selected: currentRoute == AppRoutes.inputLog,
              accent: accent,
              textMuted: textMuted,
              routeName: AppRoutes.inputLog,
              replace: true,
            ),
            LateralMenuItem(
              label: 'ANALYTICS',
              selected: currentRoute == AppRoutes.analytics,
              accent: accent,
              textMuted: textMuted,
              routeName: AppRoutes.analytics,
              replace: true,
            ),
            LateralMenuItem(
              label: 'SETTINGS',
              selected: currentRoute == AppRoutes.settings,
              accent: accent,
              textMuted: textMuted,
              routeName: AppRoutes.settings,
              replace: true,
            ),
            LateralMenuItem(
              label: 'ABOUT',
              selected: currentRoute == AppRoutes.credits,
              accent: accent,
              textMuted: textMuted,
              routeName: AppRoutes.credits,
              replace: true,
            ),

            const Spacer(),

            LateralMenuItem(
              label: 'LOG OUT',
              selected: false,
              accent: accent,
              textMuted: textMuted,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  /// Clears local stores, signs out, and navigates back to [AppRoutes.home].
  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();

    final habitStore = context.read<HabitDayStore>();
    final metricsStore = context.read<DailyMetricsStore>();

    await habitStore.clearAll();
    await metricsStore.clearAll();

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    // The predicate always returns false, clearing the entire navigation stack.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, _removeAll);
  }
}
