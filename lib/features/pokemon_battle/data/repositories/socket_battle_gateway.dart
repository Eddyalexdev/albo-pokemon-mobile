import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../domain/entities/lobby.dart';
import '../../domain/repositories/battle_gateway.dart';
import '../models/lobby_mapper.dart';

class SocketBattleGateway implements BattleGateway {
  io.Socket? _socket;

  final _lobbyStatus = StreamController<Lobby>.broadcast();
  final _battleStart = StreamController<Lobby>.broadcast();
  final _turnResult =
      StreamController<({Lobby lobby, TurnRecord turn})>.broadcast();
  final _battleEnd =
      StreamController<({Lobby lobby, String winnerPlayerId})>.broadcast();
  final _errors = StreamController<String>.broadcast();

  @override
  Future<void> connect(String baseUrl) async {
    if (_socket?.connected ?? false) return;
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .enableAutoConnect()
          .build(),
    );

    _socket!.on('lobby_status', (data) {
      _lobbyStatus.add(LobbyMapper.fromJson(Map<String, dynamic>.from(data as Map)));
    });
    _socket!.on('battle_start', (data) {
      _battleStart.add(LobbyMapper.fromJson(Map<String, dynamic>.from(data as Map)));
    });
    _socket!.on('turn_result', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _turnResult.add((
        lobby: LobbyMapper.fromJson(Map<String, dynamic>.from(map['lobby'] as Map)),
        turn: LobbyMapper.turnFromJson(Map<String, dynamic>.from(map['turn'] as Map)),
      ));
    });
    _socket!.on('battle_end', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _battleEnd.add((
        lobby: LobbyMapper.fromJson(Map<String, dynamic>.from(map['lobby'] as Map)),
        winnerPlayerId: map['winnerPlayerId'] as String,
      ));
    });
    _socket!.on('error_event', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _errors.add(map['message'] as String? ?? 'Unknown error');
    });

    final completer = Completer<void>();
    _socket!.onConnect((_) {
      if (!completer.isCompleted) completer.complete();
    });
    _socket!.onConnectError((err) {
      if (!completer.isCompleted) completer.completeError(err as Object);
    });
    return completer.future;
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  @override
  Future<({String playerId, String lobbyId})> joinLobby(String nickname) async {
    final res = await _emitAck('join_lobby', {'nickname': nickname});
    return (playerId: res['playerId'] as String, lobbyId: res['lobbyId'] as String);
  }

  @override
  Future<void> assignPokemon() => _emitAck('assign_pokemon', const {});

  @override
  Future<void> ready() => _emitAck('ready', const {});

  @override
  Future<void> attack() => _emitAck('attack', const {});

  @override
  Future<void> resetLobby() => _emitAck('reset_lobby', const {});

  Future<Map<String, dynamic>> _emitAck(
    String event,
    Map<String, dynamic> payload,
  ) {
    final socket = _socket;
    if (socket == null) {
      return Future.error(StateError('Socket not connected'));
    }
    final completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(event, payload, ack: (Object? data) {
      final map = Map<String, dynamic>.from(data as Map);
      if (map['ok'] == true) {
        completer.complete(map);
      } else {
        completer.completeError(Exception(map['message'] ?? 'Request failed'));
      }
    });
    return completer.future;
  }

  @override
  Stream<Lobby> get lobbyStatusStream => _lobbyStatus.stream;

  @override
  Stream<Lobby> get battleStartStream => _battleStart.stream;

  @override
  Stream<({Lobby lobby, TurnRecord turn})> get turnResultStream =>
      _turnResult.stream;

  @override
  Stream<({Lobby lobby, String winnerPlayerId})> get battleEndStream =>
      _battleEnd.stream;

  @override
  Stream<String> get errorStream => _errors.stream;
}
