import 'package:equatable/equatable.dart';
import 'player.dart';

enum LobbyStatus { waiting, ready, battling, finished }

LobbyStatus lobbyStatusFromString(String raw) => switch (raw) {
      'waiting' => LobbyStatus.waiting,
      'ready' => LobbyStatus.ready,
      'battling' => LobbyStatus.battling,
      'finished' => LobbyStatus.finished,
      _ => LobbyStatus.waiting,
    };

class Lobby extends Equatable {
  final String id;
  final LobbyStatus status;
  final List<Player> players;
  final String? currentTurnPlayerId;
  final String? winnerPlayerId;

  const Lobby({
    required this.id,
    required this.status,
    required this.players,
    required this.currentTurnPlayerId,
    required this.winnerPlayerId,
  });

  Player? playerById(String id) {
    for (final p in players) {
      if (p.id == id) return p;
    }
    return null;
  }

  Player? opponentOf(String playerId) {
    for (final p in players) {
      if (p.id != playerId) return p;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [id, status, players, currentTurnPlayerId, winnerPlayerId];
}

class TurnRecord extends Equatable {
  final int turnNumber;
  final String attackerPlayerId;
  final String defenderPlayerId;
  final int damage;
  final int defenderHpAfter;
  final bool defenderDefeated;

  const TurnRecord({
    required this.turnNumber,
    required this.attackerPlayerId,
    required this.defenderPlayerId,
    required this.damage,
    required this.defenderHpAfter,
    required this.defenderDefeated,
  });

  @override
  List<Object?> get props => [
        turnNumber,
        attackerPlayerId,
        defenderPlayerId,
        damage,
        defenderHpAfter,
        defenderDefeated,
      ];
}
