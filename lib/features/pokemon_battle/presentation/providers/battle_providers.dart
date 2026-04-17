import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../data/repositories/socket_battle_gateway.dart';
import '../../domain/entities/lobby.dart';
import '../../domain/repositories/battle_gateway.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return AppConfig(prefs);
});

final battleGatewayProvider = Provider<BattleGateway>((ref) {
  final gateway = SocketBattleGateway();
  ref.onDispose(gateway.disconnect);
  return gateway;
});

class BattleState {
  final Lobby? lobby;
  final String? playerId;
  final String? lastError;
  final TurnRecord? lastTurn;
  final bool connected;

  const BattleState({
    this.lobby,
    this.playerId,
    this.lastError,
    this.lastTurn,
    this.connected = false,
  });

  BattleState copyWith({
    Lobby? lobby,
    String? playerId,
    String? lastError,
    TurnRecord? lastTurn,
    bool? connected,
  }) {
    return BattleState(
      lobby: lobby ?? this.lobby,
      playerId: playerId ?? this.playerId,
      lastError: lastError,
      lastTurn: lastTurn ?? this.lastTurn,
      connected: connected ?? this.connected,
    );
  }
}

class BattleController extends StateNotifier<BattleState> {
  final BattleGateway _gateway;

  BattleController(this._gateway) : super(const BattleState()) {
    _gateway.lobbyStatusStream.listen((lobby) => state = state.copyWith(lobby: lobby));
    _gateway.battleStartStream.listen((lobby) => state = state.copyWith(lobby: lobby));
    _gateway.turnResultStream.listen((p) =>
        state = state.copyWith(lobby: p.lobby, lastTurn: p.turn));
    _gateway.battleEndStream.listen((p) => state = state.copyWith(lobby: p.lobby));
    _gateway.errorStream.listen((msg) => state = state.copyWith(lastError: msg));
  }

  Future<void> connect(String baseUrl) async {
    await _gateway.connect(baseUrl);
    state = state.copyWith(connected: true);
  }

  Future<void> joinLobby(String nickname) async {
    final res = await _gateway.joinLobby(nickname);
    state = state.copyWith(playerId: res.playerId);
  }

  Future<void> assignPokemon() => _gateway.assignPokemon();
  Future<void> ready() => _gateway.ready();

  Future<void> attack() async {
    if (state.lobby?.currentTurnPlayerId != state.playerId) {
      state = state.copyWith(lastError: 'Not your turn');
      return;
    }
    await _gateway.attack();
  }

  Future<void> resetLobby() async {
    await _gateway.resetLobby();
    state = const BattleState();
  }
}

final battleControllerProvider =
    StateNotifierProvider<BattleController, BattleState>((ref) {
  return BattleController(ref.watch(battleGatewayProvider));
});
