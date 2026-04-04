import 'task_status.dart';

class TaskTransitionRule {
  const TaskTransitionRule._();

  static const Map<TaskStatus, Set<TaskStatus>> allowed = {
    TaskStatus.postponing: {
      TaskStatus.shelved,
      TaskStatus.done,
      TaskStatus.dropped,
    },
    TaskStatus.shelved: {
      TaskStatus.postponing,
      TaskStatus.done,
      TaskStatus.dropped,
    },
    TaskStatus.done: {},
    TaskStatus.dropped: {},
  };

  static bool canTransition(TaskStatus from, TaskStatus to) {
    return allowed[from]?.contains(to) ?? false;
  }
}
