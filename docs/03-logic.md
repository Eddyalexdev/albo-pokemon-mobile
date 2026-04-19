# Logic

This document explains how the app works internally.

---

## 1. Socket.IO Communication

### What is Socket.IO?

Socket.IO is a library that enables **real-time, bidirectional** communication between a client (mobile app) and a server.

Think of it like a walkie-talkie:
- You can **send messages** (emit)
- You can **receive messages** (listen)
- The connection stays **open** (unlike HTTP where each request is separate)

### How We Use It

```dart
class SocketService {
  // 1. Create socket connection
  _socket = io.io(serverUrl, options);

  // 2. Set up listeners for incoming events
  _socket!.on('event_name', (data) {
    // Handle incoming data
  });

  // 3. Send events to server
  _socket!.emit('event_name', {'key': 'value'});
}
```

### Event Flow

```
MOBILE APP                           SERVER
    │                                   │
    │──── emit join_lobby ─────────────►│
    │                                   │
    │◄─── ack response ─────────────────│
    │                                   │
    │◄═══ lobby_status ════════════════│ (when state changes)
    │◄═══ battle_start ══════════════════│ (when both ready)
    │◄═══ turn_result ════════════════════│ (after each attack)
    │◄═══ pokemon_defeated ══════════════│ (when Pokemon faints)
    │◄═══ battle_end ══════════════════════│ (when battle finishes)
```

### Our Events

**Client → Server (emit):**
| Event | Payload | Description |
|-------|---------|-------------|
| `join_lobby` | `{nickname: String}` | Enter lobby with name |
| `assign_pokemon` | `{}` | Get random team |
| `ready` | `{}` | Mark ready for battle |
| `attack` | `{}` | Perform attack (your turn) |
| `reset_lobby` | `{}` | Reset lobby state |

**Server → Client (on):**
| Event | Payload | Description |
|-------|---------|-------------|
| `lobby_status` | `Lobby` | Full lobby state sync |
| `battle_start` | `Lobby` | Battle is starting |
| `turn_result` | `{lobby, turn}` | Attack result |
| `pokemon_defeated` | `{lobby, playerId, pokemonId}` | A Pokemon fainted |
| `pokemon_entered` | `{lobby, playerId, pokemonId}` | New Pokemon entered |
| `battle_end` | `{lobby, winnerPlayerId}` | Battle finished |
| `error_event` | `{message: String}` | Error occurred |

---

## 2. Battle Logic

### Turn Order

Turn order is determined by **Speed stat**:
1. When battle starts, server compares Speed of both active Pokemon
2. Higher Speed goes first
3. Turns alternate until one player's team is defeated

### Damage Calculation

The **server** calculates damage (mobile never calculates it):

```dart
damage = attacker.attack - defender.defense

if (damage < 1) {
  damage = 1  // Minimum 1 damage
}

defender.currentHp = defender.currentHp - damage
```

### Battle End Conditions

A battle ends when one of these is true:
- All 3 Pokemon of a player have `currentHp <= 0` or `defeated = true`
- An opponent disconnects

---

## 3. State Management

### Provider + ChangeNotifier Pattern

We use **Provider** for dependency injection and **ChangeNotifier** for state management.

**Components:**

1. **ChangeNotifier** (ViewModels) - Hold state and business logic
2. **Consumer** / **context.watch** - Rebuild UI when state changes
3. **notifyListeners()** - Tell UI to rebuild

### Example: LobbyViewModel

```dart
class LobbyViewModel extends ChangeNotifier {
  Lobby? _lobby;  // Private state

  // Public getter - UI accesses this
  Lobby? get lobby => _lobby;

  // When server sends update, we update and notify
  void onLobbyUpdate(Lobby newLobby) {
    _lobby = newLobby;
    notifyListeners();  // All Consumer<LobbyViewModel> will rebuild
  }
}
```

### In the Widget:

```dart
Consumer<LobbyViewModel>(
  builder: (context, viewModel, child) {
    // This rebuilds whenever notifyListeners() is called
    return Text('Players: ${viewModel.lobby?.players.length}');
  },
)
```

---

## 4. Animation System

### Banner Animation (BattleScreen)

Banners appear from top with a slide + fade animation:

```dart
// 1. AnimationController manages the animation
_bannerController = AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this,  // From TickerProviderStateMixin
);

// 2. Define the animation
_bannerSlide = Tween<Offset>(
  begin: Offset(0, -0.5),  // Start above screen
  end: Offset.zero,        // End at normal position
).animate(CurvedAnimation(
  parent: _bannerController,
  curve: Curves.easeOut,
));

// 3. Play animation
_bannerController.forward();   // Show
_bannerController.reverse(); // Hide
```

