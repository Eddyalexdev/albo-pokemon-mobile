import 'package:equatable/equatable.dart';

import 'pokemon.dart';

/// Player in the lobby or battle.
class Player extends Equatable {
  final String id;
  final String nickname;
  final List<PokemonSummary> team;
  final bool ready;

  const Player({
    required this.id,
    required this.nickname,
    required this.team,
    required this.ready,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      team: (json['team'] as List<dynamic>?)
              ?.map((p) => PokemonSummary.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      ready: json['ready'] == true,
    );
  }

  Player copyWith({
    String? id,
    String? nickname,
    List<PokemonSummary>? team,
    bool? ready,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      team: team ?? this.team,
      ready: ready ?? this.ready,
    );
  }

  @override
  List<Object?> get props => [id, nickname, team, ready];
}
