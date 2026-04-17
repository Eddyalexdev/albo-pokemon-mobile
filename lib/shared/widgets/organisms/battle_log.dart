import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Organism displaying a scrollable battle log.
class BattleLog extends StatefulWidget {
  final List<String> events;
  final int maxEvents;

  const BattleLog({
    super.key,
    required this.events,
    this.maxEvents = 50,
  });

  @override
  State<BattleLog> createState() => _BattleLogState();
}

class _BattleLogState extends State<BattleLog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(BattleLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events.length > oldWidget.events.length) {
      // Auto-scroll to bottom when new events are added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: DesignColors.creamSoft.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.ink, width: 2),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(DesignSpacing.sm),
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          final event = widget.events[index];
          final isRecent = index >= widget.events.length - 5;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              event,
              style: DesignTypography.bodySmall.copyWith(
                color: isRecent ? DesignColors.ink : DesignColors.goldDeep,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        },
      ),
    );
  }
}
