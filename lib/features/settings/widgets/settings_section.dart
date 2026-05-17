import 'package:flutter/material.dart';

import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.subtitle,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSectionTitle(title: title, subtitle: subtitle, icon: icon),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
