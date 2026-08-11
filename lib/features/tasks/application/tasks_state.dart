import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_history.dart';

enum TaskOperationFailure { load, validation, save, update, action }

extension TaskOperationFailureMessage on TaskOperationFailure {
  String get message => switch (this) {
    TaskOperationFailure.load => '할 일을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
    TaskOperationFailure.validation => '입력한 내용을 다시 확인해 주세요.',
    TaskOperationFailure.save => '할 일을 저장하지 못했어요. 다시 시도해 주세요.',
    TaskOperationFailure.update => '할 일을 수정하지 못했어요. 다시 시도해 주세요.',
    TaskOperationFailure.action => '변경사항을 저장하지 못했어요. 다시 시도해 주세요.',
  };
}

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.recommendations = const [],
    this.holdingBoxRevisitSuggestions = const [],
    this.selectedTaskId,
    this.loading = true,
    this.operationFailure,
  });

  final List<Task> tasks;
  final List<TaskRecommendation> recommendations;
  final List<TaskRecommendation> holdingBoxRevisitSuggestions;
  final String? selectedTaskId;
  final bool loading;
  final TaskOperationFailure? operationFailure;

  Task? get selectedTask => selectedTaskId == null
      ? null
      : tasks.where((task) => task.id == selectedTaskId).firstOrNull;

  List<Task> get postponingTasks =>
      tasks.where((task) => task.status == TaskStatus.postponing).toList();

  List<Task> get availablePostponingTasks => postponingTasks
      .where(
        (task) => TaskSuggestionPolicyView(task: task).isAvailableForReexposure,
      )
      .toList();

  List<Task> get coolingDownTasks => postponingTasks
      .where(
        (task) =>
            !TaskSuggestionPolicyView(task: task).isAvailableForReexposure,
      )
      .toList();

  List<Task> get shelvedTasks =>
      tasks.where((task) => task.status == TaskStatus.shelved).toList();

  TasksState copyWith({
    List<Task>? tasks,
    List<TaskRecommendation>? recommendations,
    List<TaskRecommendation>? holdingBoxRevisitSuggestions,
    String? selectedTaskId,
    bool? loading,
    TaskOperationFailure? operationFailure,
    bool clearOperationFailure = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      recommendations: recommendations ?? this.recommendations,
      holdingBoxRevisitSuggestions:
          holdingBoxRevisitSuggestions ?? this.holdingBoxRevisitSuggestions,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      loading: loading ?? this.loading,
      operationFailure: clearOperationFailure
          ? null
          : (operationFailure ?? this.operationFailure),
    );
  }
}
