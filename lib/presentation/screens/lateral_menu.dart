import 'package:flutter/material.dart';
import 'package:habit_control/presentation/router/app_routes.dart';

class LateralMenu extends StatelessWidget {
  const LateralMenu({super.key});

  // Colores propios del drawer (no vienen del Theme).
  static const Color _card = Color(0xFF141A22);
  static const Color _border = Color(0xFF1F2A37);

  @override
  Widget build(BuildContext context) {
    // Theme de la app (AppTheme.dark()).
    final theme = Theme.of(context);

    // Colores del Theme.
    final bg = theme.scaffoldBackgroundColor;
    final accent = theme.primaryColor;

    // Color de texto (si el theme no lo trae, uso un fallback).
    final textMain =
        theme.textTheme.headlineLarge?.color ?? const Color(0xFFF8FAFC);
    final textMuted =
        theme.textTheme.bodyMedium?.color ?? const Color(0xFF94A3B8);

    // Ruta actual (ej: '/dashboard'). Sirve para marcar el item seleccionado.
    // Puede ser null si la pantalla no tiene "name".
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Crea un botón del menú (reutilizable).
    Widget item({required String label, required String routeName}) {
      final selected = currentRoute == routeName;
      final color = selected ? accent : textMuted;

      return Container(
        height: 48,
        decoration: const BoxDecoration(
          color: _card,
          border: Border(
            top: BorderSide(color: _border),
            bottom: BorderSide(color: _border),
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Cierra el drawer
            Navigator.pushReplacementNamed(
              context,
              routeName,
            ); // Cambia pantalla
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // '>' separado del texto para controlar spacing/alineación.
                Text(
                  '>',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/imgs/habit_control_logo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'HABIT\nCONTROL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: _border),

            // ITEMS
            item(label: 'DASHBOARD', routeName: AppRoutes.dashboard),
            item(label: 'REGISTRO DE DATOS', routeName: AppRoutes.dataLogging),
            item(label: 'ANALÍTICAS', routeName: AppRoutes.analytics),
            item(label: 'ACERCA DE', routeName: AppRoutes.credits),

            const Spacer(),

            item(label: 'CERRAR SESIÓN', routeName: AppRoutes.home),
          ],
        ),
      ),
    );
  }
}
