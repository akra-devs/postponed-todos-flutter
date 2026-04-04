import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postponed_todos/core/theme/app_theme.dart';
import 'package:postponed_todos/features/tasks/application/default_task_recommendation_service.dart';
import 'package:postponed_todos/features/tasks/application/tasks_cubit.dart';
import 'package:postponed_todos/features/tasks/data/in_memory_task_repository.dart';
import 'package:postponed_todos/features/tasks/presentation/shelved_tasks_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShelvedTasksScreen polish', () {
    late InMemoryTaskRepository repository;
    late TasksCubit cubit;

    setUp(() {
      repository = InMemoryTaskRepository();
      cubit = TasksCubit(repository, const DefaultTaskRecommendationService());
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    testWidgets('shows calmer holding-box intro and empty-state copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: BlocProvider.value(
            value: cubit,
            child: const ShelvedTasksScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('잠시 쉬어두는 선반'), findsOneWidget);
      expect(find.text('지금은 조용히 쉬는 칸'), findsOneWidget);
      expect(find.text('아직 내려둔 일이 없어요'), findsOneWidget);
      expect(find.textContaining('필요해질 때 다시 꺼내면 돼요'), findsOneWidget);
    });
  });
}
