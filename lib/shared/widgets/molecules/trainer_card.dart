import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/player.dart';
import 'pokemon_tile.dart';

/// Molecule displaying player trainer info with team.
class TrainerCard extends StatelessWidget {
  final Player? player;
  final String label;
  final Color accentColor;
  final bool isEmpty;

  const TrainerCard({
    super.key,
    this.player,
    required this.label,
    this.accentColor = DesignColors.crimson,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: DesignSpacing.md),
          _buildTeam(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (player == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.ink,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: DesignSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: DesignColors.creamSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.ink, width: 1),
            ),
            child: Text(
              '...',
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.goldDeep,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.ink,
                ),
              ),
              TextSpan(
                text: player!.nickname,
                style: DesignTypography.labelMedium.copyWith(
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: player!.ready ? DesignColors.forest : DesignColors.creamSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: DesignColors.ink, width: 2),
          ),
          child: Text(
            player!.ready ? 'LISTO' : 'ELIGIENDO',
            style: DesignTypography.labelSmall.copyWith(
              color: player!.ready ? DesignColors.cream : DesignColors.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeam() {
    if (isEmpty || player == null || player!.team.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
          child: Text(
            isEmpty ? 'Esperando un segundo entrenador…' : 'Sin equipo todavía',
            style: DesignTypography.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: DesignColors.goldDeep,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Row(
      children: player!.team
          .map((pokemon) => Expanded(
                child: PokemonTile(
                  pokemon: pokemon,
                  compact: true,
                ),
              ))
          .toList(),
    );
  }
}
