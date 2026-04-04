import 'package:flutter/material.dart';

import '../../../../core/config/ui_copy.dart';
import '../../domain/task_recommendation_service.dart';

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
    final isRevisit = recommendation.suggestHoldingRevisit;
    final supportsHoldingSuggestion = recommendation.suggestHoldingBox;
    final reason = recommendation.reasons.isEmpty
        ? isRevisit
              ? '한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'
              : '지금 다시 꺼내보기 괜찮아 보여요'
        : recommendation.reasons.first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isRevisit
              ? colorScheme.primary.withValues(alpha: 0.14)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                        highlighted: isRevisit,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation.task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _CalmScorePill(
                  label: isRevisit ? '가볍게' : '추천',
                  highlighted: isRevisit,
                ),
              ],
            ),
            if ((recommendation.task.note ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                recommendation.task.note!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _ReasonPanel(
              label: isRevisit ? '왜 다시 보여주냐면' : '지금 꺼내본 이유',
              body: reason,
              highlighted: isRevisit,
            ),
            if (isRevisit || supportsHoldingSuggestion) ...[
              const SizedBox(height: 10),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isRevisit ? UiCopy.holdingRestore : UiCopy.homePrimary,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onSnooze,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isRevisit ? UiCopy.restoreDefer : UiCopy.homeSnooze,
                    textAlign: TextAlign.center,
                  ),
                ),
                OutlinedButton(
                  onPressed: onShelf,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isRevisit ? '상세 보기' : UiCopy.homeHolding,
                    textAlign: TextAlign.center,
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
  const _EyebrowLabel({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.75)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlighted
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CalmScorePill extends StatelessWidget {
  const _CalmScorePill({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlighted ? colorScheme.primary : colorScheme.onSurface,
          ),
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
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
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
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: highlighted ? colorScheme.primary : colorScheme.outline,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
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
