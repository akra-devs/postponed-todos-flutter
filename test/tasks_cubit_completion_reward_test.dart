import 'package:flutter_test/flutter_test.dart';

import 'package:postponed_todos/core/config/product_policy_defaults.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/data/in_memory_task_repository.dart';

void main() {
  group('TasksCubit completion reward throttling', () {
    test(
      'suppresses rhythm-eligible attempts during cooldown window',
      () async {
        final repository = InMemoryTaskRepository();
        final cubit = TasksCubit(
          repository,
          DefaultTaskRecommendationService(),
        );
        final now = DateTime(2026, 4, 6, 12, 0);
        final cooldown = ProductPolicyDefaults.completionRewardThrottleCooldown;

        expect(await cubit.shouldShowCompletionReward(now: now), isTrue);

        expect(
          await cubit.shouldShowCompletionReward(
            now: now.add(const Duration(minutes: 5)),
          ),
          isFalse,
        );
        // 3번째 시도인데, 쿨다운 동안에는 모달이 뜨면 안 됨
        expect(
          await cubit.shouldShowCompletionReward(
            now: now.add(const Duration(minutes: 10)),
          ),
          isFalse,
        );

        expect(
          await cubit.shouldShowCompletionReward(
            now: now.add(cooldown + const Duration(minutes: 1)),
          ),
          isFalse,
        );
        expect(
          await cubit.shouldShowCompletionReward(
            now: now.add(Duration(minutes: cooldown.inMinutes * 2 + 1)),
          ),
          isFalse,
        );
        expect(
          await cubit.shouldShowCompletionReward(
            now: now.add(Duration(minutes: cooldown.inMinutes * 3 + 1)),
          ),
          isTrue,
        );

        await cubit.close();
        await repository.dispose();
      },
    );

    test('keeps cooldown state across cubit recreation', () async {
      final repository = InMemoryTaskRepository();
      final firstCubit = TasksCubit(
        repository,
        DefaultTaskRecommendationService(),
      );
      final now = DateTime(2026, 4, 6, 13, 0);

      expect(await firstCubit.shouldShowCompletionReward(now: now), isTrue);
      await firstCubit.close();

      final secondCubit = TasksCubit(
        repository,
        DefaultTaskRecommendationService(),
      );
      expect(
        await secondCubit.shouldShowCompletionReward(
          now: now.add(const Duration(minutes: 1)),
        ),
        isFalse,
      );
      // 재시작 후에도 마지막 표시 시각이 남아 있어 즉시 노출되지 않음
      expect(
        await secondCubit.shouldShowCompletionReward(
          now: now.add(const Duration(minutes: 2)),
        ),
        isFalse,
      );

      await secondCubit.close();
      await repository.dispose();
    });

    int simulateRewardShows({
      required Duration cooldown,
      List<int> attemptOffsetsMinutes = const [
        0,
        10,
        20,
        30,
        40,
        50,
        60,
        70,
        80,
        90,
        100,
        110,
      ],
    }) {
      var attempt = 0;
      DateTime? lastShownAt;
      var showCount = 0;
      final base = DateTime(2026, 4, 6, 12, 0);

      for (final offset in attemptOffsetsMinutes) {
        attempt += 1;
        final now = base.add(Duration(minutes: offset));
        if (attempt == 1 || attempt % 3 == 0) {
          if (lastShownAt == null || now.difference(lastShownAt) >= cooldown) {
            showCount += 1;
            lastShownAt = now;
          }
        }
      }

      return showCount;
    }

    test('compares cooldown thresholds with rapid completion bursts', () {
      expect(
        simulateRewardShows(cooldown: const Duration(minutes: 30)),
        equals(4),
      );
      expect(
        simulateRewardShows(cooldown: const Duration(minutes: 45)),
        equals(3),
      );
      expect(
        simulateRewardShows(cooldown: const Duration(minutes: 60)),
        equals(2),
      );
    });
  });
}
