import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../shared/models/lobby_state.dart';

/// Service for Socket.IO communication with the battle server.
class SocketService {
  io.Socket? _socket;
  String? _currentPlayerId;

  final _lobbyStatusController = StreamController<Lobby>.broadcast();
  final _battleStartController = StreamController<Lobby>.broadcast();
  final _turnResultController = StreamController<({Lobby lobby, TurnRecord turn})>.broadcast();
  final _battleEndController = StreamController<({Lobby lobby, String winnerPlayerId})>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Player id returned by the server after a successful join_lobby.
  /// Shared across view models so navigation between screens does not need
  /// to pass this through arguments.
  String? get currentPlayerId => _currentPlayerId;

  /// Stream of lobby status updates.
  Stream<Lobby> get lobbyStatusStream => _lobbyStatusController.stream;

  /// Stream of battle start events.
  Stream<Lobby> get battleStartStream => _battleStartController.stream;

  /// Stream of turn results.
  Stream<({Lobby lobby, TurnRecord turn})> get turnResultStream =>
      _turnResultController.stream;

  /// Stream of battle end events.
  Stream<({Lobby lobby, String winnerPlayerId})> get battleEndStream =>
      _battleEndController.stream;

  /// Stream of error messages.
  Stream<String> get errorStream => _errorController.stream;

  /// Whether the socket is currently connected.
  bool get isConnected => _socket?.connected ?? false;

  /// Connect to the battle server.
  Future<void> connect(String baseUrl) async {
    if (_socket?.connected ?? false) return;

    // Ensure URL has proper format for socket.io
    String serverUrl = baseUrl.trim();
    if (serverUrl.endsWith('/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 1);
    }

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(3)
          .setReconnectionDelay(500)
          .build(),
    );

    _setupListeners();

    // Explicitly connect
    _socket!.connect();

    final completer = Completer<void>();
    _socket!.onConnect((_) {
      if (!completer.isCompleted) completer.complete();
    });
    _socket!.onConnectError((err) {
      if (!completer.isCompleted) {
        completer.completeError(Exception(err.toString()));
      }
    });
    _socket!.on('connect', (_) {
      if (!completer.isCompleted) completer.complete();
    });

    // Timeout after 10 seconds
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Connection timeout - check server URL'));
        }
      },
    );
  }

  void _setupListeners() {
    _socket!.on('lobby_status', (data) {
      final lobby = Lobby.fromJson(Map<String, dynamic>.from(data as Map));
      _lobbyStatusController.add(lobby);
    });

    _socket!.on('battle_start', (data) {
      final lobby = Lobby.fromJson(Map<String, dynamic>.from(data as Map));
      _battleStartController.add(lobby);
    });

    _socket!.on('turn_result', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _turnResultController.add((
        lobby: Lobby.fromJson(Map<String, dynamic>.from(map['lobby'] as Map)),
        turn: TurnRecord.fromJson(Map<String, dynamic>.from(map['turn'] as Map)),
      ));
    });

    _socket!.on('battle_end', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _battleEndController.add((
        lobby: Lobby.fromJson(Map<String, dynamic>.from(map['lobby'] as Map)),
        winnerPlayerId: map['winnerPlayerId']?.toString() ?? '',
      ));
    });

    _socket!.on('error_event', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      _errorController.add(map['message']?.toString() ?? 'Unknown error');
    });
  }

  /// Disconnect from the server.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentPlayerId = null;
  }

  /// Join a lobby with the given nickname.
  Future<({String playerId, String lobbyId})> joinLobby(String nickname) async {
    final result = await _emitAck('join_lobby', {'nickname': nickname});
    final playerId = result['playerId'] as String;
    _currentPlayerId = playerId;
    return (
      playerId: playerId,
      lobbyId: result['lobbyId'] as String,
    );
  }

  /// Request random Pokemon team assignment.
  Future<void> assignPokemon() async {
    await _emitAck('assign_pokemon', {});
  }

  /// Mark player as ready.
  Future<void> ready() async {
    await _emitAck('ready', {});
  }

  /// Execute an attack.
  Future<void> attack() async {
    await _emitAck('attack', {});
  }

  /// Reset the lobby.
  Future<void> resetLobby() async {
    await _emitAck('reset_lobby', {});
  }

  Future<Map<String, dynamic>> _emitAck(
    String event,
    Map<String, dynamic> payload,
  ) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      return Future.error(Exception('Socket not connected'));
    }

    final completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(event, payload, ack: (Object? data) {
      if (data == null) {
        completer.completeError(Exception('No response from server'));
        return;
      }
      final map = Map<String, dynamic>.from(data as Map);
      if (map['ok'] == true) {
        completer.complete(map);
      } else {
        completer.completeError(Exception(map['message']?.toString() ?? 'Request failed'));
      }
    });

    return completer.future;
  }

  /// Dispose all resources.
  void dispose() {
    disconnect();
    _lobbyStatusController.close();
    _battleStartController.close();
    _turnResultController.close();
    _battleEndController.close();
    _errorController.close();
  }
}
