import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/data/task_repository.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_event.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_history.dart';
import 'package:postponed_todos/features/tasks/presentation/tasks_home_screen.dart';
import 'package:postponed_todos/features/tasks/presentation/widgets/home_recommendation_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Holding-box revisit widget integration', () {
    late InMemoryTaskRepository repository;
    late TasksCubit cubit;
    late DateTime now;

    setUp(() {
      repository = InMemoryTaskRepository();
      cubit = TasksCubit(repository, const DefaultTaskRecommendationService());
      now = DateTime.now();
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    testWidgets(
      'TasksHomeScreen records recommendation exposure after first frame',
      (tester) async {
        final recommendationTask = Task(
          id: 'home-recommendation-task',
          title: '메일 답장 보내기',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );

        await repository.save(recommendationTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations, hasLength(1));

        var events = await repository.getSuggestionEventsForTask(
          recommendationTask.id,
        );
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.recommendationExposed,
          ),
          isEmpty,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final exposed = await repository.getById(recommendationTask.id);
        expect(exposed, isNotNull);
        expect(exposed!.lastExposedAt, isNotNull);
        expect(exposed.consecutiveNoActionCount, 1);

        events = await repository.getSuggestionEventsForTask(
          recommendationTask.id,
        );
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.recommendationExposed,
          ),
          hasLength(1),
        );

        await tester.pump();

        events = await repository.getSuggestionEventsForTask(
          recommendationTask.id,
        );
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.recommendationExposed,
          ),
          hasLength(1),
        );
      },
    );

    testWidgets(
      'TasksHomeScreen avoids duplicate exposure for same recommendation key and records again when the key changes',
      (tester) async {
        final firstTask = Task(
          id: 'recommendation-key-a',
          title: '메일 답장 보내기',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );

        await repository.save(firstTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-key-a',
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        var firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await tester.pump();

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        final secondTask = Task(
          id: 'recommendation-key-b',
          title: '통신사 앱 확인',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
          lastInteractedAt: now.subtract(const Duration(hours: 2)),
        );

        await repository.save(secondTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-key-b',
          'recommendation-key-a',
        ]);

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        final secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );

        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await tester.pump();

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        final secondTaskEventsAfterExtraPump = await repository
            .getSuggestionEventsForTask(secondTask.id);
        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEventsAfterExtraPump
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
      },
    );

    testWidgets(
      'TasksHomeScreen keeps exposure dedupe stable when recommendation order changes with the same ids',
      (tester) async {
        final firstTask = Task(
          id: 'recommendation-reorder-a',
          title: '메일 답장 보내기',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        );
        final secondTask = Task(
          id: 'recommendation-reorder-b',
          title: '통신사 앱 확인',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        );

        await repository.save(firstTask);
        await repository.save(secondTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-reorder-a',
          'recommendation-reorder-b',
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        var firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        var secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );

        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await repository.update(
          secondTask.copyWith(updatedAt: now, lastInteractedAt: now),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-reorder-b',
          'recommendation-reorder-a',
        ]);

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );

        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await tester.pump();

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );
        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
      },
    );

    testWidgets(
      'TasksHomeScreen records a fresh exposure when a recommendation disappears and later returns outside the dedupe window',
      (tester) async {
        final task = Task(
          id: 'recommendation-reappear-a',
          title: '다시 붙잡을 작은 일',
          status: TaskStatus.done,
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(hours: 13)),
          closedAt: now.subtract(const Duration(hours: 13)),
          lastExposedAt: now.subtract(const Duration(hours: 13)),
          consecutiveNoActionCount: 1,
        );

        await repository.save(task);
        await repository.addSuggestionEvent(
          TaskSuggestionEvent(
            id: '${task.id}-seed-exposure',
            taskId: task.id,
            type: TaskSuggestionEventType.recommendationExposed,
            createdAt: now.subtract(const Duration(hours: 13)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations, isEmpty);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        var events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await repository.update(
          task.copyWith(
            status: TaskStatus.postponing,
            closedAt: null,
            updatedAt: now,
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-reappear-a',
        ]);

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          2,
        );

        await repository.update(
          task.copyWith(
            status: TaskStatus.done,
            closedAt: now.add(const Duration(minutes: 1)),
            updatedAt: now.add(const Duration(minutes: 1)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.recommendations, isEmpty);

        await repository.update(
          task.copyWith(
            status: TaskStatus.postponing,
            closedAt: null,
            updatedAt: now.add(const Duration(minutes: 2)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          2,
        );

        await tester.pump();

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          2,
        );
      },
    );

    testWidgets(
      'TasksHomeScreen keeps exposure dedupe stable when recommendations shrink from two items to one',
      (tester) async {
        final firstTask = Task(
          id: 'recommendation-shrink-a',
          title: '메일 답장 보내기',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
          lastInteractedAt: now.subtract(const Duration(hours: 2)),
        );
        final secondTask = Task(
          id: 'recommendation-shrink-b',
          title: '천천히 읽을 글 정리',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        );

        await repository.save(firstTask);
        await repository.save(secondTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-shrink-a',
          'recommendation-shrink-b',
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        var firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        var secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );

        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await repository.update(
          firstTask.copyWith(
            status: TaskStatus.done,
            closedAt: now,
            updatedAt: now,
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'recommendation-shrink-b',
        ]);

        firstTaskEvents = await repository.getSuggestionEventsForTask(
          firstTask.id,
        );
        secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );

        expect(
          firstTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );

        await tester.pump();

        secondTaskEvents = await repository.getSuggestionEventsForTask(
          secondTask.id,
        );
        expect(
          secondTaskEvents
              .where(
                (event) =>
                    event.type == TaskSuggestionEventType.recommendationExposed,
              )
              .length,
          1,
        );
      },
    );

    testWidgets(
      'TasksHomeScreen records holding revisit exposure after first frame',
      (tester) async {
        final revisitTask = Task(
          id: 'home-revisit-task',
          title: '다시 꺼내볼 작은 일',
          status: TaskStatus.shelved,
          createdAt: now.subtract(const Duration(days: 24)),
          updatedAt: now.subtract(const Duration(days: 16)),
          shelvedAt: now.subtract(const Duration(days: 20)),
        );

        await repository.save(revisitTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.holdingBoxRevisitSuggestions, hasLength(1));

        var events = await repository.getSuggestionEventsForTask(
          revisitTask.id,
        );
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.holdingRevisitSuggested,
          ),
          isEmpty,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final exposed = await repository.getById(revisitTask.id);
        expect(exposed, isNotNull);
        expect(exposed!.lastHoldingRevisitSuggestedAt, isNotNull);

        events = await repository.getSuggestionEventsForTask(revisitTask.id);
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.holdingRevisitSuggested,
          ),
          hasLength(1),
        );

        await tester.pump();

        events = await repository.getSuggestionEventsForTask(revisitTask.id);
        expect(
          events.where(
            (event) =>
                event.type == TaskSuggestionEventType.holdingRevisitSuggested,
          ),
          hasLength(1),
        );
      },
    );

    testWidgets(
      'TasksHomeScreen records a fresh holding revisit exposure when a revisit suggestion disappears and later returns outside the dedupe window',
      (tester) async {
        final task = Task(
          id: 'holding-revisit-reappear-a',
          title: '잠시 쉬어둔 아이디어 다시 보기',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 40)),
          updatedAt: now.subtract(const Duration(days: 15, hours: 1)),
          shelvedAt: null,
          lastHoldingRevisitSuggestedAt: now.subtract(
            const Duration(days: 15, hours: 1),
          ),
        );

        await repository.save(task);
        await repository.addSuggestionEvent(
          TaskSuggestionEvent(
            id: '${task.id}-seed-revisit',
            taskId: task.id,
            type: TaskSuggestionEventType.holdingRevisitSuggested,
            createdAt: now.subtract(const Duration(days: 15, hours: 1)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.holdingBoxRevisitSuggestions, isEmpty);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        var events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type ==
                    TaskSuggestionEventType.holdingRevisitSuggested,
              )
              .length,
          1,
        );

        await repository.update(
          task.copyWith(
            status: TaskStatus.shelved,
            shelvedAt: now.subtract(const Duration(days: 20)),
            updatedAt: now,
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(
          cubit.state.holdingBoxRevisitSuggestions.map((item) => item.task.id),
          ['holding-revisit-reappear-a'],
        );

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type ==
                    TaskSuggestionEventType.holdingRevisitSuggested,
              )
              .length,
          2,
        );

        await repository.update(
          task.copyWith(
            status: TaskStatus.postponing,
            shelvedAt: null,
            updatedAt: now.add(const Duration(minutes: 1)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        expect(cubit.state.holdingBoxRevisitSuggestions, isEmpty);

        await repository.update(
          task.copyWith(
            status: TaskStatus.shelved,
            shelvedAt: now.subtract(const Duration(days: 20)),
            updatedAt: now.add(const Duration(minutes: 2)),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pumpAndSettle();

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type ==
                    TaskSuggestionEventType.holdingRevisitSuggested,
              )
              .length,
          2,
        );

        await tester.pump();

        events = await repository.getSuggestionEventsForTask(task.id);
        expect(
          events
              .where(
                (event) =>
                    event.type ==
                    TaskSuggestionEventType.holdingRevisitSuggested,
              )
              .length,
          2,
        );
      },
    );

    testWidgets(
      'home shows quick-entry plus recommendation and revisit sections without reviving the old metric-first summary copy',
      (tester) async {
        final recommendationTask = Task(
          id: 'home-hierarchy-recommendation-task',
          title: '다시 붙잡을 메일',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        );
        final revisitTask = Task(
          id: 'home-hierarchy-revisit-task',
          title: '잠깐 쉬어둔 아이디어',
          status: TaskStatus.shelved,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 18)),
          shelvedAt: now.subtract(const Duration(days: 20)),
        );

        await repository.save(recommendationTask);
        await repository.save(revisitTask);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        });
        await tester.pump();

        expect(cubit.state.recommendations.map((item) => item.task.id), [
          'home-hierarchy-recommendation-task',
        ]);
        expect(
          cubit.state.holdingBoxRevisitSuggestions.map((item) => item.task.id),
          ['home-hierarchy-revisit-task'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const TasksHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('미루는 중'), findsOneWidget);
        expect(find.text('보류함'), findsOneWidget);
        expect(find.text('홈 추천'), findsOneWidget);
        expect(find.text('보류함에서 다시 꺼내볼래'), findsOneWidget);

        expect(find.text('지금 다시 볼 수 있어요'), findsNothing);
        expect(find.text('조금 더 두는 중'), findsNothing);

        final quickEntryTop = tester.getTopLeft(find.text('미루는 중')).dy;
        final recommendationSectionTop = tester
            .getTopLeft(find.text('홈 추천'))
            .dy;
        final revisitSectionTop = tester
            .getTopLeft(find.text('보류함에서 다시 꺼내볼래'))
            .dy;

        expect(quickEntryTop, lessThan(recommendationSectionTop));
        expect(recommendationSectionTop, lessThan(revisitSectionTop));
      },
    );

    testWidgets(
      'home recommendation and revisit cards keep distinct action semantics',
      (tester) async {
        final recommendationTask = Task(
          id: 'direct-recommendation-task',
          title: '오늘 다시 시작할 일',
          status: TaskStatus.postponing,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );
        final revisitTask = Task(
          id: 'revisit-recommendation-task',
          title: '부담 없이 다시 볼 일',
          status: TaskStatus.shelved,
          createdAt: now.subtract(const Duration(days: 40)),
          updatedAt: now.subtract(const Duration(days: 18)),
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        final directRecommendation = TaskRecommendation(
          task: recommendationTask,
          score: 88,
          reasons: const ['지금 붙잡으면 짧게 끝내기 좋아요'],
        );
        final revisitRecommendation = TaskRecommendation(
          task: revisitTask,
          score: 72,
          reasons: const ['한동안 쉬어둔 일이라 천천히 다시 꺼내볼 수 있어요'],
          suggestHoldingRevisit: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeRecommendationCard(
                    recommendation: directRecommendation,
                    onOpen: () {},
                    onSnooze: () {},
                    onShelf: () {},
                  ),
                  HomeRecommendationCard(
                    recommendation: revisitRecommendation,
                    onOpen: () {},
                    onSnooze: () {},
                    onShelf: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('오늘은 이 일만 다시'), findsOneWidget);
        expect(find.text('다시 시작할래'), findsOneWidget);
        expect(find.text('보류함에 둘래'), findsOneWidget);

        expect(find.text('보류함에서 조심스럽게 다시'), findsOneWidget);
        expect(find.text('다시 꺼낼래'), findsOneWidget);
        expect(find.text('더 둘래'), findsOneWidget);
        expect(find.text('상세 보기'), findsOneWidget);
      },
    );

    testWidgets(
      'revisit card exposure, confirm, and dismiss reach persistence through cubit wiring',
      (tester) async {
        final reopenTask = Task(
          id: 'reopen-task',
          title: '다시 시작할 사이드프로젝트',
          status: TaskStatus.shelved,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 16)),
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        final dismissTask = Task(
          id: 'dismiss-task',
          title: '언젠가 읽을 자료 정리',
          status: TaskStatus.shelved,
          createdAt: now.subtract(const Duration(days: 28)),
          updatedAt: now.subtract(const Duration(days: 15)),
          shelvedAt: now.subtract(const Duration(days: 19)),
        );
        final reopenRecommendation = TaskRecommendation(
          task: reopenTask,
          score: 80,
          reasons: const ['한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'],
          suggestHoldingRevisit: true,
        );
        final dismissRecommendation = TaskRecommendation(
          task: dismissTask,
          score: 74,
          reasons: const ['지금은 더 조용히 두는 선택도 괜찮아요'],
          suggestHoldingRevisit: true,
        );

        await repository.save(reopenTask);
        await repository.save(dismissTask);
        await cubit.recordHoldingBoxRevisitExposure([
          reopenRecommendation,
          dismissRecommendation,
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HomeRecommendationCard(
                    recommendation: reopenRecommendation,
                    onOpen: () => cubit.confirmHoldingBoxRevisit(reopenTask),
                    onSnooze: () => cubit.dismissHoldingBoxRevisit(reopenTask),
                    onShelf: () {},
                  ),
                  HomeRecommendationCard(
                    recommendation: dismissRecommendation,
                    onOpen: () => cubit.confirmHoldingBoxRevisit(dismissTask),
                    onSnooze: () => cubit.dismissHoldingBoxRevisit(dismissTask),
                    onShelf: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text(reopenTask.title), findsOneWidget);
        expect(find.text(dismissTask.title), findsOneWidget);

        final exposedReopen = await repository.getById(reopenTask.id);
        final exposedDismiss = await repository.getById(dismissTask.id);
        expect(exposedReopen!.lastHoldingRevisitSuggestedAt, isNotNull);
        expect(exposedDismiss!.lastHoldingRevisitSuggestedAt, isNotNull);

        var reopenEvents = await repository.getSuggestionEventsForTask(
          reopenTask.id,
        );
        var dismissEvents = await repository.getSuggestionEventsForTask(
          dismissTask.id,
        );
        expect(
          reopenEvents.map((event) => event.type),
          contains(TaskSuggestionEventType.holdingRevisitSuggested),
        );
        expect(
          dismissEvents.map((event) => event.type),
          contains(TaskSuggestionEventType.holdingRevisitSuggested),
        );

        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, '다시 꺼낼래').first,
            )
            .onPressed!
            .call();
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, '더 둘래').last,
            )
            .onPressed!
            .call();
        await tester.pump();

        final reopened = await repository.getById(reopenTask.id);
        final dismissed = await repository.getById(dismissTask.id);

        expect(reopened, isNotNull);
        expect(reopened!.status, TaskStatus.postponing);
        expect(reopened.shelvedAt, isNull);
        expect(reopened.lastHoldingRevisitConfirmedAt, isNotNull);
        expect(reopened.lastHoldingRevisitDismissedAt, isNull);

        expect(dismissed, isNotNull);
        expect(dismissed!.status, TaskStatus.shelved);
        expect(dismissed.shelvedAt, isNotNull);
        expect(dismissed.lastHoldingRevisitDismissedAt, isNotNull);

        reopenEvents = await repository.getSuggestionEventsForTask(
          reopenTask.id,
        );
        dismissEvents = await repository.getSuggestionEventsForTask(
          dismissTask.id,
        );
        expect(
          reopenEvents.map((event) => event.type),
          containsAll([
            TaskSuggestionEventType.holdingRevisitSuggested,
            TaskSuggestionEventType.holdingRevisitConfirmed,
          ]),
        );
        expect(
          dismissEvents.map((event) => event.type),
          containsAll([
            TaskSuggestionEventType.holdingRevisitSuggested,
            TaskSuggestionEventType.holdingRevisitDismissed,
          ]),
        );
      },
    );
  });
}

