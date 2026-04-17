import 'package:flutter/material.dart';

/// Design system colors matching web-new CSS variables.
/// Use these constants instead of hardcoded colors throughout the app.
abstract final class DesignColors {
  // Primary palette
  static const Color ink = Color(0xFF1A1410);
  static const Color cream = Color(0xFFFDF8EE);
  static const Color creamSoft = Color(0xFFF5ECD8);
  static const Color gold = Color(0xFFD4A84B);
  static const Color goldDeep = Color(0xFFA87C1E);
  static const Color crimson = Color(0xFFB23A2A);
  static const Color crimsonDeep = Color(0xFF7A2518);
  static const Color forest = Color(0xFF2D5A3D);
  static const Color sky = Color(0xFF6FB3D9);

  // Pokémon type colors
  static const Color typeNormal = Color(0xFFC6C6A7);
  static const Color typeFire = Color(0xFFF5AC78);
  static const Color typeWater = Color(0xFF9DB7F5);
  static const Color typeElectric = Color(0xFFFAE078);
  static const Color typeGrass = Color(0xFFA7DB8D);
  static const Color typeIce = Color(0xFFBCE6E6);
  static const Color typeFighting = Color(0xFFD67873);
  static const Color typePoison = Color(0xFFC183C1);
  static const Color typeGround = Color(0xFFEBD69D);
  static const Color typeFlying = Color(0xFFC6B7F5);
  static const Color typePsychic = Color(0xFFFA92B2);
  static const Color typeBug = Color(0xFFC6D16E);
  static const Color typeRock = Color(0xFFD1C17D);
  static const Color typeGhost = Color(0xFFA292BC);
  static const Color typeDragon = Color(0xFFA27DFA);
  static const Color typeDark = Color(0xFFA29288);
  static const Color typeSteel = Color(0xFFD1D1E0);
  static const Color typeFairy = Color(0xFFF4BDC9);

  /// Get Pokémon type color by type name (lowercase).
  static Color forType(String type) {
    return switch (type.toLowerCase()) {
      'normal' => typeNormal,
      'fire' => typeFire,
      'water' => typeWater,
      'electric' => typeElectric,
      'grass' => typeGrass,
      'ice' => typeIce,
      'fighting' => typeFighting,
      'poison' => typePoison,
      'ground' => typeGround,
      'flying' => typeFlying,
      'psychic' => typePsychic,
      'bug' => typeBug,
      'rock' => typeRock,
      'ghost' => typeGhost,
      'dragon' => typeDragon,
      'dark' => typeDark,
      'steel' => typeSteel,
      'fairy' => typeFairy,
      _ => typeNormal,
    };
  }
}
