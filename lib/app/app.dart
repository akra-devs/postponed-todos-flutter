import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/tasks/application/default_task_recommendation_service.dart';
import '../features/tasks/application/tasks_cubit.dart';
import '../features/tasks/data/task_repository.dart';
import '../features/tasks/presentation/tasks_shell_screen.dart';
import 'app_services.dart';

class PostponedTodosApp extends StatefulWidget {
  const PostponedTodosApp({super.key});

  @override
  State<PostponedTodosApp> createState() => _PostponedTodosAppState();
}

class _PostponedTodosAppState extends State<PostponedTodosApp> {
  late final AppServices _services;
  late final TaskRepository _repository;
  late final DefaultTaskRecommendationService _recommendationService;

  @override
  void initState() {
    super.initState();
    _services = createAppServices();
    _repository = _services.repository;
    _recommendationService = const DefaultTaskRecommendationService();
  }

  @override
  void dispose() {
    _services.dispose();
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
          darkTheme: buildAppTheme(brightness: Brightness.dark),
          themeMode: ThemeMode.system,
          supportedLocales: const [Locale('ko'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const TasksShellScreen(),
        ),
      ),
    );
  }
}
