// widgets/settings_header.dart
import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final VoidCallback onMenuTap;

  const SettingsHeader({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.white;

    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.menu, color: iconColor),
          onPressed: onMenuTap,
        ),
        const Spacer(),
        Text(
          'SETTINGS',
          style: TextStyle(fontSize: 11, letterSpacing: 1.8, color: iconColor),
        ),
      ],
    );
  }
}
