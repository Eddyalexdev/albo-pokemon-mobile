import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../../shared/widgets/molecules/pokeball_indicator.dart';
import '../../../shared/widgets/organisms/battle_field.dart';
import '../../../shared/widgets/organisms/battle_log.dart';
import '../viewmodel/battle_viewmodel.dart';

/// Battle screen - real-time battle arena.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();

  // Banner state
  String? _bannerMessage;
  bool _showBanner = false;
  late AnimationController _bannerController;
  late Animation<double> _bannerOpacity;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.crossfadeToBattle();
    });

    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bannerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeIn),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _audioService.crossfadeToBg();
    _bannerController.dispose();
    super.dispose();
  }

  void _navigateToStart() {
    Navigator.of(context).pushReplacementNamed('/start');
  }

  void _showTransientBanner(String message, {Duration duration = const Duration(seconds: 3)}) {
    setState(() {
      _bannerMessage = message;
      _showBanner = true;
    });
    _bannerController.forward();
    Future.delayed(duration, () {
      if (mounted) {
        _bannerController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showBanner = false;
              _bannerMessage = null;
            });
          }
        });
      }
    });
  }

  void _showBattleResult(bool isVictory, String winnerName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BattleResultDialog(
        isVictory: isVictory,
        message: '$winnerName gana la batalla!',
        onDismiss: () {
          Navigator.of(context).pop();
          _navigateToStart();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BattleViewModel>(
        builder: (context, viewModel, _) {
          // Handle opponent disconnect - navigate to start
          if (viewModel.shouldReturnToStart) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToStart();
              viewModel.clearNavigationFlag();
            });
          }

          // Show battle start banner
          if (viewModel.battleJustStarted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTransientBanner('¡La batalla comenzó!');
              viewModel.clearBattleStartFlag();
            });
          }

          // Show pokemon defeated banner
          if (viewModel.lastDefeatedPokemon != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTransientBanner('¡${viewModel.lastDefeatedPokemon} fue derrotado!');
              viewModel.clearDefeatedFlag();
            });
          }

          // Show result dialog when battle ends (only once via flag in viewModel)
          if (viewModel.battleEnded && viewModel.winnerId != null && !viewModel.resultDialogShown) {
            final isVictory = viewModel.winnerId == viewModel.playerId;
            final winner = isVictory ? viewModel.currentPlayer : viewModel.opponent;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showBattleResult(isVictory, winner?.nickname ?? 'Jugador');
              viewModel.markResultDialogShown();
            });
          }

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.55, 1.0],
                    colors: [
                      Color(0xFF87CEEB), // sky
                      Color(0xFFB5D9A4), // light grass
                      Color(0xFF8FB87A), // deeper grass
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    child: Column(
                      children: [
                        _buildHeader(viewModel),
                        const SizedBox(height: DesignSpacing.lg),
                        _buildBattleArea(viewModel),
                        const SizedBox(height: DesignSpacing.md),
                        _buildTeamStatus(viewModel),
                        const SizedBox(height: DesignSpacing.md),
                        _buildActions(viewModel),
                        const SizedBox(height: DesignSpacing.md),
                        Expanded(child: BattleLog(events: viewModel.battleLog)),
                      ],
                    ),
                  ),
                ),
              ),
              // Transient banner overlay
              if (_showBanner && _bannerMessage != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _bannerSlide,
                    child: FadeTransition(
                      opacity: _bannerOpacity,
                      child: _buildBanner(_bannerMessage!),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: DesignSpacing.md,
        horizontal: DesignSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: DesignColors.ink.withValues(alpha: 0.85),
        border: Border.all(color: DesignColors.ink, width: 3),
      ),
      child: Text(
        message,
        style: DesignTypography.labelMedium.copyWith(
          color: DesignColors.cream,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeader(BattleViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'BATTLE',
          style: DesignTypography.displayMedium.copyWith(
            color: DesignColors.cream,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                color: DesignColors.ink.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        if (viewModel.battleEnded)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DesignColors.gold,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.ink, width: 2),
            ),
            child: Text(
              'FINISHED',
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.ink,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: viewModel.isMyTurn ? DesignColors.forest : DesignColors.crimson,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.ink, width: 2),
            ),
            child: Text(
              viewModel.isMyTurn ? 'YOUR TURN' : 'ENEMY TURN',
              style: DesignTypography.labelSmall.copyWith(
                color: DesignColors.cream,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBattleArea(BattleViewModel viewModel) {
    return BattleField(
      player: viewModel.currentPlayer,
      opponent: viewModel.opponent,
      currentPlayerId: viewModel.playerId,
      animate: !viewModel.battleEnded,
    );
  }

  Widget _buildTeamStatus(BattleViewModel viewModel) {
    final player = viewModel.currentPlayer;
    if (player == null || player.team.isEmpty) {
      return const SizedBox.shrink();
    }

    final teamStatus = player.team.map((p) => !p.isFainted).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TEAM: ',
          style: DesignTypography.labelSmall.copyWith(
            color: DesignColors.cream,
          ),
        ),
        PokeballIndicator(
          teamStatus: teamStatus,
          activeIndex: player.activeIndex,
        ),
      ],
    );
  }

  Widget _buildActions(BattleViewModel viewModel) {
    if (viewModel.battleEnded) {
      return AppButton(
        label: 'VOLVER AL INICIO',
        onPressed: _navigateToStart,
      );
    }

    return AppButton(
      label: 'ATACAR',
      onPressed: viewModel.isMyTurn ? viewModel.attack : null,
      enabled: viewModel.isMyTurn,
    );
  }
}

/// Dialog shown when battle ends, displaying victory or defeat.
class _BattleResultDialog extends StatelessWidget {
  final bool isVictory;
  final String message;
  final VoidCallback onDismiss;

  const _BattleResultDialog({
    required this.isVictory,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: DesignColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVictory ? DesignColors.forest : DesignColors.crimson,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: DesignColors.ink.withValues(alpha: 0.3),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVictory ? '¡Ganaste!' : '¡Perdiste!',
              style: DesignTypography.displayMedium.copyWith(
                color: isVictory ? DesignColors.forest : DesignColors.crimson,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              message,
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSpacing.lg),
            AppButton(
              label: 'VOLVER AL INICIO',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
