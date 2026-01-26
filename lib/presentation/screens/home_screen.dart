import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 61, 144, 253),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          foregroundColor: Color.fromARGB(255, 201, 187, 61),
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 201, 187, 61),
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),

      initialRoute: '/splash', // Pantalla inicial con rutas nombradas

      // Rutas disponibles en la app
      routes: {
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => const SplashScreen(),
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
      // Estructura principal con AppBar y Drawer
      appBar: AppBar(
        title: const Text("Habit Control"),
      ),

      drawer: const Drawer(
        child: LateralMenu(), // Menú lateral reutilizable
      ),

      // Contenido principal
      body: const Center(
        child: Text('¡Abre el menú lateral para navegar!'),
      ),
    );
  }
}