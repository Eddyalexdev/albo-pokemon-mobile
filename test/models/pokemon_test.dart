import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_stadium/shared/models/pokemon.dart';

void main() {
  group('PokemonSummary', () {
    test('fromJson creates PokemonSummary correctly', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': 'https://example.com/pikachu.png',
        'types': ['electric'],
      };

      final pokemon = PokemonSummary.fromJson(json);

      expect(pokemon.id, '25');
      expect(pokemon.name, 'Pikachu');
      expect(pokemon.sprite, 'https://example.com/pikachu.png');
      expect(pokemon.types, [PokemonType.electric]);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final pokemon = PokemonSummary.fromJson(json);

      expect(pokemon.id, '');
      expect(pokemon.name, '');
      expect(pokemon.sprite, '');
      expect(pokemon.types, [PokemonType.normal]);
    });

    test('fromJson handles multiple types', () {
      final json = {
        'id': '6',
        'name': 'Charizard',
        'sprite': 'https://example.com/charizard.png',
        'types': ['fire', 'flying'],
      };

      final pokemon = PokemonSummary.fromJson(json);

      expect(pokemon.types, [PokemonType.fire, PokemonType.flying]);
    });

    test('fromJson handles unknown type as normal', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'sprite': '',
        'types': ['unknown_type'],
      };

      final pokemon = PokemonSummary.fromJson(json);

      expect(pokemon.types, [PokemonType.normal]);
    });

    test('props returns correct fields for equality', () {
      final json1 = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': 'https://example.com/pikachu.png',
        'types': ['electric'],
      };
      final json2 = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': 'https://example.com/pikachu.png',
        'types': ['electric'],
      };

      final pokemon1 = PokemonSummary.fromJson(json1);
      final pokemon2 = PokemonSummary.fromJson(json2);

      expect(pokemon1, equals(pokemon2));
    });
  });

  group('PokemonDetail', () {
    test('fromJson creates PokemonDetail with stats', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': 'https://example.com/pikachu.png',
        'types': ['electric'],
        'maxHp': 100,
        'attack': 55,
        'defense': 40,
        'speed': 90,
      };

      final pokemon = PokemonDetail.fromJson(json);

      expect(pokemon.maxHp, 100);
      expect(pokemon.attack, 55);
      expect(pokemon.defense, 40);
      expect(pokemon.speed, 90);
    });

    test('fromJson uses hp as fallback for maxHp', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': '',
        'types': ['electric'],
        'hp': 150,
      };

      final pokemon = PokemonDetail.fromJson(json);

      expect(pokemon.maxHp, 150);
    });

    test('fromJson handles string numbers', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': '',
        'types': ['electric'],
        'maxHp': '100',
        'attack': '55',
        'defense': '40',
        'speed': '90',
      };

      final pokemon = PokemonDetail.fromJson(json);

      expect(pokemon.maxHp, 100);
      expect(pokemon.attack, 55);
      expect(pokemon.defense, 40);
      expect(pokemon.speed, 90);
    });
  });

  group('BattlePokemon', () {
    test('fromJson creates BattlePokemon with battle state', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': 'https://example.com/pikachu.png',
        'type': ['electric'],
        'maxHp': 100,
        'hp': 65,
        'attack': 55,
        'defense': 40,
        'speed': 90,
        'defeated': false,
      };

      final pokemon = BattlePokemon.fromJson(json);

      expect(pokemon.currentHp, 65);
      expect(pokemon.defeated, false);
      expect(pokemon.isFainted, false);
    });

    test('isFainted is true when defeated flag is set', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': '',
        'type': ['electric'],
        'maxHp': 100,
        'hp': 50,
        'attack': 55,
        'defense': 40,
        'speed': 90,
        'defeated': true,
      };

      final pokemon = BattlePokemon.fromJson(json);

      expect(pokemon.isFainted, true);
    });

    test('isFainted is true when currentHp is 0', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': '',
        'type': ['electric'],
        'maxHp': 100,
        'hp': 0,
        'attack': 55,
        'defense': 40,
        'speed': 90,
        'defeated': false,
      };

      final pokemon = BattlePokemon.fromJson(json);

      expect(pokemon.isFainted, true);
    });

    test('isFainted is true when currentHp is negative', () {
      final json = {
        'id': '25',
        'name': 'Pikachu',
        'sprite': '',
        'type': ['electric'],
        'maxHp': 100,
        'hp': -10,
        'attack': 55,
        'defense': 40,
        'speed': 90,
        'defeated': false,
      };

      final pokemon = BattlePokemon.fromJson(json);

      expect(pokemon.isFainted, true);
    });

    test('hpPercent returns correct percentage', () {
      final pokemon = BattlePokemon(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
        currentHp: 75,
      );

      expect(pokemon.hpPercent, 0.75);
    });

    test('hpPercent clamps to 0.0 when hp is negative', () {
      final pokemon = BattlePokemon(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
        currentHp: -10,
      );

      expect(pokemon.hpPercent, 0.0);
    });

    test('hpPercent clamps to 1.0 when hp exceeds maxHp', () {
      final pokemon = BattlePokemon(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
        currentHp: 150,
      );

      expect(pokemon.hpPercent, 1.0);
    });

    test('hpPercent returns 0.0 when maxHp is 0', () {
      final pokemon = BattlePokemon(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 0,
        attack: 55,
        defense: 40,
        speed: 90,
        currentHp: 0,
      );

      expect(pokemon.hpPercent, 0.0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = BattlePokemon(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
        currentHp: 100,
      );

      final updated = original.copyWith(currentHp: 50, defeated: true);

      expect(updated.currentHp, 50);
      expect(updated.defeated, true);
      expect(updated.name, 'Pikachu');
      expect(updated.maxHp, 100);
    });

    test('fromDetail creates BattlePokemon from PokemonDetail', () {
      const detail = PokemonDetail(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
      );

      final battlePokemon = BattlePokemon.fromDetail(detail);

      expect(battlePokemon.currentHp, 100);
      expect(battlePokemon.defeated, false);
      expect(battlePokemon.name, 'Pikachu');
    });

    test('fromDetail uses custom hp if provided', () {
      const detail = PokemonDetail(
        id: '25',
        name: 'Pikachu',
        sprite: '',
        types: [PokemonType.electric],
        maxHp: 100,
        attack: 55,
        defense: 40,
        speed: 90,
      );

      final battlePokemon = BattlePokemon.fromDetail(detail, hp: 50);

      expect(battlePokemon.currentHp, 50);
    });

    // NOTE: The code does NOT handle single type as string - it throws.
    // This is a known limitation. If the server sends 'type' instead of
    // 'types' as a List, the app will crash. This should be fixed separately.
  });

  group('PokemonType', () {
    test('fromString handles all known types case-insensitively', () {
      expect(PokemonType.fromString('fire'), PokemonType.fire);
      expect(PokemonType.fromString('FIRE'), PokemonType.fire);
      expect(PokemonType.fromString('Fire'), PokemonType.fire);
    });

    test('fromString returns normal for unknown types', () {
      expect(PokemonType.fromString('unknown'), PokemonType.normal);
      expect(PokemonType.fromString(''), PokemonType.normal);
    });
  });
}
