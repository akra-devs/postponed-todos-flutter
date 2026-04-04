import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import '../domain/task_suggestion_history.dart';

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.recommendations = const [],
    this.holdingBoxRevisitSuggestions = const [],
    this.selectedTaskId,
    this.loading = true,
  });

  final List<Task> tasks;
  final List<TaskRecommendation> recommendations;
  final List<TaskRecommendation> holdingBoxRevisitSuggestions;
  final String? selectedTaskId;
  final bool loading;

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
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      recommendations: recommendations ?? this.recommendations,
      holdingBoxRevisitSuggestions:
          holdingBoxRevisitSuggestions ?? this.holdingBoxRevisitSuggestions,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      loading: loading ?? this.loading,
    );
  }
}
