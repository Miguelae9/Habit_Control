import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_control/router/app_routes.dart';

import 'widgets/auth_logo.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_section_label.dart';
import 'widgets/auth_text_field.dart';

/// Login screen backed by Firebase Auth email/password sign-in.
///
/// Visible behavior:
/// - Converts the entered identifier into an email via [_toEmail]
/// - Calls [FirebaseAuth.signInWithEmailAndPassword]
/// - On success, navigates to [AppRoutes.splash] via [Navigator.pushReplacementNamed]
/// - On [FirebaseAuthException], shows a [SnackBar]
class LoginScreen extends StatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLoading = false;

  /// Converts a user-entered identifier into an email address.
  ///
  /// Needs clarification from author: The `@profe.local` domain and the special
  /// `usuario` mapping appear to be environment-specific, but no context is
  /// provided in this file.
  String _toEmail(String username) {
    final u = username.trim();
    if (u.contains('@')) return u;
    if (u.toLowerCase() == 'usuario') return 'usuario@profe.local';
    return '$u@profe.local';
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final String user = _userCtrl.text.trim();
    final String pass = _passCtrl.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Complete all fields')));
      return;
    }

    setState(_setLoadingTrue);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _toEmail(user),
        password: pass,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.splash);
    } on FirebaseAuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    } finally {
      if (mounted) {
        setState(_setLoadingFalse);
      }
    }
  }

  void _setLoadingTrue() {
    _isLoading = true;
  }

  void _setLoadingFalse() {
    _isLoading = false;
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bg = theme.scaffoldBackgroundColor;
    final Color textMain =
        theme.textTheme.headlineLarge?.color ?? const Color(0xFFE5E7EB);
    final Color textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF);

    final String buttonText = _isLoading ? 'CONNECTING...' : 'CONNECT';
    final VoidCallback? onPressed = _isLoading ? null : _login;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(child: AuthLogo()),
                const SizedBox(height: 18),
                Text(
                  'HABIT\nCONTROL',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'SYSTEM\nINITIALIZATION',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    height: 1.2,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 50),

                const AuthSectionLabel(text: '> IDENTIFIER'),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _userCtrl,
                  hintText: 'user@gmail.com',
                  obscureText: false,
                ),

                const SizedBox(height: 18),

                const AuthSectionLabel(text: '> ACCESS KEY'),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _passCtrl,
                  hintText: '•••••••',
                  obscureText: true,
                ),

                const SizedBox(height: 40),

                AuthPrimaryButton(text: buttonText, onPressed: onPressed),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                  child: const Text("Don't have an account? Register here"),
                ),

                const SizedBox(height: 20),

                Text(
                  'v1.4.0 [MVP_BUILD]',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
