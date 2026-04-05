import '../../../core/config/product_policy_defaults.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_suggestion_history.dart';

class DefaultTaskRecommendationService implements TaskRecommendationService {
  const DefaultTaskRecommendationService();

  @override
  List<TaskRecommendation> rank(
    List<Task> candidates, {
    Map<String, TaskSuggestionHistory> histories = const {},
    int limit = ProductPolicyDefaults.homeDefaultCards,
  }) {
    final ranked =
        candidates
            .where(
              (task) => TaskSuggestionPolicyView(
                task: task,
                history: histories[task.id],
              ).isAvailableForReexposure,
            )
            .map((task) => _score(task, histories[task.id]))
            .toList()
          ..sort(_compareRecommendation);

    return _applyLightDiversity(ranked).take(limit).toList(growable: false);
  }

  TaskRecommendation _score(Task task, TaskSuggestionHistory? history) {
    final now = DateTime.now();
    final policy = TaskSuggestionPolicyView(task: task, history: history);
    final reasons = <String>[];
    var score = 50.0;

    final creationBonus = _recentCreationBonus(task, now);
    if (creationBonus > 0) {
      score += creationBonus;
      reasons.add('최근에 담아둔 일이라 다시 붙잡기 쉬워 보여요');
    }

    final easyReentryBonus = _easyReentryBonus(task);
    score += easyReentryBonus;
    if (easyReentryBonus >= 15) {
      reasons.add('짧고 가벼워 보여서 지금 해보기 쉬워요');
    } else if (easyReentryBonus > 0) {
      reasons.add('지금 가볍게 다시 꺼내보기 괜찮아 보여요');
    }

    final interestBonus = _userInterestBonus(task, now);
    if (interestBonus > 0) {
      score += interestBonus;
      reasons.add('최근에 다시 들여다본 흔적이 있어요');
    }

    final snoozePenalty = _snoozePenalty(policy);
    if (snoozePenalty > 0) {
      score -= snoozePenalty;
      reasons.add('여러 번 쉬었다 다시 볼 수 있게 잠시 내려뒀어요');
    }

    final noActionPenalty = _noActionPenalty(policy);
    if (noActionPenalty > 0) {
      score -= noActionPenalty;
      reasons.add('최근 홈에서 반응 없이 지나간 적이 있어요');
    }

    final recentExposurePenalty = _recentExposurePenalty(policy, now);
    if (recentExposurePenalty > 0) {
      score -= recentExposurePenalty;
      reasons.add('너무 자주 보이지 않도록 잠시 뒤로 물렸어요');
    }

    final heavyRepeatPenalty = _heavyRepeatPenalty(policy, now);
    if (heavyRepeatPenalty > 0) {
      score -= heavyRepeatPenalty;
      reasons.add('무거운 일 하나가 홈을 오래 차지하지 않게 조정했어요');
    }

    if (policy.isHoldingBoxSuggestionCandidate) {
      reasons.add('반복해서 뒤로 둔 일이어서 잠시 보류함에 두는 선택도 괜찮아요');
    }

    return TaskRecommendation(
      task: task,
      score: score,
      reasons: reasons,
      suggestHoldingBox: policy.isHoldingBoxSuggestionCandidate,
      lastExposedAt: policy.lastExposedAt,
    );
  }

  @override
  List<TaskRecommendation> rankHoldingBoxRevisitSuggestions(
    List<Task> tasks, {
    Map<String, TaskSuggestionHistory> histories = const {},
    int limit = 2,
  }) {
    final candidates =
        tasks
            .where(
              (task) => TaskSuggestionPolicyView(
                task: task,
                history: histories[task.id],
              ).isEligibleForHoldingBoxRevisit,
            )
            .map((task) => _scoreHoldingBoxRevisit(task, histories[task.id]))
            .toList()
          ..sort(_compareRecommendation);

    return candidates.take(limit).toList(growable: false);
  }

  TaskRecommendation _scoreHoldingBoxRevisit(
    Task task,
    TaskSuggestionHistory? history,
  ) {
    final policy = TaskSuggestionPolicyView(task: task, history: history);
    final reasons = <String>['한동안 쉬어뒀던 일이라 부담 없이 다시 꺼내볼 수 있어요'];

    if (policy.lastHoldingRevisitDismissedAt != null) {
      reasons.add('이전 제안 뒤에도 충분히 시간을 두고 다시 가져왔어요');
    }

    return TaskRecommendation(
      task: task,
      score: 40,
      reasons: reasons,
      suggestHoldingRevisit: true,
      lastExposedAt: policy.lastExposedAt,
    );
  }

