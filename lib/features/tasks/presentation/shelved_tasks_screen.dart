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
    return Scaffold(
      appBar: AppBar(title: const Text('보류함')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = state.shelvedTasks;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '당분간 거리를 두기로 한 일들',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  const TaskEmptyStateCard(
                    title: '보류함은 아직 비어 있어요',
                    message: '지금은 잠시 멀리 두고 싶은 일은 보류함으로 옮길 수 있어요.',
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
    );
  }
}
