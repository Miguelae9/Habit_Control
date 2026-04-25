import 'package:flutter/material.dart';
import 'package:habit_control/screens/analytics/analytics_screen.dart';
import 'package:habit_control/screens/auth/register.dart';
import 'package:habit_control/screens/credits/credits_screen.dart';
import 'package:habit_control/screens/dashboard/dashboard_screen.dart';
import 'package:habit_control/screens/habits/habits_screen.dart';
import 'package:habit_control/screens/input_log/input_log_screen.dart';
import 'package:habit_control/screens/settings/settings_screen.dart';
import 'package:habit_control/screens/splash/splash_screen.dart';
import 'package:habit_control/screens/auth/home_screen.dart';

/// Named routes and route-to-widget mapping used by the app.
class AppRoutes {
  AppRoutes._();

  /// Route name for the splash screen.
  static const splash = '/splash';

  /// Route name for the authentication/home screen.
  static const home = '/home';

  /// Route name for the authentication/register screen.
  static const register = '/register';

  /// Route name for the credits screen.
  static const dashboard = '/dashboard';

  /// Route name for the credits screen.
  static const credits = '/credits';

  /// Route name for the habits screen.
  static const habits = '/habits';

  /// Route name for the input log screen.
  static const inputLog = '/input_log';

  /// Route name for the analytics screen.
  static const analytics = '/analytics';

  /// Route name for the settings screen.
  static const settings = '/settings';

  /// Map of route name -> screen builder.
  static final Map<String, WidgetBuilder> map = {
    splash: (context) => const SplashScreen(),
    home: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    dashboard: (context) => const DashboardScreen(),
    credits: (context) => const CreditsScreen(),
    habits: (context) => const HabitsScreen(),
    inputLog: (context) => const InputLogScreen(),
    analytics: (context) => const AnalyticsScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
