enum TaskStatus { postponing, shelved, done, dropped }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.postponing => '미루는 중',
    TaskStatus.shelved => '보류함',
    TaskStatus.done => '완료',
    TaskStatus.dropped => '안 하기로 정리',
  };

  String get description => switch (this) {
    TaskStatus.postponing => '아직 붙잡고는 있지만, 지금 당장 하진 않는 상태',
    TaskStatus.shelved => '당분간 거리를 두는 상태',
    TaskStatus.done => '이 일은 마무리됐어',
    TaskStatus.dropped => '더 붙잡지 않기로 한 일',
  };

  bool get isClosed => this == TaskStatus.done || this == TaskStatus.dropped;
}
