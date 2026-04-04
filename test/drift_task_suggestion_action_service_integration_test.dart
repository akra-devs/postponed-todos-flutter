import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/task_suggestion_action_service.dart';
import 'package:postponed_todos/features/tasks/data/drift_task_repository.dart';
import 'package:postponed_todos/features/tasks/data/local/app_database.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_event.dart';

void main() {
  group('TaskSuggestionActionService Drift integration', () {
    late AppDatabase database;
    late FailingDriftTaskRepository repository;
    late TaskSuggestionActionService service;
    late DateTime now;
    late Task task;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = FailingDriftTaskRepository(database);
      service = TaskSuggestionActionService(repository);
      now = DateTime(2026, 4, 4, 12);
      task = Task(
        id: 'task-1',
        title: '책상 정리',
        status: TaskStatus.postponing,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );
      await repository.save(task);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'persists recommendation exposure writes on real Drift transaction when exposure path succeeds',
      () async {
        final recommendation = TaskRecommendation(
          task: task,
          score: 62,
          reasons: const ['가볍게 다시 시작하기 쉬워 보여'],
          suggestHoldingBox: true,
        );

        await service.recordRecommendationExposure([recommendation], now: now);

        final persisted = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(persisted, isNotNull);
        expect(persisted!.lastExposedAt, now);
        expect(persisted.consecutiveNoActionCount, 1);
        expect(events, hasLength(2));
        expect(events.map((event) => event.type), [
          TaskSuggestionEventType.recommendationExposed,
          TaskSuggestionEventType.holdingSuggested,
        ]);
        expect(events.every((event) => event.taskId == task.id), isTrue);
        expect(events.every((event) => event.createdAt == now), isTrue);
      },
    );

    test(
      'rolls back recommendation exposure writes on real Drift transaction when holding event logging fails',
      () async {
        repository.failOnEventType = TaskSuggestionEventType.holdingSuggested;
        final recommendation = TaskRecommendation(
          task: task,
          score: 62,
          reasons: const ['가볍게 다시 시작하기 쉬워 보여'],
          suggestHoldingBox: true,
        );

        await expectLater(
          () =>
              service.recordRecommendationExposure([recommendation], now: now),
          throwsA(isA<StateError>()),
        );

        final unchanged = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.lastExposedAt, isNull);
        expect(unchanged.consecutiveNoActionCount, 0);
        expect(events, isEmpty);
      },
    );

    test(
      'rolls back snooze writes on real Drift transaction when snooze event logging fails',
      () async {
        repository.failOnEventType = TaskSuggestionEventType.snoozed;

        await expectLater(
          () => service.snooze(task, now: now),
          throwsA(isA<StateError>()),
        );

        final unchanged = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.consecutiveSnoozeCount, 0);
        expect(unchanged.lastInteractedAt, isNull);
        expect(unchanged.resurfaceAt, isNull);
        expect(events, isEmpty);
      },
    );

    test(
      'persists shelving confirmation writes on real Drift transaction when confirm path succeeds',
      () async {
        final postponingTask = task.copyWith(
          updatedAt: now.subtract(const Duration(days: 5)),
          lastInteractedAt: now.subtract(const Duration(days: 4)),
          resurfaceAt: now.add(const Duration(days: 2)),
          closedAt: now.subtract(const Duration(days: 3)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 8)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 6)),
          lastHoldingRevisitConfirmedAt: now.subtract(const Duration(days: 5)),
          lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 4)),
        );
        await repository.update(postponingTask);

        await service.transition(postponingTask, TaskStatus.shelved, now: now);

        final persisted = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(persisted, isNotNull);
        expect(persisted!.status, TaskStatus.shelved);
        expect(persisted.updatedAt, now);
        expect(persisted.lastInteractedAt, now);
        expect(persisted.resurfaceAt, postponingTask.resurfaceAt);
        expect(persisted.closedAt, isNull);
        expect(
          persisted.consecutiveSnoozeCount,
          postponingTask.consecutiveSnoozeCount,
        );
        expect(persisted.consecutiveNoActionCount, 0);
        expect(persisted.shelvedAt, now);
        expect(
          persisted.lastHoldingRevisitSuggestedAt,
          postponingTask.lastHoldingRevisitSuggestedAt,
        );
        expect(
          persisted.lastHoldingRevisitConfirmedAt,
          postponingTask.lastHoldingRevisitConfirmedAt,
        );
        expect(
          persisted.lastHoldingRevisitDismissedAt,
          postponingTask.lastHoldingRevisitDismissedAt,
        );

        expect(events, hasLength(1));
        expect(events.single.type, TaskSuggestionEventType.holdingConfirmed);
        expect(events.single.taskId, task.id);
        expect(events.single.createdAt, now);
      },
    );

    test(
      'rolls back shelving confirmation writes on real Drift transaction when confirm event logging fails',
      () async {
        repository.failOnEventType = TaskSuggestionEventType.holdingConfirmed;
        final postponingTask = task.copyWith(
          updatedAt: now.subtract(const Duration(days: 5)),
          lastInteractedAt: now.subtract(const Duration(days: 4)),
          resurfaceAt: now.add(const Duration(days: 2)),
          closedAt: now.subtract(const Duration(days: 3)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 8)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 6)),
          lastHoldingRevisitConfirmedAt: now.subtract(const Duration(days: 5)),
          lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 4)),
        );
        await repository.update(postponingTask);

        await expectLater(
          () =>
              service.transition(postponingTask, TaskStatus.shelved, now: now),
          throwsA(isA<StateError>()),
        );

        final unchanged = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.status, TaskStatus.postponing);
        expect(unchanged.updatedAt, postponingTask.updatedAt);
        expect(unchanged.lastInteractedAt, postponingTask.lastInteractedAt);
        expect(unchanged.resurfaceAt, postponingTask.resurfaceAt);
        expect(unchanged.closedAt, postponingTask.closedAt);
        expect(
          unchanged.consecutiveSnoozeCount,
          postponingTask.consecutiveSnoozeCount,
        );
        expect(
          unchanged.consecutiveNoActionCount,
          postponingTask.consecutiveNoActionCount,
        );
        expect(unchanged.shelvedAt, postponingTask.shelvedAt);
        expect(
          unchanged.lastHoldingRevisitSuggestedAt,
          postponingTask.lastHoldingRevisitSuggestedAt,
        );
        expect(
          unchanged.lastHoldingRevisitConfirmedAt,
          postponingTask.lastHoldingRevisitConfirmedAt,
        );
        expect(
          unchanged.lastHoldingRevisitDismissedAt,
          postponingTask.lastHoldingRevisitDismissedAt,
        );
        expect(events, isEmpty);
      },
    );

    test(
      'persists holding revisit exposure writes on real Drift transaction when exposure path succeeds',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        await repository.update(shelvedTask);

        await service.recordHoldingBoxRevisitExposure([
          TaskRecommendation(
            task: shelvedTask,
            score: 44,
            reasons: const ['조금 쉬었다 다시 꺼내볼 수 있어 보여'],
            suggestHoldingRevisit: true,
          ),
        ], now: now);

        final persisted = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(persisted, isNotNull);
        expect(persisted!.lastHoldingRevisitSuggestedAt, now);
        expect(events, hasLength(1));
        expect(
          events.single.type,
          TaskSuggestionEventType.holdingRevisitSuggested,
        );
        expect(events.single.taskId, task.id);
        expect(events.single.createdAt, now);
      },
    );

    test(
      'persists holding revisit confirm reopen writes on real Drift transaction when confirm path succeeds',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          updatedAt: now.subtract(const Duration(days: 15)),
          lastInteractedAt: now.subtract(const Duration(days: 16)),
          resurfaceAt: now.subtract(const Duration(days: 3)),
          closedAt: now.subtract(const Duration(days: 10)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 20)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 2)),
          lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 1)),
        );
        await repository.update(shelvedTask);

        await service.confirmHoldingBoxRevisit(shelvedTask, now: now);

        final persisted = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(persisted, isNotNull);
        expect(persisted!.status, TaskStatus.postponing);
        expect(persisted.updatedAt, now);
        expect(persisted.lastInteractedAt, now);
        expect(persisted.resurfaceAt, isNull);
        expect(persisted.closedAt, isNull);
        expect(persisted.consecutiveSnoozeCount, 0);
        expect(persisted.consecutiveNoActionCount, 0);
        expect(persisted.shelvedAt, isNull);
        expect(
          persisted.lastHoldingRevisitSuggestedAt,
          shelvedTask.lastHoldingRevisitSuggestedAt,
        );
        expect(persisted.lastHoldingRevisitConfirmedAt, now);
        expect(persisted.lastHoldingRevisitDismissedAt, isNull);

        expect(events, hasLength(1));
        expect(
          events.single.type,
          TaskSuggestionEventType.holdingRevisitConfirmed,
        );
        expect(events.single.taskId, task.id);
        expect(events.single.createdAt, now);
      },
    );

    test(
      'rolls back holding revisit confirm reopen writes on real Drift transaction when confirm event logging fails',
      () async {
        repository.failOnEventType =
            TaskSuggestionEventType.holdingRevisitConfirmed;
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          updatedAt: now.subtract(const Duration(days: 15)),
          lastInteractedAt: now.subtract(const Duration(days: 16)),
          resurfaceAt: now.subtract(const Duration(days: 3)),
          closedAt: now.subtract(const Duration(days: 10)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 20)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 2)),
          lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 1)),
        );
        await repository.update(shelvedTask);

        await expectLater(
          () => service.confirmHoldingBoxRevisit(shelvedTask, now: now),
          throwsA(isA<StateError>()),
        );

        final unchanged = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.status, TaskStatus.shelved);
        expect(unchanged.updatedAt, shelvedTask.updatedAt);
        expect(unchanged.lastInteractedAt, shelvedTask.lastInteractedAt);
        expect(unchanged.resurfaceAt, shelvedTask.resurfaceAt);
        expect(unchanged.closedAt, shelvedTask.closedAt);
        expect(
          unchanged.consecutiveSnoozeCount,
          shelvedTask.consecutiveSnoozeCount,
        );
        expect(
          unchanged.consecutiveNoActionCount,
          shelvedTask.consecutiveNoActionCount,
        );
        expect(unchanged.shelvedAt, shelvedTask.shelvedAt);
        expect(
          unchanged.lastHoldingRevisitSuggestedAt,
          shelvedTask.lastHoldingRevisitSuggestedAt,
        );
        expect(
          unchanged.lastHoldingRevisitDismissedAt,
          shelvedTask.lastHoldingRevisitDismissedAt,
        );
        expect(unchanged.lastHoldingRevisitConfirmedAt, isNull);
        expect(events, isEmpty);
      },
    );

    test(
      'persists holding revisit dismiss writes on real Drift transaction when dismiss path succeeds',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          updatedAt: now.subtract(const Duration(days: 15)),
          lastInteractedAt: now.subtract(const Duration(days: 16)),
          resurfaceAt: now.subtract(const Duration(days: 3)),
          closedAt: now.subtract(const Duration(days: 10)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 20)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 2)),
          lastHoldingRevisitConfirmedAt: now.subtract(const Duration(days: 1)),
        );
        await repository.update(shelvedTask);

        await service.dismissHoldingBoxRevisit(shelvedTask, now: now);

        final persisted = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(persisted, isNotNull);
        expect(persisted!.status, TaskStatus.shelved);
        expect(persisted.updatedAt, shelvedTask.updatedAt);
        expect(persisted.lastInteractedAt, shelvedTask.lastInteractedAt);
        expect(persisted.resurfaceAt, shelvedTask.resurfaceAt);
        expect(persisted.closedAt, shelvedTask.closedAt);
        expect(
          persisted.consecutiveSnoozeCount,
          shelvedTask.consecutiveSnoozeCount,
        );
        expect(
          persisted.consecutiveNoActionCount,
          shelvedTask.consecutiveNoActionCount,
        );
        expect(persisted.shelvedAt, shelvedTask.shelvedAt);
        expect(
          persisted.lastHoldingRevisitSuggestedAt,
          shelvedTask.lastHoldingRevisitSuggestedAt,
        );
        expect(
          persisted.lastHoldingRevisitConfirmedAt,
          shelvedTask.lastHoldingRevisitConfirmedAt,
        );
        expect(persisted.lastHoldingRevisitDismissedAt, now);

        expect(events, hasLength(1));
        expect(
          events.single.type,
          TaskSuggestionEventType.holdingRevisitDismissed,
        );
        expect(events.single.taskId, task.id);
        expect(events.single.createdAt, now);
      },
    );

    test(
      'rolls back holding revisit dismiss writes on real Drift transaction when dismiss event logging fails',
      () async {
        repository.failOnEventType =
            TaskSuggestionEventType.holdingRevisitDismissed;
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          updatedAt: now.subtract(const Duration(days: 15)),
          lastInteractedAt: now.subtract(const Duration(days: 16)),
          resurfaceAt: now.subtract(const Duration(days: 3)),
          closedAt: now.subtract(const Duration(days: 10)),
          consecutiveSnoozeCount: 2,
          consecutiveNoActionCount: 3,
          shelvedAt: now.subtract(const Duration(days: 20)),
          lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 2)),
          lastHoldingRevisitConfirmedAt: now.subtract(const Duration(days: 1)),
        );
        await repository.update(shelvedTask);

        await expectLater(
          () => service.dismissHoldingBoxRevisit(shelvedTask, now: now),
          throwsA(isA<StateError>()),
        );

        final unchanged = await repository.getById(task.id);
        final events = await repository.getSuggestionEventsForTask(task.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.status, TaskStatus.shelved);
        expect(unchanged.updatedAt, shelvedTask.updatedAt);
        expect(unchanged.lastInteractedAt, shelvedTask.lastInteractedAt);
        expect(unchanged.resurfaceAt, shelvedTask.resurfaceAt);
        expect(unchanged.closedAt, shelvedTask.closedAt);
        expect(
          unchanged.consecutiveSnoozeCount,
          shelvedTask.consecutiveSnoozeCount,
        );
        expect(
          unchanged.consecutiveNoActionCount,
          shelvedTask.consecutiveNoActionCount,
        );
        expect(unchanged.shelvedAt, shelvedTask.shelvedAt);
        expect(
          unchanged.lastHoldingRevisitSuggestedAt,
          shelvedTask.lastHoldingRevisitSuggestedAt,
        );
        expect(
          unchanged.lastHoldingRevisitConfirmedAt,
          shelvedTask.lastHoldingRevisitConfirmedAt,
        );
        expect(unchanged.lastHoldingRevisitDismissedAt, isNull);
        expect(events, isEmpty);
      },
    );
  });
}

class FailingDriftTaskRepository extends DriftTaskRepository {
  FailingDriftTaskRepository(super.database);

  TaskSuggestionEventType? failOnEventType;

  @override
  Future<void> addSuggestionEvent(TaskSuggestionEvent event) {
    if (event.type == failOnEventType) {
      throw StateError('failed to log ${event.type.name}');
    }
    return super.addSuggestionEvent(event);
  }
}
