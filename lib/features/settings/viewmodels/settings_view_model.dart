import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  /// Re-authenticates the user with [currentPassword] and updates their
  /// Firebase Auth password to [newPassword].
  ///
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      return 'You must be signed in to change your password.';
    }

    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters.';
    }

    if (newPassword == currentPassword) {
      return 'New password must be different from the current one.';
    }

    try {
      await user.reload();

      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('changePassword failed: ${e.code}');
      return _messageFor(e);
    } catch (e) {
      debugPrint('changePassword unexpected error: $e');
      return 'Unexpected error. Please try again.';
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Current password is incorrect.';
      case 'user-mismatch':
        return 'Credentials do not match the signed-in user.';
      case 'user-not-found':
        return 'Account not found.';
      case 'weak-password':
        return 'The new password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again before changing your password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Could not change password (${e.code}).';
    }
  }
}
