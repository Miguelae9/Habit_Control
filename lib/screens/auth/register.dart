import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_control/router/app_routes.dart';

import 'widgets/auth_logo.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_section_label.dart';
import 'widgets/auth_text_field.dart';

/// Register screen backed by Firebase Auth email/password sign-up.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLoading = false;

  String _toEmail(String email) {
    return email.trim();
  }

  Future<void> _register() async {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _toEmail(user),
        password: pass,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration completed successfully')),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Could not register user. Please try again.';

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Email address is not valid.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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

    final String buttonText = _isLoading ? 'CREATING...' : 'CREATE ACCOUNT';
    final VoidCallback? onPressed = _isLoading ? null : _register;

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
                  'NEW USER\nREGISTRATION',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    height: 1.2,
                    color: textMuted,
                  ),
                ),

                const SizedBox(height: 50),

                const AuthSectionLabel(text: '> NEW IDENTIFIER'),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _userCtrl,
                  hintText: 'user@gmail.com',
                  obscureText: false,
                ),

                const SizedBox(height: 18),

                const AuthSectionLabel(text: '> NEW ACCESS KEY'),
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
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          );
                        },
                  child: const Text('Go back to login'),
                ),

                const SizedBox(height: 20),

                Text(
                  'v0.1.0 [MVP_BUILD]',
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
