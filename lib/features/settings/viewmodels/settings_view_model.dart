import 'package:firebase_auth/firebase_auth.dart';

import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';

/// Settings-level operations that span multiple VMs.
class SettingsViewModel {
  SettingsViewModel({
    required this.habitCatalog,
    required this.habitDay,
    required this.metrics,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final HabitCatalogViewModel habitCatalog;
  final HabitDayViewModel habitDay;
  final MetricsViewModel metrics;
  final FirebaseAuth _auth;

  /// Clears local state from every feature VM and signs out of Firebase.
  Future<void> signOut() async {
    await habitCatalog.clearAll();
    await habitDay.clearAll();
    await metrics.clearAll();
    await _auth.signOut();
  }
}