class InMemoryTaskRepository implements TaskRepository {
  final _tasks = <String, Task>{};
  final _events = <TaskSuggestionEvent>[];
  final _controller = StreamController<List<Task>>.broadcast();

  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Stream<List<Task>> watchAll() async* {
    yield _sortedTasks();
    yield* _controller.stream;
  }

  @override
  Future<List<Task>> getAll() async => _sortedTasks();

  @override
  Future<Task?> getById(String id) async => _tasks[id];

  @override
  Future<void> save(Task task) async {
    _tasks[task.id] = task;
    _emit();
  }

  @override
  Future<void> update(Task task) async {
    _tasks[task.id] = task;
    _emit();
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();

  @override
  Future<void> addSuggestionEvent(TaskSuggestionEvent event) async {
    _events.add(event);
  }

  @override
  Future<List<TaskSuggestionEvent>> getSuggestionEventsForTask(
    String taskId,
  ) async {
    return _events.where((event) => event.taskId == taskId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Map<String, TaskSuggestionHistory>> getSuggestionHistories(
    Iterable<String> taskIds,
  ) async {
    final ids = taskIds.toSet();
    return {
      for (final id in ids)
        id: TaskSuggestionHistory.fromEvents(
          id,
          _events.where((event) => event.taskId == id).toList(),
        ),
    };
  }

  List<Task> _sortedTasks() {
    final tasks = _tasks.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tasks;
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(_sortedTasks());
  }
}