### Animation Widget Tree:

```dart
SlideTransition(
  position: _bannerSlide,      // Slide from top
  child: FadeTransition(
    opacity: _bannerOpacity,   // Fade in/out
    child: _buildBanner(message),
  ),
)
```

---

## 5. Responsive Design

### LayoutBuilder for Responsive Layout

`LayoutBuilder` gives us the available width to make decisions:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    final isCompact = width < 380;  // Mobile breakpoint

    return Row(
      children: [
        Expanded(
          child: PokemonTile(
            compact: isCompact,  // Compact on mobile
          ),
        ),
      ],
    );
  },
)
```

### Breakpoints Used:

| Width | Mode | PokemonTile | TrainerCard |
|-------|------|------------|------------|
| < 380px | Mobile | Compact (sprite + name) | Smaller header |
| >= 380px | Tablet | Full (sprite + types + stats) | Full header |

---

## 6. Pokemon Detail Modal

On mobile, tapping a Pokemon shows a modal with full details:

```dart
// In PokemonTile compact mode:
GestureDetector(
  onTap: () => showDetailModal(context, pokemon),
  child: ...
)

// The modal method:
static void showDetailModal(BuildContext context, PokemonDetail pokemon) {
  showDialog(
    context: context,
    builder: (context) => _PokemonDetailDialog(pokemon: pokemon),
  );
}
```

---

## 7. Error Handling

### Socket Connection Errors

```dart
Future<void> connect(String baseUrl) async {
  final completer = Completer<void>();

  _socket!.onConnectError((err) {
    completer.completeError(Exception(err.toString()));
  });

  // Timeout after 10 seconds
  return completer.future.timeout(
    Duration(seconds: 10),
    onTimeout: () {
      completer.completeError(
        Exception('Connection timeout - check server URL'),
      );
    },
  );
}
```

### UI Error Display

Errors are stored in ViewModel and displayed in UI:

```dart
// ViewModel
_errorSub = _socketService.errorStream.listen((error) {
  _error = error;
  _addLog('Error: $error');
  notifyListeners();
});

// UI
if (viewModel.error != null)
  Text(viewModel.error!, style: TextStyle(color: Colors.red))
```

---

## 8. Navigation

### How Navigation Works

```dart
// main.dart defines routes
MaterialApp(
  routes: {
    '/config': (context) => ConfigScreen(...),
    '/start': (context) => StartScreen(...),
    '/lobby': (context) => LobbyScreen(...),
    '/battle': (context) => BattleScreen(...),
  },
)

// Navigate forward
Navigator.of(context).pushReplacementNamed('/next');

// Navigate back
Navigator.of(context).pop();
```

### Battle Navigation Triggers

1. **Battle starts** → LobbyViewModel calls `onBattleStartEvent` → App navigates to `/battle`
2. **Battle ends** → User taps "VOLVER AL INICIO" → Navigates to `/start`
3. **Opponent disconnects** → BattleViewModel sets `shouldReturnToStart` → Auto-navigates to `/start`

---

## 9. Audio System

Simple crossfade between background and battle music:

```dart
class AudioService {
  AudioPlayer _bgMusicPlayer = AudioPlayer();
  AudioPlayer _battleMusicPlayer = AudioPlayer();

  void crossfadeToBattle() {
    // Lower bg, raise battle music over 500ms
    _bgMusicPlayer.setVolume(0);
    _battleMusicPlayer.setVolume(1);
  }

  void crossfadeToBg() {
    // Lower battle, raise bg music
    _battleMusicPlayer.setVolume(0);
    _bgMusicPlayer.setVolume(1);
  }
}
```

---

## 10. Key Design Decisions

### Why StreamControllers?

We use `StreamController` to convert Socket.IO events into Dart Streams:

```dart
// Socket event
_socket!.on('battle_start', (data) {
  _battleStartController.add(Lobby.fromJson(data));
});

// UI listens to stream
_battleStartController.stream.listen((lobby) {
  // Handle battle start
});
```

### Why Named Constructors in Records?

```dart
StreamSubscription<({Lobby lobby, TurnRecord turn})>
```

This is a **record type** with named fields. It makes the code self-documenting:

```dart
// Without names (confusing)
data.lobby  // What is this?
data.turn   // What turn?

// With names (clear)
data.lobby      // The lobby state
data.turn       // The turn record
```

### Why Equatable?

`Equatable` makes value comparison easy:

```dart
class Pokemon extends Equatable {
  final String name;
  final int hp;

  @override
  List<Object?> get props => [name, hp];  // Used for equality
}

// Now you can compare:
pokemon1 == pokemon2  // Compares props automatically
```
