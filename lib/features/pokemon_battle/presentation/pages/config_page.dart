import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/game_theme.dart';
import '../../../../core/widgets/game_bg.dart';
import '../../../../core/widgets/game_card.dart';
import '../providers/battle_providers.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  final _controller = TextEditingController(text: 'http://192.168.1.100:8080');

  Future<void> _save() async {
    final url = _controller.text.trim().replaceAll(RegExp(r'/+$'), '');
    if (!url.startsWith('http')) return;
    final config = await ref.read(appConfigProvider.future);
    await config.setBaseUrl(url);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBg(
        asset: 'assets/bg/cerulean_city.png',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GameCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pokémon Stadium Lite',
                      style: GoogleFonts.bungee(
                        fontSize: 20,
                        color: GameColors.crimson,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            color: GameColors.gold.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Conectar al servidor',
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ingresá la URL del backend para empezar',
                      style: GoogleFonts.fraunces(
                        fontSize: 14,
                        color: GameColors.goldDeep,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GameColors.creamSoft,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GameColors.ink),
                      ),
                      child: Text(
                        'http://192.168.X.X:8080',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: GameColors.goldDeep,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.url,
                      onSubmitted: (_) => _save(),
                      decoration: const InputDecoration(
                        hintText: 'http://192.168.X.X:8080',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('GUARDAR Y CONTINUAR'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
