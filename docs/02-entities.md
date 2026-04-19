# Entities

This document describes all data models (entities) in the app and how they relate to each other.

---

## Entity Hierarchy

```
Equatable (base class)
    │
    ├── PokemonSummary
    │       │
    │       └── PokemonDetail
    │               │
    │               └── BattlePokemon
    │
    ├── Player
    │
    ├── Lobby
    │
    └── TurnRecord
```

---

## 1. PokemonSummary

The simplest Pokemon data - used for lists and catalogs.

```dart
class PokemonSummary extends Equatable {
  final String id;           // "1", "25" (Pokédex number as string)
  final String name;          // "Pikachu"
  final String sprite;       // URL to sprite image
  final List<PokemonType> types;  // [electric]
}
```

**Used for:**
- Pokemon catalog list from API
- Brief displays

---

## 2. PokemonDetail

Extends `PokemonSummary` with battle stats.

```dart
class PokemonDetail extends PokemonSummary {
  final int maxHp;    // 100 - Maximum HP
  final int attack;    // 55  - Attack stat
  final int defense;   // 40  - Defense stat
  final int speed;    // 90  - Speed stat (determines turn order)
}
```

**Used for:**
- Full Pokemon display with stats
- Team assignment display

---

## 3. BattlePokemon

Extends `PokemonDetail` with real-time battle state.

```dart
class BattlePokemon extends PokemonDetail {
  final int currentHp;   // 65 - Current HP (changes during battle)
  final bool defeated;  // false - True when Pokemon faints
}

// Helper getters:
BattlePokemon.hpPercent  // 0.65 (currentHp / maxHp as 0.0 to 1.0)
BattlePokemon.isFainted  // true if defeated OR currentHp <= 0
```

**Used for:**
- Player's team in lobby
- Active battle state

---

## 4. Player

A participant in the battle.

```dart
class Player extends Equatable {
  final String id;           // Server-assigned unique ID
  final String nickname;     // "Ash", "Misty"
  final List<BattlePokemon> team;  // 3 Pokemon
  final bool ready;          // True when player taps "LISTO"
  final int activeIndex;     // 0, 1, or 2 (index of active Pokemon)

// Helpers:
Player.activePokemon         // team[activeIndex] - the Pokemon currently fighting
Player.aliveCount           // team.where((p) => !p.isFainted).length
```

**Relationships:**
- `Player.team` contains 3 `BattlePokemon` instances
- `Player.activePokemon` is the current fighter

---

## 5. Lobby

The battle room containing both players.

```dart
enum LobbyStatus {
  waiting,   // Waiting for players to be ready
  ready,    // Both players ready (brief state before battle)
  battling, // Battle in progress
  finished, // Battle ended
}

class Lobby extends Equatable {
  final String id;                      // "lobby-abc123"
  final LobbyStatus status;             // Current state
  final List<Player> players;           // Always 2 players
  final String? currentTurnPlayerId;   // ID of player whose turn it is
  final String? winnerPlayerId;         // ID of winner (null until finished)

// Helpers:
Lobby.playerById(id)          // Get player by ID
Lobby.opponentOf(playerId)   // Get other player
```

**Lobby Status Flow:**

```
waiting ───(both ready)───► ready ───(auto)───► battling ───(all defeated)───► finished
   │                                                                      │
   │◄──────────────────(opponent leaves)────────────────────────────────┘
```

---

## 6. TurnRecord

Record of a single attack action.

```dart
class TurnRecord extends Equatable {
  final int turnNumber;           // 1, 2, 3... (attack count)
  final String attackerPlayerId;  // Who attacked
  final String defenderPlayerId;  // Who was attacked
  final int damage;              // Damage dealt
  final int defenderHpAfter;      // HP remaining after damage
  final bool defenderDefeated;   // True if defender's Pokemon fainted
}
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         EXTERNAL API                                 │
│                    (Pokemon Catalog)                                 │
│                                                                      │
│  GET /list ──► List<PokemonSummary>                                │
│  GET /list?id=1 ──► PokemonDetail                                   │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ (via PokemonApiService)
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         SERVER                                       │
│                                                                      │
│  Player joins ──► Server creates Player with empty team            │
│  assign_pokemon ──► Server picks 3 random Pokemon                   │
│                    ──► Server creates BattlePokemon for each         │
│                    ──► Sets currentHp = maxHp, defeated = false     │
│                                                                      │
│  During battle:                                                     │
│  attack ──► Server calculates damage                                │
│         ──► Updates currentHp                                       │
│         ──► If HP <= 0, sets defeated = true                       │
│         ──► If all team defeated, sets winnerPlayerId              │
│                                                                      │
│  Events emitted:                                                   │
│  - lobby_status (sync)                                             │
│  - battle_start                                                     │
│  - turn_result (damage, HP after)                                  │
│  - pokemon_defeated                                                 │
│  - pokemon_entered                                                  │
│  - battle_end (winner)                                             │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ (via Socket.IO)
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        MOBILE APP                                   │
│                                                                      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐        │
│  │   Lobby     │     │   Battle    │     │  Pokemon    │        │
│  │  ViewModel  │     │  ViewModel  │     │   Tile     │        │
│  │             │     │             │     │             │        │
│  │  _lobby ────┼────►│  _lobby ────┼────►│  pokemon    │        │
│  │  _players ──┼────►│  _players ──┼────►│  (detail)   │        │
│  │             │     │             │     │             │        │
│  │             │     │             │     │  currentHp │        │
│  │             │     │             │     │  maxHp      │        │
│  │             │     │             │     │  defeated   │        │
│  └─────────────┘     └─────────────┘     └─────────────┘        │
│         │                   │                                       │
│         ▼                   ▼                                       │
│  ┌─────────────┐     ┌─────────────┐                              │
│  │TrainerCard │     │ BattleField │                              │
│  │(shows team)│     │(shows both  │                              │
│  │            │     │ players)     │                              │
│  └─────────────┘     └─────────────┘                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## JSON Mapping

The app uses `fromJson` factory constructors to convert server JSON to Dart objects.

### PokemonSummary.fromJson
```json
{
  "id": "25",
  "name": "Pikachu",
  "sprite": "https://raw.githubusercontent.com/...",
  "types": ["electric"]
}
```

### BattlePokemon.fromJson (from server)
```json
{
  "id": "25",
  "name": "Pikachu",
  "sprite": "https://raw.githubusercontent.com/...",
  "type": ["electric"],
  "maxHp": 100,
  "hp": 65,
  "attack": 55,
  "defense": 40,
  "speed": 90,
  "defeated": false
}
```

### Lobby.fromJson
```json
{
  "id": "lobby-abc123",
  "status": "battling",
  "players": [
    { "id": "p1", "nickname": "Ash", "team": [...], "ready": true },
    { "id": "p2", "nickname": "Misty", "team": [...], "ready": true }
  ],
  "currentTurnPlayerId": "p1",
  "winnerPlayerId": null
}
```

---

## SharedPreferences Storage

Key-value local storage for app settings.

| Key | Type | Description |
|-----|------|-------------|
| `server_url` | String | Battle server URL |
| `nickname` | String | Player nickname |

```dart
// Reading
final prefs = context.read<SharedPreferences>();
final url = prefs.getString('server_url');
final nick = prefs.getString('nickname');

// Writing
await prefs.setString('server_url', url);
await prefs.setString('nickname', nick);
```
