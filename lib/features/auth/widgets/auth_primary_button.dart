import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_primary_button.dart';

/// Primary call-to-action button used on authentication screens.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: AppPrimaryButton(text: text, onPressed: onPressed),
    );
  }
}
