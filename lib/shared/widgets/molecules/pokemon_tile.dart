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

  // Stat bar max values for percentage calculation (matches web design)
  // Key: 0=HP, 1=ATK, 2=DEF, 3=SPD
  static const _statMaxHp = 200;
  static const _statMaxAtk = 180;
  static const _statMaxDef = 180;
  static const _statMaxSpd = 180;

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
        child: compact ? _buildCompactContent(context) : _buildFullContent(),
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

  Widget _buildCompactContent(BuildContext context) {
    return GestureDetector(
      onTap: () => showDetailModal(context, pokemon),
      child: Column(
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
      ),
    );
  }

  /// Show a detail modal for this Pokemon.
  static void showDetailModal(BuildContext context, PokemonDetail pokemon) {
    showDialog<void>(
      context: context,
      builder: (context) => _PokemonDetailDialog(pokemon: pokemon),
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
        _StatBar(label: 'HP', value: detail.maxHp, max: _statMaxHp, index: 0),
        _StatBar(label: 'ATK', value: detail.attack, max: _statMaxAtk, index: 1),
        _StatBar(label: 'DEF', value: detail.defense, max: _statMaxDef, index: 2),
        _StatBar(label: 'SPD', value: detail.speed, max: _statMaxSpd, index: 3),
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

/// Dialog showing full Pokemon stats.
class _PokemonDetailDialog extends StatelessWidget {
  final PokemonDetail pokemon;

  const _PokemonDetailDialog({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final dexId = pokemon.id.padLeft(3, '0');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: DesignColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignColors.ink, width: 3),
          boxShadow: [
            BoxShadow(
              color: DesignColors.ink.withValues(alpha: 0.3),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$dexId',
                  style: DesignTypography.statsSmall.copyWith(
                    color: DesignColors.goldDeep,
                    fontSize: 14,
                  ),
                ),
                Text(
                  pokemon.name,
                  style: DesignTypography.displayMedium.copyWith(
                    color: DesignColors.ink,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),

            // Sprite
            Container(
              padding: const EdgeInsets.all(DesignSpacing.sm),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [DesignColors.cream, DesignColors.cream.withValues(alpha: 0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                pokemon.sprite,
                height: 100,
                width: 100,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.catching_pokemon,
                  color: DesignColors.goldDeep,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),

            // Type pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemon.types.map((type) {
                final color = DesignColors.forType(type.name);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: DesignColors.ink, width: 2),
                    ),
                    child: Text(
                      type.name.toUpperCase(),
                      style: DesignTypography.statsSmall.copyWith(
                        color: _typeTextColor(type.name),
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DesignSpacing.md),

            // Stats
            _StatBar(label: 'HP', value: pokemon.maxHp, max: 200, index: 0),
            _StatBar(label: 'ATK', value: pokemon.attack, max: 180, index: 1),
            _StatBar(label: 'DEF', value: pokemon.defense, max: 180, index: 2),
            _StatBar(label: 'SPD', value: pokemon.speed, max: 180, index: 3),
            const SizedBox(height: DesignSpacing.md),

            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CERRAR',
                style: DesignTypography.labelSmall.copyWith(
                  color: DesignColors.goldDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeTextColor(String type) {
    return switch (type.toLowerCase()) {
      'dragon' || 'dark' => DesignColors.cream,
      _ => DesignColors.ink,
    };
  }
}
