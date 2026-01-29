import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/analytics.dart';
import 'package:habit_control/presentation/screens/credits.dart';
import 'package:habit_control/presentation/screens/dashboard.dart';
import 'package:habit_control/presentation/screens/input_log.dart';
import 'package:habit_control/presentation/screens/splash.dart';
import 'package:habit_control/presentation/screens/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const home = '/home';
  static const credits = '/credits';
  static const dashboard = '/dashboard';
  static const dataLogging = '/data_logging';
  static const analytics = '/analytics';

  static Map<String, WidgetBuilder> get map => {
    home: (context) => const HomeScreen(),
    splash: (context) => const SplashScreen(),
    credits: (context) => const CreditsScreen(),
    dashboard: (context) => const DashboardScreen(),
    dataLogging: (context) => const InputLogScreen(),
    analytics: (context) => const AnalyticsScreen(),
  };
}
