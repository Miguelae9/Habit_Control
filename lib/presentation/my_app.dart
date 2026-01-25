import 'package:flutter/material.dart';
import 'package:habit_control_mvp/config/theme/app_theme.dart'; // Asegúrate que esta ruta exista

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Control',
      theme: AppTheme.darkTheme, // Usamos tu tema oscuro
      home: const Scaffold(
        body: Center(child: Text("Cargando Sistema...")),
      ),
      // Más adelante cambiaremos 'home' por 'routerConfig' de GoRouter
    );
  }
}