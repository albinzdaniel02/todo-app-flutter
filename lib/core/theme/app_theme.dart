import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Custom-tailored Light Theme colors
  static const Color _lightPrimary = Color(0xFF4F46E5); // Indigo 600
  static const Color _lightOnPrimary = Colors.white;
  static const Color _lightPrimaryContainer = Color(0xFFE0E7FF); // Indigo 100
  static const Color _lightOnPrimaryContainer = Color(0xFF312E81); // Indigo 900
  static const Color _lightSecondary = Color(0xFF0EA5E9); // Sky 500
  static const Color _lightOnSecondary = Colors.white;
  static const Color _lightSecondaryContainer = Color(0xFFE0F2FE); // Sky 100
  static const Color _lightOnSecondaryContainer = Color(0xFF0369A1); // Sky 700
  static const Color _lightTertiary = Color(0xFF10B981); // Emerald 500
  static const Color _lightOnTertiary = Colors.white;
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _lightSurface = Colors.white;
  static const Color _lightOnSurface = Color(0xFF0F172A); // Slate 900
  static const Color _lightOnSurfaceVariant = Color(0xFF475569); // Slate 600
  static const Color _lightError = Color(0xFFEF4444); // Red 500
  static const Color _lightOnError = Colors.white;
  static const Color _lightOutline = Color(0xFFCBD5E1); // Slate 300

  // Custom-tailored Dark Theme colors
  static const Color _darkPrimary = Color(0xFF818CF8); // Indigo 400
  static const Color _darkOnPrimary = Color(0xFF1E1B4B); // Indigo 950
  static const Color _darkPrimaryContainer = Color(0xFF312E81); // Indigo 900
  static const Color _darkOnPrimaryContainer = Color(0xFFE0E7FF); // Indigo 100
  static const Color _darkSecondary = Color(0xFF38BDF8); // Sky 400
  static const Color _darkOnSecondary = Color(0xFF082F49); // Sky 950
  static const Color _darkSecondaryContainer = Color(0xFF0369A1); // Sky 700
  static const Color _darkOnSecondaryContainer = Color(0xFFE0F2FE); // Sky 100
  static const Color _darkTertiary = Color(0xFF34D399); // Emerald 400
  static const Color _darkOnTertiary = Color(0xFF064E3B); // Emerald 950
  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color _darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color _darkOnSurface = Color(0xFFF8FAFC); // Slate 50
  static const Color _darkOnSurfaceVariant = Color(0xFF94A3B8); // Slate 400
  static const Color _darkError = Color(0xFFF87171); // Red 400
  static const Color _darkOnError = Color(0xFF7F1D1D); // Red 950
  static const Color _darkOutline = Color(0xFF475569); // Slate 600

  static ColorScheme get _lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: _lightPrimary,
    onPrimary: _lightOnPrimary,
    primaryContainer: _lightPrimaryContainer,
    onPrimaryContainer: _lightOnPrimaryContainer,
    secondary: _lightSecondary,
    onSecondary: _lightOnSecondary,
    secondaryContainer: _lightSecondaryContainer,
    onSecondaryContainer: _lightOnSecondaryContainer,
    tertiary: _lightTertiary,
    onTertiary: _lightOnTertiary,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    onSurfaceVariant: _lightOnSurfaceVariant,
    error: _lightError,
    onError: _lightOnError,
    outline: _lightOutline,
  );

  static ColorScheme get _darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: _darkPrimary,
    onPrimary: _darkOnPrimary,
    primaryContainer: _darkPrimaryContainer,
    onPrimaryContainer: _darkOnPrimaryContainer,
    secondary: _darkSecondary,
    onSecondary: _darkOnSecondary,
    secondaryContainer: _darkSecondaryContainer,
    onSecondaryContainer: _darkOnSecondaryContainer,
    tertiary: _darkTertiary,
    onTertiary: _darkOnTertiary,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    onSurfaceVariant: _darkOnSurfaceVariant,
    error: _darkError,
    onError: _darkOnError,
    outline: _darkOutline,
  );

  static ThemeData get lightThemeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightOnSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: _lightSurface, elevation: 1),
  );

  static ThemeData get darkThemeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkOnSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: _darkSurface, elevation: 1),
  );
}
