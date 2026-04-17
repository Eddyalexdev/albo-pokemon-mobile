import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../../shared/widgets/atoms/app_input.dart';
import '../viewmodel/start_viewmodel.dart';

/// Screen for entering player nickname before joining lobby.
class StartScreen extends StatefulWidget {
  final VoidCallback onStart;

  const StartScreen({
    super.key,
    required this.onStart,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<StartViewModel>();
      viewModel.loadSavedNickname();
      if (viewModel.nickname.isNotEmpty) {
        _nicknameController.text = viewModel.nickname;
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    final viewModel = context.read<StartViewModel>();
    final success = await viewModel.saveNickname();
    if (success && mounted) {
      widget.onStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/bg/bg-pokemon.jpg',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),
          // Overlay
          Container(
            color: DesignColors.ink.withValues(alpha: 0.4),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Title
                  Text(
                    'POKÉMON',
                    style: DesignTypography.displayLarge.copyWith(
                      color: DesignColors.gold,
                      fontSize: 40,
                      shadows: [
                        Shadow(
                          offset: const Offset(3, 3),
                          color: DesignColors.ink.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'STADIUM LITE',
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
                  const Spacer(),
                  // Nickname card
                  Container(
                    padding: const EdgeInsets.all(DesignSpacing.lg),
                    decoration: BoxDecoration(
                      color: DesignColors.cream.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DesignColors.ink, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: DesignColors.ink.withValues(alpha: 0.3),
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Consumer<StartViewModel>(
                      builder: (context, viewModel, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppInput(
                              labelText: 'Your Nickname',
                              hintText: 'Enter nickname',
                              controller: _nicknameController,
                              onChanged: viewModel.updateNickname,
                              maxLength: 12,
                              autofocus: true,
                            ),
                            if (viewModel.error != null) ...[
                              const SizedBox(height: DesignSpacing.sm),
                              Text(
                                viewModel.error!,
                                style: DesignTypography.bodySmall.copyWith(
                                  color: DesignColors.crimson,
                                ),
                              ),
                            ],
                            const SizedBox(height: DesignSpacing.lg),
                            AppButton(
                              label: 'START',
                              onPressed: viewModel.isValid ? _handleStart : null,
                              enabled: viewModel.isValid,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
