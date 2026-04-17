import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class GameBg extends StatelessWidget {
  final String asset;
  final Widget child;
  final double overlayOpacity;

  const GameBg({
    super.key,
    required this.asset,
    required this.child,
    this.overlayOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.ink.withValues(alpha: overlayOpacity * 0.3),
                GameColors.ink.withValues(alpha: overlayOpacity),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
