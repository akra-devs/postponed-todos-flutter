import 'package:drift/drift.dart';

import '../domain/task.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_event.dart';
import '../domain/task_suggestion_history.dart';
import 'local/app_database.dart';
import 'task_repository.dart';

class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._database);

  final AppDatabase _database;
  static const String _completionRewardMetaKey = "completionRewardShownAt";

  @override
  Stream<List<Task>> watchAll() {
    final query = _database.select(_database.tasksTable)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<List<Task>> getAll() async {
    final rows = await (_database.select(
      _database.tasksTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return rows.map(_mapRow).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final row = await (_database.select(
      _database.tasksTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> save(Task task) {
    return _database.into(_database.tasksTable).insert(_toCompanion(task));
  }

  @override
  Future<void> update(Task task) {
    return _database
        .into(_database.tasksTable)
        .insertOnConflictUpdate(_toCompanion(task));
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) {
    return _database.transaction(action);
  }

  @override
  Future<void> addSuggestionEvent(TaskSuggestionEvent event) {
    return _database
        .into(_database.taskSuggestionEventsTable)
        .insert(
          TaskSuggestionEventsTableCompanion(
            id: Value(event.id),
            taskId: Value(event.taskId),
            type: Value(event.type.name),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  @override
  Future<List<TaskSuggestionEvent>> getSuggestionEventsForTask(
    String taskId,
  ) async {
    final rows =
        await (_database.select(_database.taskSuggestionEventsTable)
              ..where((tbl) => tbl.taskId.equals(taskId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_mapSuggestionEvent).toList();
  }

  @override
  Future<Map<String, TaskSuggestionHistory>> getSuggestionHistories(
    Iterable<String> taskIds,
  ) async {
    final ids = taskIds.toSet().toList(growable: false);
    if (ids.isEmpty) return const {};

    final rows =
        await (_database.select(_database.taskSuggestionEventsTable)
              ..where((tbl) => tbl.taskId.isIn(ids))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    final eventsByTask = <String, List<TaskSuggestionEvent>>{
      for (final id in ids) id: <TaskSuggestionEvent>[],
    };

    for (final row in rows) {
      final event = _mapSuggestionEvent(row);
      eventsByTask
          .putIfAbsent(event.taskId, () => <TaskSuggestionEvent>[])
          .add(event);
    }

    return {
      for (final entry in eventsByTask.entries)
        entry.key: TaskSuggestionHistory.fromEvents(entry.key, entry.value),
    };
  }

  @override
  Future<void> markCompletionRewardShown(DateTime at) async {
    // Persisted in key-value table via sqlite preference table if available.
    // Reuse taskSuggestionEvents table as a timestamp marker to keep schema stable.
    await _database
        .into(_database.taskSuggestionEventsTable)
        .insertOnConflictUpdate(
          TaskSuggestionEventsTableCompanion(
            id: Value(_completionRewardMetaKey),
            taskId: Value('__meta__'),
            type: Value(TaskSuggestionEventType.completionRewardShown.name),
            createdAt: Value(at),
          ),
        );
  }

  @override
  Future<DateTime?> getLastCompletionRewardShownAt() async {
    final row =
        await (_database.select(_database.taskSuggestionEventsTable)
              ..where((tbl) => tbl.id.equals(_completionRewardMetaKey))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return row.createdAt;
  }

  Task _mapRow(TasksTableData row) {
    return Task(
      id: row.id,
      title: row.title,
      note: row.note,
      status: TaskStatus.values.byName(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastInteractedAt: row.lastInteractedAt,
      resurfaceAt: row.resurfaceAt,
      closedAt: row.closedAt,
      consecutiveSnoozeCount: row.consecutiveSnoozeCount,
      consecutiveNoActionCount: row.consecutiveNoActionCount,
      lastExposedAt: row.lastExposedAt,
      shelvedAt: row.shelvedAt,
      lastHoldingRevisitSuggestedAt: row.lastHoldingRevisitSuggestedAt,
      lastHoldingRevisitConfirmedAt: row.lastHoldingRevisitConfirmedAt,
      lastHoldingRevisitDismissedAt: row.lastHoldingRevisitDismissedAt,
    );
  }

  TaskSuggestionEvent _mapSuggestionEvent(TaskSuggestionEventsTableData row) {
    return TaskSuggestionEvent(
      id: row.id,
      taskId: row.taskId,
      type: TaskSuggestionEventType.values.byName(row.type),
      createdAt: row.createdAt,
    );
  }

  TasksTableCompanion _toCompanion(Task task) {
    return TasksTableCompanion(
      id: Value(task.id),
      title: Value(task.title),
      note: Value(task.note),
      status: Value(task.status.name),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      lastInteractedAt: Value(task.lastInteractedAt),
      resurfaceAt: Value(task.resurfaceAt),
      closedAt: Value(task.closedAt),
      consecutiveSnoozeCount: Value(task.consecutiveSnoozeCount),
      consecutiveNoActionCount: Value(task.consecutiveNoActionCount),
      lastExposedAt: Value(task.lastExposedAt),
      shelvedAt: Value(task.shelvedAt),
      lastHoldingRevisitSuggestedAt: Value(task.lastHoldingRevisitSuggestedAt),
      lastHoldingRevisitConfirmedAt: Value(task.lastHoldingRevisitConfirmedAt),
      lastHoldingRevisitDismissedAt: Value(task.lastHoldingRevisitDismissedAt),
    );
  }
}