  int _compareRecommendation(
    TaskRecommendation left,
    TaskRecommendation right,
  ) {
    final byScore = right.score.compareTo(left.score);
    if (byScore != 0) return byScore;

    final leftExposure = left.lastExposedAt;
    final rightExposure = right.lastExposedAt;
    if (leftExposure == null && rightExposure != null) return -1;
    if (leftExposure != null && rightExposure == null) return 1;
    if (leftExposure != null && rightExposure != null) {
      final byExposure = leftExposure.compareTo(rightExposure);
      if (byExposure != 0) return byExposure;
    }

    final byCreation = right.task.createdAt.compareTo(left.task.createdAt);
    if (byCreation != 0) return byCreation;

    return left.task.id.compareTo(right.task.id);
  }

  List<TaskRecommendation> _applyLightDiversity(
    List<TaskRecommendation> ranked,
  ) {
    var heavyStreak = 0;
    final diversified = <TaskRecommendation>[];
    final deferredHeavy = <TaskRecommendation>[];

    for (final recommendation in ranked) {
      final isHeavy = _isHeavyTask(recommendation.task);
      if (isHeavy && heavyStreak >= 2) {
        deferredHeavy.add(recommendation);
        continue;
      }

      diversified.add(recommendation);
      heavyStreak = isHeavy ? heavyStreak + 1 : 0;
    }

    diversified.addAll(deferredHeavy);
    return diversified;
  }

  double _recentCreationBonus(Task task, DateTime now) {
    final age = now.difference(task.createdAt);
    if (age <= const Duration(hours: 24)) return 12;
    if (age <= const Duration(days: 3)) return 8;
    if (age <= const Duration(days: 7)) return 4;
    return 0;
  }

  double _easyReentryBonus(Task task) {
    final text = '${task.title} ${task.note ?? ''}'.trim();
    final isHeavy = _isHeavyTask(task);
    if (isHeavy) return 0;
    if (_looksQuickTask(text)) return 15;
    return 7;
  }

  double _userInterestBonus(Task task, DateTime now) {
    final interaction = task.lastInteractedAt;
    if (interaction == null) return 0;
    return now.difference(interaction) <= const Duration(days: 3) ? 8 : 0;
  }

  double _snoozePenalty(TaskSuggestionPolicyView policy) {
    final count = policy.consecutiveSnoozeCount;
    if (count <= 0) return 0;
    if (count == 1) return 4;
    if (count == 2) return 10;
    return 18;
  }

  double _noActionPenalty(TaskSuggestionPolicyView policy) {
    final count = policy.consecutiveNoActionCount;
    if (count <= 1) return 0;
    if (count == 2) return 6;
    if (count == 3) return 12;
    return 20;
  }

  double _recentExposurePenalty(TaskSuggestionPolicyView policy, DateTime now) {
    final exposedAt = policy.lastExposedAt;
    if (exposedAt == null) return 0;
    final elapsed = now.difference(exposedAt);
    if (elapsed <= const Duration(hours: 24)) return 12;
    if (elapsed <= const Duration(days: 3)) return 6;
    return 0;
  }

  double _heavyRepeatPenalty(TaskSuggestionPolicyView policy, DateTime now) {
    final exposedAt = policy.lastExposedAt;
    if (!_isHeavyTask(policy.task) || exposedAt == null) return 0;
    return now.difference(exposedAt) <= const Duration(days: 3) ? 10 : 0;
  }

  bool _looksQuickTask(String text) {
    final normalized = text.toLowerCase();
    final wordCount = normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
    final quickKeywords = ['보내기', '답장', '예약', '정리', '확인', '구매', '전화', '메일'];
    return wordCount <= 6 || quickKeywords.any(normalized.contains);
  }

  bool _isHeavyTask(Task task) {
    final text = '${task.title} ${task.note ?? ''}'.trim().toLowerCase();
    final heavyKeywords = ['기획', '정리하기', '준비', '프로젝트', '전면', '전체', '리서치', '계획'];
    final wordCount = text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    return wordCount >= 10 || heavyKeywords.any(text.contains);
  }
}
