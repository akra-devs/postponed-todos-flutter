import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_event.dart';
import 'package:postponed_todos/features/tasks/domain/task_suggestion_history.dart';

void main() {
  const service = DefaultTaskRecommendationService();

  Task buildTask({
    required String id,
    required String title,
    required DateTime now,
    TaskStatus status = TaskStatus.postponing,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInteractedAt,
    DateTime? resurfaceAt,
    int consecutiveSnoozeCount = 0,
    int consecutiveNoActionCount = 0,
    DateTime? lastExposedAt,
    DateTime? shelvedAt,
    DateTime? lastHoldingRevisitSuggestedAt,
    DateTime? lastHoldingRevisitDismissedAt,
  }) {
    return Task(
      id: id,
      title: title,
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      lastInteractedAt: lastInteractedAt,
      resurfaceAt: resurfaceAt,
      consecutiveSnoozeCount: consecutiveSnoozeCount,
      consecutiveNoActionCount: consecutiveNoActionCount,
      lastExposedAt: lastExposedAt,
      shelvedAt: shelvedAt,
      lastHoldingRevisitSuggestedAt: lastHoldingRevisitSuggestedAt,
      lastHoldingRevisitDismissedAt: lastHoldingRevisitDismissedAt,
    );
  }

  TaskSuggestionEvent buildEvent({
    required String id,
    required String taskId,
    required TaskSuggestionEventType type,
    required DateTime at,
  }) {
    return TaskSuggestionEvent(
      id: id,
      taskId: taskId,
      type: type,
      createdAt: at,
    );
  }

  test(
    'filters out shelved, closed, and cooldown tasks from home recommendations',
    () {
      final now = DateTime.now();
      final recommendations = service.rank([
        buildTask(id: 'a', title: '답장 보내기', now: now),
        buildTask(
          id: 'b',
          title: '보류된 일',
          now: now,
          status: TaskStatus.shelved,
        ),
        buildTask(id: 'c', title: '완료된 일', now: now, status: TaskStatus.done),
        buildTask(
          id: 'd',
          title: '다시 보기 대기',
          now: now,
          resurfaceAt: now.add(const Duration(hours: 12)),
        ),
      ]);

      expect(recommendations.map((item) => item.task.id), ['a']);
    },
  );

  test('builds suggestion history streaks from event log', () {
    final now = DateTime.now();
    final history = TaskSuggestionHistory.fromEvents('candidate', [
      buildEvent(
        id: 'opened-old',
        taskId: 'candidate',
        type: TaskSuggestionEventType.recommendationOpened,
        at: now.subtract(const Duration(days: 4)),
      ),
      buildEvent(
        id: 'exposed-1',
        taskId: 'candidate',
        type: TaskSuggestionEventType.recommendationExposed,
        at: now.subtract(const Duration(days: 3)),
      ),
      buildEvent(
        id: 'exposed-2',
        taskId: 'candidate',
        type: TaskSuggestionEventType.recommendationExposed,
        at: now.subtract(const Duration(days: 2)),
      ),
      buildEvent(
        id: 'snooze-1',
        taskId: 'candidate',
        type: TaskSuggestionEventType.snoozed,
        at: now.subtract(const Duration(days: 1, hours: 12)),
      ),
      buildEvent(
        id: 'snooze-2',
        taskId: 'candidate',
        type: TaskSuggestionEventType.snoozed,
        at: now.subtract(const Duration(days: 1)),
      ),
      buildEvent(
        id: 'exposed-3',
        taskId: 'candidate',
        type: TaskSuggestionEventType.recommendationExposed,
        at: now.subtract(const Duration(hours: 12)),
      ),
      buildEvent(
        id: 'exposed-4',
        taskId: 'candidate',
        type: TaskSuggestionEventType.recommendationExposed,
        at: now.subtract(const Duration(hours: 3)),
      ),
    ]);

    expect(history.exposureCount, 4);
    expect(history.consecutiveNoActionCount, 2);
    expect(history.consecutiveSnoozeCount, 2);
    expect(history.lastExposedAt, isNotNull);
  });

  test('marks holding-box suggestion candidates from repeated snoozes', () {
    final now = DateTime.now();
    final task = buildTask(
      id: 'candidate',
      title: '프로젝트 전체 리서치 계획 정리하기',
      now: now,
    );
    final history = TaskSuggestionHistory.fromEvents('candidate', [
      buildEvent(
        id: 's1',
        taskId: 'candidate',
        type: TaskSuggestionEventType.snoozed,
        at: now.subtract(const Duration(days: 3)),
      ),
      buildEvent(
        id: 's2',
        taskId: 'candidate',
        type: TaskSuggestionEventType.snoozed,
        at: now.subtract(const Duration(days: 2)),
      ),
      buildEvent(
        id: 's3',
        taskId: 'candidate',
        type: TaskSuggestionEventType.snoozed,
        at: now.subtract(const Duration(days: 1)),
      ),
    ]);

    final recommendations = service.rank([task], histories: {task.id: history});

    expect(recommendations.single.suggestHoldingBox, isTrue);
  });

  test('marks holding-box suggestion candidates from repeated no action', () {
    final now = DateTime.now();
    final task = buildTask(id: 'candidate', title: '답장 보내기', now: now);
    final history = TaskSuggestionHistory.fromEvents('candidate', [
      for (var index = 0; index < 4; index += 1)
        buildEvent(
          id: 'e$index',
          taskId: 'candidate',
          type: TaskSuggestionEventType.recommendationExposed,
          at: now.subtract(Duration(hours: 24 - (index * 3))),
        ),
    ]);

    final recommendations = service.rank([task], histories: {task.id: history});

    expect(recommendations.single.suggestHoldingBox, isTrue);
  });

  test('suggests 14-day holding-box revisit for long-rested shelved task', () {
    final now = DateTime.now();
    final recommendations = service.rankHoldingBoxRevisitSuggestions([
      buildTask(
        id: 'shelved',
        title: '언젠가 읽고 싶은 글 정리',
        now: now,
        status: TaskStatus.shelved,
        shelvedAt: now.subtract(const Duration(days: 15)),
      ),
    ]);

    expect(recommendations.single.task.id, 'shelved');
    expect(recommendations.single.suggestHoldingRevisit, isTrue);
  });

  test(
    'does not resuggest holding-box revisit before another 14 days pass',
    () {
      final now = DateTime.now();
      final task = buildTask(
        id: 'shelved',
        title: '언젠가 읽고 싶은 글 정리',
        now: now,
        status: TaskStatus.shelved,
        shelvedAt: now.subtract(const Duration(days: 30)),
      );
      final history = TaskSuggestionHistory.fromEvents('shelved', [
        buildEvent(
          id: 'revisit',
          taskId: 'shelved',
          type: TaskSuggestionEventType.holdingRevisitSuggested,
          at: now.subtract(const Duration(days: 5)),
        ),
      ]);

      final recommendations = service.rankHoldingBoxRevisitSuggestions(
        [task],
        histories: {task.id: history},
      );

      expect(recommendations, isEmpty);
    },
  );

  test('uses suggestion history over stale holding revisit task metadata', () {
    final now = DateTime.now();
    final task = buildTask(
      id: 'shelved',
      title: '언젠가 읽고 싶은 글 정리',
      now: now,
      status: TaskStatus.shelved,
      shelvedAt: now.subtract(const Duration(days: 30)),
      lastHoldingRevisitSuggestedAt: now.subtract(const Duration(days: 30)),
    );

    final recommendations = service.rankHoldingBoxRevisitSuggestions(
      [task],
      histories: {
        task.id: TaskSuggestionHistory.fromEvents('shelved', [
          buildEvent(
            id: 'revisit-fresh',
            taskId: 'shelved',
            type: TaskSuggestionEventType.holdingRevisitSuggested,
            at: now.subtract(const Duration(days: 3)),
          ),
        ]),
      },
    );

    expect(recommendations, isEmpty);
  });

  test('uses suggestion history over stale task exposure metadata', () {
    final now = DateTime.now();
    final staleTask = buildTask(
      id: 'stale',
      title: '메일 답장 보내기',
      now: now,
      createdAt: now.subtract(const Duration(days: 2)),
      lastExposedAt: now.subtract(const Duration(days: 5)),
    );
    final freshTask = buildTask(
      id: 'fresh',
      title: '계좌 확인하기',
      now: now,
      createdAt: now.subtract(const Duration(days: 2)),
      lastExposedAt: now.subtract(const Duration(days: 5)),
    );

    final recommendations = service.rank(
      [staleTask, freshTask],
      histories: {
        staleTask.id: TaskSuggestionHistory.fromEvents('stale', [
          buildEvent(
            id: 'stale-exposed',
            taskId: 'stale',
            type: TaskSuggestionEventType.recommendationExposed,
            at: now.subtract(const Duration(hours: 2)),
          ),
        ]),
      },
    );

    expect(recommendations.first.task.id, 'fresh');
  });

  test('prefers easy re-entry task over repeatedly snoozed heavy task', () {
    final now = DateTime.now();
    final heavy = buildTask(
      id: 'heavy',
      title: '프로젝트 전체 리서치 계획 정리하기',
      now: now,
      createdAt: now.subtract(const Duration(days: 10)),
      lastExposedAt: now.subtract(const Duration(hours: 4)),
    );
    final easy = buildTask(
      id: 'easy',
      title: '메일 답장 보내기',
      now: now,
      createdAt: now.subtract(const Duration(hours: 5)),
      lastInteractedAt: now.subtract(const Duration(hours: 2)),
    );

    final recommendations = service.rank(
      [heavy, easy],
      histories: {
        heavy.id: TaskSuggestionHistory.fromEvents('heavy', [
          buildEvent(
            id: 'hs1',
            taskId: 'heavy',
            type: TaskSuggestionEventType.snoozed,
            at: now.subtract(const Duration(days: 3)),
          ),
          buildEvent(
            id: 'hs2',
            taskId: 'heavy',
            type: TaskSuggestionEventType.snoozed,
            at: now.subtract(const Duration(days: 2)),
          ),
          buildEvent(
            id: 'hs3',
            taskId: 'heavy',
            type: TaskSuggestionEventType.snoozed,
            at: now.subtract(const Duration(days: 1)),
          ),
          buildEvent(
            id: 'he1',
            taskId: 'heavy',
            type: TaskSuggestionEventType.recommendationExposed,
            at: now.subtract(const Duration(hours: 4)),
          ),
          buildEvent(
            id: 'he2',
            taskId: 'heavy',
            type: TaskSuggestionEventType.recommendationExposed,
            at: now.subtract(const Duration(hours: 2)),
          ),
          buildEvent(
            id: 'he3',
            taskId: 'heavy',
            type: TaskSuggestionEventType.recommendationExposed,
            at: now.subtract(const Duration(hours: 1)),
          ),
        ]),
      },
    );

    expect(recommendations.first.task.id, 'easy');
    expect(
      recommendations.first.score,
      greaterThan(recommendations.last.score),
    );
    expect(recommendations.first.reasons, isNotEmpty);
  });
}
