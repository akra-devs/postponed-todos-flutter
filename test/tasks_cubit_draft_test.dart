import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/application/tasks_state.dart';
import 'package:postponed_todos/features/tasks/data/in_memory_task_repository.dart';
import 'package:postponed_todos/features/tasks/domain/task.dart';
import 'package:postponed_todos/features/tasks/domain/task_status.dart';

void main() {
  group('TasksCubit draft handling', () {
    late InMemoryTaskRepository repository;
    late TasksCubit cubit;

    setUp(() {
      repository = InMemoryTaskRepository();
      cubit = TasksCubit(repository, DefaultTaskRecommendationService());
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    test('rejects invalid drafts without creating a task', () async {
      expect(await cubit.addTask(title: ' ', note: null), isFalse);
      expect(cubit.state.operationFailure, TaskOperationFailure.validation);
      expect(await repository.getAll(), isEmpty);
    });

    test('updates and clears an optional note safely', () async {
      final now = DateTime(2020, 8, 8, 12);
      final task = Task(
        id: 'task-1',
        title: '기존 제목',
        note: '기존 메모',
        status: TaskStatus.postponing,
        createdAt: now,
        updatedAt: now,
      );
      await repository.save(task);

      expect(
        await cubit.updateTask(task: task, title: '  새 제목  ', note: ' '),
        isTrue,
      );

      final updated = await repository.getById(task.id);
      expect(updated?.title, '새 제목');
      expect(updated?.note, isNull);
      expect(updated?.updatedAt.isAfter(now), isTrue);
    });
  });
}
