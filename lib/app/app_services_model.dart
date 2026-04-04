import '../features/tasks/data/task_repository.dart';

class AppServices {
  const AppServices({
    required this.repository,
    required this.dispose,
  });

  final TaskRepository repository;
  final Future<void> Function() dispose;
}
