// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF6CFAFF);
  static const _bg = Color(0xFF0B0F14);
  static const _text = Color(0xFFE5E7EB);
  static const _muted = Color(0xFF9CA3AF);
  static const _inputFill = Color(0xFF141A22);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primary,
    scaffoldBackgroundColor: _bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: _bg,
      foregroundColor: _text,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _primary,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: _muted),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: _inputFill,
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primary),
      ),
      labelStyle: TextStyle(color: _primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _bg,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
