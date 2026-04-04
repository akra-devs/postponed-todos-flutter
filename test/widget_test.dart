import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/core/config/product_policy_defaults.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';
import 'package:postponed_todos/features/tasks/domain/task_transition.dart';

void main() {
  test('postponing task can move into supported follow-up states', () {
    expect(
      TaskTransitionRule.canTransition(
        TaskStatus.postponing,
        TaskStatus.shelved,
      ),
      isTrue,
    );
    expect(
      TaskTransitionRule.canTransition(TaskStatus.postponing, TaskStatus.done),
      isTrue,
    );
    expect(
      TaskTransitionRule.canTransition(
        TaskStatus.postponing,
        TaskStatus.dropped,
      ),
      isTrue,
    );
  });

  test('snooze cooldown follows staged reexposure policy', () {
    expect(
      ProductPolicyDefaults.cooldownForSnoozeCount(1),
      const Duration(hours: 24),
    );
    expect(
      ProductPolicyDefaults.cooldownForSnoozeCount(2),
      const Duration(hours: 72),
    );
    expect(
      ProductPolicyDefaults.cooldownForSnoozeCount(3),
      const Duration(days: 7),
    );
  });
}
