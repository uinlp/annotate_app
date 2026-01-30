import 'package:flutter/material.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';

const Color _appPrimary = Color(0xFF3341A4); // deep indigo/purple
const Color _appSecondary = Color(0xFF00BFA5); // teal accent

final ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: _appPrimary,
  brightness: Brightness.light,
).copyWith(secondary: _appSecondary);

final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: _appPrimary,
  brightness: Brightness.dark,
).copyWith(secondary: _appSecondary);

ThemeData _baseTheme(ColorScheme scheme) {
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: scheme.primary,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline.withAlpha(155)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceDim.withAlpha(155),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: scheme.onSurface.withAlpha(155)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.secondary,
      foregroundColor: scheme.onSecondary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurface.withAlpha(155),
      selectedIconTheme: IconThemeData(size: 22, color: scheme.primary),
      unselectedIconTheme: IconThemeData(
        size: 20,
        color: scheme.onSurface.withAlpha(155),
      ),
      showUnselectedLabels: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

/// Light theme to use in MaterialApp.theme
final ThemeData appLightTheme = _baseTheme(_lightScheme);

/// Dark theme to use in MaterialApp.darkTheme
final ThemeData appDarkTheme = _baseTheme(_darkScheme);
