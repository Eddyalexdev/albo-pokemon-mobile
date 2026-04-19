# albo pokemon app mobile by Eddy

[![Lint](https://github.com/Eddyalexdev/albo-pokemon-mobile/actions/workflows/lint.yml/badge.svg)](https://github.com/Eddyalexdev/albo-pokemon-mobile/actions/workflows/lint.yml)

![App Screenshot](assets/screenshot.png)

Flutter app with Riverpod + socket_io_client following **Clean Architecture**.

## Layers

```
lib/
├── core/
│   └── config/           # AppConfig — persists backend base URL with SharedPreferences
└── features/pokemon_battle/
    ├── domain/           # Pure entities + repository ports (BattleGateway)
    ├── data/             # SocketBattleGateway adapter + JSON mappers
    └── presentation/     # Riverpod providers, pages (config, lobby, battle)
```

## Setup

```bash
flutter pub get
flutter run
```

On first launch the app asks for the backend base URL and stores it via
`shared_preferences`. Change it by clearing app storage or navigating back to `/config`.

## Build APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Note

`flutter create .` has NOT been run in this scaffold, so the platform folders
(`android/`, `ios/`) are absent. Run:

```bash
flutter create . --org com.albo.pokemon --project-name pokemon_stadium_mobile
```

inside `mobile/` to generate them without overwriting `lib/` or `pubspec.yaml`.
