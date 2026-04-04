import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/task_suggestion_action_service.dart';
import 'package:postponed_todos/features/tasks/data/task_repository.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_event.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_history.dart';

void main() {
  group('TaskSuggestionActionService', () {
    late InMemoryTaskRepository repository;
    late TaskSuggestionActionService service;
    late DateTime now;
    late Task task;

    setUp(() {
      repository = InMemoryTaskRepository();
      service = TaskSuggestionActionService(repository);
      now = DateTime(2026, 4, 4, 12);
      task = Task(
        id: 'task-1',
        title: '책상 정리',
        status: TaskStatus.postponing,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );
      repository.tasks[task.id] = task;
    });

    test(
      'records recommendation exposure with cache sync and holding suggestion event',
      () async {
        final recommendation = TaskRecommendation(
          task: task,
          score: 62,
          reasons: const ['가볍게 다시 시작하기 쉬워 보여'],
          suggestHoldingBox: true,
        );

        await service.recordRecommendationExposure([recommendation], now: now);

        final updated = repository.tasks[task.id]!;
        expect(updated.lastExposedAt, now);
        expect(updated.consecutiveNoActionCount, 1);
        expect(repository.events.map((event) => event.type), [
          TaskSuggestionEventType.recommendationExposed,
          TaskSuggestionEventType.holdingSuggested,
        ]);
      },
    );

    test(
      'uses history projection when snoozing to sync cache and log event',
      () async {
        repository.histories[task.id] =
            TaskSuggestionHistory.fromEvents(task.id, [
              TaskSuggestionEvent(
                id: 's-1',
                taskId: task.id,
                type: TaskSuggestionEventType.snoozed,
                createdAt: now.subtract(const Duration(days: 4)),
              ),
              TaskSuggestionEvent(
                id: 's-2',
                taskId: task.id,
                type: TaskSuggestionEventType.snoozed,
                createdAt: now.subtract(const Duration(days: 2)),
              ),
            ]);

        await service.snooze(task, now: now);

        final updated = repository.tasks[task.id]!;
        expect(updated.consecutiveSnoozeCount, 3);
        expect(updated.lastInteractedAt, now);
        expect(updated.resurfaceAt, now.add(const Duration(days: 7)));
        expect(repository.events.single.type, TaskSuggestionEventType.snoozed);
      },
    );

    test(
      'blocks duplicate recommendation exposure inside 12-hour dedupe window',
      () async {
        repository.histories[task.id] =
            TaskSuggestionHistory.fromEvents(task.id, [
              TaskSuggestionEvent(
                id: 'rec-1',
                taskId: task.id,
                type: TaskSuggestionEventType.recommendationExposed,
                createdAt: now.subtract(const Duration(hours: 11, minutes: 59)),
              ),
            ]);

        final recommendation = TaskRecommendation(
          task: task,
          score: 62,
          reasons: const ['가볍게 다시 시작하기 쉬워 보여'],
          suggestHoldingBox: true,
        );

        await service.recordRecommendationExposure([recommendation], now: now);

        final unchanged = repository.tasks[task.id]!;
        expect(unchanged.lastExposedAt, isNull);
        expect(unchanged.consecutiveNoActionCount, 0);
        expect(repository.events, isEmpty);
      },
    );

    test(
      'records fresh recommendation exposure at 12-hour boundary or later',
      () async {
        repository.histories[task.id] =
            TaskSuggestionHistory.fromEvents(task.id, [
              TaskSuggestionEvent(
                id: 'rec-2',
                taskId: task.id,
                type: TaskSuggestionEventType.recommendationExposed,
                createdAt: now.subtract(const Duration(hours: 12)),
              ),
            ]);

        final recommendation = TaskRecommendation(
          task: task,
          score: 62,
          reasons: const ['가볍게 다시 시작하기 쉬워 보여'],
          suggestHoldingBox: true,
        );

        await service.recordRecommendationExposure([recommendation], now: now);

        final updated = repository.tasks[task.id]!;
        expect(updated.lastExposedAt, now);
        expect(updated.consecutiveNoActionCount, 2);
        expect(repository.events.map((event) => event.type), [
          TaskSuggestionEventType.recommendationExposed,
          TaskSuggestionEventType.holdingSuggested,
        ]);
      },
    );

    test(
      'blocks duplicate holding revisit exposure inside 12-hour dedupe window',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        repository.tasks[shelvedTask.id] = shelvedTask;
        repository.histories[shelvedTask.id] =
            TaskSuggestionHistory.fromEvents(shelvedTask.id, [
              TaskSuggestionEvent(
                id: 'hrs-1',
                taskId: shelvedTask.id,
                type: TaskSuggestionEventType.holdingRevisitSuggested,
                createdAt: now.subtract(const Duration(hours: 11, minutes: 59)),
              ),
            ]);

        await service.recordHoldingBoxRevisitExposure([
          TaskRecommendation(
            task: shelvedTask,
            score: 44,
            reasons: const ['조금 쉬었다 다시 꺼내볼 수 있어 보여'],
            suggestHoldingRevisit: true,
          ),
        ], now: now);

        final unchanged = repository.tasks[shelvedTask.id]!;
        expect(unchanged.lastHoldingRevisitSuggestedAt, isNull);
        expect(repository.events, isEmpty);
      },
    );

    test(
      'records fresh holding revisit exposure at 12-hour boundary or later',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          shelvedAt: now.subtract(const Duration(days: 20)),
        );
        repository.tasks[shelvedTask.id] = shelvedTask;
        repository.histories[shelvedTask.id] =
            TaskSuggestionHistory.fromEvents(shelvedTask.id, [
              TaskSuggestionEvent(
                id: 'hrs-2',
                taskId: shelvedTask.id,
                type: TaskSuggestionEventType.holdingRevisitSuggested,
                createdAt: now.subtract(const Duration(hours: 12)),
              ),
            ]);

        await service.recordHoldingBoxRevisitExposure([
          TaskRecommendation(
            task: shelvedTask,
            score: 44,
            reasons: const ['조금 쉬었다 다시 꺼내볼 수 있어 보여'],
            suggestHoldingRevisit: true,
          ),
        ], now: now);

        final updated = repository.tasks[shelvedTask.id]!;
        expect(updated.lastHoldingRevisitSuggestedAt, now);
        expect(repository.events.map((event) => event.type), [
          TaskSuggestionEventType.holdingRevisitSuggested,
        ]);
      },
    );

    test(
      'confirms holding revisit by reopening task and logging event',
      () async {
        final shelvedTask = task.copyWith(
          status: TaskStatus.shelved,
          shelvedAt: now.subtract(const Duration(days: 20)),
          lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 1)),
        );
        repository.tasks[shelvedTask.id] = shelvedTask;

        await service.confirmHoldingBoxRevisit(shelvedTask, now: now);

        final updated = repository.tasks[shelvedTask.id]!;
        expect(updated.status, TaskStatus.postponing);
        expect(updated.shelvedAt, isNull);
        expect(updated.lastHoldingRevisitDismissedAt, isNull);
        expect(
          repository.events.single.type,
          TaskSuggestionEventType.holdingRevisitConfirmed,
        );
      },
    );

    test(
      'rolls back recommendation exposure when event logging fails',
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

        final unchanged = repository.tasks[task.id]!;
        expect(unchanged.lastExposedAt, isNull);
        expect(unchanged.consecutiveNoActionCount, 0);
        expect(repository.events, isEmpty);
      },
    );

    test('rolls back snooze cache update when event logging fails', () async {
      repository.failOnEventType = TaskSuggestionEventType.snoozed;

      await expectLater(
        () => service.snooze(task, now: now),
        throwsA(isA<StateError>()),
      );

      final unchanged = repository.tasks[task.id]!;
      expect(unchanged.consecutiveSnoozeCount, 0);
      expect(unchanged.lastInteractedAt, isNull);
      expect(unchanged.resurfaceAt, isNull);
      expect(repository.events, isEmpty);
    });
  });
}

