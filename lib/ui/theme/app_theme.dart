import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF1B5E20);
const Color secondaryGreen = Color(0xFF66BB6A);
// const Color surfaceLight = Color(0xFFF6F8F6);
// const Color surfaceDark = Color(0xFF0F1A14);

// Core modern blues
const Color primaryBlue = Color(0xFF3B82F6); // modern soft blue (Tailwind-ish)
const Color secondaryBlue = Color(0xFF7DD3FC); // light cyan accent

// Surfaces (THIS is what makes it modern)
const Color surfaceLight = Color(0xFFF8FAFF); // blue-tinted white
const Color surfaceCard = Color(0xFFFFFFFF);
const Color surfaceDark = Color(0xFF0A0F1C); // clean dark, not navy

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Manrope',

    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: surfaceLight,
      background: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      error: Color(0xFFB3261E),
    ),

    scaffoldBackgroundColor: surfaceLight,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Manrope',

    colorScheme: ColorScheme.dark(
      primary: secondaryGreen,
      secondary: primaryGreen,
      surface: surfaceDark,
      background: surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      error: Color(0xFFCF6679),
    ),

    scaffoldBackgroundColor: surfaceDark,
  );

  static ThemeData blueLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Manrope',

    scaffoldBackgroundColor: surfaceLight,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryBlue,
      background: surfaceLight,
      surface: surfaceCard,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFF0F172A), // soft black (NOT pure black)
      error: Color(0xFFEF4444),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF0F172A),
    ),

    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );

  static ThemeData blueDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Manrope',

    scaffoldBackgroundColor: surfaceDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryBlue,
      background: surfaceDark,
      surface: Color(0xFF111827),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE5E7EB),
      error: Color(0xFFF87171),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF111827),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
