import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Atom button with 3D press effect.
/// Variants: primary (crimson), gold, default.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool enabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.enabled = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum AppButtonVariant { primary, gold, secondary }

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onPressed != null;

    final backgroundColor = switch (widget.variant) {
      AppButtonVariant.primary => isEnabled
          ? (_isPressed ? DesignColors.crimsonDeep : DesignColors.crimson)
          : DesignColors.crimsonDeep.withValues(alpha: 0.5),
      AppButtonVariant.gold => isEnabled
          ? (_isPressed ? DesignColors.goldDeep : DesignColors.gold)
          : DesignColors.goldDeep.withValues(alpha: 0.5),
      AppButtonVariant.secondary => isEnabled
          ? (_isPressed ? DesignColors.ink : DesignColors.creamSoft)
          : DesignColors.creamSoft.withValues(alpha: 0.5),
    };

    final textColor = switch (widget.variant) {
      AppButtonVariant.primary => DesignColors.cream,
      AppButtonVariant.gold => DesignColors.ink,
      AppButtonVariant.secondary => isEnabled ? DesignColors.ink : DesignColors.goldDeep,
    };

    // 3D offset: more offset when not pressed (raised), less when pressed
    final offsetY = _isPressed ? 2.0 : 4.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, offsetY, 0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? DesignColors.ink : DesignColors.goldDeep,
            width: 2,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: DesignColors.ink.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: DesignTypography.button.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
