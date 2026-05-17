import 'package:flutter/material.dart';
import 'package:habit_control/features/analytics/views/analytics_view.dart';
import 'package:habit_control/features/auth/views/register_view.dart';
import 'package:habit_control/features/settings/views/credits_view.dart';
import 'package:habit_control/features/dashboard/views/dashboard_view.dart';
import 'package:habit_control/features/habits/views/habits_view.dart';
import 'package:habit_control/features/input_log/views/input_log_view.dart';
import 'package:habit_control/features/settings/views/settings_view.dart';
import 'package:habit_control/features/splash/views/splash_view.dart';
import 'package:habit_control/features/auth/views/login_view.dart';

/// Named routes and route-to-widget mapping used by the app.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const credits = '/credits';
  static const habits = '/habits';
  static const inputLog = '/input_log';
  static const analytics = '/analytics';
  static const settings = '/settings';

  static final Map<String, WidgetBuilder> map = {
    splash: (context) => const SplashView(),
    login: (context) => const LoginView(),
    register: (context) => const RegisterView(),
    dashboard: (context) => const DashboardView(),
    credits: (context) => const CreditsView(),
    habits: (context) => const HabitsView(),
    inputLog: (context) => const InputLogView(),
    analytics: (context) => const AnalyticsView(),
    settings: (context) => const SettingsView(),
  };
}
