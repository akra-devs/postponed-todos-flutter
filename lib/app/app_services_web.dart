import '../features/tasks/data/in_memory_task_repository.dart';
import 'app_services_model.dart';

AppServices createPlatformAppServices() {
  final repository = InMemoryTaskRepository();

  return AppServices(
    repository: repository,
    dispose: repository.dispose,
  );
}
