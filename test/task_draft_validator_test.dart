import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/task_draft_validator.dart';

void main() {
  group('TaskDraftValidator', () {
    test('requires a non-empty trimmed title', () {
      expect(TaskDraftValidator.titleError(null), isNotNull);
      expect(TaskDraftValidator.titleError('   '), isNotNull);
      expect(TaskDraftValidator.titleError('다시 시작하기'), isNull);
    });

    test('enforces safe title and note limits', () {
      expect(
        TaskDraftValidator.titleError(
          '가' * (TaskDraftValidator.maxTitleLength + 1),
        ),
        isNotNull,
      );
      expect(
        TaskDraftValidator.noteError(
          '메' * (TaskDraftValidator.maxNoteLength + 1),
        ),
        isNotNull,
      );
    });

    test('normalizes optional notes without keeping blank values', () {
      expect(TaskDraftValidator.normalizeTitle('  병원 예약  '), '병원 예약');
      expect(TaskDraftValidator.normalizeNote('  메모  '), '메모');
      expect(TaskDraftValidator.normalizeNote('  '), isNull);
    });
  });
}
