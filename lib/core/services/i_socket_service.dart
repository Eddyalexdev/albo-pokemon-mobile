import '../../shared/models/lobby_state.dart';

/// Abstract interface for Socket.IO communication with the battle server.
/// Exists to enable dependency injection and testing.
abstract interface class ISocketService {
  /// Player id returned by the server after a successful join_lobby.
  String? get currentPlayerId;

  /// Whether the socket is currently connected.
  bool get isConnected;

  /// Stream of lobby status updates.
  Stream<Lobby> get lobbyStatusStream;

  /// Stream of battle start events.
  Stream<Lobby> get battleStartStream;

  /// Stream of turn results.
  Stream<({Lobby lobby, TurnRecord turn})> get turnResultStream;

  /// Stream of pokemon defeated events.
  Stream<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>
      get pokemonDefeatedStream;

  /// Stream of pokemon entered events.
  Stream<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>
      get pokemonEnteredStream;

  /// Stream of battle end events.
  Stream<({Lobby lobby, String winnerPlayerId})> get battleEndStream;

  /// Stream of error messages.
  Stream<String> get errorStream;

  /// Connect to the battle server.
  Future<void> connect(String baseUrl);

  /// Disconnect from the server.
  void disconnect();

  /// Join a lobby with the given nickname.
  Future<({String playerId, String lobbyId})> joinLobby(String nickname);

  /// Request random Pokemon team assignment.
  Future<void> assignPokemon();

  /// Mark player as ready.
  Future<void> ready();

  /// Execute an attack.
  Future<void> attack();

  /// Reset the lobby.
  Future<void> resetLobby();

  /// Dispose all resources.
  void dispose();
}