import '../../../core/config/product_policy_defaults.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_event.dart';
import '../domain/task_suggestion_history.dart';
import '../domain/task_transition.dart';
import 'task_suggestion_cache_sync.dart';
import 'task_suggestion_event_logger.dart';

class TaskSuggestionActionService {
  TaskSuggestionActionService(this._repository)
    : _eventLogger = TaskSuggestionEventLogger(_repository);

  final TaskRepository _repository;
  final TaskSuggestionEventLogger _eventLogger;
  static const TaskSuggestionCacheSync _cacheSync = TaskSuggestionCacheSync();

  Future<void> markTaskInteracted(Task task, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    await _repository.transaction(() async {
      await _repository.update(
        _cacheSync.afterInteraction(task, at: timestamp),
      );
      await _eventLogger.log(
        task: task,
        type: TaskSuggestionEventType.recommendationOpened,
        at: timestamp,
      );
    });
  }

  Future<void> transition(
    Task task,
    TaskStatus nextStatus, {
    DateTime? now,
  }) async {
    if (!TaskTransitionRule.canTransition(task.status, nextStatus)) return;

    final timestamp = now ?? DateTime.now();
    if (nextStatus == TaskStatus.shelved) {
      await _repository.transaction(() async {
        await _repository.update(
          _cacheSync.afterTransition(
            task,
            nextStatus: nextStatus,
            at: timestamp,
          ),
        );
        await _eventLogger.log(
          task: task,
          type: TaskSuggestionEventType.holdingConfirmed,
          at: timestamp,
        );
      });
      return;
    }

    await _repository.update(
      _cacheSync.afterTransition(task, nextStatus: nextStatus, at: timestamp),
    );
  }

  Future<void> snooze(Task task, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    final history = await _loadHistory(task);
    final policy = TaskSuggestionPolicyView(task: task, history: history);
    final nextCount = policy.consecutiveSnoozeCount + 1;
    final cooldown = ProductPolicyDefaults.cooldownForSnoozeCount(nextCount);

    await _repository.transaction(() async {
      await _repository.update(
        _cacheSync.afterSnooze(
          task,
          policy: policy,
          resurfaceAt: timestamp.add(cooldown),
          at: timestamp,
        ),
      );
      await _eventLogger.log(
        task: task,
        type: TaskSuggestionEventType.snoozed,
        at: timestamp,
      );
    });
  }

  Future<void> recordHoldingBoxRevisitExposure(
    List<TaskRecommendation> suggestions, {
    DateTime? now,
  }) async {
    if (suggestions.isEmpty) return;

    final histories = await _loadHistories(
      suggestions.map((item) => item.task),
    );
    final timestamp = now ?? DateTime.now();

    for (final suggestion in suggestions) {
      final task = suggestion.task;
      final policy = TaskSuggestionPolicyView(
        task: task,
        history: histories[task.id],
      );
      final lastSuggestedAt = policy.lastHoldingRevisitSuggestedAt;
      final wasRecentlySuggested =
          lastSuggestedAt != null &&
          timestamp.difference(lastSuggestedAt) < const Duration(hours: 12);
      if (wasRecentlySuggested) continue;

      await _repository.transaction(() async {
        await _repository.update(
          _cacheSync.afterHoldingRevisitSuggested(task, at: timestamp),
        );
        await _eventLogger.log(
          task: task,
          type: TaskSuggestionEventType.holdingRevisitSuggested,
          at: timestamp,
        );
      });
    }
  }

  Future<void> confirmHoldingBoxRevisit(Task task, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    await _repository.transaction(() async {
      await _repository.update(
        _cacheSync.afterHoldingRevisitConfirmed(task, at: timestamp),
      );
      await _eventLogger.log(
        task: task,
        type: TaskSuggestionEventType.holdingRevisitConfirmed,
        at: timestamp,
      );
    });
  }

  Future<void> dismissHoldingBoxRevisit(Task task, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    await _repository.transaction(() async {
      await _repository.update(
        _cacheSync.afterHoldingRevisitDismissed(task, at: timestamp),
      );
      await _eventLogger.log(
        task: task,
        type: TaskSuggestionEventType.holdingRevisitDismissed,
        at: timestamp,
      );
    });
  }

  Future<void> recordRecommendationExposure(
    List<TaskRecommendation> recommendations, {
    DateTime? now,
  }) async {
    if (recommendations.isEmpty) return;

    final histories = await _loadHistories(
      recommendations.map((recommendation) => recommendation.task),
    );
    final timestamp = now ?? DateTime.now();

    for (final recommendation in recommendations) {
      final task = recommendation.task;
      final policy = TaskSuggestionPolicyView(
        task: task,
        history: histories[task.id],
      );
      if (policy.wasExposedWithin(const Duration(hours: 12), now: timestamp)) {
        continue;
      }

      await _repository.transaction(() async {
        await _repository.update(
          _cacheSync.afterRecommendationExposure(
            task,
            policy: policy,
            at: timestamp,
          ),
        );
        await _eventLogger.log(
          task: task,
          type: TaskSuggestionEventType.recommendationExposed,
          at: timestamp,
        );
        if (recommendation.suggestHoldingBox) {
          await _eventLogger.log(
            task: task,
            type: TaskSuggestionEventType.holdingSuggested,
            at: timestamp,
          );
        }
      });
    }
  }

  Future<void> recordHoldingSuggestionDismissed(Task task, {DateTime? now}) {
    return _eventLogger.log(
      task: task,
      type: TaskSuggestionEventType.holdingCancelled,
      at: now,
    );
  }

  Future<TaskSuggestionHistory?> _loadHistory(Task task) async {
    final histories = await _loadHistories([task]);
    return histories[task.id];
  }

  Future<Map<String, TaskSuggestionHistory>> _loadHistories(
    Iterable<Task> tasks,
  ) {
    return _repository.getSuggestionHistories(tasks.map((task) => task.id));
  }
}
