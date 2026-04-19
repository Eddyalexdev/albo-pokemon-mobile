import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/player.dart';
import '../../../shared/models/pokemon.dart';
import 'pokemon_tile.dart';

/// Molecule displaying player trainer info with team.
class TrainerCard extends StatelessWidget {
  final Player? player;
  final String label;
  final Color accentColor;
  final bool isEmpty;
  final bool isLoadingTeam;

  const TrainerCard({
    super.key,
    this.player,
    required this.label,
    this.accentColor = DesignColors.crimson,
    this.isEmpty = false,
    this.isLoadingTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Mobile (< 380px): compact tiles only (full content doesn't fit)
        // Tablet/desktop: full stats tiles
        final isCompact = width < 380;

        final tileWidth = (width - (DesignSpacing.md * 2) - (DesignSpacing.xs * 4)) / 3;
        // Compact: sprite + name only. Full: sprite + types + stats
        final tileContentHeight = tileWidth * 0.85 + (isCompact ? 56.0 : 104.0);
        final cardPadding = DesignSpacing.md * 2;
        final headerHeight = isCompact ? 32.0 : 40.0;
        final spacing = isCompact ? DesignSpacing.sm : DesignSpacing.md;

        final cardHeight = cardPadding + headerHeight + spacing + tileContentHeight;

        return Container(
          height: cardHeight,
          padding: const EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: DesignColors.cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact: isCompact),
              SizedBox(height: spacing),
              Expanded(child: _buildTeam(isCompact: isCompact)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({required bool isCompact}) {
    if (player == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: (isCompact ? DesignTypography.labelSmall : DesignTypography.labelMedium)
                .copyWith(color: DesignColors.ink),
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
                style: (isCompact ? DesignTypography.labelSmall : DesignTypography.labelMedium)
                    .copyWith(color: DesignColors.ink),
              ),
              TextSpan(
                text: player!.nickname,
                style: (isCompact ? DesignTypography.labelSmall : DesignTypography.labelMedium)
                    .copyWith(color: accentColor),
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

  Widget _buildTeam({required bool isCompact}) {
    // Skeleton matches tile mode
    if (isLoadingTeam && (player == null || player!.team.isEmpty)) {
      return Row(
        children: List.generate(3, (_) => Expanded(child: _SkeletonTile(isCompact: isCompact))),
      );
    }

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

    // Show compact tiles on mobile, full tiles on tablet+
    return Row(
      children: player!.team
          .map((pokemon) => Expanded(
                child: PokemonTile(
                  pokemon: pokemon,
                  compact: isCompact,
                ),
              ))
          .toList(),
    );
  }
}

/// Skeleton tile for loading state.
class _SkeletonTile extends StatelessWidget {
  final bool isCompact;

  const _SkeletonTile({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xs),
      child: PokemonTile(
        pokemon: PokemonDetail(id: '', name: '', sprite: '', types: [], maxHp: 0, attack: 0, defense: 0, speed: 0),
        isLoading: true,
        compact: false,
      ),
    );
  }
}
