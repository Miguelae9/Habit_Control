import 'package:flutter/material.dart';

import 'package:habit_control/shared/lateral_menu/lateral_menu.dart';
import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';
import 'package:habit_control/shared/app_top_bar.dart';

class CreditsView extends StatelessWidget {
  const CreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'CREDITS'),
      drawer: const Drawer(child: LateralMenu()),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'SYSTEM\nARCHITECTURE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 28),

              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSectionTitle(
                      title: 'PROJECT',
                      subtitle: 'Application build and author information',
                      icon: Icons.info_outline,
                    ),
                    SizedBox(height: 10),
                    _InfoLine(
                      label: 'CODE',
                      value: 'Miguel Ángel Pérez García',
                    ),
                    SizedBox(height: 10),
                    _InfoLine(label: 'BUILD', value: 'v2.0.0'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSectionTitle(
                      title: 'TECHNOLOGIES',
                      subtitle: 'Main tools currently used by the app',
                      icon: Icons.memory,
                    ),
                    SizedBox(height: 10),
                    _TechTile(
                      icon: Icons.flutter_dash,
                      title: 'Flutter',
                      subtitle: 'Cross-platform UI framework',
                    ),
                    _TechTile(
                      icon: Icons.lock_outline,
                      title: 'Firebase Auth',
                      subtitle: 'User registration, login and session handling',
                    ),
                    _TechTile(
                      icon: Icons.cloud_outlined,
                      title: 'Cloud Firestore',
                      subtitle: 'Cloud persistence and synchronization',
                    ),
                    _TechTile(
                      icon: Icons.storage_outlined,
                      title: 'sqflite',
                      subtitle: 'Local SQLite persistence',
                    ),
                    _TechTile(
                      icon: Icons.sync_alt,
                      title: 'Provider',
                      subtitle: 'Shared app state management',
                    ),
                    _TechTile(
                      icon: Icons.bar_chart,
                      title: 'fl_chart',
                      subtitle: 'Analytics charts and progress visualization',
                    ),
                    _TechTile(
                      icon: Icons.donut_large,
                      title: 'percent_indicator',
                      subtitle: 'Circular and percentage progress indicators',
                    ),
                    _TechTile(
                      icon: Icons.text_fields,
                      title: 'Google Fonts',
                      subtitle: 'Application typography',
                    ),
                    _TechTile(
                      icon: Icons.calendar_month,
                      title: 'intl',
                      subtitle: 'Date formatting and locale support',
                    ),
                    _TechTile(
                      icon: Icons.wb_cloudy_outlined,
                      title: 'External APIs',
                      subtitle: 'Weather and stoic quote services',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _TechTile extends StatelessWidget {
  const _TechTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 28,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
    );
  }
}
