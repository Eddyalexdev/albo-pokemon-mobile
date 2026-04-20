# Flow Diagrams

This document shows the main flows of the app using text-based diagrams.

---

## 1. App Launch Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        APP LAUNCH                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Has saved URL?  │
                    └─────────────────┘
                      │           │
                     YES          NO
                      │           │
                      ▼           ▼
            ┌─────────────┐  ┌─────────────────┐
            │ Go to       │  │ Show ConfigScreen│
            │ StartScreen │  │ (enter server    │
            └─────────────┘  │  URL)            │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │ URL Saved in    │
                              │ SharedPrefs     │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │ Go to StartScreen│
                              │ (enter nickname) │
                              └─────────────────┘
```

---

## 2. Nickname Entry Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      NICKNAME ENTRY                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Show StartScreen│
                    │ + Load saved    │
                    │   nickname      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ User enters     │
                    │ nickname        │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Tap "EMPEZAR"  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Save nickname   │
                    │ to SharedPrefs  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Navigate to     │
                    │ LobbyScreen     │
                    └─────────────────┘
```

---

## 3. Lobby Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         LOBBY                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Connect to      │
                    │ server via      │
                    │ Socket.IO       │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Join lobby with │
                    │ nickname        │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Auto-assign    │◄─────────┐
                    │ 3 random        │          │
                    │ Pokemon         │          │
                    └────────┬────────┘          │
                             │                   │
                             ▼                   │
                    ┌─────────────────┐          │
                    │ Show Pokemon    │          │
                    │ in TrainerCard  │          │
                    └────────┬────────┘          │
                             │                   │
                             ▼                   │
                    ┌─────────────────┐          │
         ┌─────────│ Wait for        │          │
         │         │ another player  │──────────┘
         │         └────────┬────────┘   (loop until 2 players)
         │                  │
         │                  ▼
         │         ┌─────────────────┐
         │         │ Both tap        │
         │         │ "LISTO"         │
         │         └────────┬────────┘
         │                  │
         │                  ▼
         │         ┌─────────────────┐
         │         │ Server sends    │
         │         │ battle_start     │
         │         └────────┬────────┘
         │                  │
         │                  ▼
         │         ┌─────────────────┐
         │         │ Navigate to     │
         │         │ BattleScreen     │
         │         └─────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ IF OPPONENT DISCONNECTS:                                  │
│ - Server sends lobby_status with status=waiting            │
│ - ViewModel detects _inBattle + waiting                    │
│ - ShouldReturnToStart = true                              │
│ - BattleScreen navigates to StartScreen                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Battle Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         BATTLE                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Show banner:    │
                    │ "¡La batalla   │
                    │ comenzó!"       │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Header shows:   │
                    │ "YOUR TURN" or  │
                    │ "ENEMY TURN"    │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                                 │
              ▼                                 ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ IS YOUR TURN   │             │ IS ENEMY TURN   │
    │                │             │                 │
    └───────┬───────┘             └────────┬────────┘
            │                               │
            ▼                               │
    ┌─────────────────┐                     │
    │ "ATACAR" button│                    │
    │ ENABLED        │                     │
    └───────┬───────┘                     │
            │                               │
            ▼                               │
    ┌─────────────────┐                     │
    │ User taps       │                     │
    │ "ATACAR"        │                     │
    └───────┬───────┘                     │
            │                               │
            ▼                               │
    ┌─────────────────┐                     │
    │ Send attack()   │                     │
    │ to server       │                     │
    └───────┬───────┘                     │
            │                               │
            ▼                               ▼
    ┌─────────────────────────────────────────┐
    │            SERVER PROCESSES:             │
    │ 1. Calculate damage                     │
    │    damage = attacker.attack - defender.defense │
    │    if damage < 1, damage = 1            │
    │ 2. Update defender HP                    │
    │    defender.currentHp -= damage          │
    │ 3. If HP <= 0, mark defeated           │
    │ 4. If all defeated, emit battle_end     │
    │ 5. Emit turn_result                     │
    │ 6. Emit pokemon_defeated/pokemon_entered│
    │    (if applicable)                     │
    └─────────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │ Receive events   │
            │ via Streams     │
            └────────┬────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌─────────────────┐     ┌─────────────────┐
│ SHOW BANNER:    │     │ SHOW BANNER:    │
│ "X recibe Y de  │     │ "¡X fue        │
│  daño (HP: Z)"  │     │  derrotado!"    │
└─────────────────┘     └─────────────────┘
        │
        ▼
