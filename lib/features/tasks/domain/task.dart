import '../../../core/config/product_policy_defaults.dart';
import 'task_status.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.lastInteractedAt,
    this.resurfaceAt,
    this.closedAt,
    this.consecutiveSnoozeCount = 0,
    this.consecutiveNoActionCount = 0,
    this.lastExposedAt,
    this.shelvedAt,
    this.lastHoldingRevisitSuggestedAt,
    this.lastHoldingRevisitConfirmedAt,
    this.lastHoldingRevisitDismissedAt,
  });

  final String id;
  final String title;
  final String? note;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastInteractedAt;
  final DateTime? resurfaceAt;
  final DateTime? closedAt;

  /// Cached compatibility metadata.
  ///
  /// Suggestion/recommendation policy should prefer projection from
  /// [TaskSuggestionHistory] when available. These fields are kept so existing
  /// persisted rows and simple UI reads still work without reconstructing full
  /// history on every access.
  final int consecutiveSnoozeCount;
  final int consecutiveNoActionCount;
  final DateTime? lastExposedAt;
  final DateTime? shelvedAt;
  final DateTime? lastHoldingRevisitSuggestedAt;
  final DateTime? lastHoldingRevisitConfirmedAt;
  final DateTime? lastHoldingRevisitDismissedAt;

  bool get isUnderResurfaceCooldown =>
      resurfaceAt != null && resurfaceAt!.isAfter(DateTime.now());

  bool get isAvailableForReexposure =>
      status == TaskStatus.postponing && !isUnderResurfaceCooldown;

  bool get isHoldingBoxSuggestionCandidate =>
      consecutiveSnoozeCount >= 3 ||
      consecutiveNoActionCount >=
          ProductPolicyDefaults.holdingBoxSuggestionThreshold;

  bool get isEligibleForHoldingBoxRevisitSuggestion {
    if (status != TaskStatus.shelved || shelvedAt == null) {
      return false;
    }

    final now = DateTime.now();
    final revisitAnchor =
        [
          shelvedAt,
          lastHoldingRevisitSuggestedAt,
          lastHoldingRevisitDismissedAt,
        ].whereType<DateTime>().fold<DateTime>(
          shelvedAt!,
          (latest, current) => current.isAfter(latest) ? current : latest,
        );

    return !revisitAnchor
        .add(ProductPolicyDefaults.holdingBoxRevisitSuggestion)
        .isAfter(now);
  }

  Task copyWith({
    String? id,
    String? title,
    String? note,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInteractedAt,
    DateTime? resurfaceAt,
    bool clearResurfaceAt = false,
    DateTime? closedAt,
    bool clearClosedAt = false,
    int? consecutiveSnoozeCount,
    int? consecutiveNoActionCount,
    DateTime? lastExposedAt,
    DateTime? shelvedAt,
    bool clearShelvedAt = false,
    DateTime? lastHoldingRevisitSuggestedAt,
    bool clearLastHoldingRevisitSuggestedAt = false,
    DateTime? lastHoldingRevisitConfirmedAt,
    bool clearLastHoldingRevisitConfirmedAt = false,
    DateTime? lastHoldingRevisitDismissedAt,
    bool clearLastHoldingRevisitDismissedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
      resurfaceAt: clearResurfaceAt ? null : (resurfaceAt ?? this.resurfaceAt),
      closedAt: clearClosedAt ? null : (closedAt ?? this.closedAt),
      consecutiveSnoozeCount:
          consecutiveSnoozeCount ?? this.consecutiveSnoozeCount,
      consecutiveNoActionCount:
          consecutiveNoActionCount ?? this.consecutiveNoActionCount,
      lastExposedAt: lastExposedAt ?? this.lastExposedAt,
      shelvedAt: clearShelvedAt ? null : (shelvedAt ?? this.shelvedAt),
      lastHoldingRevisitSuggestedAt: clearLastHoldingRevisitSuggestedAt
          ? null
          : (lastHoldingRevisitSuggestedAt ??
                this.lastHoldingRevisitSuggestedAt),
      lastHoldingRevisitConfirmedAt: clearLastHoldingRevisitConfirmedAt
          ? null
          : (lastHoldingRevisitConfirmedAt ??
                this.lastHoldingRevisitConfirmedAt),
      lastHoldingRevisitDismissedAt: clearLastHoldingRevisitDismissedAt
          ? null
          : (lastHoldingRevisitDismissedAt ??
                this.lastHoldingRevisitDismissedAt),
    );
  }
}
