import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'core/repositories/pokemon_repository.dart';
import 'core/services/audio_service.dart';
import 'core/services/pokemon_api_service.dart';
import 'core/services/socket_service.dart';
import 'core/theme/app_theme.dart';
import 'features/battle/view/battle_screen.dart';
import 'features/battle/viewmodel/battle_viewmodel.dart';
import 'features/config/view/config_screen.dart';
import 'features/config/viewmodel/config_viewmodel.dart';
import 'features/lobby/view/lobby_screen.dart';
import 'features/lobby/viewmodel/lobby_viewmodel.dart';
import 'features/start/view/start_screen.dart';
import 'features/start/viewmodel/start_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final initialRoute = await _getInitialRoute(prefs);

  runApp(
    PokemonStadiumApp(initialRoute: initialRoute, prefs: prefs),
  );
}

Future<String> _getInitialRoute(SharedPreferences prefs) async {
  final serverUrl = prefs.getString(ApiConstants.keyServerUrl);

  if (serverUrl == null || serverUrl.isEmpty) {
    return '/config';
  }

  final nickname = prefs.getString(ApiConstants.keyNickname);
  if (nickname == null || nickname.isEmpty) {
    return '/start';
  }

  return '/lobby';
}

class PokemonStadiumApp extends StatelessWidget {
  final String initialRoute;
  final SharedPreferences prefs;

  const PokemonStadiumApp({
    super.key,
    required this.initialRoute,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // SharedPreferences
        Provider<SharedPreferences>.value(value: prefs),

        // Services
        Provider<SocketService>(
          create: (_) => SocketService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<AudioService>(
          create: (_) => AudioService(),
          dispose: (_, service) => service.dispose(),
        ),

        // Repositories
        ProxyProvider<SharedPreferences, PokemonRepository>(
          update: (_, prefs, __) {
            final apiService = PokemonApiService(
              baseUrl: prefs.getString(ApiConstants.keyServerUrl) ?? '',
            );
            return PokemonRepository(apiService: apiService);
          },
        ),

        // ViewModels
        ChangeNotifierProvider<ConfigViewModel>(
          create: (ctx) => ConfigViewModel(prefs: ctx.read<SharedPreferences>()),
        ),
        ChangeNotifierProvider<StartViewModel>(
          create: (ctx) => StartViewModel(prefs: ctx.read<SharedPreferences>()),
        ),
        ChangeNotifierProxyProvider2<SharedPreferences, SocketService, LobbyViewModel>(
          create: (ctx) => LobbyViewModel(
            prefs: ctx.read<SharedPreferences>(),
            socketService: ctx.read<SocketService>(),
          ),
          update: (_, prefs, socketService, previous) =>
              previous ??
              LobbyViewModel(
                prefs: prefs,
                socketService: socketService,
              ),
        ),
        ChangeNotifierProvider<BattleViewModel>(
          lazy: false,
          create: (ctx) => BattleViewModel(
            socketService: ctx.read<SocketService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Pokémon Stadium Lite',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        initialRoute: initialRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/config':
        return MaterialPageRoute(
          builder: (_) => ConfigScreen(
            onConnected: () {
              // Navigate to start after config
              _navigatorKey.currentState?.pushReplacementNamed('/start');
            },
          ),
        );

      case '/start':
        return MaterialPageRoute(
          builder: (_) => StartScreen(
            onStart: () {
              // Navigate to lobby after start
              _navigatorKey.currentState?.pushReplacementNamed('/lobby');
            },
          ),
        );

      case '/lobby':
        return MaterialPageRoute(
          builder: (_) => LobbyScreen(
            onBattleStart: () {
              // Navigate to battle when it starts
              _navigatorKey.currentState?.pushReplacementNamed('/battle');
            },
          ),
        );

      case '/battle':
        return MaterialPageRoute(
          builder: (_) => const BattleScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => ConfigScreen(
            onConnected: () {},
          ),
        );
    }
  }
}

// Global navigator key for programmatic navigation
final _navigatorKey = GlobalKey<NavigatorState>();
