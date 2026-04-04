import '../../../core/config/product_policy_defaults.dart';
import 'task.dart';
import 'task_status.dart';
import 'task_suggestion_event.dart';

class TaskSuggestionHistory {
  const TaskSuggestionHistory({
    required this.taskId,
    this.exposureCount = 0,
    this.consecutiveNoActionCount = 0,
    this.consecutiveSnoozeCount = 0,
    this.lastExposedAt,
    this.lastOpenedAt,
    this.lastSnoozedAt,
    this.lastHoldingSuggestedAt,
    this.lastHoldingRevisitSuggestedAt,
    this.lastHoldingRevisitDismissedAt,
  });

  final String taskId;
  final int exposureCount;
  final int consecutiveNoActionCount;
  final int consecutiveSnoozeCount;
  final DateTime? lastExposedAt;
  final DateTime? lastOpenedAt;
  final DateTime? lastSnoozedAt;
  final DateTime? lastHoldingSuggestedAt;
  final DateTime? lastHoldingRevisitSuggestedAt;
  final DateTime? lastHoldingRevisitDismissedAt;

  TaskSuggestionPolicyView project(Task task) {
    return TaskSuggestionPolicyView(task: task, history: this);
  }

  bool get isHoldingBoxSuggestionCandidate =>
      consecutiveSnoozeCount >= 3 ||
      consecutiveNoActionCount >=
          ProductPolicyDefaults.holdingBoxSuggestionThreshold;

  bool isEligibleForHoldingBoxRevisit(Task task, {DateTime? now}) {
    if (task.status != TaskStatus.shelved || task.shelvedAt == null) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    final revisitAnchor =
        [
          task.shelvedAt,
          lastHoldingRevisitSuggestedAt,
          lastHoldingRevisitDismissedAt,
        ].whereType<DateTime>().fold<DateTime>(
          task.shelvedAt!,
          (latest, current) => current.isAfter(latest) ? current : latest,
        );

    return !revisitAnchor
        .add(ProductPolicyDefaults.holdingBoxRevisitSuggestion)
        .isAfter(currentTime);
  }

  static TaskSuggestionHistory fromEvents(
    String taskId,
    List<TaskSuggestionEvent> events,
  ) {
    final ordered = [...events]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return TaskSuggestionHistory(
      taskId: taskId,
      exposureCount: ordered
          .where(
            (event) =>
                event.type == TaskSuggestionEventType.recommendationExposed,
          )
          .length,
      consecutiveNoActionCount: _countTrailingExposureStreak(ordered),
      consecutiveSnoozeCount: _countTrailingSnoozeStreak(ordered),
      lastExposedAt: _lastAt(
        ordered,
        TaskSuggestionEventType.recommendationExposed,
      ),
      lastOpenedAt: _lastAt(
        ordered,
        TaskSuggestionEventType.recommendationOpened,
      ),
      lastSnoozedAt: _lastAt(ordered, TaskSuggestionEventType.snoozed),
      lastHoldingSuggestedAt: _lastAt(
        ordered,
        TaskSuggestionEventType.holdingSuggested,
      ),
      lastHoldingRevisitSuggestedAt: _lastAt(
        ordered,
        TaskSuggestionEventType.holdingRevisitSuggested,
      ),
      lastHoldingRevisitDismissedAt: _lastAt(
        ordered,
        TaskSuggestionEventType.holdingRevisitDismissed,
      ),
    );
  }

  static DateTime? _lastAt(
    List<TaskSuggestionEvent> events,
    TaskSuggestionEventType type,
  ) {
    for (final event in events) {
      if (event.type == type) return event.createdAt;
    }
    return null;
  }

  static int _countTrailingExposureStreak(List<TaskSuggestionEvent> events) {
    var count = 0;
    for (final event in events) {
      if (event.type == TaskSuggestionEventType.recommendationExposed) {
        count += 1;
        continue;
      }
      if (_resetsNoActionStreak(event.type)) {
        break;
      }
    }
    return count;
  }

  static int _countTrailingSnoozeStreak(List<TaskSuggestionEvent> events) {
    var count = 0;
    for (final event in events) {
      if (event.type == TaskSuggestionEventType.snoozed) {
        count += 1;
        continue;
      }
      if (_resetsSnoozeStreak(event.type)) {
        break;
      }
    }
    return count;
  }

  static bool _resetsNoActionStreak(TaskSuggestionEventType type) {
    return switch (type) {
      TaskSuggestionEventType.recommendationOpened ||
      TaskSuggestionEventType.snoozed ||
      TaskSuggestionEventType.holdingConfirmed ||
      TaskSuggestionEventType.holdingRevisitConfirmed => true,
      _ => false,
    };
  }

  static bool _resetsSnoozeStreak(TaskSuggestionEventType type) {
    return switch (type) {
      TaskSuggestionEventType.recommendationOpened ||
      TaskSuggestionEventType.holdingConfirmed ||
      TaskSuggestionEventType.holdingRevisitConfirmed => true,
      _ => false,
    };
  }
}

class TaskSuggestionPolicyView {
  const TaskSuggestionPolicyView({required this.task, this.history});

  final Task task;
  final TaskSuggestionHistory? history;

  /// Resolved policy view for recommendation decisions.
  ///
  /// History-derived values are authoritative when present.
  /// Task fields act as compatibility/cache fallbacks for older rows and
  /// lightweight reads outside the suggestion pipeline.

  int get consecutiveNoActionCount =>
      history?.consecutiveNoActionCount ?? task.consecutiveNoActionCount;

  int get consecutiveSnoozeCount =>
      history?.consecutiveSnoozeCount ?? task.consecutiveSnoozeCount;

  DateTime? get lastExposedAt => history?.lastExposedAt ?? task.lastExposedAt;

  DateTime? get lastHoldingRevisitSuggestedAt =>
      history?.lastHoldingRevisitSuggestedAt ??
      task.lastHoldingRevisitSuggestedAt;

  DateTime? get lastHoldingRevisitDismissedAt =>
      history?.lastHoldingRevisitDismissedAt ??
      task.lastHoldingRevisitDismissedAt;

  bool get isAvailableForReexposure =>
      task.status == TaskStatus.postponing && !isUnderResurfaceCooldown;

  bool get isUnderResurfaceCooldown =>
      task.resurfaceAt != null && task.resurfaceAt!.isAfter(DateTime.now());

  bool get isHoldingBoxSuggestionCandidate =>
      consecutiveSnoozeCount >= 3 ||
      consecutiveNoActionCount >=
          ProductPolicyDefaults.holdingBoxSuggestionThreshold;

  bool get isEligibleForHoldingBoxRevisit {
    if (task.status != TaskStatus.shelved || task.shelvedAt == null) {
      return false;
    }

    final now = DateTime.now();
    final revisitAnchor =
        [
          task.shelvedAt,
          lastHoldingRevisitSuggestedAt,
          lastHoldingRevisitDismissedAt,
        ].whereType<DateTime>().fold<DateTime>(
          task.shelvedAt!,
          (latest, current) => current.isAfter(latest) ? current : latest,
        );

    return !revisitAnchor
        .add(ProductPolicyDefaults.holdingBoxRevisitSuggestion)
        .isAfter(now);
  }

  bool wasExposedWithin(Duration duration, {DateTime? now}) {
    final exposedAt = lastExposedAt;
    if (exposedAt == null) return false;
    return (now ?? DateTime.now()).difference(exposedAt) < duration;
  }
}
