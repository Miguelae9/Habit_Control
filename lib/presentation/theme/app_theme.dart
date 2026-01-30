// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Creamos una clase privada para los colores que usaremos en el tema
  AppTheme._();

  // Definimos los colores que vamos a usar en el tema
  static const Color _primary = Color(0xFF64F6FF); // Azul claro
  static const Color _bg = Color(0xFF090E15); // Fondo oscuro
  static const Color _text = Color(0xFFF8FAFC); // Color de texto claro
  static const Color _muted = Color(
    0xFF94A3B8,
  ); // Color gris apagado para textos secundarios
  static const Color _inputFill = Color(
    0xFF1E293B,
  ); // Color oscuro para el fondo de los campos de texto

  // El método 'dark' devuelve un ThemeData con la configuración que queremos
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark, // Usamos un tema oscuro
      // Asignamos el color principal de la app
      primaryColor: _primary,

      // Asignamos el color de fondo de la app
      scaffoldBackgroundColor: _bg,

      // Configuramos la barra de navegación superior (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: _bg, // El fondo de la AppBar será igual al del fondo
        foregroundColor: _text, // El color de los textos en AppBar será claro
        elevation: 0, // Sin sombra en la AppBar
        centerTitle: true, // Centrar el título de la AppBar
      ),

      // Estilo de los textos en toda la app
      textTheme: const TextTheme(
        // Título principal de la app (por ejemplo, la pantalla inicial)
        headlineLarge: TextStyle(
          fontSize: 32, // Tamaño grande
          fontWeight: FontWeight.bold, // Negrita
          color: _text, // Color claro para que contraste con el fondo oscuro
        ),
        // Subtítulos o títulos de secciones
        titleMedium: TextStyle(
          fontSize: 16, // Tamaño de fuente mediano
          fontWeight: FontWeight.w600, // Semi-negrita
          color:
              _primary, // El color del texto será el color primario (azul claro)
        ),
        // Texto normal (como en los párrafos)
        bodyMedium: TextStyle(
          fontSize: 14, // Tamaño de fuente pequeño
          color: _muted, // Color gris apagado para textos secundarios
        ),
      ),

      // Estilo para los campos de texto (Input Fields)
      inputDecorationTheme: const InputDecorationTheme(
        filled: true, // Permitimos que los campos tengan un color de fondo
        fillColor: _inputFill, // El fondo de los campos de texto será oscuro
        border: OutlineInputBorder(), // Bordes estándar
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _primary,
          ), // Bordes cuando el campo está enfocado (activo) serán del color primario
        ),
        labelStyle: TextStyle(
          color: _primary,
        ), // El texto de los labels será de color primario (azul claro)
      ),

      // Estilo para los botones elevados (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _primary, // El color de fondo de los botones será azul claro
          foregroundColor:
              _bg, // El texto de los botones será del color de fondo (oscuro)
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ), // Negrita en el texto de los botones
        ),
      ),
    );
  }
}
