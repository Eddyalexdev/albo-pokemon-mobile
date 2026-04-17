import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design system typography using Google Fonts.
/// Bungee for headings, Fraunces for body, JetBrains Mono for stats.
abstract final class DesignTypography {
  // Display styles (Bungee - headings, buttons, labels)
  static TextStyle displayLarge = GoogleFonts.bungee(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle displayMedium = GoogleFonts.bungee(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle displaySmall = GoogleFonts.bungee(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  // Body styles (Fraunces - body text, inputs)
  static TextStyle bodyLarge = GoogleFonts.fraunces(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle bodyMedium = GoogleFonts.fraunces(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle bodySmall = GoogleFonts.fraunces(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  // Stats style (JetBrains Mono - HP, numbers, stats)
  static TextStyle stats = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DesignColors.ink,
  );

  static TextStyle statsSmall = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DesignColors.ink,
  );

  // Label styles (Bungee - UI labels)
  static TextStyle labelLarge = GoogleFonts.bungee(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle labelMedium = GoogleFonts.bungee(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  static TextStyle labelSmall = GoogleFonts.bungee(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: DesignColors.ink,
  );

  // Button text style (Bungee - buttons)
  static TextStyle button = GoogleFonts.bungee(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DesignColors.cream,
  );
}
