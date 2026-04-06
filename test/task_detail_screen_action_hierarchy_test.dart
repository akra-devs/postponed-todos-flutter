import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/core/theme/app_theme.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/data/in_memory_task_repository.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/presentation/task_detail_screen.dart';

void main() {
  group('TaskDetailScreen action hierarchy', () {
    testWidgets(
      'shows grouped next action and closure sections for postponing tasks',
      (tester) async {
        final repository = InMemoryTaskRepository();
        final now = DateTime(2026, 4, 5, 5, 18);
        final task = Task(
          id: 'task-1',
          title: '미루는 중인 일',
          status: TaskStatus.postponing,
          createdAt: now,
          updatedAt: now,
        );
        await repository.save(task);

        final cubit = TasksCubit(
          repository,
          DefaultTaskRecommendationService(),
        );

        await tester.pumpWidget(
          _TestApp(
            cubit: cubit,
            child: const TaskDetailScreen(taskId: 'task-1'),
          ),
        );
        await tester.pump();

        expect(find.text('다음 행동'), findsOneWidget);
        expect(find.text('정리하기'), findsOneWidget);
        expect(find.text('조금 천천히 미뤄둘게요'), findsOneWidget);
        expect(find.text('보관함에 조용히 내려둘래요'), findsOneWidget);
        expect(find.text('완료했어'), findsOneWidget);
        expect(find.text('오늘은 여기서 멈출래요'), findsOneWidget);
        expect(find.text('보관함에서 관리'), findsNothing);

        await repository.dispose();
        await cubit.close();
      },
    );

    testWidgets(
      'throttles completion celebration feedback while still surfacing recent completions',
      (tester) async {
        final repository = InMemoryTaskRepository();
        final now = DateTime(2026, 4, 5, 7, 30);
        await repository.save(
          Task(
            id: 'done-old-1',
            title: '완료한 작업 A',
            status: TaskStatus.done,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await repository.save(
          Task(
            id: 'done-old-2',
            title: '완료한 작업 B',
            status: TaskStatus.done,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await repository.save(
          Task(
            id: 'task-4',
            title: '방금 마칠 작업',
            status: TaskStatus.postponing,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await repository.save(
          Task(
            id: 'task-5',
            title: '다음 작업',
            status: TaskStatus.postponing,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await repository.save(
          Task(
            id: 'task-6',
            title: '세 번째 완료 전환 일',
            status: TaskStatus.postponing,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final cubit = TasksCubit(
          repository,
          DefaultTaskRecommendationService(),
        );

        await tester.pumpWidget(
          _TestApp(
            cubit: cubit,
            child: const TaskDetailScreen(taskId: 'task-4'),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('완료했어'));
        await tester.pumpAndSettle();

        expect(find.text('마무리했어요'), findsOneWidget);
        expect(find.text('완료한 작업 A'), findsAtLeast(1));
        expect(find.text('방금 마칠 작업'), findsAtLeast(1));

        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          _TestApp(
            cubit: cubit,
            child: const TaskDetailScreen(taskId: 'task-5'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text('완료했어'));
        await tester.pump();

        expect(find.text('마무리했어요'), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('최근 마무리한 일'), findsOneWidget);
        expect(find.textContaining('•'), findsAtLeast(1));

        await tester.pumpWidget(
          _TestApp(
            cubit: cubit,
            child: const TaskDetailScreen(taskId: 'task-6'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text('완료했어'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('최근 마무리한 일'), findsOneWidget);
        expect(find.text('세 번째 완료 전환 일'), findsAtLeast(1));

        await repository.dispose();
        await cubit.close();
      },
    );

    testWidgets(
      'keeps restore/defer semantics grouped for revisitable shelved tasks',
      (tester) async {
        final repository = InMemoryTaskRepository();
        final now = DateTime.now();
        final task = Task(
          id: 'task-2',
          title: '보관함에 둔 일',
          status: TaskStatus.shelved,
          createdAt: now,
          updatedAt: now,
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        await repository.save(task);

        final cubit = TasksCubit(
          repository,
          DefaultTaskRecommendationService(),
        );

        await tester.pumpWidget(
          _TestApp(
            cubit: cubit,
            child: const TaskDetailScreen(taskId: 'task-2'),
          ),
        );
        await tester.pump();

        expect(find.text('다시 꺼내볼 타이밍'), findsOneWidget);
        expect(find.text('다시 꺼내볼래요'), findsOneWidget);
        expect(find.text('조금 뒤로 미루기'), findsOneWidget);
        expect(find.text('정리하기'), findsOneWidget);
        expect(find.text('조금 천천히 미뤄둘게요'), findsNothing);
        expect(find.text('보관함에 조용히 내려둘래요'), findsNothing);

        await repository.dispose();
        await cubit.close();
      },
    );

    testWidgets('does not throw when a closed task has no action sections', (
      tester,
    ) async {
      final repository = InMemoryTaskRepository();
      final now = DateTime(2026, 4, 5, 21, 46);
      final task = Task(
        id: 'task-3',
        title: '이미 완료한 일',
        status: TaskStatus.done,
        createdAt: now,
        updatedAt: now,
      );
      await repository.save(task);

      final cubit = TasksCubit(repository, DefaultTaskRecommendationService());

      await tester.pumpWidget(
        _TestApp(
          cubit: cubit,
          child: const TaskDetailScreen(taskId: 'task-3'),
        ),
      );
      await tester.pump();

      expect(find.text('이미 완료한 일'), findsOneWidget);
      expect(find.text('다음 행동'), findsNothing);
      expect(find.text('정리하기'), findsNothing);
      expect(tester.takeException(), isNull);

      await repository.dispose();
      await cubit.close();
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.cubit, required this.child});

  final TasksCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: BlocProvider.value(value: cubit, child: child),
    );
  }
}
