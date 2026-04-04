import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../features/tasks/application/default_task_recommendation_service.dart';
import '../features/tasks/application/tasks_cubit.dart';
import '../features/tasks/data/drift_task_repository.dart';
import '../features/tasks/data/local/app_database.dart';
import '../features/tasks/presentation/tasks_home_screen.dart';

class PostponedTodosApp extends StatefulWidget {
  const PostponedTodosApp({super.key});

  @override
  State<PostponedTodosApp> createState() => _PostponedTodosAppState();
}

class _PostponedTodosAppState extends State<PostponedTodosApp> {
  late final AppDatabase _database;
  late final DriftTaskRepository _repository;
  late final DefaultTaskRecommendationService _recommendationService;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _repository = DriftTaskRepository(_database);
    _recommendationService = const DefaultTaskRecommendationService();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _repository,
      child: BlocProvider(
        create: (_) => TasksCubit(_repository, _recommendationService),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '미뤄둔 할일들',
          theme: buildAppTheme(),
          home: const TasksHomeScreen(),
        ),
      ),
    );
  }
}
