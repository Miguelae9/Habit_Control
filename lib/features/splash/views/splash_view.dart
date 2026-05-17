import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/features/splash/viewmodels/splash_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/shared/app_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final viewModel = SplashViewModel(
      habitDayViewModel: context.read<HabitDayViewModel>(),
      habitCatalogViewModel: context.read<HabitCatalogViewModel>(),
      metricsViewModel: context.read<MetricsViewModel>(),
    );

    final nextRoute = await viewModel.bootstrap();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AppLogo(size: 280),

                const SizedBox(height: 42),

                Text(
                  'HABIT\nCONTROL',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    height: 1.05,
                    letterSpacing: 1.8,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'PERSONAL HABIT TRACKER',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),

                const SizedBox(height: 42),

                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 42),

                Text(
                  'v1.9.0 [MVP_BUILD]',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
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
