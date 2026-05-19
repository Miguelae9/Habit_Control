import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Sign-in flow backed by Firebase Auth email/password.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

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

  /// Attempts to sign in or create an account with Google.
  ///
  /// Firebase creates the user automatically if the Google account is new.
  Future<String?> signInWithGoogle() async {
    if (_loading) return null;

    _loading = true;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return 'Google sign-in cancelled';
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException {
      return 'Google sign-in failed';
    } catch (_) {
      return 'Google sign-in failed';
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