┌─────────────────┐
│ SHOW BANNER:   │
│ "¡X entra al   │
│  combate!"     │
│ (if applicable) │
└─────────────────┘
        │
        ▼
    ┌─────────────────┐
    │ Update BattleField│
    │ (HP bars, sprites)│
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Check: all      │
    │ pokemons of one  │
    │ player defeated? │
    └────────┬────────┘
             │
     ┌───────┴───────┐
     │               │
    YES              NO
     │               │
     ▼               ▼
┌─────────────────┐   ┌─────────────────┐
│ Show result    │   │ Switch turn to  │
│ dialog:        │   │ other player    │
│ "¡Ganaste!" or │   │ and repeat      │
│ "¡Perdiste!"    │   └────────┬────────┘
└────────┬────────┘            │
         │                    │
         ▼                    │
┌─────────────────┐            │
│ User taps       │            │
│ "VOLVER AL     │            │
│  INICIO"        │            │
└────────┬────────┘            │
         │                    │
         ▼                    │
┌─────────────────┐            │
│ Navigate to     │            │
│ StartScreen     │────────────┘
└─────────────────┘
```

---

## 5. Navigation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     SCREEN NAVIGATION                         │
└─────────────────────────────────────────────────────────────┘

  /config ──────────────► /start ──────────────► /lobby ──────────────► /battle
     │                        │                        │                       │
     │                        │                        │                       │
     ▼                        ▼                        ▼                       ▼
┌──────────┐            ┌──────────┐            ┌──────────┐            ┌──────────┐
│ Config   │            │ Start    │            │ Lobby    │            │ Battle   │
│ Screen   │            │ Screen   │            │ Screen   │            │ Screen   │
│          │            │          │            │          │            │          │
│ - Enter  │            │ - Enter  │            │ - Shows  │            │ - Shows  │
│   server │            │   nick-  │            │   both   │            │   battle│
│   URL    │            │   name   │            │   players│            │   arena │
│ - Save   │───────────►│ - Save   │───────────►│ - Teams  │───────────►│ - Attack│
│          │            │          │            │ - Status │            │   button│
│          │            │          │            │          │            │          │
│          │            │          │            │          │            │ - Result │
│          │            │          │            │          │            │   dialog │
│          │            │          │            │          │            │          │
│          │            │          │            │          │            │ - Back   │
│          │            │          │            │          │            │   button │
└──────────┘            └──────────┘            └──────────┘            └──────────┘

Also:
  /battle ───(opponent disconnects)───► /start
  /battle ───(battle ends + tap button)───► /start
```

---

## 6. Data Flow (Socket.IO)

```
┌──────────────────────────────────────────────────────────────────────┐
│                          DATA FLOW                                    │
└──────────────────────────────────────────────────────────────────────┘

    MOBILE APP                           SERVER
    ┌──────────┐                      ┌──────────────┐
    │          │                      │              │
    │  Socket  │◄───── HTTP ────────►│  REST API   │
    │ Service  │                      │  (catalog)   │
    │          │◄──── WEBSOCKET ────►│              │
    │          │                      │              │
    └────┬─────┘                      └──────┬───────┘
         │                                    │
         │  emit join_lobby                  │
         │ ─────────────────────────────────►
         │                                    │
         │  emit assign_pokemon               │
         │ ─────────────────────────────────►
         │                                    │
         │  emit ready                        │
         │ ─────────────────────────────────►
         │                                    │
         │  ◄══ lobby_status                 │
         │  ◄══ battle_start                 │
         │  ◄══ turn_result                  │
         │  ◄══ pokemon_defeated             │
         │  ◄══ pokemon_entered              │
         │  ◄══ battle_end                   │
         │                                    │
         │  emit attack                       │
         │ ─────────────────────────────────►
         │                                    │
         └──────────┐                      ┌───┘
                    │                      │
                    ▼                      ▼
            ┌────────────────┐    ┌────────────────┐
            │  ViewModel      │    │  Process       │
            │  listens to     │    │  attack        │
            │  Streams       │    │  atomically    │
            │                │    │                │
            │  notifies ────►│    │  update HP    │
            │                │    │  check defeat  │
            │                │    │  emit events   │
            └────────────────┘    └────────────────┘
```

---

