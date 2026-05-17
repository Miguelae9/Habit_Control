import 'package:flutter/material.dart';

import 'package:habit_control/core/router/app_routes.dart';
import 'package:habit_control/features/auth/viewmodels/register_view_model.dart';
import 'package:habit_control/shared/app_card.dart';

import '../widgets/auth_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_section_label.dart';
import '../widgets/auth_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final RegisterViewModel _viewModel = RegisterViewModel();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final error = await _viewModel.register(
      email: _userCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Registration completed successfully')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);

        final Color bg = theme.scaffoldBackgroundColor;
        final Color textMain =
            theme.textTheme.headlineLarge?.color ?? const Color(0xFFE5E7EB);
        final Color textMuted =
            theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF);

        final bool loading = _viewModel.loading;
        final String buttonText = loading ? 'CREATING...' : 'CREATE ACCOUNT';
        final VoidCallback? onPressed = loading ? null : _register;

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
                    const SizedBox(height: 30),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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

                          const SizedBox(height: 28),

                          AuthPrimaryButton(
                            text: buttonText,
                            onPressed: onPressed,
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: loading
                                ? null
                                : () => Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  ),
                            child: const Text('Go back to login'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'v1.9.0 [MVP_BUILD]',
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
      },
    );
  }
}
