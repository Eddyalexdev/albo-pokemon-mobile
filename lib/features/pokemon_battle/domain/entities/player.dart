import 'package:equatable/equatable.dart';
import 'pokemon.dart';

class Player extends Equatable {
  final String id;
  final String socketId;
  final String nickname;
  final List<Pokemon> team;
  final int activeIndex;
  final bool ready;

  const Player({
    required this.id,
    required this.socketId,
    required this.nickname,
    required this.team,
    required this.activeIndex,
    required this.ready,
  });

  Pokemon? get activePokemon =>
      activeIndex >= 0 && activeIndex < team.length ? team[activeIndex] : null;

  @override
  List<Object?> get props => [id, socketId, nickname, team, activeIndex, ready];
}
