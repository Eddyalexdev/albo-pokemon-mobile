import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets padding;

  const GameCard({
    super.key,
    required this.child,
    this.borderColor = GameColors.ink,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GameColors.cream.withValues(alpha: 0.92),
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GameColors.ink.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
