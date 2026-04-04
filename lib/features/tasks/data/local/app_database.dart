import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class TasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastInteractedAt => dateTime().nullable()();
  DateTimeColumn get resurfaceAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get consecutiveSnoozeCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get consecutiveNoActionCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastExposedAt => dateTime().nullable()();
  DateTimeColumn get shelvedAt => dateTime().nullable()();
  DateTimeColumn get lastHoldingRevisitSuggestedAt => dateTime().nullable()();
  DateTimeColumn get lastHoldingRevisitConfirmedAt => dateTime().nullable()();
  DateTimeColumn get lastHoldingRevisitDismissedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TaskSuggestionEventsTable extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [TasksTable, TaskSuggestionEventsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(tasksTable, tasksTable.shelvedAt);
        await migrator.addColumn(
          tasksTable,
          tasksTable.lastHoldingRevisitSuggestedAt,
        );
        await migrator.addColumn(
          tasksTable,
          tasksTable.lastHoldingRevisitConfirmedAt,
        );
        await migrator.addColumn(
          tasksTable,
          tasksTable.lastHoldingRevisitDismissedAt,
        );
      }
      if (from < 3) {
        await migrator.createTable(taskSuggestionEventsTable);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'postponed_todos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
