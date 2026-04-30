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
      final weekKeys = _weekKeys(today);

      await catalogStore.loadLocal();
      await habitStore.loadLocal();
      await metricsStore.loadLocal();

      await catalogStore.trySyncPending();
      await catalogStore.syncFromCloud();

      await habitStore.trySyncPending();
      for (final key in weekKeys) {
        await habitStore.syncDayFromCloud(key);
      }

      await metricsStore.trySyncPending();
      await metricsStore.syncDefinitionsFromCloud();
      await metricsStore.syncDayFromCloud(todayKey);
      await metricsStore.loadEntriesForDay(todayKey);
    }

    final nextRoute = user == null ? AppRoutes.home : AppRoutes.dashboard;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final delta = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: delta));
  }

  List<String> _weekKeys(DateTime now) {
    final start = _startOfWeek(now);
    final keys = <String>[];

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      keys.add(dayKeyFromDate(day));
    }

    return keys;
  }

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
                'v1.4.0 [MVP_BUILD]',
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
