import 'package:flutter/material.dart';

/// Reusable primary button based on the global theme.
///
/// Use it for the main action of forms and screens.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? ElevatedButton(onPressed: onPressed, child: Text(text))
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          );

    if (!expand) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
