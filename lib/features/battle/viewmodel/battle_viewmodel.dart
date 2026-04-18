import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/socket_service.dart';
import '../../../shared/models/lobby_state.dart';
import '../../../shared/models/player.dart';

/// ViewModel for BattleScreen - manages battle state and turns.
class BattleViewModel extends ChangeNotifier {
  final SocketService _socketService;

  Lobby? _lobby;
  String? _playerId;
  String? _error;
  bool _isMyTurn = false;
  List<String> _battleLog = [];
  StreamSubscription? _battleStartSub;
  StreamSubscription? _lobbyStatusSub;
  StreamSubscription? _turnResultSub;
  StreamSubscription? _battleEndSub;
  StreamSubscription? _errorSub;

  BattleViewModel({required SocketService socketService})
      : _socketService = socketService {
    _setupListeners();
  }

  Lobby? get lobby => _lobby;
  String? get playerId => _playerId;
  String? get error => _error;
  bool get isMyTurn => _isMyTurn;
  List<String> get battleLog => _battleLog;

  Player? get currentPlayer => _lobby?.playerById(_playerId ?? '');
  Player? get opponent => _lobby?.opponentOf(_playerId ?? '');
  String? get winnerId => _lobby?.winnerPlayerId;
  bool get battleEnded => _lobby?.status == LobbyStatus.finished;

  void _setupListeners() {
    _battleStartSub = _socketService.battleStartStream.listen((lobby) {
      _lobby = lobby;
      _playerId = _socketService.currentPlayerId;
      _isMyTurn = lobby.currentTurnPlayerId == _playerId;
      _battleLog = [];
      _addLog('¡La batalla comenzó!');
      notifyListeners();
    });

    // The server emits lobby_status AFTER switchTurn(), so this is what
    // actually rotates currentTurnPlayerId. turn_result arrives first but
    // still carries the pre-rotation snapshot.
    _lobbyStatusSub = _socketService.lobbyStatusStream.listen((lobby) {
      if (_playerId == null) return;
      _lobby = lobby;
      _isMyTurn = lobby.currentTurnPlayerId == _playerId;
      notifyListeners();
    });

    _turnResultSub = _socketService.turnResultStream.listen((data) {
      _lobby = data.lobby;
      _isMyTurn = data.lobby.currentTurnPlayerId == _playerId;

      final attacker = data.lobby.playerById(data.turn.attackerPlayerId);
      final defender = data.lobby.playerById(data.turn.defenderPlayerId);

      if (attacker != null && defender != null) {
        _addLog('${attacker.nickname} ataca!');
        _addLog('${defender.nickname} recibe ${data.turn.damage} de daño');

        if (data.turn.defenderDefeated) {
          _addLog('¡${defender.nickname} fue derrotado!');
        }
      }

      notifyListeners();
    });

    _battleEndSub = _socketService.battleEndStream.listen((data) {
      _lobby = data.lobby;
      _isMyTurn = false;

      final winner = data.lobby.playerById(data.winnerPlayerId);
      if (winner != null) {
        _addLog('¡${winner.nickname} gana la batalla!');
      }

      notifyListeners();
    });

    _errorSub = _socketService.errorStream.listen((error) {
      _error = error;
      _addLog('Error: $error');
      notifyListeners();
    });
  }

  /// Execute an attack.
  Future<void> attack() async {
    if (!_isMyTurn) {
      _addLog('No es tu turno');
      notifyListeners();
      return;
    }

    try {
      await _socketService.attack();
      _addLog('Atacas!');
    } catch (e) {
      _error = 'Error al atacar: $e';
      _addLog('Error: $_error');
      notifyListeners();
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _battleLog.add('[$timestamp] $message');

    // Keep only last 50 messages
    if (_battleLog.length > 50) {
      _battleLog = _battleLog.sublist(_battleLog.length - 50);
    }
  }

  @override
  void dispose() {
    _battleStartSub?.cancel();
    _lobbyStatusSub?.cancel();
    _turnResultSub?.cancel();
    _battleEndSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
