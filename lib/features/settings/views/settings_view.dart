import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_control/features/settings/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/core/router/app_routes.dart';
import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_top_bar.dart';
import 'package:habit_control/features/settings/widgets/settings_info_tile.dart';
import 'package:habit_control/features/settings/widgets/settings_section.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  static const String _appVersion = 'v1.9.0';

  Future<void> _confirmSignOut() async {
    final bool shouldSignOut =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign out'),
              content: const Text('Do you want to close your current session?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sign out'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldSignOut) return;

    await _signOut();
  }

  Future<void> _signOut() async {
    final viewModel = SettingsViewModel(
      habitCatalog: context.read<HabitCatalogViewModel>(),
      habitDay: context.read<HabitDayViewModel>(),
      metrics: context.read<MetricsViewModel>(),
    );
    final navigator = Navigator.of(context);

    await viewModel.signOut();

    if (!mounted) return;

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }

  void _openCredits() {
    Navigator.pushNamed(context, AppRoutes.credits);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const AppTopBar(title: 'SETTINGS'),
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(child: LateralMenu()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SettingsSection(
                      title: 'ACCOUNT',
                      subtitle: 'Manage your user access',
                      icon: Icons.person_outline,
                      children: <Widget>[
                        SettingsInfoTile(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          subtitle: user?.email ?? 'No email available',
                        ),
                        const SizedBox(height: 8),
                        const SettingsInfoTile(
                          icon: Icons.lock_reset,
                          title: 'Change password',
                          subtitle: 'Password reset is currently unavailable',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const SettingsSection(
                      title: 'DATA',
                      subtitle: 'Local data and cloud sync',
                      icon: Icons.storage_outlined,
                      children: <Widget>[
                        SettingsInfoTile(
                          icon: Icons.cloud_done_outlined,
                          title: 'Automatic sync',
                          subtitle: 'Your data syncs when you open the app',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SettingsSection(
                      title: 'APP',
                      subtitle: 'Version and project information',
                      icon: Icons.phone_android,
                      children: <Widget>[
                        const SettingsInfoTile(
                          icon: Icons.info_outline,
                          title: 'Version',
                          subtitle: _appVersion,
                        ),
                        const SizedBox(height: 8),
                        SettingsInfoTile(
                          icon: Icons.code,
                          title: 'Credits / Architecture',
                          subtitle: 'View project technologies',
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _openCredits,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SettingsSection(
                      title: 'SESSION',
                      subtitle: 'Account session actions',
                      icon: Icons.logout,
                      children: <Widget>[
                        SettingsInfoTile(
                          icon: Icons.logout,
                          title: 'Sign out',
                          subtitle: 'Close your current session',
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _confirmSignOut,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
