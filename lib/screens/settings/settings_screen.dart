import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';

import 'widgets/settings_header.dart';
import 'widgets/settings_info_tile.dart';
import 'widgets/settings_section.dart';

/// Settings screen showing account info, basic preferences, and sign-out.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  void _openDrawer() {
    final ScaffoldState? scaffold = _scaffoldKey.currentState;
    if (scaffold != null) {
      scaffold.openDrawer();
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
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
                          icon: Icons.person_outline,
                          title: 'Email',
                          subtitle: user?.email ?? 'No email available',
                        ),
                        const SizedBox(height: 8),
                        SettingsInfoTile(
                          icon: Icons.badge_outlined,
                          title: 'User ID',
                          subtitle: user?.uid ?? 'No user ID available',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SettingsSection(
                      title: 'PREFERENCES',
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          title: const Text('Notifications'),
                          subtitle: const Text(
                            'Enable basic app notifications',
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _darkModeEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _darkModeEnabled = value;
                            });
                          },
                          title: const Text('Dark mode'),
                          subtitle: const Text('Local visual preference'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SettingsSection(
                      title: 'SESSION',
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: _signOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
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
