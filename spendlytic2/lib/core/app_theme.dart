import 'package:flutter/material.dart';

class AppTheme {
  // 🌸 Light Theme
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7FAFF), // Light Blue

    colorScheme: const ColorScheme.light(
      primary: Color(0xFFCBB8D6), // Lavender
      secondary: Color(0xFFA4C6E9), // Sky Blue
      tertiary: Color(0xFFEFA8C8), // Soft Pink
      surface: Colors.white,
      onPrimary: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFCBB8D6),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );
}
