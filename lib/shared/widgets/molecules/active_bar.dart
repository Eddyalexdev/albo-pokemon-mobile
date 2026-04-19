import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Molecule displaying HP bar with gradient based on HP percentage.
class ActiveBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final String? label;

  const ActiveBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.label,
  });

  double get _hpPercent => maxHp > 0 ? (currentHp / maxHp).clamp(0.0, 1.0) : 0.0;

  Color get _barColor {
    if (_hpPercent > 0.5) {
      return DesignColors.forest; // Green
    } else if (_hpPercent > 0.2) {
      return DesignColors.gold; // Yellow
    } else {
      return DesignColors.crimson; // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.sm),
      decoration: BoxDecoration(
        color: DesignColors.creamSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.ink, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!.toUpperCase(),
                  style: DesignTypography.labelSmall.copyWith(
                    color: DesignColors.goldDeep,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$currentHp/$maxHp',
                  style: DesignTypography.statsSmall.copyWith(
                    color: DesignColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.xs),
          ],
          Stack(
            children: [
              // Background
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: DesignColors.ink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // HP fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 12,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _hpPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _barColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: DesignColors.ink, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
