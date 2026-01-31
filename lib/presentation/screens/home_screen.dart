import 'package:flutter/material.dart';
import 'package:habit_control/presentation/router/app_routes.dart';
import 'package:habit_control/presentation/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Control',
      theme: AppTheme.dark(), // Usa el tema definido para toda la app
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.map,
    );
  }
}

// Pantalla principal de la aplicación
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Fondo usando el tema
      body: SafeArea(
        child: SingleChildScrollView(
          // Permite que el contenido se desplace
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/imgs/habit_control_logo.png',
                      width: 130,
                      height: 130,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'HABIT\nCONTROL',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'SYSTEM\nINITIALIZATION',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    height: 1.2,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),

                const SizedBox(height: 50),

                // Usando el estilo directamente desde el Theme
                const Text(
                  '> IDENTIFIER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.6,
                    color: Color(0xFF6CFAFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: false,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: const Color(0xFFE5E7EB),
                  ),
                  decoration: InputDecoration(
                    hintText: 'usuario',
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF6CFAFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  '> ACCESS KEY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.6,
                    color: Color(0xFF6CFAFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: const Color(0xFFE5E7EB),
                  ),
                  decoration: InputDecoration(
                    hintText: '•••••••',
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF6CFAFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de conexión
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      ); // Navegar a la pantalla de dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'CONNECT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'v0.1.0 [MVP_BUILD]',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  }
}
