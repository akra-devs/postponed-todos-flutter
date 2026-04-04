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
    final reason = recommendation.reasons.isEmpty
        ? recommendation.suggestHoldingRevisit
              ? '한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'
              : '지금 다시 꺼내보기 괜찮아 보여요'
        : recommendation.reasons.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.suggestHoldingRevisit
                  ? '보류함에서 다시 꺼내볼 만한 일'
                  : '지금 다시 꺼내볼 만한 일',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(recommendation.task.title, style: theme.textTheme.titleLarge),
            if ((recommendation.task.note ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                recommendation.task.note!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(reason, style: theme.textTheme.bodyMedium),
            if (recommendation.suggestHoldingRevisit) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UiCopy.holdingRevisitTitle,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(UiCopy.holdingRevisitDescription),
                    ],
                  ),
                ),
              ),
            ] else if (recommendation.suggestHoldingBox) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UiCopy.holdingSuggestionTitle,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(UiCopy.holdingSuggestionDescription),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onOpen,
                  child: Text(
                    recommendation.suggestHoldingRevisit
                        ? UiCopy.holdingRestore
                        : UiCopy.homePrimary,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onSnooze,
                  child: Text(
                    recommendation.suggestHoldingRevisit
                        ? UiCopy.restoreDefer
                        : UiCopy.homeSnooze,
                  ),
                ),
                OutlinedButton(
                  onPressed: onShelf,
                  child: Text(
                    recommendation.suggestHoldingRevisit
                        ? '상세 보기'
                        : UiCopy.homeHolding,
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
