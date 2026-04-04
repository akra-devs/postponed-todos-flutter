import '../domain/task.dart';
import '../domain/task_suggestion_event.dart';
import '../domain/task_suggestion_history.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAll();
  Future<List<Task>> getAll();
  Future<Task?> getById(String id);
  Future<void> save(Task task);
  Future<void> update(Task task);
  Future<T> transaction<T>(Future<T> Function() action);
  Future<void> addSuggestionEvent(TaskSuggestionEvent event);
  Future<List<TaskSuggestionEvent>> getSuggestionEventsForTask(String taskId);
  Future<Map<String, TaskSuggestionHistory>> getSuggestionHistories(
    Iterable<String> taskIds,
  );
}
