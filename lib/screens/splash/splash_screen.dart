import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/router/app_routes.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';

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
    final metricsStore = context.read<DailyMetricsStore>();

    // Ensures the splash UI is visible for a minimum amount of time.
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Attempts to push any locally pending writes to Firestore.
      await habitStore.trySyncPending();
      await metricsStore.trySyncPending();
    }

    final nextRoute = (user == null) ? AppRoutes.home : AppRoutes.habits;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
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
                'v0.1.0 [MVP_BUILD]',
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
