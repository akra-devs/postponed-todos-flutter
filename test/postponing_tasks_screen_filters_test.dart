import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/core/theme/app_theme.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/application/tasks_state.dart';
import 'package:postponed_todos/features/tasks/data/in_memory_task_repository.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/presentation/postponing_tasks_screen.dart';
import 'package:postponed_todos/features/tasks/presentation/widgets/task_list_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PostponingTasksScreen filters', () {
    late InMemoryTaskRepository repository;
    late TasksCubit cubit;

    setUp(() {
      repository = InMemoryTaskRepository();
      cubit = TasksCubit(repository, const DefaultTaskRecommendationService());
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    testWidgets('shows low-pressure segments and filters visible tasks', (
      tester,
    ) async {
      final now = DateTime.now();
      cubit.emit(
        TasksState(
          tasks: [
            Task(
              id: 'available-task',
              title: '지금 다시 볼 수 있는 일',
              status: TaskStatus.postponing,
              createdAt: now,
              updatedAt: now,
            ),
            Task(
              id: 'cooling-task',
              title: '조금 더 두는 일',
              status: TaskStatus.postponing,
              createdAt: now,
              updatedAt: now,
              resurfaceAt: now.add(const Duration(days: 2)),
            ),
          ],
          loading: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: BlocProvider.value(
            value: cubit,
            child: const PostponingTasksScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(cubit.state.postponingTasks.length, 2);
      expect(cubit.state.availablePostponingTasks.length, 1);
      expect(cubit.state.coolingDownTasks.length, 1);

      expect(find.widgetWithText(ChoiceChip, '전체'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '지금 다시 보기 쉬운'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '조금 더 두는 중'), findsOneWidget);
      expect(find.text('붙잡고 있는 일 전체'), findsOneWidget);
      expect(find.byType(TaskListCard), findsNWidgets(2));

      await tester.tap(find.widgetWithText(ChoiceChip, '지금 다시 보기 쉬운'));
      await tester.pumpAndSettle();

      expect(find.text('지금 다시 보기 쉬운 일'), findsOneWidget);
      expect(find.byType(TaskListCard), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, '조금 더 두는 중'));
      await tester.pumpAndSettle();

      expect(find.text('조금 더 두는 중인 일'), findsOneWidget);
      expect(find.byType(TaskListCard), findsOneWidget);
    });
  });
}
