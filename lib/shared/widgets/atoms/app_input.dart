import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Atom text input with gold focus ring.
class AppInput extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool autofocus;

  const AppInput({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!.toUpperCase(),
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.goldDeep,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: DesignSpacing.xs),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          keyboardType: keyboardType,
          autofocus: autofocus,
          style: DesignTypography.bodyLarge,
          cursorColor: DesignColors.gold,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            filled: true,
            fillColor: DesignColors.creamSoft,
            hintStyle: DesignTypography.bodyLarge.copyWith(
              color: DesignColors.goldDeep.withValues(alpha: 0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: DesignColors.ink,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: DesignColors.gold,
                width: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
