import 'package:equatable/equatable.dart';

import 'player.dart';
import 'pokemon.dart';

/// Lobby status enum.
enum LobbyStatus {
  waiting,
  ready,
  battling,
  finished;

  static LobbyStatus fromString(String value) {
    return LobbyStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LobbyStatus.waiting,
    );
  }
}

/// Lobby state containing all players and battle info.
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
    this.currentTurnPlayerId,
    this.winnerPlayerId,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      id: json['id']?.toString() ?? '',
      status: LobbyStatus.fromString(json['status']?.toString() ?? ''),
      players: (json['players'] as List<dynamic>?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      currentTurnPlayerId: json['currentTurnPlayerId']?.toString(),
      winnerPlayerId: json['winnerPlayerId']?.toString(),
    );
  }

  Lobby copyWith({
    String? id,
    LobbyStatus? status,
    List<Player>? players,
    String? currentTurnPlayerId,
    String? winnerPlayerId,
  }) {
    return Lobby(
      id: id ?? this.id,
      status: status ?? this.status,
      players: players ?? this.players,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      winnerPlayerId: winnerPlayerId ?? this.winnerPlayerId,
    );
  }

  /// Get player by ID.
  Player? playerById(String playerId) {
    for (final player in players) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  /// Get opponent of a player.
  Player? opponentOf(String playerId) {
    for (final player in players) {
      if (player.id != playerId) return player;
    }
    return null;
  }

  /// Get current active Pokemon for a player (first non-fainted).
  PokemonSummary? activePokemonFor(String playerId) {
    final player = playerById(playerId);
    if (player == null || player.team.isEmpty) return null;
    return player.team.first;
  }

  @override
  List<Object?> get props => [id, status, players, currentTurnPlayerId, winnerPlayerId];
}

/// Turn result from the server after an attack.
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

  factory TurnRecord.fromJson(Map<String, dynamic> json) {
    return TurnRecord(
      turnNumber: (json['turnNumber'] as num?)?.toInt() ?? 0,
      attackerPlayerId: json['attackerPlayerId']?.toString() ?? '',
      defenderPlayerId: json['defenderPlayerId']?.toString() ?? '',
      damage: (json['damage'] as num?)?.toInt() ?? 0,
      defenderHpAfter: (json['defenderHpAfter'] as num?)?.toInt() ?? 0,
      defenderDefeated: json['defenderDefeated'] == true,
    );
  }

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
