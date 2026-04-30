import 'package:flutter/material.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/theme/app_theme.dart';
import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/state/weather_store.dart';

import 'dart:async';

/// Root application widget.
///
/// Provides app-wide state via [MultiProvider] and configures routing using
/// [MaterialApp.onGenerateRoute].
class MyApp extends StatefulWidget {
  /// Creates the root widget.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final HabitDayStore _habitStore;
  late final DailyMetricsStore _metricsStore;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    _habitStore = HabitDayStore()..loadLocal();
    _metricsStore = DailyMetricsStore()..loadLocal();

    // Rebuilds the widget tree when the Firebase Auth user changes so that route
    // guarding decisions reflect the latest auth state.
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (!mounted) return;
    setState(_noop);
  }

  void _noop() {}

  @override
  void dispose() {
    _authSub.cancel();
    _habitStore.dispose();
    _metricsStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitDayStore>.value(value: _habitStore),
        ChangeNotifierProvider<DailyMetricsStore>.value(value: _metricsStore),
        ChangeNotifierProvider<HabitCatalogStore>(
          create: (_) => HabitCatalogStore()..loadLocal(),
        ),
        ChangeNotifierProvider<WeatherStore>(
          create: (_) => WeatherStore()..loadWeather(),
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
    final String name = settings.name ?? AppRoutes.home;

    final bool exists = AppRoutes.map.containsKey(name);
    final String resolved = exists ? name : AppRoutes.home;

    final bool isProtected = _isProtectedRoute(resolved);
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (isProtected && !isLoggedIn) {
      return _buildRoute(settings, AppRoutes.home);
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

  /// Builds a [MaterialPageRoute] for [routeName], falling back to `home`.
  static Route<dynamic> _buildRoute(RouteSettings settings, String routeName) {
    final builder = AppRoutes.map[routeName];
    if (builder == null) {
      final fallback = AppRoutes.map[AppRoutes.home]!;
      return MaterialPageRoute(builder: fallback, settings: settings);
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
