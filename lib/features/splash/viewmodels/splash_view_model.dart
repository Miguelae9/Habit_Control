import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/core/router/app_routes.dart';
import 'package:habit_control/core/utils/date_range.dart';
import 'package:habit_control/core/utils/day_key.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';

/// Orchestrates the initial bootstrap visible behind the splash screen.
///
/// Waits a fixed delay so the brand screen is perceptible, then loads local
/// state from SQLite. Cloud synchronisation runs in the background after
/// navigation so the app stays usable when there is no network connection.
class SplashViewModel {
  SplashViewModel({
    required this.habitDayViewModel,
    required this.habitCatalogViewModel,
    required this.metricsViewModel,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final HabitDayViewModel habitDayViewModel;
  final HabitCatalogViewModel habitCatalogViewModel;
  final MetricsViewModel metricsViewModel;
  final FirebaseAuth _auth;

  static const Duration _splashDelay = Duration(seconds: 2);

  /// Runs the splash sequence and resolves to the next route name.
  ///
  /// Returns [AppRoutes.login] if no user is signed in, otherwise
  /// [AppRoutes.dashboard] after the local state has been loaded.
  /// Cloud synchronisation is fired in the background and does not block
  /// navigation, so the app boots even when the device is offline.
  Future<String> bootstrap() async {
    await Future.delayed(_splashDelay);

    final user = _auth.currentUser;
    if (user == null) return AppRoutes.login;

    await _loadLocalState();
    unawaited(_syncWithCloud());
    return AppRoutes.dashboard;
  }

  Future<void> _loadLocalState() async {
    final today = DateTime.now();
    final todayKey = dayKeyFromDate(today);

    await habitCatalogViewModel.loadLocal();
    await habitDayViewModel.loadLocal();
    await metricsViewModel.loadLocal();
    await metricsViewModel.loadEntriesForDay(todayKey);
  }

  Future<void> _syncWithCloud() async {
    final today = DateTime.now();
    final monthKeys = monthKeysOf(today);

    await habitCatalogViewModel.trySyncPending();
    await habitCatalogViewModel.syncFromCloud();

    await habitDayViewModel.trySyncPending();
    await metricsViewModel.trySyncPending();

    await metricsViewModel.syncDefinitionsFromCloud();

    for (final key in monthKeys) {
      await habitDayViewModel.syncDayFromCloud(key);
      await metricsViewModel.syncDayFromCloud(key);
    }
  }
}
