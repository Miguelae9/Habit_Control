import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';
import 'package:habit_control/shared/state/habit_catalog_store.dart';
import 'package:habit_control/shared/utils/day_key.dart';

import 'package:habit_control/shared/state/habit_day_store.dart';
import 'package:habit_control/shared/widgets/app_logo.dart';
import 'package:provider/provider.dart';

/// Initial loading screen.
///
/// Reads local state from providers and, if a Firebase user is present, triggers
/// a best-effort sync for pending local changes before navigating forward.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final habitStore = context.read<HabitDayStore>();
    final catalogStore = context.read<HabitCatalogStore>();
    final metricsStore = context.read<DailyMetricsStore>();

    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final today = DateTime.now();
      final todayKey = dayKeyFromDate(today);
      final monthKeys = _monthKeys(today);

      await catalogStore.loadLocal();
      await habitStore.loadLocal();
      await metricsStore.loadLocal();

      await catalogStore.trySyncPending();
      await catalogStore.syncFromCloud();

      await habitStore.trySyncPending();
      await metricsStore.trySyncPending();

      await metricsStore.syncDefinitionsFromCloud();

      for (final key in monthKeys) {
        await habitStore.syncDayFromCloud(key);
        await metricsStore.syncDayFromCloud(key);
      }

      await metricsStore.loadEntriesForDay(todayKey);
    }

    final nextRoute = user == null ? AppRoutes.home : AppRoutes.dashboard;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  DateTime _startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  List<String> _dayKeysBetween(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    final keys = <String>[];
    DateTime current = normalizedStart;

    while (!current.isAfter(normalizedEnd)) {
      keys.add(dayKeyFromDate(current));
      current = current.add(const Duration(days: 1));
    }

    return keys;
  }

  List<String> _monthKeys(DateTime date) {
    return _dayKeysBetween(_startOfMonth(date), _endOfMonth(date));
  }

  // Prepared for future weekly analytics.
  // Keep this logic if weekly chart filters are added later.
  /*
  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final delta = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: delta));
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(const Duration(days: 6));
  }

  List<String> _weekKeys(DateTime date) {
    return _dayKeysBetween(_startOfWeek(date), _endOfWeek(date));
  }
  */

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F14),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppLogo(size: 300),
              SizedBox(height: 50),
              Text(
                'HABIT\nCONTROL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(),
              SizedBox(height: 50),
              Text(
                'v1.6.0 [MVP_BUILD]',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
