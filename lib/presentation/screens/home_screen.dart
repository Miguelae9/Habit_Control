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
      theme: AppTheme.dark(), // Usa el tema aquí
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/imgs/habit_control_logo.png',
                      width: 130,
                      height: 130,
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

                  const Text(
                    'SYSTEM\nINITIALIZATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.0,
                      height: 1.2,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const _SectionLabel(text: '> IDENTIFICADOR'),
                  const SizedBox(height: 10),
                  const _TextFieldBox(hintText: 'usuario', obscureText: false),

                  const SizedBox(height: 18),

                  const _SectionLabel(text: '> CLAVE DE ACCESO'),
                  const SizedBox(height: 10),
                  const _TextFieldBox(hintText: '••••••••', obscureText: true),

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
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
                        'ESTABLECER CONEXIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'v1.0.0 [MVP_BUILD]',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.6,
        color: Color(0xFF6CFAFF),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const _TextFieldBox({required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(
        color: Color(0xFFE5E7EB),
        letterSpacing: 1.1,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          letterSpacing: 1.0,
        ),
        filled: true,
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
          borderSide: const BorderSide(color: Color(0xFF6CFAFF), width: 1.5),
        ),
      ),
    );
  }
}
