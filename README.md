# Pokemon Stadium Lite - Mobile

A Pokemon battle app built with Flutter. Connect to a battle server, pick a team, and fight in real-time against another player.

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Server URL

On first launch, enter your battle server URL (e.g., `http://192.168.1.100:8080`).

### 3. Run

```bash
flutter run
```

### 4. Build APK

```bash
flutter build apk --debug
```

The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                       # Shared infrastructure
│   ├── services/               # Socket, Audio, API services
│   ├── theme/                   # Colors, typography, spacing
│   └── repositories/             # Data repositories
├── features/                    # Feature modules
│   ├── config/                  # Server URL configuration
│   ├── start/                  # Nickname entry
│   ├── lobby/                  # Lobby and team selection
│   └── battle/                 # Battle screen
└── shared/                     # Shared widgets and models
    ├── widgets/
    │   ├── atoms/              # Basic components (buttons, inputs)
    │   ├── molecules/          # Composed components
    │   └── organisms/          # Complex components
    └── models/                 # Data models
```

## Documentation

- [Flow Diagrams](./docs/01-flows.md) - Main app flows as diagrams
- [Entities](./docs/02-entities.md) - Data models and their relationships
- [Logic](./docs/03-logic.md) - How the app works internally

## Features

- **Real-time battles** via Socket.IO
- **Auto team assignment** - Get 3 random Pokemon on join
- **Turn-based combat** - Attack when it's your turn
- **Live notifications** - Battle events shown as banners
- **Responsive design** - Works on mobile and tablet

## Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **Socket.IO Client** - Real-time communication
- **SharedPreferences** - Local storage

## License

MIT
