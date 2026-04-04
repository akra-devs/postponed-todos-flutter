import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import 'task_detail_screen.dart';
import 'widgets/task_empty_state_card.dart';
import 'widgets/task_list_card.dart';

class PostponingTasksScreen extends StatelessWidget {
  const PostponingTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미루는 중')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = state.postponingTasks;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '지금 당장 하진 않지만, 아직 붙잡고 있는 일들',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  const TaskEmptyStateCard(
                    title: '아직 넣어둔 일이 없어요',
                    message: '캘린더까지는 아니지만 잊고 싶지 않은 일을 가볍게 적어둘 수 있어요.',
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
