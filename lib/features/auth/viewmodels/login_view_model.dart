import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Sign-in flow backed by Firebase Auth email/password.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool _loading = false;
  bool get loading => _loading;

  /// Attempts to sign in with the provided credentials.
  ///
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> signIn({
    required String username,
    required String password,
  }) async {
    if (_loading) return null;

    final trimmedUser = username.trim();
    if (trimmedUser.isEmpty || password.isEmpty) {
      return 'Complete all fields';
    }

    _loading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: _toEmail(trimmedUser),
        password: password,
      );
      return null;
    } on FirebaseAuthException {
      return 'Invalid credentials';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // The `@profe.local` domain and the special `usuario` mapping are
  // environment-specific defaults preserved from the original screen.
  String _toEmail(String username) {
    if (username.contains('@')) return username;
    if (username.toLowerCase() == 'usuario') return 'usuario@profe.local';
    return '$username@profe.local';
  }
}