class InMemoryTaskRepository implements TaskRepository {
  final Map<String, Task> tasks = <String, Task>{};
  final Map<String, TaskSuggestionHistory> histories =
      <String, TaskSuggestionHistory>{};
  final List<TaskSuggestionEvent> events = <TaskSuggestionEvent>[];
  TaskSuggestionEventType? failOnEventType;

  @override
  Future<void> addSuggestionEvent(TaskSuggestionEvent event) async {
    if (event.type == failOnEventType) {
      throw StateError('failed to log ${event.type.name}');
    }
    events.add(event);
  }

  @override
  Future<List<Task>> getAll() async => tasks.values.toList(growable: false);

  @override
  Future<Task?> getById(String id) async => tasks[id];

  @override
  Future<List<TaskSuggestionEvent>> getSuggestionEventsForTask(
    String taskId,
  ) async {
    return events
        .where((event) => event.taskId == taskId)
        .toList(growable: false);
  }

  @override
  Future<Map<String, TaskSuggestionHistory>> getSuggestionHistories(
    Iterable<String> taskIds,
  ) async {
    return {
      for (final taskId in taskIds)
        if (histories.containsKey(taskId)) taskId: histories[taskId]!,
    };
  }

  @override
  Future<void> save(Task task) async {
    tasks[task.id] = task;
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    final tasksSnapshot = Map<String, Task>.from(tasks);
    final historiesSnapshot = Map<String, TaskSuggestionHistory>.from(
      histories,
    );
    final eventsSnapshot = List<TaskSuggestionEvent>.from(events);

    try {
      return await action();
    } catch (_) {
      tasks
        ..clear()
        ..addAll(tasksSnapshot);
      histories
        ..clear()
        ..addAll(historiesSnapshot);
      events
        ..clear()
        ..addAll(eventsSnapshot);
      rethrow;
    }
  }

  @override
  Future<void> update(Task task) async {
    tasks[task.id] = task;
  }

  @override
  Stream<List<Task>> watchAll() => const Stream.empty();
}
