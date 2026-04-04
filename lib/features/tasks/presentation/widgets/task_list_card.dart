import 'package:flutter/material.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCoolingDown = task.resurfaceAt?.isAfter(DateTime.now()) ?? false;
    final hasNote = (task.note ?? '').isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: task.status == TaskStatus.shelved
                  ? colorScheme.primary.withValues(alpha: 0.14)
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadingIntentMarker(status: task.status),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.outline,
                          ),
                        ],
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: task.status.label,
                            tone: task.status == TaskStatus.shelved
                                ? _ChipTone.accent
                                : _ChipTone.neutral,
                          ),
                          if (isCoolingDown)
                            const _StatusChip(
                              label: '조금 더 둘래 · 다시 보기 대기 중',
                              tone: _ChipTone.muted,
                            ),
                          if (task.status == TaskStatus.shelved &&
                              task.isEligibleForHoldingBoxRevisitSuggestion)
                            const _StatusChip(
                              label: '다시 꺼내보기 제안 가능',
                              tone: _ChipTone.warm,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadingIntentMarker extends StatelessWidget {
  const _LeadingIntentMarker({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isShelved = status == TaskStatus.shelved;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isShelved
            ? colorScheme.primary.withValues(alpha: 0.10)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isShelved ? Icons.inventory_2_outlined : Icons.access_time_rounded,
        size: 20,
        color: isShelved ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _ChipTone { neutral, muted, accent, warm }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color backgroundColor;
    final Color foregroundColor;
    switch (tone) {
      case _ChipTone.neutral:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
      case _ChipTone.muted:
        backgroundColor = colorScheme.secondaryContainer.withValues(alpha: 0.5);
        foregroundColor = colorScheme.onSecondaryContainer;
      case _ChipTone.accent:
        backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.8);
        foregroundColor = colorScheme.onPrimaryContainer;
      case _ChipTone.warm:
        backgroundColor = const Color(0xFFFFF1DD);
        foregroundColor = const Color(0xFF8A4B00);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
