import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme configuration for the application.
///
/// Currently exposes a single dark theme via [dark].
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  static const Color _primary = Color(0xFF64F6FF);
  static const Color _bg = Color(0xFF090E15);
  static const Color _surface = Color(0xFF111827);
  static const Color _surfaceSoft = Color(0xFF1E293B);
  static const Color _border = Color(0xFF334155);
  static const Color _text = Color(0xFFF8FAFC);
  static const Color _muted = Color(0xFF94A3B8);

  /// Returns the dark [ThemeData] used by the app.
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primary,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _primary,
        surface: _surface,
        onPrimary: _bg,
        onSurface: _text,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _primary),
      ),

      iconTheme: const IconThemeData(color: _primary, size: 22),

      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: _border,
        thickness: 1,
        space: 1,
      ),

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.jetBrainsMono(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: _text,
        ),
        headlineMedium: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _text,
        ),
        titleLarge: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _text,
        ),
        titleMedium: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
        bodyLarge: GoogleFonts.robotoMono(fontSize: 16, color: _text),
        bodyMedium: GoogleFonts.robotoMono(fontSize: 14, color: _muted),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: _muted,
          letterSpacing: 1.2,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _bg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        labelStyle: const TextStyle(color: _primary),
        hintStyle: const TextStyle(color: _muted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceSoft,
        contentTextStyle: GoogleFonts.robotoMono(fontSize: 13, color: _text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _border),
        ),
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _text,
        ),
        contentTextStyle: GoogleFonts.robotoMono(fontSize: 14, color: _muted),
      ),
    );
  }
}
