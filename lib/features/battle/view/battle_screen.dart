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

class _BattleScreenState extends State<BattleScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.crossfadeToBattle();
    });
  }

  @override
  void dispose() {
    _audioService.crossfadeToBg();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BattleViewModel>(
        builder: (context, viewModel, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Image.asset(
                'assets/bg/route_01.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
              // Overlay
              Container(
                color: DesignColors.ink.withValues(alpha: 0.2),
              ),
              // Content
              SafeArea(
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
            ],
          );
        },
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
    // Create mock team status (6 slots) - in real app this would come from lobby
    final teamStatus = List.generate(6, (i) => i < 3);

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
          activeIndex: 0,
        ),
      ],
    );
  }

  Widget _buildActions(BattleViewModel viewModel) {
    if (viewModel.battleEnded) {
      return AppButton(
        label: 'VOLVER AL LOBBY',
        onPressed: () {
          // Navigate back - in real app would use Navigator.pop
        },
      );
    }

    return AppButton(
      label: 'ATACAR',
      onPressed: viewModel.isMyTurn ? viewModel.attack : null,
      enabled: viewModel.isMyTurn,
    );
  }
}
