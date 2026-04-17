import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/game_theme.dart';
import '../../../../core/widgets/game_bg.dart';
import '../../../../core/widgets/game_card.dart';
import '../../domain/entities/lobby.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/battle_providers.dart';
import '../widgets/pokemon_stats_sheet.dart';

class LobbyPage extends ConsumerStatefulWidget {
  const LobbyPage({super.key});

  @override
  ConsumerState<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends ConsumerState<LobbyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final config = await ref.read(appConfigProvider.future);
    final baseUrl = config.baseUrl;
    if (baseUrl == null) {
      if (mounted) context.go('/config');
      return;
    }
    final nickname = config.nickname;
    if (nickname == null) {
      if (mounted) context.go('/');
      return;
    }

    final state = ref.read(battleControllerProvider);
    if (!state.connected) {
      try {
        await ref.read(battleControllerProvider.notifier).connect(baseUrl);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
        }
        return;
      }
    }

    final s = ref.read(battleControllerProvider);
    if (s.playerId == null) {
      await ref.read(battleControllerProvider.notifier).joinLobby(nickname);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(battleControllerProvider);

    ref.listen(battleControllerProvider, (prev, next) {
      if (next.lobby?.status == LobbyStatus.battling) {
        context.go('/battle');
      }
      if (next.lastError != null && next.lastError != prev?.lastError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.lastError!)),
        );
      }
    });

    final me = state.lobby?.playerById(state.playerId ?? '');
    final opponent = state.lobby?.opponentOf(state.playerId ?? '');
    final canAssign = me != null && me.team.isEmpty;
    final canReady = me != null && me.team.length == 3 && !me.ready;

    return Scaffold(
      body: GameBg(
        asset: 'assets/bg/pallet_town.png',
        overlayOpacity: 0.12,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      _header(context, state),
                      const SizedBox(height: 12),
                      _statsBar(context, state, me),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _trainerCard(context, me, 'Tú', GameColors.crimson),
                    const SizedBox(height: 12),
                    _trainerCard(context, opponent, 'Rival', GameColors.goldDeep,
                        emptyText: 'Esperando un segundo entrenador…'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: canAssign
                                ? () => ref.read(battleControllerProvider.notifier).assignPokemon()
                                : null,
                            child: const Text('🎲 EQUIPO'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: canReady
                                ? () => ref.read(battleControllerProvider.notifier).ready()
                                : null,
                            child: const Text('✓ LISTO'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (me?.team.isNotEmpty == true && !me!.ready)
                      _hint('Tocá un Pokémon para ver sus estadísticas'),
                    if (me?.ready == true && opponent?.ready != true)
                      _hint('Esperando al rival…'),
                    if (me?.ready == true && opponent?.ready == true)
                      _hint('¡Comenzando la batalla!'),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, BattleState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lobby',
                style: GoogleFonts.bungee(
                  fontSize: 24,
                  color: GameColors.ink,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      color: GameColors.gold.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              Text(
                'POKÉMON STADIUM LITE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: GameColors.goldDeep,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(state.lobby?.status),
            border: Border.all(color: GameColors.ink, width: 2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            (state.lobby?.status.name ?? 'conectando').toUpperCase(),
            style: GoogleFonts.bungee(
              fontSize: 10,
              color: _statusFg(state.lobby?.status),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(LobbyStatus? s) => switch (s) {
        LobbyStatus.ready => GameColors.gold,
        LobbyStatus.battling => GameColors.crimson,
        LobbyStatus.finished => GameColors.forest,
        _ => GameColors.cream,
      };

  Color _statusFg(LobbyStatus? s) => switch (s) {
        LobbyStatus.battling || LobbyStatus.finished => GameColors.cream,
        _ => GameColors.ink,
      };

  Widget _statsBar(BuildContext context, BattleState state, Player? me) {
    return GameCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _stat('Estado', state.lobby?.status.name ?? '—'),
          _stat('Jugadores', '${state.lobby?.players.length ?? 0} / 2'),
          _stat('Vos', me?.nickname ?? '—'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: GameColors.goldDeep,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.bungee(fontSize: 13, color: GameColors.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _trainerCard(BuildContext context, Player? player, String label, Color accent,
      {String emptyText = 'Uniéndote al lobby...'}) {
    return GameCard(
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (player != null)
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '$label: ', style: Theme.of(context).textTheme.titleSmall),
                    TextSpan(
                      text: player.nickname,
                      style: GoogleFonts.bungee(fontSize: 14, color: accent),
                    ),
                  ]),
                )
              else
                Text(label, style: Theme.of(context).textTheme.titleSmall),
              if (player != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: player.ready ? GameColors.forest : GameColors.creamSoft,
                    border: Border.all(color: GameColors.ink, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    player.ready ? '✓ LISTO' : '… ELIGIENDO',
                    style: GoogleFonts.bungee(
                      fontSize: 9,
                      color: player.ready ? GameColors.cream : GameColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (player == null || player.team.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  player == null ? emptyText : 'Sin equipo todavía',
                  style: GoogleFonts.fraunces(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: GameColors.goldDeep,
                  ),
                ),
              ),
            )
          else
            Row(
              children: player.team
                  .map((p) => Expanded(child: _monCard(context, p)))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _monCard(BuildContext context, Pokemon pokemon) {
    return GestureDetector(
      onTap: () => showPokemonStatsSheet(context, pokemon),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: GameColors.creamSoft,
          border: Border.all(color: GameColors.ink, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.network(
              pokemon.sprite,
              width: 56,
              height: 56,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 56, height: 56,
                child: Icon(Icons.catching_pokemon, size: 40, color: GameColors.goldDeep),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pokemon.name,
              style: GoogleFonts.bungee(fontSize: 9, color: GameColors.ink),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              'HP ${pokemon.maxHp} · ATK ${pokemon.attack}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 7,
                color: GameColors.goldDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.fraunces(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: GameColors.goldDeep,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
