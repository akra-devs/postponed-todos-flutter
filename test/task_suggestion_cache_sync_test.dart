import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/task_suggestion_cache_sync.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_event.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_history.dart';

void main() {
  const sync = TaskSuggestionCacheSync();

  Task buildTask({
    required String id,
    required DateTime now,
    TaskStatus status = TaskStatus.postponing,
    int consecutiveSnoozeCount = 0,
    int consecutiveNoActionCount = 0,
    DateTime? lastExposedAt,
    DateTime? shelvedAt,
    DateTime? lastHoldingRevisitDismissedAt,
  }) {
    return Task(
      id: id,
      title: '테스트',
      status: status,
      createdAt: now,
      updatedAt: now,
      consecutiveSnoozeCount: consecutiveSnoozeCount,
      consecutiveNoActionCount: consecutiveNoActionCount,
      lastExposedAt: lastExposedAt,
      shelvedAt: shelvedAt,
      lastHoldingRevisitDismissedAt: lastHoldingRevisitDismissedAt,
    );
  }

  TaskSuggestionPolicyView buildPolicy({
    required Task task,
    required DateTime now,
    int exposureCount = 0,
    int snoozeCount = 0,
  }) {
    final events = <TaskSuggestionEvent>[
      for (var index = 0; index < exposureCount; index += 1)
        TaskSuggestionEvent(
          id: 'exposed-$index',
          taskId: task.id,
          type: TaskSuggestionEventType.recommendationExposed,
          createdAt: now.subtract(Duration(hours: exposureCount - index)),
        ),
      for (var index = 0; index < snoozeCount; index += 1)
        TaskSuggestionEvent(
          id: 'snoozed-$index',
          taskId: task.id,
          type: TaskSuggestionEventType.snoozed,
          createdAt: now.subtract(Duration(minutes: snoozeCount - index)),
        ),
    ];

    return TaskSuggestionHistory.fromEvents(task.id, events).project(task);
  }

  test('syncs recommendation exposure cache fields from policy state', () {
    final now = DateTime.now();
    final task = buildTask(id: 'task', now: now);
    final updated = sync.afterRecommendationExposure(
      task,
      policy: buildPolicy(task: task, now: now, exposureCount: 2),
      at: now.add(const Duration(hours: 1)),
    );

    expect(updated.lastExposedAt, now.add(const Duration(hours: 1)));
    expect(updated.consecutiveNoActionCount, 3);
    expect(updated.updatedAt, task.updatedAt);
  });

  test('clears revisit-dismiss cache when holding revisit is confirmed', () {
    final now = DateTime.now();
    final task = buildTask(
      id: 'task',
      now: now,
      status: TaskStatus.shelved,
      consecutiveSnoozeCount: 3,
      consecutiveNoActionCount: 4,
      shelvedAt: now.subtract(const Duration(days: 20)),
      lastHoldingRevisitDismissedAt: now.subtract(const Duration(days: 1)),
    );

    final updated = sync.afterHoldingRevisitConfirmed(
      task,
      at: now.add(const Duration(days: 1)),
    );

    expect(updated.status, TaskStatus.postponing);
    expect(updated.shelvedAt, isNull);
    expect(updated.lastHoldingRevisitDismissedAt, isNull);
    expect(
      updated.lastHoldingRevisitConfirmedAt,
      now.add(const Duration(days: 1)),
    );
    expect(updated.consecutiveSnoozeCount, 0);
    expect(updated.consecutiveNoActionCount, 0);
  });

  test('uses projected snooze streak when syncing snooze cache fields', () {
    final now = DateTime.now();
    final task = buildTask(id: 'task', now: now, consecutiveSnoozeCount: 0);
    final updated = sync.afterSnooze(
      task,
      policy: buildPolicy(task: task, now: now, snoozeCount: 2),
      resurfaceAt: now.add(const Duration(days: 3)),
      at: now.add(const Duration(hours: 2)),
    );

    expect(updated.consecutiveSnoozeCount, 3);
    expect(updated.consecutiveNoActionCount, 0);
    expect(updated.resurfaceAt, now.add(const Duration(days: 3)));
    expect(updated.lastInteractedAt, now.add(const Duration(hours: 2)));
  });
}
