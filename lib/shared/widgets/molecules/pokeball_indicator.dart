import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Molecule showing team status as Pokeball indicators.
class PokeballIndicator extends StatelessWidget {
  /// List of booleans where true = alive, false = fainted.
  final List<bool> teamStatus;
  final int activeIndex;

  const PokeballIndicator({
    super.key,
    required this.teamStatus,
    this.activeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(teamStatus.length.clamp(0, 6), (index) {
        final isAlive = index < teamStatus.length && teamStatus[index];
        final isActive = index == activeIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _Pokeball(
            isAlive: isAlive,
            isActive: isActive,
          ),
        );
      }),
    );
  }
}

class _Pokeball extends StatelessWidget {
  final bool isAlive;
  final bool isActive;

  const _Pokeball({
    required this.isAlive,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAlive ? DesignColors.cream : DesignColors.ink.withValues(alpha: 0.3),
        border: Border.all(
          color: isActive ? DesignColors.gold : DesignColors.ink,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: DesignColors.gold.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isAlive
          ? Stack(
              children: [
                // Top half (red)
                ClipOval(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 9,
                      color: DesignColors.crimson,
                    ),
                  ),
                ),
                // Center line
                Container(
                  height: 2,
                  color: DesignColors.ink,
                ),
                // Center button
                Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignColors.cream,
                      border: Border.all(color: DesignColors.ink, width: 1),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
