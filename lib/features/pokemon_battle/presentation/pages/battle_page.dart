import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/game_theme.dart';
import '../../../../core/widgets/game_bg.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/hp_bar.dart';
import '../../domain/entities/lobby.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/battle_providers.dart';

class BattlePage extends ConsumerWidget {
  const BattlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(battleControllerProvider);
    final controller = ref.read(battleControllerProvider.notifier);
    final lobby = state.lobby;

    if (lobby == null) {
      return Scaffold(
        body: GameBg(
          asset: 'assets/bg/route_01.png',
          child: const Center(
            child: CircularProgressIndicator(color: GameColors.gold),
          ),
        ),
      );
    }

    final me = lobby.playerById(state.playerId ?? '');
    final opponent = lobby.opponentOf(state.playerId ?? '');
    final myTurn = lobby.currentTurnPlayerId == state.playerId;
    final isFinished = lobby.status == LobbyStatus.finished;
    final winner = lobby.winnerPlayerId != null
        ? lobby.playerById(lobby.winnerPlayerId!)
        : null;

    final turnNick = lobby.players
            .where((p) => p.id == lobby.currentTurnPlayerId)
            .map((p) => p.nickname)
            .firstOrNull ??
        '—';

    return Scaffold(
      body: GameBg(
        asset: 'assets/bg/route_01.png',
        overlayOpacity: 0.2,
        child: SafeArea(
          child: Column(
            children: [
              // HUD
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GameCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          isFinished
                              ? 'Batalla finalizada'
                              : myTurn
                                  ? '⚔ ¡Tu turno!'
                                  : 'Turno: $turnNick',
                          style: GoogleFonts.bungee(
                            fontSize: 13,
                            color: myTurn ? GameColors.crimson : GameColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banner
              if (state.lastTurn != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: GameCard(
                    borderColor: state.lastTurn!.defenderDefeated
                        ? GameColors.crimson
                        : GameColors.gold,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Turno ${state.lastTurn!.turnNumber} — ${state.lastTurn!.damage} daño · HP ${state.lastTurn!.defenderHpAfter}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: GameColors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Arena
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      _BattleField(player: opponent, role: _Role.opponent),
                      const Spacer(flex: 2),
                      _BattleField(player: me, role: _Role.self, active: myTurn),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),

              // Action dialog
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: GameCard(
                  padding: const EdgeInsets.all(16),
                  child: isFinished && winner != null
                      ? Column(
                          children: [
                            Text(
                              '🏆 ¡${winner.nickname} gana!',
                              style: GoogleFonts.bungee(
                                fontSize: 18,
                                color: GameColors.crimson,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () async {
                                  await controller.resetLobby();
                                  if (context.mounted) context.go('/');
                                },
                                child: const Text('JUGAR OTRA VEZ'),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: myTurn ? controller.attack : null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              textStyle: GoogleFonts.bungee(fontSize: 16),
                            ),
                            child: Text(myTurn ? '⚔ ATACAR' : 'Esperando al rival…'),
                          ),
                        ),
                ),
              ),

              // Log
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                constraints: const BoxConstraints(maxHeight: 120),
                child: GameCard(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'REGISTRO',
                        style: GoogleFonts.bungee(
                          fontSize: 10,
                          color: GameColors.goldDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: _buildLog(state).length,
                          itemBuilder: (_, i) {
                            final entries = _buildLog(state);
                            final entry = entries[entries.length - 1 - i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                entry,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: GameColors.ink,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _buildLog(BattleState state) {
    final entries = <String>[];
    final turn = state.lastTurn;
    if (turn != null) {
      final lobby = state.lobby;
      if (lobby != null) {
        final attNick = lobby.playerById(turn.attackerPlayerId)?.nickname ?? '?';
        final defNick = lobby.playerById(turn.defenderPlayerId)?.nickname ?? '?';
        entries.add(
            'T${turn.turnNumber}: $attNick → $defNick | ${turn.damage} dmg | HP ${turn.defenderHpAfter}');
        if (turn.defenderDefeated) {
          entries.add('💥 Pokémon de $defNick derrotado!');
        }
      }
    }
    return entries;
  }
}

enum _Role { opponent, self }

class _BattleField extends StatelessWidget {
  final Player? player;
  final _Role role;
  final bool active;

  const _BattleField({
    required this.player,
    required this.role,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    if (player == null) {
      return const Center(child: Text('—'));
    }
    final mon = player!.activePokemon;
    if (mon == null) return const SizedBox.shrink();

    final alive = player!.team.where((p) => !p.defeated).length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: role == _Role.self
          ? [_platform(mon, role), const SizedBox(width: 12), Expanded(child: _info(context, mon, alive))]
          : [Expanded(child: _info(context, mon, alive)), const SizedBox(width: 12), _platform(mon, role)],
    );
  }

  Widget _platform(Pokemon mon, _Role role) {
    return Column(
      children: [
        Transform(
          transform: role == _Role.opponent
              ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
              : Matrix4.identity(),
          alignment: Alignment.center,
          child: Image.network(
            mon.sprite,
            width: 100,
            height: 100,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.catching_pokemon,
              size: 80,
              color: GameColors.goldDeep,
            ),
          ),
        ),
        Container(
          width: 110,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: RadialGradient(
              colors: [
                GameColors.ink.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _info(BuildContext context, Pokemon mon, int alive) {
    return GameCard(
      borderColor: active ? GameColors.gold : GameColors.ink,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  player!.nickname,
                  style: GoogleFonts.bungee(fontSize: 11, color: GameColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$alive/${player!.team.length}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: GameColors.goldDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            mon.name,
            style: GoogleFonts.bungee(fontSize: 13, color: GameColors.ink),
          ),
          const SizedBox(height: 6),
          HpBar(hp: mon.hp, maxHp: mon.maxHp),
          const SizedBox(height: 6),
          Row(
            children: player!.team.map((p) {
              final isActive = p.id == mon.id;
              return Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.defeated ? GameColors.creamSoft : GameColors.crimson,
                  border: Border.all(
                    color: isActive ? GameColors.gold : GameColors.ink,
                    width: isActive ? 2 : 1.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
