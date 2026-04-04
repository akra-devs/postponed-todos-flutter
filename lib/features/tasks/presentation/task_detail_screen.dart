import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  static Route<void> route(String taskId) {
    return MaterialPageRoute<void>(
      builder: (_) => TaskDetailScreen(taskId: taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('할 일 상세')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final task = state.tasks
                .where((item) => item.id == taskId)
                .firstOrNull;
            if (task == null) {
              return const Center(child: Text('이 일을 찾을 수 없어요.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(task.status.description),
                  if (task.status == TaskStatus.shelved) ...[
                    const SizedBox(height: 16),
                    _ShelvedTaskNotice(task: task),
                  ],
                  if ((task.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('메모', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(task.note!),
                  ],
                  const SizedBox(height: 20),
                  if (task.isHoldingBoxSuggestionCandidate) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
                    const SizedBox(height: 16),
                  ],
                  if (task.isEligibleForHoldingBoxRevisitSuggestion) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
                    const SizedBox(height: 16),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildActions(context, task),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '최근 업데이트: ${_formatDateTime(task.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (task.resurfaceAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '다시 보기 예정: ${_formatDateTime(task.resurfaceAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, Task task) {
    final cubit = context.read<TasksCubit>();
    final actions = <Widget>[];

    if (task.status == TaskStatus.postponing) {
      actions.add(
        _ActionButton(
          label: UiCopy.homeSnooze,
          onPressed: () => cubit.snooze(task),
        ),
      );
      actions.add(
        _ActionButton(
          label: UiCopy.homeHolding,
          onPressed: () => _confirmShelve(context, task, cubit),
        ),
      );
    }

    if (task.status == TaskStatus.shelved) {
      actions.add(
        _ActionButton(
          label: UiCopy.holdingRestore,
          onPressed: () => task.isEligibleForHoldingBoxRevisitSuggestion
              ? cubit.confirmHoldingBoxRevisit(task)
              : cubit.reopenFromShelved(task),
          emphasis: _ActionEmphasis.primary,
        ),
      );
      if (task.isEligibleForHoldingBoxRevisitSuggestion) {
        actions.add(
          _ActionButton(
            label: UiCopy.restoreDefer,
            onPressed: () => cubit.dismissHoldingBoxRevisit(task),
            emphasis: _ActionEmphasis.secondary,
          ),
        );
      }
    }

    if (!task.status.isClosed) {
      actions.add(
        _ActionButton(
          label: UiCopy.detailComplete,
          onPressed: () => cubit.transition(task, TaskStatus.done),
          emphasis: _ActionEmphasis.secondary,
        ),
      );
      actions.add(
        _ActionButton(
          label: UiCopy.detailDrop,
          onPressed: () => cubit.transition(task, TaskStatus.dropped),
          emphasis: _ActionEmphasis.secondary,
        ),
      );
    }

    return actions;
  }

  Future<void> _confirmShelve(
    BuildContext context,
    Task task,
    TasksCubit cubit,
  ) async {
    final shouldShelve = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiCopy.holdingSuggestionTitle),
        content: const Text(UiCopy.holdingSuggestionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(UiCopy.holdingCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(UiCopy.homeHolding),
          ),
        ],
      ),
    );

    if (shouldShelve != true) {
      if (context.mounted) {
        await cubit.recordHoldingSuggestionDismissed(task);
      }
      return;
    }
    if (!context.mounted) return;
    await cubit.transition(task, TaskStatus.shelved);
  }

  String _formatDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

class _ShelvedTaskNotice extends StatelessWidget {
  const _ShelvedTaskNotice({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D5C2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보류함에 잠시 내려둔 일이에요',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              task.isEligibleForHoldingBoxRevisitSuggestion
                  ? '지금은 다시 꺼내보기 괜찮은 시점이라, 복원 버튼을 먼저 두었어요.'
                  : '급하지 않다면 이대로 둬도 괜찮아요. 필요해질 때 복원하면 다시 미루는 중으로 돌아가요.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ActionEmphasis { defaultTone, primary, secondary }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.emphasis = _ActionEmphasis.defaultTone,
  });

  final String label;
  final VoidCallback onPressed;
  final _ActionEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    switch (emphasis) {
      case _ActionEmphasis.primary:
        return FilledButton(onPressed: onPressed, child: Text(label));
      case _ActionEmphasis.secondary:
        return OutlinedButton(onPressed: onPressed, child: Text(label));
      case _ActionEmphasis.defaultTone:
        return FilledButton.tonal(onPressed: onPressed, child: Text(label));
    }
  }
}
