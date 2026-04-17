import '../../domain/entities/lobby.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/pokemon.dart';

/// Pure mapping from raw Socket.IO payloads (JSON-like maps) to domain entities.
class LobbyMapper {
  static Lobby fromJson(Map<String, dynamic> json) {
    return Lobby(
      id: json['id'] as String,
      status: lobbyStatusFromString(json['status'] as String),
      players: (json['players'] as List<dynamic>)
          .map((p) => _playerFromJson(p as Map<String, dynamic>))
          .toList(),
      currentTurnPlayerId: json['currentTurnPlayerId'] as String?,
      winnerPlayerId: json['winnerPlayerId'] as String?,
    );
  }

  static Player _playerFromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      socketId: json['socketId'] as String,
      nickname: json['nickname'] as String,
      team: (json['team'] as List<dynamic>)
          .map((p) => _pokemonFromJson(p as Map<String, dynamic>))
          .toList(),
      activeIndex: (json['activeIndex'] as num).toInt(),
      ready: json['ready'] as bool,
    );
  }

  static Pokemon _pokemonFromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: (json['type'] as List<dynamic>).cast<String>(),
      hp: (json['hp'] as num).toInt(),
      maxHp: (json['maxHp'] as num).toInt(),
      attack: (json['attack'] as num).toInt(),
      defense: (json['defense'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      sprite: json['sprite'] as String,
      defeated: json['defeated'] as bool,
    );
  }

  static TurnRecord turnFromJson(Map<String, dynamic> json) {
    return TurnRecord(
      turnNumber: (json['turnNumber'] as num).toInt(),
      attackerPlayerId: json['attackerPlayerId'] as String,
      defenderPlayerId: json['defenderPlayerId'] as String,
      damage: (json['damage'] as num).toInt(),
      defenderHpAfter: (json['defenderHpAfter'] as num).toInt(),
      defenderDefeated: json['defenderDefeated'] as bool,
    );
  }
}
