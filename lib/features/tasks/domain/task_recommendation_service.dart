import 'task.dart';
import 'task_suggestion_history.dart';

abstract class TaskRecommendationService {
  List<TaskRecommendation> rank(
    List<Task> candidates, {
    Map<String, TaskSuggestionHistory> histories = const {},
    int limit = 4,
  });

  List<TaskRecommendation> rankHoldingBoxRevisitSuggestions(
    List<Task> tasks, {
    Map<String, TaskSuggestionHistory> histories = const {},
    int limit = 2,
  });
}

class TaskRecommendation {
  const TaskRecommendation({
    required this.task,
    required this.score,
    required this.reasons,
    this.suggestHoldingBox = false,
    this.suggestHoldingRevisit = false,
    this.lastExposedAt,
  });

  final Task task;
  final double score;
  final List<String> reasons;
  final bool suggestHoldingBox;
  final bool suggestHoldingRevisit;
  final DateTime? lastExposedAt;
}
