import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/ui_copy.dart';
import '../../application/tasks_cubit.dart';
import '../../application/tasks_state.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final task = state.tasks.where((item) => item.id == taskId).firstOrNull;
        if (task == null) {
          return const SizedBox(
            height: 240,
            child: Center(child: Text('이 일을 찾을 수 없어요.')),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(task.status.description),
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
          ),
        );
      },
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
        ),
      );
      if (task.isEligibleForHoldingBoxRevisitSuggestion) {
        actions.add(
          _ActionButton(
            label: UiCopy.restoreDefer,
            onPressed: () => cubit.dismissHoldingBoxRevisit(task),
          ),
        );
      }
    }

    if (!task.status.isClosed) {
      actions.add(
        _ActionButton(
          label: UiCopy.detailComplete,
          onPressed: () => cubit.transition(task, TaskStatus.done),
        ),
      );
      actions.add(
        _ActionButton(
          label: UiCopy.detailDrop,
          onPressed: () => cubit.transition(task, TaskStatus.dropped),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
}
