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
    final isCoolingDown = task.resurfaceAt?.isAfter(DateTime.now()) ?? false;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: theme.textTheme.titleMedium),
              if ((task.note ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.note!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(label: task.status.label),
                  if (isCoolingDown)
                    const _StatusChip(label: '조금 더 둘래 · 다시 보기 대기 중'),
                  if (task.status == TaskStatus.shelved &&
                      task.isEligibleForHoldingBoxRevisitSuggestion)
                    const _StatusChip(label: '다시 꺼내보기 제안 가능'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}
