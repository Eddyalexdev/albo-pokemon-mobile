import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Molecule showing lobby or battle status as a badge.
class StatusChip extends StatelessWidget {
  final String text;
  final StatusChipColor color;

  const StatusChip({
    super.key,
    required this.text,
    this.color = StatusChipColor.neutral,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DesignColors.ink, width: 2),
      ),
      child: Text(
        text.toUpperCase(),
        style: DesignTypography.labelSmall.copyWith(
          color: color.textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

enum StatusChipColor {
  neutral,
  success,
  warning,
  danger;

  Color get backgroundColor => switch (this) {
        neutral => DesignColors.cream,
        success => DesignColors.forest,
        warning => DesignColors.gold,
        danger => DesignColors.crimson,
      };

  Color get textColor => switch (this) {
        neutral => DesignColors.ink,
        success => DesignColors.cream,
        warning => DesignColors.ink,
        danger => DesignColors.cream,
      };
}
