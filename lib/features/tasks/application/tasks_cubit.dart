import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_event.dart';
import '../domain/task_suggestion_history.dart';
import 'task_suggestion_action_service.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._repository, this._recommendationService)
    : _actionService = TaskSuggestionActionService(_repository),
      super(const TasksState()) {
    _subscription = _repository.watchAll().listen((tasks) async {
      final suggestionHistories = await _loadSuggestionHistories(tasks);
      emit(
        state.copyWith(
          tasks: tasks,
          recommendations: _recommendationService.rank(
            tasks,
            histories: suggestionHistories,
          ),
          holdingBoxRevisitSuggestions: _recommendationService
              .rankHoldingBoxRevisitSuggestions(
                tasks,
                histories: suggestionHistories,
              ),
          loading: false,
        ),
      );
    });
  }

  static const String _completionRewardMetaTaskId = '__completion_reward__';

  final TaskRepository _repository;
  final TaskRecommendationService _recommendationService;
  final TaskSuggestionActionService _actionService;
  StreamSubscription<List<Task>>? _subscription;

  Future<Map<String, TaskSuggestionHistory>> _loadSuggestionHistories(
    List<Task> tasks,
  ) {
    return _repository.getSuggestionHistories(tasks.map((task) => task.id));
  }

  Future<void> addTask({required String title, String? note}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final task = Task(
      id: now.microsecondsSinceEpoch.toString(),
      title: trimmed,
      note: note?.trim().isEmpty ?? true ? null : note?.trim(),
      status: TaskStatus.postponing,
      createdAt: now,
      updatedAt: now,
      lastInteractedAt: now,
    );
    await _repository.save(task);
    emit(state.copyWith(selectedTaskId: task.id));
  }

  void selectTask(String? id) {
    emit(state.copyWith(selectedTaskId: id));
  }

  Future<void> markTaskInteracted(Task task) {
    return _actionService.markTaskInteracted(task);
  }

  Future<void> transition(Task task, TaskStatus nextStatus) {
    return _actionService.transition(task, nextStatus);
  }

  Future<void> snooze(Task task) {
    return _actionService.snooze(task);
  }

  Future<void> reopenFromShelved(Task task) =>
      transition(task, TaskStatus.postponing);

  Future<void> recordHoldingBoxRevisitExposure(
    List<TaskRecommendation> suggestions,
  ) {
    return _actionService.recordHoldingBoxRevisitExposure(suggestions);
  }

  Future<void> confirmHoldingBoxRevisit(Task task) {
    return _actionService.confirmHoldingBoxRevisit(task);
  }

  Future<void> dismissHoldingBoxRevisit(Task task) {
    return _actionService.dismissHoldingBoxRevisit(task);
  }

  Future<void> recordRecommendationExposure(
    List<TaskRecommendation> recommendations,
  ) {
    return _actionService.recordRecommendationExposure(recommendations);
  }

  Future<void> recordHoldingSuggestionDismissed(Task task) {
    return _actionService.recordHoldingSuggestionDismissed(task);
  }

  Future<bool> shouldShowCompletionReward({DateTime? now}) async {
    final timestamp = now ?? DateTime.now();

    await _recordCompletionRewardAttempt(timestamp);

    final attempts = await _loadCompletionRewardAttempts();
    if (attempts == 1 || attempts % 3 == 0) {
      await _repository.markCompletionRewardShown(timestamp);
      return true;
    }

    return false;
  }

  Future<void> _recordCompletionRewardAttempt(DateTime timestamp) {
    return _repository.addSuggestionEvent(
      TaskSuggestionEvent(
        id: '$_completionRewardMetaTaskId-attempt-${timestamp.microsecondsSinceEpoch}',
        taskId: _completionRewardMetaTaskId,
        type: TaskSuggestionEventType.completionRewardAttempted,
        createdAt: timestamp,
      ),
    );
  }

  Future<int> _loadCompletionRewardAttempts() async {
    final events = await _repository.getSuggestionEventsForTask(
      _completionRewardMetaTaskId,
    );
    return events
        .where(
          (event) =>
              event.type == TaskSuggestionEventType.completionRewardAttempted,
        )
        .length;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
