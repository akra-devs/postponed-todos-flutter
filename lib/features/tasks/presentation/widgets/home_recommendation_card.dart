import 'package:flutter/material.dart';

import '../../../../core/config/ui_copy.dart';
import '../../../../core/theme/app_icon_tokens.dart';
import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/reentry_atlas_tokens.dart';
import '../../domain/task_recommendation_service.dart';
import 'reentry_atlas_components.dart';

class HomeRecommendationCard extends StatelessWidget {
  const HomeRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onOpen,
    required this.onSnooze,
    required this.onShelf,
  });

  final TaskRecommendation recommendation;
  final VoidCallback onOpen;
  final VoidCallback onSnooze;
  final VoidCallback onShelf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final compact = MediaQuery.sizeOf(context).width < 420;
    final isRevisit = recommendation.suggestHoldingRevisit;
    final supportsHoldingSuggestion = recommendation.suggestHoldingBox;
    final note = recommendation.task.note?.trim();
    final reason = recommendation.reasons.isEmpty
        ? isRevisit
              ? '한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'
              : '지금 다시 꺼내보기 괜찮아 보여요'
        : recommendation.reasons.first;

    return ReentryPorcelainTicket(
      minimumHeight: 224,
      notchPosition: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TicketStateMark(isRevisit: isRevisit),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    isRevisit ? '보관함에서 천천히 다시 보기' : '오늘은 가볍게 다시 보기',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isRevisit
                          ? const Color(0xFF477F76)
                          : atlas.periwinkleDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              recommendation.task.title,
              style:
                  (compact
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleLarge)
                      ?.copyWith(
                        color: atlas.ink,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.45,
                      ),
            ),
            if (note?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: atlas.inkMuted,
                  height: 1.42,
                ),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.md),
            Divider(color: atlas.ink.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: AppSpacingTokens.sm),
            _TicketContextLine(
              icon: isRevisit
                  ? AppIconTokens.statusRevisit
                  : Icons.auto_awesome_outlined,
              label: isRevisit ? '다시 보여주는 이유' : '지금 꺼내본 이유',
              body: reason,
              accent: isRevisit
                  ? const Color(0xFF477F76)
                  : atlas.periwinkleDeep,
            ),
            if (isRevisit || supportsHoldingSuggestion) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              _TicketContextLine(
                icon: isRevisit
                    ? AppIconTokens.quickEntryShelved
                    : AppIconTokens.actionHold,
                label: isRevisit
                    ? UiCopy.holdingRevisitTitle
                    : UiCopy.holdingSuggestionTitle,
                body: isRevisit
                    ? UiCopy.holdingRevisitDescription
                    : UiCopy.holdingSuggestionDescription,
                accent: isRevisit ? const Color(0xFF477F76) : atlas.inkMuted,
              ),
            ],
            const SizedBox(height: AppSpacingTokens.md),
            Wrap(
              spacing: AppSpacingTokens.xs,
              runSpacing: AppSpacingTokens.xs,
              children: [
                FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: atlas.periwinkleDeep,
                    foregroundColor: atlas.porcelain,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                    ),
                  ),
                  icon: Icon(
                    isRevisit
                        ? AppIconTokens.actionOpen
                        : AppIconTokens.actionPrimary,
                    size: 19,
                  ),
                  label: Text(
                    isRevisit ? UiCopy.holdingRestore : UiCopy.homePrimary,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onSnooze,
                  style: FilledButton.styleFrom(
                    backgroundColor: atlas.periwinkleSoft.withValues(
                      alpha: 0.58,
                    ),
                    foregroundColor: atlas.ink,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                    ),
                  ),
                  icon: Icon(
                    isRevisit
                        ? AppIconTokens.actionDefer
                        : AppIconTokens.actionSnooze,
                    size: 19,
                  ),
                  label: Text(
                    isRevisit ? UiCopy.restoreDefer : UiCopy.homeSnooze,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onShelf,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: atlas.inkMuted,
                    minimumSize: const Size(0, 48),
                    side: BorderSide(color: atlas.ink.withValues(alpha: 0.16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                    ),
                  ),
                  icon: Icon(AppIconTokens.actionHold, size: 19),
                  label: Text(isRevisit ? '자세히 보기' : UiCopy.homeHolding),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketStateMark extends StatelessWidget {
  const _TicketStateMark({required this.isRevisit});

  final bool isRevisit;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    final color = isRevisit ? atlas.mint : atlas.periwinkle;
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: atlas.porcelain,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: atlas.ink.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.45),
            colors: [Color.lerp(color, Colors.white, 0.34)!, color],
          ),
        ),
        child: Icon(
          isRevisit ? Icons.inventory_2_outlined : Icons.refresh_rounded,
          color: atlas.ink.withValues(alpha: 0.72),
          size: 21,
        ),
      ),
    );
  }
}

class _TicketContextLine extends StatelessWidget {
  const _TicketContextLine({
    required this.icon,
    required this.label,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: atlas.inkMuted,
                  height: 1.42,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
