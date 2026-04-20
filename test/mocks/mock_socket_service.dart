import 'dart:async';

import 'package:pokemon_stadium/core/services/i_socket_service.dart';
import 'package:pokemon_stadium/shared/models/lobby_state.dart';

/// Mock implementation of [ISocketService] for testing.
/// Allows tests to control streams and mock responses.
class MockSocketService implements ISocketService {
  String? _currentPlayerId;
  bool _isConnected = false;

  // Stream controllers for each event type
  final _lobbyStatusController = StreamController<Lobby>.broadcast();
  final _battleStartController = StreamController<Lobby>.broadcast();
  final _turnResultController =
      StreamController<({Lobby lobby, TurnRecord turn})>.broadcast();
  final _pokemonDefeatedController = StreamController<
      ({Lobby lobby, String playerId, int pokemonId, String pokemonName})>.broadcast();
  final _pokemonEnteredController = StreamController<
      ({Lobby lobby, String playerId, int pokemonId, String pokemonName})>.broadcast();
  final _battleEndController =
      StreamController<({Lobby lobby, String winnerPlayerId})>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Completers for async methods
  final Map<String, Completer<void>> _methodCompleters = {};

  // Track calls for assertions
  final List<String> callLog = [];

  // Configuration for mocked responses
  bool connectShouldSucceed = true;
  bool joinLobbyShouldSucceed = true;
  bool assignPokemonShouldSucceed = true;
  bool readyShouldSucceed = true;
  bool attackShouldSucceed = true;
  bool resetLobbyShouldSucceed = true;

  String? connectError;
  String? joinLobbyError;
  String? assignPokemonError;
  String? readyError;
  String? attackError;
  String? resetLobbyError;

  String? joinLobbyPlayerId;
  String? joinLobbyLobbyId;

  @override
  String? get currentPlayerId => _currentPlayerId;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<Lobby> get lobbyStatusStream => _lobbyStatusController.stream;

  @override
  Stream<Lobby> get battleStartStream => _battleStartController.stream;

  @override
  Stream<({Lobby lobby, TurnRecord turn})> get turnResultStream =>
      _turnResultController.stream;

  @override
  Stream<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>
      get pokemonDefeatedStream => _pokemonDefeatedController.stream;

  @override
  Stream<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>
      get pokemonEnteredStream => _pokemonEnteredController.stream;

  @override
  Stream<({Lobby lobby, String winnerPlayerId})> get battleEndStream =>
      _battleEndController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  /// Helper to emit a lobby status update for tests.
  void emitLobbyStatus(Lobby lobby) {
    _lobbyStatusController.add(lobby);
  }

  /// Helper to emit a battle start event for tests.
  void emitBattleStart(Lobby lobby) {
    _battleStartController.add(lobby);
  }

  /// Helper to emit a turn result for tests.
  void emitTurnResult({required Lobby lobby, required TurnRecord turn}) {
    _turnResultController.add((lobby: lobby, turn: turn));
  }

  /// Helper to emit a pokemon defeated event for tests.
  void emitPokemonDefeated({
    required Lobby lobby,
    required String playerId,
    required int pokemonId,
    required String pokemonName,
  }) {
    _pokemonDefeatedController.add((
      lobby: lobby,
      playerId: playerId,
      pokemonId: pokemonId,
      pokemonName: pokemonName,
    ));
  }

  /// Helper to emit a pokemon entered event for tests.
  void emitPokemonEntered({
    required Lobby lobby,
    required String playerId,
    required int pokemonId,
    required String pokemonName,
  }) {
    _pokemonEnteredController.add((
      lobby: lobby,
      playerId: playerId,
      pokemonId: pokemonId,
      pokemonName: pokemonName,
    ));
  }

  /// Helper to emit a battle end event for tests.
  void emitBattleEnd({required Lobby lobby, required String winnerPlayerId}) {
    _battleEndController.add((lobby: lobby, winnerPlayerId: winnerPlayerId));
  }

  /// Helper to emit an error for tests.
  void emitError(String message) {
    _errorController.add(message);
  }

  @override
  Future<void> connect(String baseUrl) async {
    callLog.add('connect($baseUrl)');

    if (connectError != null) {
      throw Exception(connectError);
    }

    if (!connectShouldSucceed) {
      throw Exception('Connection failed');
    }

    _isConnected = true;
  }

  @override
  void disconnect() {
    callLog.add('disconnect');
    _isConnected = false;
    _currentPlayerId = null;
  }

  @override
  Future<({String playerId, String lobbyId})> joinLobby(String nickname) async {
    callLog.add('joinLobby($nickname)');

    if (joinLobbyError != null) {
      throw Exception(joinLobbyError);
    }

    if (!joinLobbyShouldSucceed) {
      throw Exception('Join lobby failed');
    }

    _currentPlayerId = joinLobbyPlayerId ?? 'test-player-id';
    return (
      playerId: _currentPlayerId!,
      lobbyId: joinLobbyLobbyId ?? 'test-lobby-id',
    );
  }

  @override
  Future<void> assignPokemon() async {
    callLog.add('assignPokemon');

    if (assignPokemonError != null) {
      throw Exception(assignPokemonError);
    }

    if (!assignPokemonShouldSucceed) {
      throw Exception('Assign pokemon failed');
    }
  }

  @override
  Future<void> ready() async {
    callLog.add('ready');

    if (readyError != null) {
      throw Exception(readyError);
    }

    if (!readyShouldSucceed) {
      throw Exception('Ready failed');
    }
  }

  @override
  Future<void> attack() async {
    callLog.add('attack');

    if (attackError != null) {
      throw Exception(attackError);
    }

    if (!attackShouldSucceed) {
      throw Exception('Attack failed');
    }
  }

  @override
  Future<void> resetLobby() async {
    callLog.add('resetLobby');

    if (resetLobbyError != null) {
      throw Exception(resetLobbyError);
    }

    if (!resetLobbyShouldSucceed) {
      throw Exception('Reset lobby failed');
    }
  }

  @override
  void dispose() {
    callLog.add('dispose');
    _lobbyStatusController.close();
    _battleStartController.close();
    _turnResultController.close();
    _pokemonDefeatedController.close();
    _pokemonEnteredController.close();
    _battleEndController.close();
    _errorController.close();
  }

  /// Reset all state for a new test.
  void reset() {
    _currentPlayerId = null;
    _isConnected = false;
    callLog.clear();

    connectShouldSucceed = true;
    joinLobbyShouldSucceed = true;
    assignPokemonShouldSucceed = true;
    readyShouldSucceed = true;
    attackShouldSucceed = true;
    resetLobbyShouldSucceed = true;

    connectError = null;
    joinLobbyError = null;
    assignPokemonError = null;
    readyError = null;
    attackError = null;
    resetLobbyError = null;

    joinLobbyPlayerId = null;
    joinLobbyLobbyId = null;
  }
}
