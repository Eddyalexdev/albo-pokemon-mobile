import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Atom label with uppercase Bungee font.
class AppLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;

  const AppLabel(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: DesignTypography.labelLarge.copyWith(
        color: color ?? DesignColors.ink,
        fontSize: fontSize,
      ),
      textAlign: textAlign,
    );
  }
}
