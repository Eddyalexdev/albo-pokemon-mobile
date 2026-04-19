import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/pokemon.dart';
import '../../../shared/models/player.dart';
import '../molecules/active_bar.dart';

/// Organism displaying the battle arena with two Pokemon platforms.
class BattleField extends StatefulWidget {
  final Player? player;
  final Player? opponent;
  final String? currentPlayerId;
  final bool animate;

  const BattleField({
    super.key,
    this.player,
    this.opponent,
    this.currentPlayerId,
    this.animate = true,
  });

  @override
  State<BattleField> createState() => _BattleFieldState();
}

class _BattleFieldState extends State<BattleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BattleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_bounceController.isAnimating) {
      _bounceController.repeat(reverse: true);
    } else if (!widget.animate && _bounceController.isAnimating) {
      _bounceController.stop();
      _bounceController.value = 0;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Opponent side
        _buildTrainerSide(
          player: widget.opponent,
          isOpponent: true,
        ),
        const SizedBox(height: DesignSpacing.xl),
        // Player side
        _buildTrainerSide(
          player: widget.player,
          isOpponent: false,
        ),
      ],
    );
  }

  Widget _buildTrainerSide({
    required Player? player,
    required bool isOpponent,
  }) {
    final BattlePokemon? pokemon = player?.activePokemon;

    return Column(
      children: [
        // Trainer info
        Row(
          children: [
            if (isOpponent && player != null) ...[
              Expanded(
                child: Text(
                  player.nickname.toUpperCase(),
                  style: DesignTypography.labelMedium.copyWith(
                    color: DesignColors.ink,
                  ),
                ),
              ),
            ],
            if (!isOpponent && player != null) ...[
              Expanded(
                child: Text(
                  player.nickname.toUpperCase(),
                  style: DesignTypography.labelMedium.copyWith(
                    color: DesignColors.ink,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        // Platform and sprite
        Row(
          mainAxisAlignment:
              isOpponent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // Platform
            _buildPlatform(isOpponent: isOpponent),
            const SizedBox(width: DesignSpacing.md),
            // Pokemon sprite with bounce animation
            if (pokemon != null)
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: _buildPokemonSprite(pokemon, isOpponent: isOpponent),
                  );
                },
              ),
          ],
        ),
        if (!isOpponent && pokemon != null) ...[
          const SizedBox(height: DesignSpacing.sm),
          ActiveBar(
            currentHp: pokemon.currentHp,
            maxHp: pokemon.maxHp,
            label: pokemon.name,
          ),
        ],
        if (isOpponent && pokemon != null) ...[
          const SizedBox(height: DesignSpacing.sm),
          ActiveBar(
            currentHp: pokemon.currentHp,
            maxHp: pokemon.maxHp,
            label: pokemon.name,
          ),
        ],
      ],
    );
  }

  Widget _buildPlatform({required bool isOpponent}) {
    return Container(
      width: 80,
      height: 16,
      decoration: BoxDecoration(
        color: DesignColors.ink.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(color: DesignColors.ink, width: 2),
      ),
    );
  }

  Widget _buildPokemonSprite(PokemonSummary pokemon, {required bool isOpponent}) {
    return Image.network(
      pokemon.sprite,
      height: 96,
      width: 96,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, __, ___) => const SizedBox(
        height: 96,
        width: 96,
        child: Icon(
          Icons.catching_pokemon,
          color: DesignColors.goldDeep,
          size: 48,
        ),
      ),
    );
  }
}
