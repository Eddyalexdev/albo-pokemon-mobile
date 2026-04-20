import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokemon_stadium/core/constants/api_constants.dart';
import 'package:pokemon_stadium/features/lobby/viewmodel/lobby_viewmodel.dart';
import 'package:pokemon_stadium/shared/models/lobby_state.dart';
import 'package:pokemon_stadium/shared/models/player.dart';
import 'package:pokemon_stadium/shared/models/pokemon.dart';
import '../mocks/mock_socket_service.dart';

void main() {
  late LobbyViewModel viewModel;
  late SharedPreferences prefs;
  late MockSocketService mockSocket;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      ApiConstants.keyNickname: 'TestPlayer',
      ApiConstants.keyServerUrl: 'http://localhost:8080',
    });
    prefs = await SharedPreferences.getInstance();
    mockSocket = MockSocketService();

    // Use Duration.zero to skip auto-assign delay in tests
    viewModel = LobbyViewModel(
      prefs: prefs,
      socketService: mockSocket,
      autoAssignDelay: Duration.zero,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('LobbyViewModel', () {
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

      test('isConnected is false initially', () {
        expect(viewModel.isConnected, false);
      });

      test('isJoined is false initially', () {
        expect(viewModel.isJoined, false);
      });

      test('team is empty initially', () {
        expect(viewModel.team, isEmpty);
      });
    });

    // ===== GETTERS =====

    group('nickname and serverUrl getters', () {
      test('nickname returns saved nickname', () {
        expect(viewModel.nickname, 'TestPlayer');
      });

      test('serverUrl returns saved serverUrl', () {
        expect(viewModel.serverUrl, 'http://localhost:8080');
      });
    });

    // ===== INITIALIZE =====

    group('initialize', () {
      test('sets error when nickname is missing', () async {
        SharedPreferences.setMockInitialValues({
          ApiConstants.keyServerUrl: 'http://localhost:8080',
        });
        final freshPrefs = await SharedPreferences.getInstance();
        final freshViewModel = LobbyViewModel(
          prefs: freshPrefs,
          socketService: mockSocket,
          autoAssignDelay: Duration.zero,
        );

        await freshViewModel.initialize(autoAssign: false);

        expect(freshViewModel.error, 'Missing configuration');
        freshViewModel.dispose();
      });

      test('sets error when serverUrl is missing', () async {
        SharedPreferences.setMockInitialValues({
          ApiConstants.keyNickname: 'TestPlayer',
        });
        final freshPrefs = await SharedPreferences.getInstance();
        final freshViewModel = LobbyViewModel(
          prefs: freshPrefs,
          socketService: mockSocket,
          autoAssignDelay: Duration.zero,
        );

        await freshViewModel.initialize(autoAssign: false);

        expect(freshViewModel.error, 'Missing configuration');
        freshViewModel.dispose();
      });

      test('connects to server on success', () async {
        await viewModel.initialize(autoAssign: false);

        expect(mockSocket.callLog.any((l) => l.contains('connect')), true);
      });

      test('joins lobby on success', () async {
        await viewModel.initialize(autoAssign: false);

        expect(mockSocket.callLog.any((l) => l.contains('joinLobby')), true);
      });

      test('sets isConnected to true on success', () async {
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.isConnected, true);
      });

      test('sets isJoined to true on success', () async {
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.isJoined, true);
      });

      test('sets playerId on success', () async {
        // Default mock returns 'test-player-id'
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.playerId, 'test-player-id');
      });

      test('sets custom playerId when configured', () async {
        mockSocket.joinLobbyPlayerId = 'player-123';

        await viewModel.initialize(autoAssign: false);

        expect(viewModel.playerId, 'player-123');
      });

      test('sets error on connection failure', () async {
        mockSocket.connectShouldSucceed = false;
        mockSocket.connectError = 'Connection refused';

        await viewModel.initialize(autoAssign: false);

        expect(viewModel.error, contains('Error al conectar'));
      });

      test('auto-assigns team when autoAssign is true', () async {
        await viewModel.initialize(autoAssign: true);

        expect(mockSocket.callLog, contains('assignPokemon'));
      });

      test('does not auto-assign team when autoAssign is false', () async {
        await viewModel.initialize(autoAssign: false);

        expect(mockSocket.callLog, isNot(contains('assignPokemon')));
      });

      test('logs connecting message', () async {
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.logMessages.first, contains('Conectando'));
      });
    });

    // ===== CAN ASSIGN TEAM =====

    group('canAssignTeam', () {
      test('is false when not joined', () {
        expect(viewModel.canAssignTeam, false);
      });

      test('is true when joined and no team received yet', () async {
        await viewModel.initialize(autoAssign: false);

        // currentPlayer is null until lobby_status is received
        // canAssignTeam returns true if currentPlayer is null
        expect(viewModel.canAssignTeam, true);
      });
    });

    // ===== CAN READY =====

    group('canReady', () {
      test('is false when playerId is null', () {
        expect(viewModel.canReady, false);
      });

      test('is false when no lobby received', () async {
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.canReady, false);
      });
    });

    // ===== IS READY =====

    group('isReady', () {
      test('is false when currentPlayer is null', () {
        expect(viewModel.isReady, false);
      });
    });

    // ===== ASSIGN TEAM =====

    group('assignTeam', () {
      test('calls socket.assignPokemon', () async {
        await viewModel.initialize(autoAssign: false);

        await viewModel.assignTeam();

        expect(mockSocket.callLog, contains('assignPokemon'));
      });

      test('does not assign twice when already loading', () async {
        await viewModel.initialize(autoAssign: false);
        mockSocket.assignPokemonShouldSucceed = false;
        mockSocket.assignPokemonError = 'timeout';

        viewModel.assignTeam();
        await viewModel.assignTeam();

        final assignCount =
            mockSocket.callLog.where((e) => e == 'assignPokemon').length;
        expect(assignCount, 1);
      });

      test('sets error on failure', () async {
        await viewModel.initialize(autoAssign: false);
        mockSocket.assignPokemonShouldSucceed = false;
        mockSocket.assignPokemonError = 'timeout';

        await viewModel.assignTeam();

        expect(viewModel.error, contains('Error al asignar equipo'));
      });
    });

    // ===== READY =====

    group('ready', () {
      test('returns early when playerId is null', () async {
        await viewModel.ready();

        expect(mockSocket.callLog, isNot(contains('ready')));
      });

      test('sets error when player has no team', () async {
        mockSocket.joinLobbyPlayerId = 'player-without-team';
        await viewModel.initialize(autoAssign: false);

        // Emit a lobby with the player having no team
        final lobby = _createLobby([_createPlayer('player-without-team', 'TestPlayer', [])]);
        mockSocket.emitLobbyStatus(lobby);
        await Future.delayed(Duration.zero, () {});

        await viewModel.ready();

        expect(viewModel.error, 'Primero necesitás un equipo');
      });
    });

    // ===== RESET LOBBY =====

    group('resetLobby', () {
      test('calls socket.resetLobby', () async {
        await viewModel.initialize(autoAssign: false);

        await viewModel.resetLobby();

        expect(mockSocket.callLog, contains('resetLobby'));
      });

      test('clears lobby state', () async {
        await viewModel.initialize(autoAssign: false);
        expect(viewModel.lobby, isNull); // Lobby never received

        await viewModel.resetLobby();

        expect(viewModel.lobby, isNull);
      });
    });

    // ===== BATTLE STARTED =====

    group('battleStarted', () {
      test('is false when lobby is null', () {
        expect(viewModel.battleStarted, false);
      });
    });

    // ===== ERROR HANDLING =====

    group('error handling', () {
      test('error is set when socket error event received', () async {
        await viewModel.initialize(autoAssign: false);

        mockSocket.emitError('Test error message');
        await Future.delayed(Duration.zero, () {}); // Let error stream subscriber process

        expect(viewModel.error, 'Test error message');
      });
    });

    // ===== LOG MESSAGES =====

    group('log messages', () {
      test('logMessages starts empty', () {
        expect(viewModel.logMessages, isEmpty);
      });

      test('logMessages are added during initialize', () async {
        await viewModel.initialize(autoAssign: false);

        expect(viewModel.logMessages, isNotEmpty);
        expect(viewModel.logMessages.first, contains('Conectando'));
      });
    });
  });
}

// Helper functions
Player _createPlayer(String id, String nickname, List<BattlePokemon> team) {
  return Player(
    id: id,
    nickname: nickname,
    team: team,
    activeIndex: 0,
    ready: true,
  );
}

Lobby _createLobby(List<Player> players) {
  return Lobby(
    id: 'lobby-123',
    status: LobbyStatus.waiting,
    players: players,
    currentTurnPlayerId: players.isNotEmpty ? players.first.id : null,
  );
}
