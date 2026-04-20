import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_stadium/features/battle/viewmodel/battle_viewmodel.dart';
import 'package:pokemon_stadium/shared/models/lobby_state.dart';
import 'package:pokemon_stadium/shared/models/player.dart';
import '../mocks/mock_socket_service.dart';

void main() {
  late BattleViewModel viewModel;
  late MockSocketService mockSocket;

  setUp(() {
    mockSocket = MockSocketService();
    viewModel = BattleViewModel(socketService: mockSocket);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('BattleViewModel', () {
    // ===== INITIAL STATE =====

    group('initial state', () {
      test('lobby is null initially', () {
        expect(viewModel.lobby, isNull);
      });

      test('playerId is null initially', () {
        expect(viewModel.playerId, isNull);
      });

      test('error is null initially', () {
        expect(viewModel.error, isNull);
      });

      test('isMyTurn is false initially', () {
        expect(viewModel.isMyTurn, false);
      });

      test('battleLog is empty initially', () {
        expect(viewModel.battleLog, isEmpty);
      });

      test('shouldReturnToStart is false initially', () {
        expect(viewModel.shouldReturnToStart, false);
      });

      test('resultDialogShown is false initially', () {
        expect(viewModel.resultDialogShown, false);
      });

      test('battleJustStarted is false initially', () {
        expect(viewModel.battleJustStarted, false);
      });

      test('lastDefeatedPokemon is null initially', () {
        expect(viewModel.lastDefeatedPokemon, isNull);
      });

      test('lastEnteredPokemon is null initially', () {
        expect(viewModel.lastEnteredPokemon, isNull);
      });
    });

    // ===== ATTACK =====

    group('attack', () {
      test('calls socket.attack when it is my turn', () async {
        // Set up battle with player1's turn
        mockSocket.joinLobbyPlayerId = 'player-1';
        await mockSocket.joinLobby('TestPlayer'); // Sets _currentPlayerId
        final lobby = _createBattlingLobby('player-1', 'player-2');
        mockSocket.emitBattleStart(lobby);
        await Future.delayed(const Duration(milliseconds: 16)); // Let stream subscriber process the event

        await viewModel.attack();

        expect(mockSocket.callLog, contains('attack'));
      });

      test('does not call socket.attack when not my turn', () async {
        // Set up battle with player2's turn (not our turn)
        mockSocket.joinLobbyPlayerId = 'player-2';
        await mockSocket.joinLobby('TestPlayer'); // Sets _currentPlayerId
        final lobby = _createBattlingLobby('player-1', 'player-2');
        mockSocket.emitBattleStart(lobby);
        await Future.delayed(const Duration(milliseconds: 16)); // Let stream subscriber process the event

        await viewModel.attack();

        expect(mockSocket.callLog, isNot(contains('attack')));
      });

      test('adds log message on attack', () async {
        mockSocket.joinLobbyPlayerId = 'player-1';
        await mockSocket.joinLobby('TestPlayer'); // Sets _currentPlayerId
        final lobby = _createBattlingLobby('player-1', 'player-2');
        mockSocket.emitBattleStart(lobby);
        await Future.delayed(const Duration(milliseconds: 16)); // Let stream subscriber process the event

        await viewModel.attack();

        expect(viewModel.battleLog.any((m) => m.contains('Atacas')), true);
      });
    });

    // ===== HELPER GETTERS =====

    group('helper getters', () {
      test('battleEnded is false when lobby is null', () {
        expect(viewModel.battleEnded, false);
      });

      test('currentPlayer returns null when lobby is null', () {
        expect(viewModel.currentPlayer, isNull);
      });

      test('opponent returns null when lobby is null', () {
        expect(viewModel.opponent, isNull);
      });
    });

    // ===== NAVIGATION FLAGS =====

    group('clearNavigationFlag', () {
      test('sets shouldReturnToStart to false', () {
        expect(viewModel.shouldReturnToStart, false);

        viewModel.clearNavigationFlag();

        expect(viewModel.shouldReturnToStart, false);
      });
    });

    group('clearBattleStartFlag', () {
      test('sets battleJustStarted to false', () {
        viewModel.clearBattleStartFlag();

        expect(viewModel.battleJustStarted, false);
      });
    });

    group('clearDefeatedFlag', () {
      test('sets lastDefeatedPokemon to null', () {
        viewModel.clearDefeatedFlag();

        expect(viewModel.lastDefeatedPokemon, isNull);
      });
    });

    group('clearEnteredFlag', () {
      test('sets lastEnteredPokemon to null', () {
        viewModel.clearEnteredFlag();

        expect(viewModel.lastEnteredPokemon, isNull);
      });
    });

    group('markResultDialogShown', () {
      test('sets resultDialogShown to true', () {
        expect(viewModel.resultDialogShown, false);

        viewModel.markResultDialogShown();

        expect(viewModel.resultDialogShown, true);
      });
    });

    // ===== BATTLE LOG =====

    group('battle log', () {
      test('log has timestamps in HH:mm:ss format', () async {
        mockSocket.joinLobbyPlayerId = 'player-1';
        await mockSocket.joinLobby('TestPlayer'); // Sets _currentPlayerId
        final lobby = _createBattlingLobby('player-1', 'player-2');
        mockSocket.emitBattleStart(lobby);
        await Future.delayed(const Duration(milliseconds: 16)); // Let stream subscriber process the event

        expect(viewModel.battleLog.first, matches(RegExp(r'\[\d{2}:\d{2}:\d{2}\]')));
      });
    });

    // ===== ERROR EVENTS =====

    group('error events', () {
      test('sets error on error event', () async {
        // Set up battle first
        mockSocket.joinLobbyPlayerId = 'player-1';
        await mockSocket.joinLobby('TestPlayer'); // Sets _currentPlayerId
        final lobby = _createBattlingLobby('player-1', 'player-2');
        mockSocket.emitBattleStart(lobby);
        await Future.delayed(const Duration(milliseconds: 16)); // Let stream subscriber process the event

        mockSocket.emitError('Connection lost');
        await Future.delayed(const Duration(milliseconds: 16)); // Let error stream subscriber process

        expect(viewModel.error, 'Connection lost');
      });
    });
  });
}

// Helper functions
Player _createPlayer(String id, String nickname) {
  return Player(
    id: id,
    nickname: nickname,
    team: [],
    activeIndex: 0,
    ready: true,
  );
}

Lobby _createBattlingLobby(String player1Id, String player2Id) {
  return Lobby(
    id: 'lobby-123',
    status: LobbyStatus.battling,
    players: [
      _createPlayer(player1Id, 'Player1'),
      _createPlayer(player2Id, 'Player2'),
    ],
    currentTurnPlayerId: player1Id,
  );
}
