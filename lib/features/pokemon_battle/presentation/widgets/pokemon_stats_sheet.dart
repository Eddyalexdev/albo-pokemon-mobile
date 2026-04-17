import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/game_theme.dart';
import '../../domain/entities/pokemon.dart';

void showPokemonStatsSheet(BuildContext context, Pokemon pokemon) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: GameColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PokemonStatsContent(pokemon: pokemon),
  );
}

class _PokemonStatsContent extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonStatsContent({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('HP', pokemon.maxHp),
      ('ATTACK', pokemon.attack),
      ('DEFENSE', pokemon.defense),
      ('SPEED', pokemon.speed),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GameColors.ink, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GameColors.goldDeep,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Image.network(
            pokemon.sprite,
            width: 120,
            height: 120,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.catching_pokemon,
              size: 80,
              color: GameColors.goldDeep,
            ),
          ),
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: GameColors.goldDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pokemon.name,
            style: GoogleFonts.bungee(fontSize: 22, color: GameColors.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: pokemon.type
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: GameColors.ink,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.toUpperCase(),
                        style: GoogleFonts.bungee(fontSize: 10, color: GameColors.cream),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          ...stats.map((s) => _statRow(context, s.$1, s.$2)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, int value) {
    final ratio = (value / 180).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: GameColors.goldDeep,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: GameColors.ink, width: 2),
                borderRadius: BorderRadius.circular(6),
                color: GameColors.creamSoft,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: GameColors.crimson,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: GameColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