## 7. State Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                         MAIN.DART                           │
│  MultiProvider / ProxyProvider                             │
│  ├── ConfigViewModel                                       │
│  ├── StartViewModel                                        │
│  ├── LobbyViewModel                                        │
│  ├── BattleViewModel                                       │
│  └── SocketService (shared across ViewModels)              │
└──────────────────────┬────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      SCREEN                                 │
│                                                             │
│  Consumer<LobbyViewModel>(                                  │
│    builder: (context, viewModel, _) {                      │
│      // Widget rebuilds when notifyListeners() is called     │
│    },                                                      │
│  )                                                         │
└──────────────────────┬────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    VIEWMODEL                                │
│                                                             │
│  class LobbyViewModel extends ChangeNotifier {               │
│    Lobby? _lobby;                                          │
│                                                             │
│    // Public getter - triggers rebuild when accessed         │
│    Lobby? get lobby => _lobby;                             │
│                                                             │
│    // Private setter - calls notifyListeners()              │
│    void _updateLobby(Lobby newLobby) {                    │
│      _lobby = newLobby;                                    │
│      notifyListeners(); // <-- Rebuilds all Consumers     │
│    }                                                       │
│  }                                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Testing Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      TESTING                                 │
└─────────────────────────────────────────────────────────────┘

                    ┌─────────────────┐
                    │  flutter test   │
                    └────────┬────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   TEST STRUCTURE                           │
│                                                             │
│  test/                                                      │
│  ├── mocks/                    # MockSocketService          │
│  │   └── mock_socket_service.dart                          │
│  ├── models/                  # Pure Dart model tests       │
│  │   ├── pokemon_test.dart                                 │
│  │   ├── player_test.dart                                 │
│  │   └── lobby_state_test.dart                            │
│  └── viewmodels/             # ViewModel tests with mocks  │
│      ├── start_viewmodel_test.dart                        │
│      ├── config_viewmodel_test.dart                       │
│      ├── lobby_viewmodel_test.dart                        │
│      └── battle_viewmodel_test.dart                       │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   MOCKING STRATEGY                          │
│                                                             │
│  ISocketService (interface)                                 │
│      │                                                      │
│      └──► SocketService (real) ──► MockSocketService (test)│
│                                                             │
│  MockSocketService provides:                                │
│  • Controllable streams (emitBattleStart, emitError, etc.) │
│  • Call tracking (callLog)                                   │
│  • Configurable success/failure                             │
│  • Join lobby simulation (_currentPlayerId)                 │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                 CI/CD GATES                                 │
│                                                             │
│  lint.yml:                                                  │
│    • flutter analyze ──► MUST PASS                         │
│    • flutter test ────► MUST PASS                           │
│                                                             │
│  release.yml (on tag v*):                                   │
│    • quality-checks (analyze + test) ──► MUST PASS          │
│    • build (flutter build apk)                              │
│    • release (GitHub Release)                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. Key Testing Patterns

```
┌─────────────────────────────────────────────────────────────┐
│            STREAM-BASED TESTING PATTERN                     │
│                                                             │
│  Problem: Stream subscriptions are async — test assertions │
│           run before the stream handler executes.            │
│                                                             │
│  Solution:                                                   │
│  1. Emit event via mock                                     │
│  2. await Future.delayed(Duration(milliseconds: 16))        │
│  3. THEN assert state                                        │
│                                                             │
│  Example:                                                    │
│  ```dart                                                    │
│  mockSocket.emitBattleStart(lobby);                          │
│  await Future.delayed(Duration(milliseconds: 16));          │
│  expect(viewModel.battleLog, isNotEmpty);                    │
│  ```                                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           MOCK SOCKET STATE PATTERN                         │
│                                                             │
│  BattleViewModel reads _socketService.currentPlayerId        │
│  on battle_start. Mock must simulate joinLobby first:        │
│                                                             │
│  ```dart                                                    │
│  mockSocket.joinLobbyPlayerId = 'player-1';                 │
│  await mockSocket.joinLobby('TestPlayer'); // Sets internal │
│  mockSocket.emitBattleStart(lobby);                         │
│  await Future.delayed(Duration(milliseconds: 16));          │
│  ```                                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           LOBBY STATE INJECTION PATTERN                     │
│                                                             │
│  To test LobbyViewModel.ready() with no team:               │
│  1. initialize(autoAssign: false)                           │
│  2. Emit lobby_status with player who has empty team         │
│  3. await Future.delayed(Duration(milliseconds: 16))        │
│  4. Call ready() and assert error message                   │
└─────────────────────────────────────────────────────────────┘
```
