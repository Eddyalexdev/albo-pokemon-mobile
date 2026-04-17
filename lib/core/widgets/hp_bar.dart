import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class HpBar extends StatelessWidget {
  final int hp;
  final int maxHp;

  const HpBar({super.key, required this.hp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp == 0 ? 0.0 : hp / maxHp;
    final Color color;
    if (ratio > 0.5) {
      color = GameColors.forest;
    } else if (ratio > 0.25) {
      color = GameColors.gold;
    } else {
      color = GameColors.crimson;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(color: GameColors.ink, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: GameColors.creamSoft,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0, 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$hp / $maxHp',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
