import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class GameColors {
  static const ink = Color(0xFF1A1410);
  static const cream = Color(0xFFFDF8EE);
  static const creamSoft = Color(0xFFF5ECD8);
  static const gold = Color(0xFFD4A84B);
  static const goldDeep = Color(0xFFA87C1E);
  static const crimson = Color(0xFFB23A2A);
  static const crimsonDeep = Color(0xFF7A2518);
  static const forest = Color(0xFF2D5A3D);
  static const sky = Color(0xFF6FB3D9);
}

ThemeData buildGameTheme() {
  final bungee = GoogleFonts.bungeeTextTheme();
  final fraunces = GoogleFonts.frauncesTextTheme();
  final jetbrains = GoogleFonts.jetBrainsMonoTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: GameColors.cream,
    colorSchemeSeed: GameColors.crimson,
    brightness: Brightness.light,
    textTheme: fraunces.copyWith(
      displayLarge: bungee.displayLarge?.copyWith(color: GameColors.ink),
      displayMedium: bungee.displayMedium?.copyWith(color: GameColors.ink),
      displaySmall: bungee.displaySmall?.copyWith(color: GameColors.ink),
      headlineLarge: bungee.headlineLarge?.copyWith(color: GameColors.ink),
      headlineMedium: bungee.headlineMedium?.copyWith(color: GameColors.ink),
      headlineSmall: bungee.headlineSmall?.copyWith(color: GameColors.ink),
      titleLarge: bungee.titleLarge?.copyWith(color: GameColors.ink),
      titleMedium: bungee.titleMedium?.copyWith(color: GameColors.ink),
      titleSmall: bungee.titleSmall?.copyWith(color: GameColors.ink),
      labelLarge: bungee.labelLarge?.copyWith(color: GameColors.ink),
      labelMedium: jetbrains.labelMedium?.copyWith(color: GameColors.goldDeep),
      labelSmall: jetbrains.labelSmall?.copyWith(color: GameColors.goldDeep),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: GameColors.crimson,
      foregroundColor: GameColors.cream,
      titleTextStyle: bungee.titleLarge?.copyWith(
        color: GameColors.cream,
        fontSize: 18,
      ),
      elevation: 0,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GameColors.crimson,
        foregroundColor: GameColors.cream,
        textStyle: bungee.labelLarge?.copyWith(
          letterSpacing: 1.5,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: GameColors.ink, width: 3),
        ),
        elevation: 4,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GameColors.ink,
        textStyle: bungee.labelLarge?.copyWith(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: GameColors.ink, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GameColors.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GameColors.ink, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GameColors.ink, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GameColors.gold, width: 3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: GameColors.cream,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GameColors.ink, width: 3),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GameColors.crimson,
      contentTextStyle: fraunces.bodyMedium?.copyWith(color: GameColors.cream),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
