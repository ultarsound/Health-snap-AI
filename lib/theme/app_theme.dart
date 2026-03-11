import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color softWhite = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E2E);
  static const Color bgDark = Color(0xFF0F0F1A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: softWhite,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentOrange,
      surface: cardLight,
    ),
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: lightGreen,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: lightGreen,
      secondary: accentOrange,
      surface: cardDark,
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: lightGreen,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
  );
}
