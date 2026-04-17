import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/game_theme.dart';
import '../../../../core/widgets/game_bg.dart';
import '../../../../core/widgets/game_card.dart';
import '../providers/battle_providers.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final config = await ref.read(appConfigProvider.future);
    if (config.nickname != null) {
      _controller.text = config.nickname!;
    }
  }

  Future<void> _submit() async {
    final trimmed = _controller.text.trim();
    if (trimmed.length < 2) {
      setState(() => _error = 'El nombre necesita al menos 2 letras.');
      return;
    }
    if (trimmed.length > 16) {
      setState(() => _error = 'Máximo 16 caracteres.');
      return;
    }
    final config = await ref.read(appConfigProvider.future);
    await config.setNickname(trimmed);
    if (mounted) context.go('/lobby');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBg(
        asset: 'assets/bg/pallet_town.png',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Pokémon\nStadium Lite',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bungee(
                      fontSize: 36,
                      color: GameColors.cream,
                      shadows: [
                        const Shadow(offset: Offset(4, 4), color: GameColors.ink),
                        const Shadow(offset: Offset(8, 8), color: GameColors.crimson),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '· Entrenador, bienvenido ·',
                    style: GoogleFonts.bungee(
                      fontSize: 12,
                      color: GameColors.gold,
                      letterSpacing: 3,
                      shadows: [
                        const Shadow(offset: Offset(2, 2), color: GameColors.ink),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  GameCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¿Cuál es tu nombre?',
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          maxLength: 16,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) => setState(() => _error = null),
                          decoration: const InputDecoration(
                            hintText: 'Red, Blue, Eddy...',
                            counterText: '',
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: GameColors.crimson,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submit,
                            child: const Text('IR AL LOBBY'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona Enter para continuar',
                          style: GoogleFonts.fraunces(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: GameColors.goldDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
