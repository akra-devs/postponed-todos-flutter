import '../domain/task.dart';
import '../domain/task_suggestion_event.dart';
import '../data/task_repository.dart';

class TaskSuggestionEventLogger {
  const TaskSuggestionEventLogger(this._repository);

  final TaskRepository _repository;

  Future<void> log({
    required Task task,
    required TaskSuggestionEventType type,
    DateTime? at,
  }) {
    final timestamp = at ?? DateTime.now();
    return _repository.addSuggestionEvent(
      TaskSuggestionEvent(
        id: '${task.id}-${type.name}-${timestamp.microsecondsSinceEpoch}',
        taskId: task.id,
        type: type,
        createdAt: timestamp,
      ),
    );
  }
}
