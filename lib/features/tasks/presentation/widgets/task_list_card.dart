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
    final isShelved = task.status == TaskStatus.shelved;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isShelved ? const Color(0xFFFCFBF7) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isShelved
                  ? const Color(0xFFDCCFBC)
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isShelved ? 0.025 : 0.035,
                ),
                blurRadius: isShelved ? 18 : 20,
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
                                ? _ChipTone.shelf
                                : _ChipTone.neutral,
                          ),
                          if (isShelved && task.shelvedAt != null)
                            _StatusChip(
                              label: '보관 ${_daysSince(task.shelvedAt!)}일째',
                              tone: _ChipTone.muted,
                            ),
                          if (isCoolingDown)
                            const _StatusChip(
                              label: '조금 더 둘래 · 다시 보기 대기 중',
                              tone: _ChipTone.muted,
                            ),
                          if (task.status == TaskStatus.shelved &&
                              task.isEligibleForHoldingBoxRevisitSuggestion)
                            const _StatusChip(
                              label: '다시 꺼내볼 때가 됐어요',
                              tone: _ChipTone.warm,
                            ),
                        ],
                      ),
                      if (isShelved) ...[
                        const SizedBox(height: 12),
                        Text(
                          task.isEligibleForHoldingBoxRevisitSuggestion
                              ? '준비되면 다시 꺼내볼 수 있어요.'
                              : '지금은 서두르지 말고 여기 두어도 괜찮아요.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF7B7368),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  static int _daysSince(DateTime from) {
    final difference = DateTime.now().difference(from).inDays;
    return difference < 1 ? 1 : difference;
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
            ? const Color(0xFFF0E7D8)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isShelved ? Icons.inventory_2_outlined : Icons.access_time_rounded,
        size: 20,
        color: isShelved
            ? const Color(0xFF7D6E58)
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _ChipTone { neutral, muted, shelf, warm }

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
        backgroundColor = const Color(0xFFF1ECE2);
        foregroundColor = const Color(0xFF6F6557);
      case _ChipTone.shelf:
        backgroundColor = const Color(0xFFE7DED0);
        foregroundColor = const Color(0xFF665B4D);
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
