import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Organism displaying a scrollable battle log, styled after the web
/// .battle-log-box: cream card with a gold-deep header and monospace rows.
class BattleLog extends StatefulWidget {
  final List<String> events;

  const BattleLog({
    super.key,
    required this.events,
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
      decoration: BoxDecoration(
        color: DesignColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignColors.ink, width: 3),
        boxShadow: [
          BoxShadow(
            color: DesignColors.ink.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        DesignSpacing.md,
        DesignSpacing.sm,
        DesignSpacing.md,
        DesignSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'REGISTRO',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.goldDeep,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: DesignSpacing.xs),
          Flexible(
            child: widget.events.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
                      child: Text(
                        'Sin eventos todavía',
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.goldDeep,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: widget.events.length,
                    itemBuilder: (context, index) {
                      final event = widget.events[index];
                      final isLast = index == widget.events.length - 1;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLast
                              ? DesignColors.creamSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event,
                          style: DesignTypography.statsSmall.copyWith(
                            color: DesignColors.ink,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
