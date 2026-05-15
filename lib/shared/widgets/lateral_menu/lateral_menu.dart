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

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const LateralMenuHeader(),
            const SizedBox(height: 12),
            const Divider(),

            LateralMenuItem(
              icon: Icons.dashboard_outlined,
              label: 'DASHBOARD',
              selected: currentRoute == AppRoutes.dashboard,
              routeName: AppRoutes.dashboard,
            ),
            LateralMenuItem(
              icon: Icons.checklist,
              label: 'HABITS',
              selected: currentRoute == AppRoutes.habits,
              routeName: AppRoutes.habits,
            ),
            LateralMenuItem(
              icon: Icons.monitor_heart_outlined,
              label: 'INPUT LOG',
              selected: currentRoute == AppRoutes.inputLog,
              routeName: AppRoutes.inputLog,
            ),
            LateralMenuItem(
              icon: Icons.bar_chart,
              label: 'ANALYTICS',
              selected: currentRoute == AppRoutes.analytics,
              routeName: AppRoutes.analytics,
            ),
            LateralMenuItem(
              icon: Icons.settings_outlined,
              label: 'SETTINGS',
              selected: currentRoute == AppRoutes.settings,
              routeName: AppRoutes.settings,
            ),

            const Spacer(),
            const Divider(),

            LateralMenuItem(
              icon: Icons.logout,
              label: 'LOG OUT',
              selected: false,
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
