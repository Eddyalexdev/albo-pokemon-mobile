import '../entities/lobby.dart';

abstract class BattleGateway {
  Future<void> connect(String baseUrl);
  void disconnect();

  Future<({String playerId, String lobbyId})> joinLobby(String nickname);
  Future<void> assignPokemon();
  Future<void> ready();
  Future<void> attack();
  Future<void> resetLobby();

  Stream<Lobby> get lobbyStatusStream;
  Stream<Lobby> get battleStartStream;
  Stream<({Lobby lobby, TurnRecord turn})> get turnResultStream;
  Stream<({Lobby lobby, String winnerPlayerId})> get battleEndStream;
  Stream<String> get errorStream;
}
