import 'package:equatable/equatable.dart';

import 'pokemon.dart';

class Player extends Equatable {
  final String id;
  final String nickname;
  final List<BattlePokemon> team;
  final int activeIndex;
  final bool ready;

  const Player({
    required this.id,
    required this.nickname,
    required this.team,
    required this.activeIndex,
    required this.ready,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      team: (json['team'] as List<dynamic>?)
              ?.map((p) => BattlePokemon.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      activeIndex: (json['activeIndex'] as num?)?.toInt() ?? 0,
      ready: json['ready'] == true,
    );
  }

  BattlePokemon? get activePokemon {
    if (team.isEmpty) return null;
    if (activeIndex < 0 || activeIndex >= team.length) return team.first;
    return team[activeIndex];
  }

  Player copyWith({
    String? id,
    String? nickname,
    List<BattlePokemon>? team,
    int? activeIndex,
    bool? ready,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      team: team ?? this.team,
      activeIndex: activeIndex ?? this.activeIndex,
      ready: ready ?? this.ready,
    );
  }

  @override
  List<Object?> get props => [id, nickname, team, activeIndex, ready];
}
