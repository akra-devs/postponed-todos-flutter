import '../features/tasks/data/drift_task_repository.dart';
import '../features/tasks/data/local/app_database.dart';
import 'app_services_model.dart';

AppServices createPlatformAppServices() {
  final database = AppDatabase();
  final repository = DriftTaskRepository(database);

  return AppServices(
    repository: repository,
    dispose: () => database.close(),
  );
}
