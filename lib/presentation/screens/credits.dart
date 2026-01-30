import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menú lateral
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Fondo usando el tema
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  // Botón para abrir el drawer
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

              // Título
              Text(
                'ARQUITECTURA DEL\nSISTEMA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 28),

              // Información adicional
              Text(
                'CODE: [Miguel Ángel Pérez García]',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),

              const SizedBox(height: 8),

              Text(
                'BUILD: v0.1.0',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),

              const SizedBox(height: 32),

              // Subtítulo de tecnologías
              Text(
                'TECNOLOGÍAS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              // Lista de tecnologías
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
                'PROVIDER (gestión de estado · MVVM)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'GO ROUTER (navegación)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'FL CHART (gráficas)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'PERCENT INDICATOR (indicadores de progreso)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 15),
              Text(
                'GOOGLE FONTS (tipografía)',
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
