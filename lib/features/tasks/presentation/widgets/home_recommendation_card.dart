import 'package:flutter/material.dart';

import '../../../../core/config/ui_copy.dart';
import '../../../../core/theme/app_elevation_tokens.dart';
import '../../../../core/theme/app_icon_tokens.dart';
import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/app_theme_ext.dart';
import '../../domain/task_recommendation_service.dart';

const EdgeInsets _ctaButtonPadding = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 12,
);
const EdgeInsets _eyebrowChipPadding = EdgeInsets.symmetric(
  horizontal: 10,
  vertical: 5,
);
const EdgeInsets _scorePillPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 8,
);
const double _secondaryContextDotSize = 8;
const double _secondaryContextDotTopOffset = 6;
const double _secondaryContextContentGap = 10;

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
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;
    final isRevisit = recommendation.suggestHoldingRevisit;
    final supportsHoldingSuggestion = recommendation.suggestHoldingBox;
    final reason = recommendation.reasons.isEmpty
        ? isRevisit
              ? '한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'
              : '지금 다시 꺼내보기 괜찮아 보여요'
        : recommendation.reasons.first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(
          color: isRevisit
              ? colorScheme.primary.withValues(alpha: 0.14)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppElevationTokens.heroBlur,
            offset: const Offset(0, AppElevationTokens.heroOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.cardInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EyebrowLabel(
                        label: isRevisit ? '보류함에서 조심스럽게 다시' : '오늘은 이 일만 다시',
                        icon: isRevisit
                            ? AppIconTokens.statusRevisit
                            : AppIconTokens.statusPostponing,
                        highlighted: isRevisit,
                      ),
                      const SizedBox(height: AppSpacingTokens.eyebrowGap),
                      Text(
                        recommendation.task.title,
                        style: theme.appTextRoles.cardTitle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                _CalmScorePill(
                  label: isRevisit ? '가볍게' : '추천',
                  icon: isRevisit
                      ? AppIconTokens.statusRevisit
                      : AppIconTokens.actionPrimary,
                  highlighted: isRevisit,
                ),
              ],
            ),
            if ((recommendation.task.note ?? '').isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                recommendation.task.note!,
                style: theme.appTextRoles.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.listGap),
            _ReasonPanel(
              label: isRevisit ? '왜 다시 보여주냐면' : '지금 꺼내본 이유',
              body: reason,
              highlighted: isRevisit,
            ),
            if (isRevisit || supportsHoldingSuggestion) ...[
              const SizedBox(height: AppSpacingTokens.actionGap),
              _SecondaryContextPanel(
                title: isRevisit
                    ? UiCopy.holdingRevisitTitle
                    : UiCopy.holdingSuggestionTitle,
                description: isRevisit
                    ? UiCopy.holdingRevisitDescription
                    : UiCopy.holdingSuggestionDescription,
                highlighted: isRevisit,
              ),
            ],
            const SizedBox(height: AppSpacingTokens.listGap),
            Wrap(
              spacing: AppSpacingTokens.xs,
              runSpacing: AppSpacingTokens.xs,
              children: [
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(padding: _ctaButtonPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRevisit
                            ? AppIconTokens.actionOpen
                            : AppIconTokens.actionPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRevisit ? UiCopy.holdingRestore : UiCopy.homePrimary,
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onSnooze,
                  style: FilledButton.styleFrom(padding: _ctaButtonPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRevisit
                            ? AppIconTokens.actionDefer
                            : AppIconTokens.actionSnooze,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRevisit ? UiCopy.restoreDefer : UiCopy.homeSnooze,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: onShelf,
                  style: OutlinedButton.styleFrom(padding: _ctaButtonPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIconTokens.actionHold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isRevisit ? '상세 보기' : UiCopy.homeHolding,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EyebrowLabel extends StatelessWidget {
  const _EyebrowLabel({
    required this.label,
    required this.icon,
    required this.highlighted,
  });

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.75)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: _eyebrowChipPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.appTextRoles.eyebrow.copyWith(
                color: highlighted
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalmScorePill extends StatelessWidget {
  const _CalmScorePill({
    required this.label,
    required this.icon,
    required this.highlighted,
  });

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(alpha: 0.08)
            : surfaces.cardMuted,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      ),
      child: Padding(
        padding: _scorePillPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: highlighted ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.appTextRoles.emphasisLabel.copyWith(
                color: highlighted
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonPanel extends StatelessWidget {
  const _ReasonPanel({
    required this.label,
    required this.body,
    required this.highlighted,
  });

  final String label;
  final String body;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(alpha: 0.05)
            : theme.appSurfaces.reasonPanel,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.appTextRoles.eyebrow.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.compactTextGap),
            Text(body, style: theme.appTextRoles.body),
          ],
        ),
      ),
    );
  }
}

class _SecondaryContextPanel extends StatelessWidget {
  const _SecondaryContextPanel({
    required this.title,
    required this.description,
    required this.highlighted,
  });

  final String title;
  final String description;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
            : theme.appSurfaces.cardMuted.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _secondaryContextDotSize,
              height: _secondaryContextDotSize,
              margin: const EdgeInsets.only(top: _secondaryContextDotTopOffset),
              decoration: BoxDecoration(
                color: highlighted ? colorScheme.primary : colorScheme.outline,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: _secondaryContextContentGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.appTextRoles.panelTitle),
                  const SizedBox(height: AppSpacingTokens.compactTextGap),
                  Text(
                    description,
                    style: theme.appTextRoles.supportingBody.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
