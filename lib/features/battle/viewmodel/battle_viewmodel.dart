import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/i_socket_service.dart';
import '../../../shared/models/lobby_state.dart';
import '../../../shared/models/player.dart';

/// ViewModel for BattleScreen - manages battle state and turns.
class BattleViewModel extends ChangeNotifier {
  final ISocketService _socketService;

  Lobby? _lobby;
  String? _playerId;
  String? _error;
  bool _isMyTurn = false;
  List<String> _battleLog = [];
  bool _shouldReturnToStart = false;
  bool _inBattle = false;

  // Transient UI flags
  bool _battleJustStarted = false;
  String? _lastDefeatedPokemon;
  String? _lastEnteredPokemon;
  bool _resultDialogShown = false;

  StreamSubscription<Lobby>? _battleStartSub;
  StreamSubscription<Lobby>? _lobbyStatusSub;
  StreamSubscription<({Lobby lobby, TurnRecord turn})>? _turnResultSub;
  StreamSubscription<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>? _pokemonDefeatedSub;
  StreamSubscription<({Lobby lobby, String playerId, int pokemonId, String pokemonName})>? _pokemonEnteredSub;
  StreamSubscription<({Lobby lobby, String winnerPlayerId})>? _battleEndSub;
  StreamSubscription<String>? _errorSub;

  BattleViewModel({required ISocketService socketService})
      : _socketService = socketService {
    _setupListeners();
  }

  Lobby? get lobby => _lobby;
  String? get playerId => _playerId;
  String? get error => _error;
  bool get isMyTurn => _isMyTurn;
  List<String> get battleLog => _battleLog;
  bool get shouldReturnToStart => _shouldReturnToStart;
  bool get battleJustStarted => _battleJustStarted;
  String? get lastDefeatedPokemon => _lastDefeatedPokemon;
  String? get lastEnteredPokemon => _lastEnteredPokemon;
  bool get resultDialogShown => _resultDialogShown;

  Player? get currentPlayer => _lobby?.playerById(_playerId ?? '');
  Player? get opponent => _lobby?.opponentOf(_playerId ?? '');
  String? get winnerId => _lobby?.winnerPlayerId;
  bool get battleEnded => _lobby?.status == LobbyStatus.finished;

  void _setupListeners() {
    _battleStartSub = _socketService.battleStartStream.listen((Lobby lobby) {
      _lobby = lobby;
      _playerId = _socketService.currentPlayerId;
      _isMyTurn = lobby.currentTurnPlayerId == _playerId;
      _battleLog = [];
      _inBattle = true;
      _shouldReturnToStart = false;
      _resultDialogShown = false;
      _battleJustStarted = true;
      _lastDefeatedPokemon = null;
      _addLog('¡La batalla comenzó!');
      notifyListeners();
    });

    // The server emits lobby_status AFTER switchTurn(), so this is what
    // actually rotates currentTurnPlayerId. turn_result arrives first but
    // still carries the pre-rotation snapshot.
    _lobbyStatusSub = _socketService.lobbyStatusStream.listen((Lobby lobby) {
      if (_playerId == null) return;
      _lobby = lobby;
      _isMyTurn = lobby.currentTurnPlayerId == _playerId;

      // If we're in battle but opponent disappears, navigate to start
      if (_inBattle && lobby.status == LobbyStatus.waiting) {
        _shouldReturnToStart = true;
        _addLog('El oponente se fue. Volviendo al inicio...');
      }

      notifyListeners();
    });

    _turnResultSub = _socketService.turnResultStream.listen(
        (({Lobby lobby, TurnRecord turn}) data) {
      _lobby = data.lobby;
      _isMyTurn = data.lobby.currentTurnPlayerId == _playerId;

      final attacker = data.lobby.playerById(data.turn.attackerPlayerId);
      final defender = data.lobby.playerById(data.turn.defenderPlayerId);

      if (attacker != null && defender != null) {
        _addLog('${attacker.nickname} ataca!');
        _addLog('${defender.nickname} recibe ${data.turn.damage} de daño (HP: ${data.turn.defenderHpAfter})');

        if (data.turn.defenderDefeated) {
          _lastDefeatedPokemon = defender.nickname;
          _addLog('¡${defender.nickname} fue derrotado!');
        }
      }

      notifyListeners();
    });

    _pokemonDefeatedSub =
        _socketService.pokemonDefeatedStream.listen(((
            {Lobby lobby,
            String playerId,
            int pokemonId,
            String pokemonName}) data) {
      _lobby = data.lobby;
      _lastDefeatedPokemon = data.pokemonName;
      _addLog('¡${data.pokemonName} fue derrotado!');
      notifyListeners();
    });

    _pokemonEnteredSub =
        _socketService.pokemonEnteredStream.listen(((
            {Lobby lobby,
            String playerId,
            int pokemonId,
            String pokemonName}) data) {
      _lobby = data.lobby;
      _lastEnteredPokemon = data.pokemonName;
      _addLog('${data.pokemonName} entra al combate!');
      notifyListeners();
    });

    _battleEndSub =
        _socketService.battleEndStream.listen((({Lobby lobby, String winnerPlayerId}) data) {
      _lobby = data.lobby;
      _isMyTurn = false;
      _inBattle = false;

      final winner = data.lobby.playerById(data.winnerPlayerId);
      if (winner != null) {
        _addLog('¡${winner.nickname} gana la batalla!');
      }

      notifyListeners();
    });

    _errorSub = _socketService.errorStream.listen((String error) {
      _error = error;
      _addLog('Error: $error');
      notifyListeners();
    });
  }

  /// Clear the navigation flag after navigating away.
  void clearNavigationFlag() {
    _shouldReturnToStart = false;
  }

  /// Clear the battle started flag after showing banner.
  void clearBattleStartFlag() {
    _battleJustStarted = false;
  }

  /// Clear the defeated pokemon flag after showing banner.
  void clearDefeatedFlag() {
    _lastDefeatedPokemon = null;
  }

  /// Clear the entered pokemon flag after showing banner.
  void clearEnteredFlag() {
    _lastEnteredPokemon = null;
  }

  /// Mark that the result dialog has been shown.
  void markResultDialogShown() {
    _resultDialogShown = true;
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
    // Format: HH:mm:ss using DateTime fields for clarity
    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    _battleLog.add('[$timestamp] $message');

    // Keep only last 50 messages to avoid memory bloat
    if (_battleLog.length > 50) {
      _battleLog = _battleLog.sublist(_battleLog.length - 50);
    }
  }

  @override
  void dispose() {
    _battleStartSub?.cancel();
    _lobbyStatusSub?.cancel();
    _turnResultSub?.cancel();
    _pokemonDefeatedSub?.cancel();
    _pokemonEnteredSub?.cancel();
    _battleEndSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
