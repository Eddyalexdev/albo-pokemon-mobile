import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// App-wide ThemeData using design system tokens.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: DesignColors.crimson,
        onPrimary: DesignColors.cream,
        secondary: DesignColors.gold,
        onSecondary: DesignColors.ink,
        surface: DesignColors.cream,
        onSurface: DesignColors.ink,
        error: DesignColors.crimsonDeep,
      ),
      scaffoldBackgroundColor: DesignColors.cream,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: DesignTypography.displayMedium,
        iconTheme: const IconThemeData(color: DesignColors.ink),
      ),
      textTheme: TextTheme(
        displayLarge: DesignTypography.displayLarge,
        displayMedium: DesignTypography.displayMedium,
        displaySmall: DesignTypography.displaySmall,
        bodyLarge: DesignTypography.bodyLarge,
        bodyMedium: DesignTypography.bodyMedium,
        bodySmall: DesignTypography.bodySmall,
        labelLarge: DesignTypography.labelLarge,
        labelMedium: DesignTypography.labelMedium,
        labelSmall: DesignTypography.labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignColors.creamSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColors.ink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColors.ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColors.gold, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignColors.crimson, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: DesignTypography.bodyMedium.copyWith(
          color: DesignColors.goldDeep,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.crimson,
          foregroundColor: DesignColors.cream,
          textStyle: DesignTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignColors.ink,
          textStyle: DesignTypography.button.copyWith(color: DesignColors.ink),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: DesignColors.ink, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: DesignColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DesignColors.ink, width: 2),
        ),
      ),
    );
  }
}
