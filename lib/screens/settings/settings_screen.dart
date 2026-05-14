import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';

import 'widgets/settings_header.dart';
import 'widgets/settings_info_tile.dart';
import 'widgets/settings_section.dart';

/// Settings screen showing account, data, app info and session actions.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _appVersion = 'v1.6.0';

  void _openDrawer() {
    final ScaffoldState? scaffold = _scaffoldKey.currentState;
    if (scaffold != null) {
      scaffold.openDrawer();
    }
  }

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
    final habitCatalogStore = context.read<HabitCatalogStore>();
    final habitDayStore = context.read<HabitDayStore>();
    final dailyMetricsStore = context.read<DailyMetricsStore>();
    final NavigatorState navigator = Navigator.of(context);

    await habitCatalogStore.clearAll();
    await habitDayStore.clearAll();
    await dailyMetricsStore.clearAll();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.home,
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
      key: _scaffoldKey,
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
                    SettingsHeader(onMenuTap: _openDrawer),
                    const SizedBox(height: 30),

                    SettingsSection(
                      title: 'ACCOUNT',
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
