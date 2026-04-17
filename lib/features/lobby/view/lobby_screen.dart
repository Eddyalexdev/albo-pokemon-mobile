import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/lobby_state.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../../shared/widgets/molecules/status_chip.dart';
import '../../../shared/widgets/molecules/trainer_card.dart';
import '../../../shared/widgets/organisms/battle_log.dart';
import '../viewmodel/lobby_viewmodel.dart';

/// Lobby screen - waiting room before battle.
class LobbyScreen extends StatefulWidget {
  final VoidCallback onBattleStart;

  const LobbyScreen({
    super.key,
    required this.onBattleStart,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LobbyViewModel>().initialize();
      _audioService.playBgMusic();
    });
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LobbyViewModel>(
        builder: (context, viewModel, _) {
          // Listen for battle start
          if (viewModel.battleStarted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onBattleStart();
            });
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Image.asset(
                'assets/bg/pallet_town.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
              // Overlay
              Container(
                color: DesignColors.ink.withValues(alpha: 0.12),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(viewModel),
                    const SizedBox(height: DesignSpacing.md),
                    _buildTrainerCards(viewModel),
                    const SizedBox(height: DesignSpacing.md),
                    _buildActions(viewModel),
                    const SizedBox(height: DesignSpacing.md),
                    _buildLog(viewModel),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(LobbyViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOBBY',
                  style: DesignTypography.displayMedium.copyWith(
                    color: DesignColors.ink,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        color: DesignColors.gold.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                Text(
                  'POKÉMON STADIUM LITE',
                  style: DesignTypography.statsSmall.copyWith(
                    color: DesignColors.goldDeep,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            text: viewModel.lobby?.status.name ?? 'connecting',
            color: _statusChipColor(viewModel.lobby?.status),
          ),
        ],
      ),
    );
  }

  StatusChipColor _statusChipColor(LobbyStatus? status) {
    if (status == null) return StatusChipColor.neutral;
    return switch (status) {
      LobbyStatus.waiting => StatusChipColor.neutral,
      LobbyStatus.ready => StatusChipColor.success,
      LobbyStatus.battling => StatusChipColor.warning,
      LobbyStatus.finished => StatusChipColor.danger,
    };
  }

  Widget _buildTrainerCards(LobbyViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      child: Column(
        children: [
          TrainerCard(
            player: viewModel.currentPlayer,
            label: 'Tú',
            accentColor: DesignColors.crimson,
          ),
          const SizedBox(height: DesignSpacing.sm),
          TrainerCard(
            player: viewModel.opponent,
            label: 'Rival',
            accentColor: DesignColors.goldDeep,
            isEmpty: viewModel.opponent == null,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(LobbyViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: viewModel.canAssignTeam ? viewModel.assignTeam : null,
              child: Text(
                viewModel.isLoadingTeam ? 'CARREGANDO...' : '🎲 EQUIPO',
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: AppButton(
              label: '✓ LISTO',
              onPressed: viewModel.canReady ? viewModel.ready : null,
              enabled: viewModel.canReady,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLog(LobbyViewModel viewModel) {
    if (viewModel.currentPlayer?.team.isNotEmpty == true && !viewModel.isReady) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        child: Text(
          'Tocá un Pokémon para ver sus estadísticas',
          style: DesignTypography.bodySmall.copyWith(
            fontStyle: FontStyle.italic,
            color: DesignColors.goldDeep,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (viewModel.isReady && viewModel.opponent?.ready != true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        child: Text(
          'Esperando al rival…',
          style: DesignTypography.bodySmall.copyWith(
            fontStyle: FontStyle.italic,
            color: DesignColors.goldDeep,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md),
        child: BattleLog(events: viewModel.logMessages),
      ),
    );
  }
}
