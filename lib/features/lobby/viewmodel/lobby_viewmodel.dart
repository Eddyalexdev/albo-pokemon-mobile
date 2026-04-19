import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/models/lobby_state.dart';
import '../../../shared/models/player.dart';
import '../../../shared/models/pokemon.dart';

/// ViewModel for LobbyScreen - manages lobby state and team selection.
class LobbyViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  final SocketService _socketService;

  Lobby? _lobby;
  String? _playerId;
  String? _error;
  bool _isConnected = false;
  bool _isJoined = false;
  bool _isLoadingTeam = false;
  List<PokemonDetail> _team = [];
  List<String> _logMessages = [];
  StreamSubscription<Lobby>? _lobbyStatusSub;
  StreamSubscription<Lobby>? _battleStartSub;
  StreamSubscription<String>? _errorSub;

  /// Callback triggered when battle should start
  VoidCallback? onBattleStartEvent;

  /// Callback triggered when user wants to change nickname
  VoidCallback? onNicknameChange;

  LobbyViewModel({
    required SharedPreferences prefs,
    required SocketService socketService,
  })  : _prefs = prefs,
        _socketService = socketService;

  Lobby? get lobby => _lobby;
  String? get playerId => _playerId;
  String? get error => _error;
  bool get isConnected => _isConnected;
  bool get isJoined => _isJoined;
  bool get isLoadingTeam => _isLoadingTeam;
  List<PokemonDetail> get team => _team;
  List<String> get logMessages => _logMessages;

  Player? get currentPlayer => _lobby?.playerById(_playerId ?? '');
  Player? get opponent => _lobby?.opponentOf(_playerId ?? '');
  bool get canAssignTeam {
    // Can assign if: joined lobby AND not loading AND (no team yet OR team exists but is empty)
    if (!_isJoined || _isLoadingTeam) return false;
    // If currentPlayer is null, lobby status hasn't arrived yet - allow anyway
    if (currentPlayer == null) return true;
    return currentPlayer!.team.isEmpty;
  }
  bool get canReady => currentPlayer != null && currentPlayer!.team.isNotEmpty && !currentPlayer!.ready;
  bool get isReady => currentPlayer?.ready ?? false;
  bool get battleStarted => _lobby?.status == LobbyStatus.battling;

  String? get nickname => _prefs.getString(ApiConstants.keyNickname);
  String? get serverUrl => _prefs.getString(ApiConstants.keyServerUrl);

  /// Initialize the lobby - connect socket and join.
  Future<void> initialize() async {
    final url = serverUrl;
    final nick = nickname;

    if (url == null || nick == null) {
      _error = 'Missing configuration';
      _addLog('Error: Falta URL o nickname');
      notifyListeners();
      return;
    }

    _addLog('Conectando a $url...');
    _setupListeners();

    try {
      await _socketService.connect(url);
      _isConnected = true;
      _addLog('Conectado! Uniéndote al lobby...');

      final result = await _socketService.joinLobby(nick);
      _playerId = result.playerId;
      _isJoined = true;
      _addLog('Te uniste al lobby como $nick (ID: $_playerId)');

      // Auto-assign team on join
      await assignTeam();

      notifyListeners();
    } catch (e) {
      _error = 'Error al conectar: $e';
      _addLog('Error: $_error');
      notifyListeners();
    }
  }

  void _setupListeners() {
    _lobbyStatusSub = _socketService.lobbyStatusStream.listen((lobby) {
      _lobby = lobby;
      _addLog(_describeLobbyUpdate(lobby));
      notifyListeners();
    });

    _battleStartSub = _socketService.battleStartStream.listen((lobby) {
      _lobby = lobby;
      _addLog('¡La batalla está por comenzar!');
      notifyListeners();
      // Trigger navigation callback
      onBattleStartEvent?.call();
    });

    _errorSub = _socketService.errorStream.listen((error) {
      _error = error;
      _addLog('Error: $error');
      notifyListeners();
    });
  }

  String _describeLobbyUpdate(Lobby lobby) {
    final playerCount = lobby.players.length;
    final readyCount = lobby.players.where((p) => p.ready).length;

    if (playerCount == 1) {
      return 'Esperando oponente...';
    } else if (readyCount < playerCount) {
      return '$readyCount/$playerCount jugadores listos';
    } else {
      return '¡Todos listos!';
    }
  }

  /// Request random team assignment.
  Future<void> assignTeam() async {
    if (_isLoadingTeam) return;

    _isLoadingTeam = true;
    _error = null;
    notifyListeners();

    try {
      await _socketService.assignPokemon();
      _addLog('Equipo randomizado');
    } catch (e) {
      _error = 'Error al asignar equipo: $e';
      _addLog('Error: $_error');
    } finally {
      _isLoadingTeam = false;
      notifyListeners();
    }
  }

  /// Mark player as ready.
  Future<void> ready() async {
    if (_playerId == null) {
      _error = 'No estás en el lobby';
      notifyListeners();
      return;
    }

    if (currentPlayer == null) {
      _error = 'Datos del jugador no encontrados';
      notifyListeners();
      return;
    }

    if (currentPlayer!.team.isEmpty) {
      _error = 'Primero necesitás un equipo';
      notifyListeners();
      return;
    }

    if (currentPlayer!.ready) {
      _error = 'Ya estás listo';
      notifyListeners();
      return;
    }

    try {
      await _socketService.ready();
      _addLog('Listo enviado al servidor');
    } catch (e) {
      _error = 'Error al marcar listo: $e';
      _addLog('Error: $_error');
      notifyListeners();
    }
  }

  /// Reset the lobby.
  Future<void> resetLobby() async {
    try {
      await _socketService.resetLobby();
      _lobby = null;
      _team = [];
      _addLog('Lobby reiniciado');
      notifyListeners();
    } catch (e) {
      _error = 'Error al reiniciar: $e';
      notifyListeners();
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now();
    _logMessages.add('[$timestamp] $message');

    // Keep only last 50 messages
    if (_logMessages.length > 50) {
      _logMessages = _logMessages.sublist(_logMessages.length - 50);
    }
  }

  @override
  void dispose() {
    _lobbyStatusSub?.cancel();
    _battleStartSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
