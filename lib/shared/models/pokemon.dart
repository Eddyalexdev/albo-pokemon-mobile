import 'package:equatable/equatable.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Pokemon type enum for type safety.
enum PokemonType {
  normal,
  fire,
  water,
  electric,
  grass,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy;

  static PokemonType fromString(String value) {
    return PokemonType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PokemonType.normal,
    );
  }
}

/// Summary Pokemon data from GET /list.
class PokemonSummary extends Equatable {
  final String id;
  final String name;
  final String sprite;
  final List<PokemonType> types;

  const PokemonSummary({
    required this.id,
    required this.name,
    required this.sprite,
    required this.types,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List<dynamic>?)
            ?.map((t) => PokemonType.fromString(t as String))
            .toList() ??
        [PokemonType.normal];

    return PokemonSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sprite: json['sprite']?.toString() ?? '',
      types: typesList,
    );
  }

  @override
  List<Object?> get props => [id, name, sprite, types];
}

/// Detailed Pokemon data including stats from GET /list/{id}.
class PokemonDetail extends PokemonSummary {
  final int maxHp;
  final int attack;
  final int defense;

  const PokemonDetail({
    required super.id,
    required super.name,
    required super.sprite,
    required super.types,
    required this.maxHp,
    required this.attack,
    required this.defense,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List<dynamic>?)
            ?.map((t) => PokemonType.fromString(t as String))
            .toList() ??
        [PokemonType.normal];

    return PokemonDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sprite: json['sprite']?.toString() ?? '',
      types: typesList,
      maxHp: _parseInt(json['maxHp']) ?? _parseInt(json['hp']) ?? 100,
      attack: _parseInt(json['attack']) ?? 50,
      defense: _parseInt(json['defense']) ?? 50,
    );
  }

  @override
  List<Object?> get props => [...super.props, maxHp, attack, defense];
}

/// Pokemon as it appears inside a Player.team payload from the server.
/// Carries current hp, max hp, stats and defeated flag — mirrors the
/// backend Pokemon contract (see web-new domain/types).
class BattlePokemon extends PokemonDetail {
  final int currentHp;
  final bool defeated;

  const BattlePokemon({
    required super.id,
    required super.name,
    required super.sprite,
    required super.types,
    required super.maxHp,
    required super.attack,
    required super.defense,
    required this.currentHp,
    this.defeated = false,
  });

  factory BattlePokemon.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List<dynamic>? ?? json['type'] as List<dynamic>?)
            ?.map((t) => PokemonType.fromString(t as String))
            .toList() ??
        [PokemonType.normal];

    final maxHp = _parseInt(json['maxHp']) ?? 100;
    final currentHp = _parseInt(json['hp']) ?? _parseInt(json['currentHp']) ?? maxHp;

    return BattlePokemon(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sprite: json['sprite']?.toString() ?? '',
      types: typesList,
      maxHp: maxHp,
      attack: _parseInt(json['attack']) ?? 50,
      defense: _parseInt(json['defense']) ?? 50,
      currentHp: currentHp,
      defeated: json['defeated'] == true,
    );
  }

  factory BattlePokemon.fromDetail(PokemonDetail detail, {int? hp}) {
    return BattlePokemon(
      id: detail.id,
      name: detail.name,
      sprite: detail.sprite,
      types: detail.types,
      maxHp: detail.maxHp,
      attack: detail.attack,
      defense: detail.defense,
      currentHp: hp ?? detail.maxHp,
    );
  }

  BattlePokemon copyWith({int? currentHp, bool? defeated}) {
    return BattlePokemon(
      id: id,
      name: name,
      sprite: sprite,
      types: types,
      maxHp: maxHp,
      attack: attack,
      defense: defense,
      currentHp: currentHp ?? this.currentHp,
      defeated: defeated ?? this.defeated,
    );
  }

  double get hpPercent => maxHp > 0 ? (currentHp / maxHp).clamp(0.0, 1.0) : 0.0;

  bool get isFainted => defeated || currentHp <= 0;

  @override
  List<Object?> get props => [...super.props, currentHp, defeated];
}
