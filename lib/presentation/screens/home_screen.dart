import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/analytics.dart';
import 'package:habit_control/presentation/screens/credits.dart';
import 'package:habit_control/presentation/screens/dashboard.dart';
import 'package:habit_control/presentation/screens/input_log';
import 'package:habit_control/presentation/screens/splash.dart';
// Import único de todas las pantallas

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Clase raíz de la aplicación

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "Debug"
      title: 'Habit Control',

      // Tema general de la app
      theme: ThemeData(
        brightness: Brightness.dark,

        primaryColor: const Color(0xFF6CFAFF),
        scaffoldBackgroundColor: const Color(0xFF0B0F14),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F14),
          foregroundColor: Color(0xFFE5E7EB),
          elevation: 0,
          centerTitle: true,
        ),

        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6CFAFF),
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF141A22),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6CFAFF)),
          ),
          labelStyle: TextStyle(color: Color(0xFF6CFAFF)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6CFAFF),
            foregroundColor: const Color(0xFF0B0F14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      initialRoute: '/credits', // Pantalla inicial con rutas nombradas
      // Rutas disponibles en la app
      routes: {
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/credits': (context) => const CreditsScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/data_logging': (context) => const InputLogScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
      },
    );
  }
}

// Pantalla principal de la aplicación
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),

                  // TODO: aquí va la imagen/logo (icono del cerebro)
                  // Center(child: Image.asset('assets/logo.png', width: 84, height: 84)),
                  const SizedBox(height: 18),

                  const Text(
                    'HABIT\nCONTROL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: 2.0,
                      color: Color(0xFFE5E7EB),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6CFAFF),
                        foregroundColor: const Color(0xFF0B0F14),
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
        fillColor: const Color(0xFF1B2430),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF6CFAFF), width: 1.5),
        ),
      ),
    );
  }
}
