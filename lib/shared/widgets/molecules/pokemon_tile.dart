import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/pokemon.dart';

/// Molecule displaying a Pokemon with sprite, type, and stats.
class PokemonTile extends StatelessWidget {
  final PokemonSummary pokemon;
  final bool compact;
  final VoidCallback? onTap;

  const PokemonTile({
    super.key,
    required this.pokemon,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: compact ? 2 : DesignSpacing.xs),
        padding: EdgeInsets.all(compact ? DesignSpacing.xs : DesignSpacing.sm),
        decoration: BoxDecoration(
          color: DesignColors.creamSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignColors.ink, width: 2),
        ),
        child: compact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSprite(height: 48),
        const SizedBox(height: 2),
        Text(
          pokemon.name,
          style: DesignTypography.labelSmall.copyWith(
            color: DesignColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSprite(height: 72),
        const SizedBox(height: DesignSpacing.xs),
        Text(
          pokemon.name.toUpperCase(),
          style: DesignTypography.labelMedium.copyWith(
            color: DesignColors.ink,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        const SizedBox(height: DesignSpacing.xs),
        _buildTypeChips(),
        if (pokemon is PokemonDetail) ...[
          const SizedBox(height: DesignSpacing.xs),
          _buildStats(pokemon as PokemonDetail),
        ],
      ],
    );
  }

  Widget _buildSprite({required double height}) {
    return Image.network(
      pokemon.sprite,
      height: height,
      width: height,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, __, ___) => SizedBox(
        height: height,
        width: height,
        child: const Icon(
          Icons.catching_pokemon,
          color: DesignColors.goldDeep,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildTypeChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pokemon.types.map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: DesignColors.forType(type.name),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: DesignColors.ink, width: 1),
            ),
            child: Text(
              type.name.toUpperCase(),
              style: DesignTypography.statsSmall.copyWith(
                color: DesignColors.ink,
                fontSize: 8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats(PokemonDetail detail) {
    return Column(
      children: [
        _statRow('HP', detail.maxHp),
        _statRow('ATK', detail.attack),
        _statRow('DEF', detail.defense),
      ],
    );
  }

  Widget _statRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label ',
          style: DesignTypography.statsSmall.copyWith(
            color: DesignColors.goldDeep,
            fontSize: 9,
          ),
        ),
        Text(
          '$value',
          style: DesignTypography.statsSmall.copyWith(
            color: DesignColors.ink,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
