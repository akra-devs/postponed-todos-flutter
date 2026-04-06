import 'dart:async';

import '../domain/task.dart';
import '../domain/task_suggestion_event.dart';
import '../domain/task_suggestion_history.dart';
import 'task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository() {
    _emit();
  }

  final Map<String, Task> _tasks = <String, Task>{};
  final List<TaskSuggestionEvent> _events = <TaskSuggestionEvent>[];
  DateTime? _lastCompletionRewardShownAt;
  final StreamController<List<Task>> _tasksController =
      StreamController<List<Task>>.broadcast();

  Stream<List<Task>> get _watchStream async* {
    yield _sortedTasks();
    yield* _tasksController.stream;
  }

  @override
  Stream<List<Task>> watchAll() => _watchStream;

  @override
  Future<List<Task>> getAll() async => _sortedTasks();

  @override
  Future<Task?> getById(String id) async => _tasks[id];

  @override
  Future<void> save(Task task) async {
    _tasks[task.id] = task;
    _emit();
  }

  @override
  Future<void> update(Task task) async {
    _tasks[task.id] = task;
    _emit();
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    final tasksSnapshot = Map<String, Task>.from(_tasks);
    final eventsSnapshot = List<TaskSuggestionEvent>.from(_events);
    final lastCompletionRewardShownAtSnapshot = _lastCompletionRewardShownAt;

    try {
      final result = await action();
      _emit();
      return result;
    } catch (_) {
      _tasks
        ..clear()
        ..addAll(tasksSnapshot);
      _events
        ..clear()
        ..addAll(eventsSnapshot);
      _lastCompletionRewardShownAt = lastCompletionRewardShownAtSnapshot;
      _emit();
      rethrow;
    }
  }

  @override
  Future<void> addSuggestionEvent(TaskSuggestionEvent event) async {
    _events.add(event);
  }

  @override
  Future<List<TaskSuggestionEvent>> getSuggestionEventsForTask(
    String taskId,
  ) async {
    return _events
        .where((event) => event.taskId == taskId)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Map<String, TaskSuggestionHistory>> getSuggestionHistories(
    Iterable<String> taskIds,
  ) async {
    final ids = taskIds.toSet().toList(growable: false);
    return {
      for (final taskId in ids)
        taskId: TaskSuggestionHistory.fromEvents(
          taskId,
          _events.where((event) => event.taskId == taskId).toList(),
        ),
    };
  }

  @override
  Future<void> markCompletionRewardShown(DateTime at) async {
    _lastCompletionRewardShownAt = at;
  }

  @override
  Future<DateTime?> getLastCompletionRewardShownAt() async {
    return _lastCompletionRewardShownAt;
  }

  Future<void> dispose() => _tasksController.close();

  void _emit() {
    if (!_tasksController.isClosed) {
      _tasksController.add(_sortedTasks());
    }
  }

  List<Task> _sortedTasks() {
    final tasks = _tasks.values.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tasks;
  }
}
