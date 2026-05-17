import 'package:flutter/material.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/core/router/app_routes.dart';
import 'package:habit_control/core/theme/app_theme.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/features/dashboard/viewmodels/weather_view_model.dart';
import 'package:habit_control/core/state/selected_day_view_model.dart';

import 'dart:async';

/// Root application widget.
///
/// Composes the dependency graph with [MultiProvider] and configures
/// [MaterialApp] with a route guard that redirects unauthenticated users
/// away from protected routes whenever the Firebase Auth state changes.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitDayViewModel>(
          create: (_) => HabitDayViewModel()..loadLocal(),
        ),
        ChangeNotifierProvider<MetricsViewModel>(
          create: (_) => MetricsViewModel()..loadLocal(),
        ),
        ChangeNotifierProvider<SelectedDayViewModel>(
          create: (_) => SelectedDayViewModel(),
        ),
        ChangeNotifierProvider<HabitCatalogViewModel>(
          create: (_) => HabitCatalogViewModel()..loadLocal(),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel()..loadWeather(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habit Control',
        theme: AppTheme.dark(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Route factory used by [MaterialApp.onGenerateRoute].
  ///
  /// Applies a basic "protected routes" check based on whether
  /// [FirebaseAuth.currentUser] is non-null.
  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final String name = settings.name ?? AppRoutes.login;

    final bool exists = AppRoutes.map.containsKey(name);
    final String resolved = exists ? name : AppRoutes.login;

    final bool isProtected = _isProtectedRoute(resolved);
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (isProtected && !isLoggedIn) {
      return _buildRoute(settings, AppRoutes.login);
    }

    return _buildRoute(settings, resolved);
  }

  /// Returns whether [routeName] requires an authenticated user.
  static bool _isProtectedRoute(String routeName) {
    if (routeName == AppRoutes.dashboard) return true;
    if (routeName == AppRoutes.habits) return true;
    if (routeName == AppRoutes.inputLog) return true;
    if (routeName == AppRoutes.analytics) return true;
    if (routeName == AppRoutes.settings) return true;
    return false;
  }

  /// Builds a [MaterialPageRoute] for [routeName], falling back to `login`.
  static Route<dynamic> _buildRoute(RouteSettings settings, String routeName) {
    final builder = AppRoutes.map[routeName];
    if (builder == null) {
      final fallback = AppRoutes.map[AppRoutes.login]!;
      return MaterialPageRoute(builder: fallback, settings: settings);
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
