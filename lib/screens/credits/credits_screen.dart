import 'package:flutter/material.dart';
import 'package:habit_control/shared/widgets/lateral_menu/lateral_menu.dart';

/// Static "credits / architecture" screen.
///
/// Shows a drawer entry point and a list of technologies as plain text.
class CreditsScreen extends StatelessWidget {
  /// Creates the credits screen.
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: Theme.of(context).iconTheme.color,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'SYSTEM\nARCHITECTURE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 28),

              Text(
                'CODE: [Miguel Ángel Pérez García]',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),

              const SizedBox(height: 8),

              Text(
                'BUILD: v1.4.0',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),

              const SizedBox(height: 32),

              Text(
                'TECHNOLOGIES',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'FLUTTER (framework)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'FIREBASE (auth & firestore)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'PROVIDER (state management · MVVM)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'GO ROUTER (navigation)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'FL CHART (charts)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'PERCENT INDICATOR (progress indicators)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'GOOGLE FONTS (typography)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
