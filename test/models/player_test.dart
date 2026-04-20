import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_stadium/shared/models/player.dart';
import 'package:pokemon_stadium/shared/models/pokemon.dart';

void main() {
  group('Player', () {
    test('fromJson creates Player correctly', () {
      final json = {
        'id': 'player-1',
        'nickname': 'Ash',
        'team': [
          {
            'id': '25',
            'name': 'Pikachu',
            'sprite': '',
            'type': ['electric'],
            'maxHp': 100,
            'hp': 100,
            'attack': 55,
            'defense': 40,
            'speed': 90,
          }
        ],
        'activeIndex': 0,
        'ready': true,
      };

      final player = Player.fromJson(json);

      expect(player.id, 'player-1');
      expect(player.nickname, 'Ash');
      expect(player.team.length, 1);
      expect(player.activeIndex, 0);
      expect(player.ready, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final player = Player.fromJson(json);

      expect(player.id, '');
      expect(player.nickname, '');
      expect(player.team, isEmpty);
      expect(player.activeIndex, 0);
      expect(player.ready, false);
    });

    test('fromJson parses team of BattlePokemon correctly', () {
      final json = {
        'id': 'player-1',
        'nickname': 'Ash',
        'team': [
          {
            'id': '25',
            'name': 'Pikachu',
            'sprite': '',
            'type': ['electric'],
            'maxHp': 100,
            'hp': 100,
            'attack': 55,
            'defense': 40,
            'speed': 90,
          },
          {
            'id': '6',
            'name': 'Charizard',
            'sprite': '',
            'type': ['fire', 'flying'],
            'maxHp': 150,
            'hp': 150,
            'attack': 84,
            'defense': 78,
            'speed': 100,
          },
        ],
        'activeIndex': 1,
        'ready': false,
      };

      final player = Player.fromJson(json);

      expect(player.team.length, 2);
      expect(player.team[0].name, 'Pikachu');
      expect(player.team[1].name, 'Charizard');
      expect(player.activeIndex, 1);
    });

    group('activePokemon', () {
      test('returns the pokemon at activeIndex', () {
        final json = {
          'id': 'player-1',
          'nickname': 'Ash',
          'team': [
            {
              'id': '25',
              'name': 'Pikachu',
              'sprite': '',
              'type': ['electric'],
              'maxHp': 100,
              'hp': 100,
              'attack': 55,
              'defense': 40,
              'speed': 90,
            },
            {
              'id': '6',
              'name': 'Charizard',
              'sprite': '',
              'type': ['fire'],
              'maxHp': 150,
              'hp': 150,
              'attack': 84,
              'defense': 78,
              'speed': 100,
            },
          ],
          'activeIndex': 1,
          'ready': false,
        };

        final player = Player.fromJson(json);

        expect(player.activePokemon?.name, 'Charizard');
      });

      test('returns first team member when activeIndex is out of bounds', () {
        final json = {
          'id': 'player-1',
          'nickname': 'Ash',
          'team': [
            {
              'id': '25',
              'name': 'Pikachu',
              'sprite': '',
              'type': ['electric'],
              'maxHp': 100,
              'hp': 100,
              'attack': 55,
              'defense': 40,
              'speed': 90,
            },
          ],
          'activeIndex': 5, // Out of bounds
          'ready': false,
        };

        final player = Player.fromJson(json);

        expect(player.activePokemon?.name, 'Pikachu');
      });

      test('returns first team member when activeIndex is negative', () {
        final json = {
          'id': 'player-1',
          'nickname': 'Ash',
          'team': [
            {
              'id': '25',
              'name': 'Pikachu',
              'sprite': '',
              'type': ['electric'],
              'maxHp': 100,
              'hp': 100,
              'attack': 55,
              'defense': 40,
              'speed': 90,
            },
          ],
          'activeIndex': -1,
          'ready': false,
        };

        final player = Player.fromJson(json);

        expect(player.activePokemon?.name, 'Pikachu');
      });

      test('returns null when team is empty', () {
        final json = {
          'id': 'player-1',
          'nickname': 'Ash',
          'team': [],
          'activeIndex': 0,
          'ready': false,
        };

        final player = Player.fromJson(json);

        expect(player.activePokemon, isNull);
      });
    });

    test('copyWith creates new instance with updated values', () {
      final original = Player(
        id: 'player-1',
        nickname: 'Ash',
        team: [
          BattlePokemon(
            id: '25',
            name: 'Pikachu',
            sprite: '',
            types: [PokemonType.electric],
            maxHp: 100,
            attack: 55,
            defense: 40,
            speed: 90,
            currentHp: 100,
          ),
        ],
        activeIndex: 0,
        ready: false,
      );

      final updated = original.copyWith(ready: true, activeIndex: 1);

      expect(updated.ready, true);
      expect(updated.activeIndex, 1);
      expect(updated.nickname, 'Ash');
      expect(updated.id, 'player-1');
    });

    test('props includes all fields for equality', () {
      final json = {
        'id': 'player-1',
        'nickname': 'Ash',
        'team': [],
        'activeIndex': 0,
        'ready': false,
      };

      final player1 = Player.fromJson(json);
      final player2 = Player.fromJson(json);

      expect(player1, equals(player2));
    });
  });
}
