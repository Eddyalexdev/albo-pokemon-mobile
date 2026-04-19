import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/pokemon.dart';

/// Molecule displaying a Pokemon with sprite, type, and stats.
/// Matches the design of web-new's TrainerCard PokemonTile.
class PokemonTile extends StatelessWidget {
  final PokemonDetail pokemon;
  final bool compact;
  final bool isLoading;
  final VoidCallback? onTap;

  const PokemonTile({
    super.key,
    required this.pokemon,
    this.compact = false,
    this.isLoading = false,
    this.onTap,
  });

  // Stat max values for bar rendering (matches web)
  static const _statMax = {0: 200, 1: 180, 2: 180, 3: 180};

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: compact ? 2 : DesignSpacing.xs),
        padding: EdgeInsets.all(compact ? DesignSpacing.xs : DesignSpacing.sm),
        decoration: BoxDecoration(
          color: DesignColors.creamSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DesignColors.ink, width: 3),
          boxShadow: const [BoxShadow(color: DesignColors.ink, offset: Offset(0, 3), blurRadius: 0)],
        ),
        child: compact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 2 : DesignSpacing.xs),
      padding: EdgeInsets.all(compact ? DesignSpacing.xs : DesignSpacing.sm),
      decoration: BoxDecoration(
        color: DesignColors.creamSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignColors.ink, width: 3),
      ),
      child: compact ? _buildSkeletonCompact() : _buildSkeletonFull(),
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
          style: DesignTypography.labelSmall.copyWith(color: DesignColors.ink),
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
        // Header: #dex + name
        _buildHeader(),
        const SizedBox(height: DesignSpacing.xs),
        // Sprite with radial gradient backdrop
        _buildSpriteWithGradient(),
        const SizedBox(height: DesignSpacing.xs),
        // Type pills
        _buildTypePills(),
        const SizedBox(height: DesignSpacing.xs),
        _buildStats(pokemon),
      ],
    );
  }

  Widget _buildHeader() {
    final dexId = pokemon.id.padLeft(3, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '#$dexId',
          style: DesignTypography.statsSmall.copyWith(
            color: DesignColors.goldDeep,
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            pokemon.name,
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.ink,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSpriteWithGradient() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.2,
          colors: [DesignColors.cream, DesignColors.cream.withValues(alpha: 0)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: _buildSprite(height: 96)),
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

  Widget _buildTypePills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pokemon.types.map((type) {
        final color = DesignColors.forType(type.name);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.ink, width: 2),
              boxShadow: const [BoxShadow(color: DesignColors.ink, offset: Offset(0, 1), blurRadius: 0)],
            ),
            child: Text(
              type.name.toUpperCase(),
              style: DesignTypography.statsSmall.copyWith(
                color: _typeTextColor(type.name),
                fontSize: 8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Text color for type pills (dark types need light text)
  Color _typeTextColor(String type) {
    return switch (type.toLowerCase()) {
      'dragon' || 'dark' => DesignColors.cream,
      _ => DesignColors.ink,
    };
  }

  Widget _buildStats(PokemonDetail detail) {
    return Column(
      children: [
        _StatBar(label: 'HP', value: detail.maxHp, max: _statMax[0]!, index: 0),
        _StatBar(label: 'ATK', value: detail.attack, max: _statMax[1]!, index: 1),
        _StatBar(label: 'DEF', value: detail.defense, max: _statMax[2]!, index: 2),
        _StatBar(label: 'SPD', value: detail.speed, max: _statMax[3]!, index: 3),
      ],
    );
  }

  // ─── SKELETON ───────────────────────────────────────────────────────────────

  Widget _buildSkeletonCompact() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DesignColors.creamSoft,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: DesignColors.ink, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 48, height: 10, decoration: _skeletonDecoration()),
      ],
    );
  }

  Widget _buildSkeletonFull() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 30, height: 10, decoration: _skeletonDecoration()),
            Container(width: 60, height: 12, decoration: _skeletonDecoration()),
          ],
        ),
        const SizedBox(height: DesignSpacing.xs),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: DesignColors.creamSoft,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: DesignColors.ink, width: 2),
          ),
        ),
        const SizedBox(height: DesignSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 50, height: 16, decoration: _skeletonDecoration(radius: 999)),
            const SizedBox(width: 4),
            Container(width: 50, height: 16, decoration: _skeletonDecoration(radius: 999)),
          ],
        ),
        const SizedBox(height: DesignSpacing.xs),
        ...List.generate(4, (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _skeletonStatRow(),
        )),
      ],
    );
  }

  Widget _skeletonStatRow() {
    return Row(
      children: [
        Container(width: 30, height: 10, decoration: _skeletonDecoration()),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: DesignColors.creamSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.ink, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(width: 30, height: 10, decoration: _skeletonDecoration()),
      ],
    );
  }

  BoxDecoration _skeletonDecoration({double radius = 6}) {
    return BoxDecoration(
      color: DesignColors.creamSoft,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: DesignColors.ink, width: 2),
    );
  }
}

/// Stat bar with label, gradient fill, and value.
class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final int index;

  const _StatBar({
    required this.label,
    required this.value,
    required this.max,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Gradient: gold → crimson (matches web)
    final pct = (value / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              label,
              style: DesignTypography.statsSmall.copyWith(
                color: DesignColors.ink,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: DesignColors.cream,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: DesignColors.ink, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DesignColors.gold, DesignColors.crimson],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              style: DesignTypography.statsSmall.copyWith(
                color: DesignColors.goldDeep,
                fontSize: 9,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
