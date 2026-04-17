import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/atoms/app_button.dart';
import '../../../shared/widgets/atoms/app_input.dart';
import '../viewmodel/config_viewmodel.dart';

/// Screen for configuring the backend server URL.
class ConfigScreen extends StatefulWidget {
  final VoidCallback onConnected;

  const ConfigScreen({
    super.key,
    required this.onConnected,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ConfigViewModel>();
      viewModel.loadSavedUrl();
      if (viewModel.hasUrl) {
        _urlController.text = viewModel.serverUrl;
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final viewModel = context.read<ConfigViewModel>();
    final success = await viewModel.saveUrl();
    if (success && mounted) {
      widget.onConnected();
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
            color: DesignColors.ink.withValues(alpha: 0.3),
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
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
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
                  // URL input card
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
                    child: Consumer<ConfigViewModel>(
                      builder: (context, viewModel, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppInput(
                              labelText: 'Server URL',
                              hintText: ApiConstants.defaultUrlHint,
                              controller: _urlController,
                              onChanged: viewModel.updateUrl,
                              keyboardType: TextInputType.url,
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
                              label: viewModel.isLoading ? 'CONNECTING...' : 'CONNECT',
                              onPressed: viewModel.isLoading ? null : _handleConnect,
                              enabled: !viewModel.isLoading,
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
