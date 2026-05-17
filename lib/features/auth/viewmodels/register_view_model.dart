import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Sign-up flow backed by Firebase Auth email/password.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool _loading = false;
  bool get loading => _loading;

  /// Attempts to create an account with the provided credentials.
  ///
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> register({
    required String email,
    required String password,
  }) async {
    if (_loading) return null;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      return 'Complete all fields';
    }

    _loading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageFor(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Email address is not valid.';
      default:
        return 'Could not register user. Please try again.';
    }
  }
}
