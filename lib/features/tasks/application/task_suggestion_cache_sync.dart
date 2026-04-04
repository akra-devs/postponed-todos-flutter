import '../domain/task.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_history.dart';

class TaskSuggestionCacheSync {
  const TaskSuggestionCacheSync();

  Task afterInteraction(Task task, {required DateTime at}) {
    return task.copyWith(
      updatedAt: at,
      lastInteractedAt: at,
      consecutiveNoActionCount: 0,
    );
  }

  Task afterTransition(
    Task task, {
    required TaskStatus nextStatus,
    required DateTime at,
  }) {
    return task.copyWith(
      status: nextStatus,
      updatedAt: at,
      lastInteractedAt: at,
      closedAt: nextStatus.isClosed ? at : null,
      clearClosedAt: !nextStatus.isClosed,
      clearResurfaceAt: nextStatus == TaskStatus.postponing,
      consecutiveNoActionCount: 0,
      consecutiveSnoozeCount: nextStatus == TaskStatus.postponing
          ? 0
          : task.consecutiveSnoozeCount,
      shelvedAt: nextStatus == TaskStatus.shelved ? at : null,
      clearShelvedAt: nextStatus != TaskStatus.shelved,
    );
  }

  Task afterSnooze(
    Task task, {
    required TaskSuggestionPolicyView policy,
    required DateTime resurfaceAt,
    required DateTime at,
  }) {
    return task.copyWith(
      updatedAt: at,
      lastInteractedAt: at,
      resurfaceAt: resurfaceAt,
      consecutiveSnoozeCount: policy.consecutiveSnoozeCount + 1,
      consecutiveNoActionCount: 0,
    );
  }

  Task afterRecommendationExposure(
    Task task, {
    required TaskSuggestionPolicyView policy,
    required DateTime at,
  }) {
    return task.copyWith(
      updatedAt: task.updatedAt,
      lastExposedAt: at,
      consecutiveNoActionCount: policy.consecutiveNoActionCount + 1,
    );
  }

  Task afterHoldingRevisitSuggested(Task task, {required DateTime at}) {
    return task.copyWith(
      updatedAt: task.updatedAt,
      lastHoldingRevisitSuggestedAt: at,
    );
  }

  Task afterHoldingRevisitConfirmed(Task task, {required DateTime at}) {
    return task.copyWith(
      status: TaskStatus.postponing,
      updatedAt: at,
      lastInteractedAt: at,
      clearClosedAt: true,
      clearResurfaceAt: true,
      clearShelvedAt: true,
      consecutiveSnoozeCount: 0,
      consecutiveNoActionCount: 0,
      lastHoldingRevisitConfirmedAt: at,
      clearLastHoldingRevisitDismissedAt: true,
    );
  }

  Task afterHoldingRevisitDismissed(Task task, {required DateTime at}) {
    return task.copyWith(
      updatedAt: task.updatedAt,
      lastHoldingRevisitDismissedAt: at,
    );
  }
}
