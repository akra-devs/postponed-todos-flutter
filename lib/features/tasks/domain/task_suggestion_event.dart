enum TaskSuggestionEventType {
  recommendationExposed,
  recommendationOpened,
  snoozed,
  holdingSuggested,
  holdingConfirmed,
  holdingCancelled,
  holdingRevisitSuggested,
  holdingRevisitConfirmed,
  holdingRevisitDismissed,
}

class TaskSuggestionEvent {
  const TaskSuggestionEvent({
    required this.id,
    required this.taskId,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final TaskSuggestionEventType type;
  final DateTime createdAt;
}
