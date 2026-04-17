import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final List<String> type;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;
  final String sprite;
  final bool defeated;

  const Pokemon({
    required this.id,
    required this.name,
    required this.type,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.sprite,
    required this.defeated,
  });

  double get hpRatio => maxHp == 0 ? 0 : hp / maxHp;

  @override
  List<Object?> get props =>
      [id, name, type, hp, maxHp, attack, defense, speed, sprite, defeated];
}
