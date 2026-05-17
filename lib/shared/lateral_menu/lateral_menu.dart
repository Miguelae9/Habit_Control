import 'package:flutter/material.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/settings/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/core/router/app_routes.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';

import 'lateral_menu_header.dart';
import 'lateral_menu_item.dart';

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

  Future<void> _logout(BuildContext context) async {
    final viewModel = SettingsViewModel(
      habitCatalog: context.read<HabitCatalogViewModel>(),
      habitDay: context.read<HabitDayViewModel>(),
      metrics: context.read<MetricsViewModel>(),
    );

    Navigator.of(context).pop();
    await viewModel.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, _removeAll);
  }
}
