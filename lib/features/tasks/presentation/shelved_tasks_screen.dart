import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import 'task_detail_screen.dart';
import 'widgets/task_empty_state_card.dart';
import 'widgets/task_list_card.dart';

class ShelvedTasksScreen extends StatelessWidget {
  const ShelvedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4EF),
      appBar: AppBar(
        title: const Text('보류함'),
        backgroundColor: const Color(0xFFF5F4EF),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF1EFE7),
              const Color(0xFFF7F6F2),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = state.shelvedTasks;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  _HoldingBoxIntroCard(taskCount: tasks.length),
                  const SizedBox(height: 18),
                  Text(
                    tasks.isEmpty ? '지금은 조용히 쉬는 칸' : '안전하게 내려둔 일들',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '급하게 밀어올리지 않고, 준비될 때 다시 꺼낼 수 있게 차분히 보관해둔 목록이에요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tasks.isEmpty)
                    const TaskEmptyStateCard(
                      title: '아직 내려둔 일이 없어요',
                      message:
                          '반복해서 마음이 멀어지는 일은 여기로 잠시 옮겨둘 수 있어요. 필요해질 때 다시 꺼내면 돼요.',
                    )
                  else
                    ...tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskListCard(
                          task: task,
                          onTap: () => Navigator.of(
                            context,
                          ).push(TaskDetailScreen.route(task.id)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoldingBoxIntroCard extends StatelessWidget {
  const _HoldingBoxIntroCard({required this.taskCount});

  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEEE8DB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9D0BE)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '잠시 쉬어두는 선반',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '급한 목록에서 잠깐 내려둔 일들을 보관해요',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _CountPill(count: taskCount),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '보류함은 포기한 곳이 아니라, 지금 당장 붙잡지 않아도 되는 일을 조용히 두는 자리예요. 다시 꺼낼 준비가 되면 복원부터 하면 돼요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: const Color(0xFF5C5448),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$count개',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5C5448),
          ),
        ),
      ),
    );
  }
}
