// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TasksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastInteractedAtMeta = const VerificationMeta(
    'lastInteractedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteractedAt =
      GeneratedColumn<DateTime>(
        'last_interacted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resurfaceAtMeta = const VerificationMeta(
    'resurfaceAt',
  );
  @override
  late final GeneratedColumn<DateTime> resurfaceAt = GeneratedColumn<DateTime>(
    'resurface_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consecutiveSnoozeCountMeta =
      const VerificationMeta('consecutiveSnoozeCount');
  @override
  late final GeneratedColumn<int> consecutiveSnoozeCount = GeneratedColumn<int>(
    'consecutive_snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _consecutiveNoActionCountMeta =
      const VerificationMeta('consecutiveNoActionCount');
  @override
  late final GeneratedColumn<int> consecutiveNoActionCount =
      GeneratedColumn<int>(
        'consecutive_no_action_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastExposedAtMeta = const VerificationMeta(
    'lastExposedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExposedAt =
      GeneratedColumn<DateTime>(
        'last_exposed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shelvedAtMeta = const VerificationMeta(
    'shelvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> shelvedAt = GeneratedColumn<DateTime>(
    'shelved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastHoldingRevisitSuggestedAtMeta =
      const VerificationMeta('lastHoldingRevisitSuggestedAt');
  @override
  late final GeneratedColumn<DateTime> lastHoldingRevisitSuggestedAt =
      GeneratedColumn<DateTime>(
        'last_holding_revisit_suggested_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastHoldingRevisitConfirmedAtMeta =
      const VerificationMeta('lastHoldingRevisitConfirmedAt');
  @override
  late final GeneratedColumn<DateTime> lastHoldingRevisitConfirmedAt =
      GeneratedColumn<DateTime>(
        'last_holding_revisit_confirmed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastHoldingRevisitDismissedAtMeta =
      const VerificationMeta('lastHoldingRevisitDismissedAt');
  @override
  late final GeneratedColumn<DateTime> lastHoldingRevisitDismissedAt =
      GeneratedColumn<DateTime>(
        'last_holding_revisit_dismissed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    lastInteractedAt,
    resurfaceAt,
    closedAt,
    consecutiveSnoozeCount,
    consecutiveNoActionCount,
    lastExposedAt,
    shelvedAt,
    lastHoldingRevisitSuggestedAt,
    lastHoldingRevisitConfirmedAt,
    lastHoldingRevisitDismissedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_interacted_at')) {
      context.handle(
        _lastInteractedAtMeta,
        lastInteractedAt.isAcceptableOrUnknown(
          data['last_interacted_at']!,
          _lastInteractedAtMeta,
        ),
      );
    }
    if (data.containsKey('resurface_at')) {
      context.handle(
        _resurfaceAtMeta,
        resurfaceAt.isAcceptableOrUnknown(
          data['resurface_at']!,
          _resurfaceAtMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('consecutive_snooze_count')) {
      context.handle(
        _consecutiveSnoozeCountMeta,
        consecutiveSnoozeCount.isAcceptableOrUnknown(
          data['consecutive_snooze_count']!,
          _consecutiveSnoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('consecutive_no_action_count')) {
      context.handle(
        _consecutiveNoActionCountMeta,
        consecutiveNoActionCount.isAcceptableOrUnknown(
          data['consecutive_no_action_count']!,
          _consecutiveNoActionCountMeta,
        ),
      );
    }
    if (data.containsKey('last_exposed_at')) {
      context.handle(
        _lastExposedAtMeta,
        lastExposedAt.isAcceptableOrUnknown(
          data['last_exposed_at']!,
          _lastExposedAtMeta,
        ),
      );
    }
    if (data.containsKey('shelved_at')) {
      context.handle(
        _shelvedAtMeta,
        shelvedAt.isAcceptableOrUnknown(data['shelved_at']!, _shelvedAtMeta),
      );
    }
    if (data.containsKey('last_holding_revisit_suggested_at')) {
      context.handle(
        _lastHoldingRevisitSuggestedAtMeta,
        lastHoldingRevisitSuggestedAt.isAcceptableOrUnknown(
          data['last_holding_revisit_suggested_at']!,
          _lastHoldingRevisitSuggestedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_holding_revisit_confirmed_at')) {
      context.handle(
        _lastHoldingRevisitConfirmedAtMeta,
        lastHoldingRevisitConfirmedAt.isAcceptableOrUnknown(
          data['last_holding_revisit_confirmed_at']!,
          _lastHoldingRevisitConfirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_holding_revisit_dismissed_at')) {
      context.handle(
        _lastHoldingRevisitDismissedAtMeta,
        lastHoldingRevisitDismissedAt.isAcceptableOrUnknown(
          data['last_holding_revisit_dismissed_at']!,
          _lastHoldingRevisitDismissedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastInteractedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interacted_at'],
      ),
      resurfaceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resurface_at'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      consecutiveSnoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_snooze_count'],
      )!,
      consecutiveNoActionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_no_action_count'],
      )!,
      lastExposedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_exposed_at'],
      ),
      shelvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shelved_at'],
      ),
      lastHoldingRevisitSuggestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_holding_revisit_suggested_at'],
      ),
      lastHoldingRevisitConfirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_holding_revisit_confirmed_at'],
      ),
      lastHoldingRevisitDismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_holding_revisit_dismissed_at'],
      ),
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TasksTableData extends DataClass implements Insertable<TasksTableData> {
  final String id;
  final String title;
  final String? note;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastInteractedAt;
  final DateTime? resurfaceAt;
  final DateTime? closedAt;
  final int consecutiveSnoozeCount;
  final int consecutiveNoActionCount;
  final DateTime? lastExposedAt;
  final DateTime? shelvedAt;
  final DateTime? lastHoldingRevisitSuggestedAt;
  final DateTime? lastHoldingRevisitConfirmedAt;
  final DateTime? lastHoldingRevisitDismissedAt;
  const TasksTableData({
    required this.id,
    required this.title,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastInteractedAt,
    this.resurfaceAt,
    this.closedAt,
    required this.consecutiveSnoozeCount,
    required this.consecutiveNoActionCount,
    this.lastExposedAt,
    this.shelvedAt,
    this.lastHoldingRevisitSuggestedAt,
    this.lastHoldingRevisitConfirmedAt,
    this.lastHoldingRevisitDismissedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastInteractedAt != null) {
      map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt);
    }
    if (!nullToAbsent || resurfaceAt != null) {
      map['resurface_at'] = Variable<DateTime>(resurfaceAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['consecutive_snooze_count'] = Variable<int>(consecutiveSnoozeCount);
    map['consecutive_no_action_count'] = Variable<int>(
      consecutiveNoActionCount,
    );
    if (!nullToAbsent || lastExposedAt != null) {
      map['last_exposed_at'] = Variable<DateTime>(lastExposedAt);
    }
    if (!nullToAbsent || shelvedAt != null) {
      map['shelved_at'] = Variable<DateTime>(shelvedAt);
    }
    if (!nullToAbsent || lastHoldingRevisitSuggestedAt != null) {
      map['last_holding_revisit_suggested_at'] = Variable<DateTime>(
        lastHoldingRevisitSuggestedAt,
      );
    }
    if (!nullToAbsent || lastHoldingRevisitConfirmedAt != null) {
      map['last_holding_revisit_confirmed_at'] = Variable<DateTime>(
        lastHoldingRevisitConfirmedAt,
      );
    }
    if (!nullToAbsent || lastHoldingRevisitDismissedAt != null) {
      map['last_holding_revisit_dismissed_at'] = Variable<DateTime>(
        lastHoldingRevisitDismissedAt,
      );
    }
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastInteractedAt: lastInteractedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractedAt),
      resurfaceAt: resurfaceAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resurfaceAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      consecutiveSnoozeCount: Value(consecutiveSnoozeCount),
      consecutiveNoActionCount: Value(consecutiveNoActionCount),
      lastExposedAt: lastExposedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExposedAt),
      shelvedAt: shelvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(shelvedAt),
      lastHoldingRevisitSuggestedAt:
          lastHoldingRevisitSuggestedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHoldingRevisitSuggestedAt),
      lastHoldingRevisitConfirmedAt:
          lastHoldingRevisitConfirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHoldingRevisitConfirmedAt),
      lastHoldingRevisitDismissedAt:
          lastHoldingRevisitDismissedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHoldingRevisitDismissedAt),
    );
  }

  factory TasksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastInteractedAt: serializer.fromJson<DateTime?>(
        json['lastInteractedAt'],
      ),
      resurfaceAt: serializer.fromJson<DateTime?>(json['resurfaceAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      consecutiveSnoozeCount: serializer.fromJson<int>(
        json['consecutiveSnoozeCount'],
      ),
      consecutiveNoActionCount: serializer.fromJson<int>(
        json['consecutiveNoActionCount'],
      ),
      lastExposedAt: serializer.fromJson<DateTime?>(json['lastExposedAt']),
      shelvedAt: serializer.fromJson<DateTime?>(json['shelvedAt']),
      lastHoldingRevisitSuggestedAt: serializer.fromJson<DateTime?>(
        json['lastHoldingRevisitSuggestedAt'],
      ),
      lastHoldingRevisitConfirmedAt: serializer.fromJson<DateTime?>(
        json['lastHoldingRevisitConfirmedAt'],
      ),
      lastHoldingRevisitDismissedAt: serializer.fromJson<DateTime?>(
        json['lastHoldingRevisitDismissedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastInteractedAt': serializer.toJson<DateTime?>(lastInteractedAt),
      'resurfaceAt': serializer.toJson<DateTime?>(resurfaceAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'consecutiveSnoozeCount': serializer.toJson<int>(consecutiveSnoozeCount),
      'consecutiveNoActionCount': serializer.toJson<int>(
        consecutiveNoActionCount,
      ),
      'lastExposedAt': serializer.toJson<DateTime?>(lastExposedAt),
      'shelvedAt': serializer.toJson<DateTime?>(shelvedAt),
      'lastHoldingRevisitSuggestedAt': serializer.toJson<DateTime?>(
        lastHoldingRevisitSuggestedAt,
      ),
      'lastHoldingRevisitConfirmedAt': serializer.toJson<DateTime?>(
        lastHoldingRevisitConfirmedAt,
      ),
      'lastHoldingRevisitDismissedAt': serializer.toJson<DateTime?>(
        lastHoldingRevisitDismissedAt,
      ),
    };
  }

  TasksTableData copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastInteractedAt = const Value.absent(),
    Value<DateTime?> resurfaceAt = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
    int? consecutiveSnoozeCount,
    int? consecutiveNoActionCount,
    Value<DateTime?> lastExposedAt = const Value.absent(),
    Value<DateTime?> shelvedAt = const Value.absent(),
    Value<DateTime?> lastHoldingRevisitSuggestedAt = const Value.absent(),
    Value<DateTime?> lastHoldingRevisitConfirmedAt = const Value.absent(),
    Value<DateTime?> lastHoldingRevisitDismissedAt = const Value.absent(),
  }) => TasksTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastInteractedAt: lastInteractedAt.present
        ? lastInteractedAt.value
        : this.lastInteractedAt,
    resurfaceAt: resurfaceAt.present ? resurfaceAt.value : this.resurfaceAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    consecutiveSnoozeCount:
        consecutiveSnoozeCount ?? this.consecutiveSnoozeCount,
    consecutiveNoActionCount:
        consecutiveNoActionCount ?? this.consecutiveNoActionCount,
    lastExposedAt: lastExposedAt.present
        ? lastExposedAt.value
        : this.lastExposedAt,
    shelvedAt: shelvedAt.present ? shelvedAt.value : this.shelvedAt,
    lastHoldingRevisitSuggestedAt: lastHoldingRevisitSuggestedAt.present
        ? lastHoldingRevisitSuggestedAt.value
        : this.lastHoldingRevisitSuggestedAt,
    lastHoldingRevisitConfirmedAt: lastHoldingRevisitConfirmedAt.present
        ? lastHoldingRevisitConfirmedAt.value
        : this.lastHoldingRevisitConfirmedAt,
    lastHoldingRevisitDismissedAt: lastHoldingRevisitDismissedAt.present
        ? lastHoldingRevisitDismissedAt.value
        : this.lastHoldingRevisitDismissedAt,
  );
  TasksTableData copyWithCompanion(TasksTableCompanion data) {
    return TasksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastInteractedAt: data.lastInteractedAt.present
          ? data.lastInteractedAt.value
          : this.lastInteractedAt,
      resurfaceAt: data.resurfaceAt.present
          ? data.resurfaceAt.value
          : this.resurfaceAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      consecutiveSnoozeCount: data.consecutiveSnoozeCount.present
          ? data.consecutiveSnoozeCount.value
          : this.consecutiveSnoozeCount,
      consecutiveNoActionCount: data.consecutiveNoActionCount.present
          ? data.consecutiveNoActionCount.value
          : this.consecutiveNoActionCount,
      lastExposedAt: data.lastExposedAt.present
          ? data.lastExposedAt.value
          : this.lastExposedAt,
      shelvedAt: data.shelvedAt.present ? data.shelvedAt.value : this.shelvedAt,
      lastHoldingRevisitSuggestedAt: data.lastHoldingRevisitSuggestedAt.present
          ? data.lastHoldingRevisitSuggestedAt.value
          : this.lastHoldingRevisitSuggestedAt,
      lastHoldingRevisitConfirmedAt: data.lastHoldingRevisitConfirmedAt.present
          ? data.lastHoldingRevisitConfirmedAt.value
          : this.lastHoldingRevisitConfirmedAt,
      lastHoldingRevisitDismissedAt: data.lastHoldingRevisitDismissedAt.present
          ? data.lastHoldingRevisitDismissedAt.value
          : this.lastHoldingRevisitDismissedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastInteractedAt: $lastInteractedAt, ')
          ..write('resurfaceAt: $resurfaceAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('consecutiveSnoozeCount: $consecutiveSnoozeCount, ')
          ..write('consecutiveNoActionCount: $consecutiveNoActionCount, ')
          ..write('lastExposedAt: $lastExposedAt, ')
          ..write('shelvedAt: $shelvedAt, ')
          ..write(
            'lastHoldingRevisitSuggestedAt: $lastHoldingRevisitSuggestedAt, ',
          )
          ..write(
            'lastHoldingRevisitConfirmedAt: $lastHoldingRevisitConfirmedAt, ',
          )
          ..write(
            'lastHoldingRevisitDismissedAt: $lastHoldingRevisitDismissedAt',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    lastInteractedAt,
    resurfaceAt,
    closedAt,
    consecutiveSnoozeCount,
    consecutiveNoActionCount,
    lastExposedAt,
    shelvedAt,
    lastHoldingRevisitSuggestedAt,
    lastHoldingRevisitConfirmedAt,
    lastHoldingRevisitDismissedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastInteractedAt == this.lastInteractedAt &&
          other.resurfaceAt == this.resurfaceAt &&
          other.closedAt == this.closedAt &&
          other.consecutiveSnoozeCount == this.consecutiveSnoozeCount &&
          other.consecutiveNoActionCount == this.consecutiveNoActionCount &&
          other.lastExposedAt == this.lastExposedAt &&
          other.shelvedAt == this.shelvedAt &&
          other.lastHoldingRevisitSuggestedAt ==
              this.lastHoldingRevisitSuggestedAt &&
          other.lastHoldingRevisitConfirmedAt ==
              this.lastHoldingRevisitConfirmedAt &&
          other.lastHoldingRevisitDismissedAt ==
              this.lastHoldingRevisitDismissedAt);
}

class TasksTableCompanion extends UpdateCompanion<TasksTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastInteractedAt;
  final Value<DateTime?> resurfaceAt;
  final Value<DateTime?> closedAt;
  final Value<int> consecutiveSnoozeCount;
  final Value<int> consecutiveNoActionCount;
  final Value<DateTime?> lastExposedAt;
  final Value<DateTime?> shelvedAt;
  final Value<DateTime?> lastHoldingRevisitSuggestedAt;
  final Value<DateTime?> lastHoldingRevisitConfirmedAt;
  final Value<DateTime?> lastHoldingRevisitDismissedAt;
  final Value<int> rowid;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastInteractedAt = const Value.absent(),
    this.resurfaceAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.consecutiveSnoozeCount = const Value.absent(),
    this.consecutiveNoActionCount = const Value.absent(),
    this.lastExposedAt = const Value.absent(),
    this.shelvedAt = const Value.absent(),
    this.lastHoldingRevisitSuggestedAt = const Value.absent(),
    this.lastHoldingRevisitConfirmedAt = const Value.absent(),
    this.lastHoldingRevisitDismissedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksTableCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastInteractedAt = const Value.absent(),
    this.resurfaceAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.consecutiveSnoozeCount = const Value.absent(),
    this.consecutiveNoActionCount = const Value.absent(),
    this.lastExposedAt = const Value.absent(),
    this.shelvedAt = const Value.absent(),
    this.lastHoldingRevisitSuggestedAt = const Value.absent(),
    this.lastHoldingRevisitConfirmedAt = const Value.absent(),
    this.lastHoldingRevisitDismissedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TasksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastInteractedAt,
    Expression<DateTime>? resurfaceAt,
    Expression<DateTime>? closedAt,
    Expression<int>? consecutiveSnoozeCount,
    Expression<int>? consecutiveNoActionCount,
    Expression<DateTime>? lastExposedAt,
    Expression<DateTime>? shelvedAt,
    Expression<DateTime>? lastHoldingRevisitSuggestedAt,
    Expression<DateTime>? lastHoldingRevisitConfirmedAt,
    Expression<DateTime>? lastHoldingRevisitDismissedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastInteractedAt != null) 'last_interacted_at': lastInteractedAt,
      if (resurfaceAt != null) 'resurface_at': resurfaceAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (consecutiveSnoozeCount != null)
        'consecutive_snooze_count': consecutiveSnoozeCount,
      if (consecutiveNoActionCount != null)
        'consecutive_no_action_count': consecutiveNoActionCount,
      if (lastExposedAt != null) 'last_exposed_at': lastExposedAt,
      if (shelvedAt != null) 'shelved_at': shelvedAt,
      if (lastHoldingRevisitSuggestedAt != null)
        'last_holding_revisit_suggested_at': lastHoldingRevisitSuggestedAt,
      if (lastHoldingRevisitConfirmedAt != null)
        'last_holding_revisit_confirmed_at': lastHoldingRevisitConfirmedAt,
      if (lastHoldingRevisitDismissedAt != null)
        'last_holding_revisit_dismissed_at': lastHoldingRevisitDismissedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastInteractedAt,
    Value<DateTime?>? resurfaceAt,
    Value<DateTime?>? closedAt,
    Value<int>? consecutiveSnoozeCount,
    Value<int>? consecutiveNoActionCount,
    Value<DateTime?>? lastExposedAt,
    Value<DateTime?>? shelvedAt,
    Value<DateTime?>? lastHoldingRevisitSuggestedAt,
    Value<DateTime?>? lastHoldingRevisitConfirmedAt,
    Value<DateTime?>? lastHoldingRevisitDismissedAt,
    Value<int>? rowid,
  }) {
    return TasksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInteractedAt: lastInteractedAt ?? this.lastInteractedAt,
      resurfaceAt: resurfaceAt ?? this.resurfaceAt,
      closedAt: closedAt ?? this.closedAt,
      consecutiveSnoozeCount:
          consecutiveSnoozeCount ?? this.consecutiveSnoozeCount,
      consecutiveNoActionCount:
          consecutiveNoActionCount ?? this.consecutiveNoActionCount,
      lastExposedAt: lastExposedAt ?? this.lastExposedAt,
      shelvedAt: shelvedAt ?? this.shelvedAt,
      lastHoldingRevisitSuggestedAt:
          lastHoldingRevisitSuggestedAt ?? this.lastHoldingRevisitSuggestedAt,
      lastHoldingRevisitConfirmedAt:
          lastHoldingRevisitConfirmedAt ?? this.lastHoldingRevisitConfirmedAt,
      lastHoldingRevisitDismissedAt:
          lastHoldingRevisitDismissedAt ?? this.lastHoldingRevisitDismissedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastInteractedAt.present) {
      map['last_interacted_at'] = Variable<DateTime>(lastInteractedAt.value);
    }
    if (resurfaceAt.present) {
      map['resurface_at'] = Variable<DateTime>(resurfaceAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (consecutiveSnoozeCount.present) {
      map['consecutive_snooze_count'] = Variable<int>(
        consecutiveSnoozeCount.value,
      );
    }
    if (consecutiveNoActionCount.present) {
      map['consecutive_no_action_count'] = Variable<int>(
        consecutiveNoActionCount.value,
      );
    }
    if (lastExposedAt.present) {
      map['last_exposed_at'] = Variable<DateTime>(lastExposedAt.value);
    }
    if (shelvedAt.present) {
      map['shelved_at'] = Variable<DateTime>(shelvedAt.value);
    }
    if (lastHoldingRevisitSuggestedAt.present) {
      map['last_holding_revisit_suggested_at'] = Variable<DateTime>(
        lastHoldingRevisitSuggestedAt.value,
      );
    }
    if (lastHoldingRevisitConfirmedAt.present) {
      map['last_holding_revisit_confirmed_at'] = Variable<DateTime>(
        lastHoldingRevisitConfirmedAt.value,
      );
    }
    if (lastHoldingRevisitDismissedAt.present) {
      map['last_holding_revisit_dismissed_at'] = Variable<DateTime>(
        lastHoldingRevisitDismissedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastInteractedAt: $lastInteractedAt, ')
          ..write('resurfaceAt: $resurfaceAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('consecutiveSnoozeCount: $consecutiveSnoozeCount, ')
          ..write('consecutiveNoActionCount: $consecutiveNoActionCount, ')
          ..write('lastExposedAt: $lastExposedAt, ')
          ..write('shelvedAt: $shelvedAt, ')
          ..write(
            'lastHoldingRevisitSuggestedAt: $lastHoldingRevisitSuggestedAt, ',
          )
          ..write(
            'lastHoldingRevisitConfirmedAt: $lastHoldingRevisitConfirmedAt, ',
          )
          ..write(
            'lastHoldingRevisitDismissedAt: $lastHoldingRevisitDismissedAt, ',
          )
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSuggestionEventsTableTable extends TaskSuggestionEventsTable
    with
        TableInfo<
          $TaskSuggestionEventsTableTable,
          TaskSuggestionEventsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSuggestionEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_suggestion_events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSuggestionEventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSuggestionEventsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSuggestionEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskSuggestionEventsTableTable createAlias(String alias) {
    return $TaskSuggestionEventsTableTable(attachedDatabase, alias);
  }
}

class TaskSuggestionEventsTableData extends DataClass
    implements Insertable<TaskSuggestionEventsTableData> {
  final String id;
  final String taskId;
  final String type;
  final DateTime createdAt;
  const TaskSuggestionEventsTableData({
    required this.id,
    required this.taskId,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskSuggestionEventsTableCompanion toCompanion(bool nullToAbsent) {
    return TaskSuggestionEventsTableCompanion(
      id: Value(id),
      taskId: Value(taskId),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory TaskSuggestionEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSuggestionEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskSuggestionEventsTableData copyWith({
    String? id,
    String? taskId,
    String? type,
    DateTime? createdAt,
  }) => TaskSuggestionEventsTableData(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskSuggestionEventsTableData copyWithCompanion(
    TaskSuggestionEventsTableCompanion data,
  ) {
    return TaskSuggestionEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSuggestionEventsTableData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSuggestionEventsTableData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class TaskSuggestionEventsTableCompanion
    extends UpdateCompanion<TaskSuggestionEventsTableData> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TaskSuggestionEventsTableCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSuggestionEventsTableCompanion.insert({
    required String id,
    required String taskId,
    required String type,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<TaskSuggestionEventsTableData> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSuggestionEventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TaskSuggestionEventsTableCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSuggestionEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $TaskSuggestionEventsTableTable taskSuggestionEventsTable =
      $TaskSuggestionEventsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasksTable,
    taskSuggestionEventsTable,
  ];
}

typedef $$TasksTableTableCreateCompanionBuilder =
    TasksTableCompanion Function({
      required String id,
      required String title,
      Value<String?> note,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastInteractedAt,
      Value<DateTime?> resurfaceAt,
      Value<DateTime?> closedAt,
      Value<int> consecutiveSnoozeCount,
      Value<int> consecutiveNoActionCount,
      Value<DateTime?> lastExposedAt,
      Value<DateTime?> shelvedAt,
      Value<DateTime?> lastHoldingRevisitSuggestedAt,
      Value<DateTime?> lastHoldingRevisitConfirmedAt,
      Value<DateTime?> lastHoldingRevisitDismissedAt,
      Value<int> rowid,
    });
typedef $$TasksTableTableUpdateCompanionBuilder =
    TasksTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> note,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastInteractedAt,
      Value<DateTime?> resurfaceAt,
      Value<DateTime?> closedAt,
      Value<int> consecutiveSnoozeCount,
      Value<int> consecutiveNoActionCount,
      Value<DateTime?> lastExposedAt,
      Value<DateTime?> shelvedAt,
      Value<DateTime?> lastHoldingRevisitSuggestedAt,
      Value<DateTime?> lastHoldingRevisitConfirmedAt,
      Value<DateTime?> lastHoldingRevisitDismissedAt,
      Value<int> rowid,
    });

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resurfaceAt => $composableBuilder(
    column: $table.resurfaceAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveSnoozeCount => $composableBuilder(
    column: $table.consecutiveSnoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveNoActionCount => $composableBuilder(
    column: $table.consecutiveNoActionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExposedAt => $composableBuilder(
    column: $table.lastExposedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shelvedAt => $composableBuilder(
    column: $table.shelvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastHoldingRevisitSuggestedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitSuggestedAt,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastHoldingRevisitConfirmedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitConfirmedAt,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastHoldingRevisitDismissedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitDismissedAt,
        builder: (column) => ColumnFilters(column),
      );
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resurfaceAt => $composableBuilder(
    column: $table.resurfaceAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveSnoozeCount => $composableBuilder(
    column: $table.consecutiveSnoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveNoActionCount => $composableBuilder(
    column: $table.consecutiveNoActionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExposedAt => $composableBuilder(
    column: $table.lastExposedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shelvedAt => $composableBuilder(
    column: $table.shelvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastHoldingRevisitSuggestedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitSuggestedAt,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastHoldingRevisitConfirmedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitConfirmedAt,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastHoldingRevisitDismissedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitDismissedAt,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastInteractedAt => $composableBuilder(
    column: $table.lastInteractedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resurfaceAt => $composableBuilder(
    column: $table.resurfaceAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get consecutiveSnoozeCount => $composableBuilder(
    column: $table.consecutiveSnoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveNoActionCount => $composableBuilder(
    column: $table.consecutiveNoActionCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExposedAt => $composableBuilder(
    column: $table.lastExposedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shelvedAt =>
      $composableBuilder(column: $table.shelvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastHoldingRevisitSuggestedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitSuggestedAt,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastHoldingRevisitConfirmedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitConfirmedAt,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastHoldingRevisitDismissedAt =>
      $composableBuilder(
        column: $table.lastHoldingRevisitDismissedAt,
        builder: (column) => column,
      );
}

class $$TasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTableTable,
          TasksTableData,
          $$TasksTableTableFilterComposer,
          $$TasksTableTableOrderingComposer,
          $$TasksTableTableAnnotationComposer,
          $$TasksTableTableCreateCompanionBuilder,
          $$TasksTableTableUpdateCompanionBuilder,
          (
            TasksTableData,
            BaseReferences<_$AppDatabase, $TasksTableTable, TasksTableData>,
          ),
          TasksTableData,
          PrefetchHooks Function()
        > {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastInteractedAt = const Value.absent(),
                Value<DateTime?> resurfaceAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> consecutiveSnoozeCount = const Value.absent(),
                Value<int> consecutiveNoActionCount = const Value.absent(),
                Value<DateTime?> lastExposedAt = const Value.absent(),
                Value<DateTime?> shelvedAt = const Value.absent(),
                Value<DateTime?> lastHoldingRevisitSuggestedAt =
                    const Value.absent(),
                Value<DateTime?> lastHoldingRevisitConfirmedAt =
                    const Value.absent(),
                Value<DateTime?> lastHoldingRevisitDismissedAt =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastInteractedAt: lastInteractedAt,
                resurfaceAt: resurfaceAt,
                closedAt: closedAt,
                consecutiveSnoozeCount: consecutiveSnoozeCount,
                consecutiveNoActionCount: consecutiveNoActionCount,
                lastExposedAt: lastExposedAt,
                shelvedAt: shelvedAt,
                lastHoldingRevisitSuggestedAt: lastHoldingRevisitSuggestedAt,
                lastHoldingRevisitConfirmedAt: lastHoldingRevisitConfirmedAt,
                lastHoldingRevisitDismissedAt: lastHoldingRevisitDismissedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastInteractedAt = const Value.absent(),
                Value<DateTime?> resurfaceAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> consecutiveSnoozeCount = const Value.absent(),
                Value<int> consecutiveNoActionCount = const Value.absent(),
                Value<DateTime?> lastExposedAt = const Value.absent(),
                Value<DateTime?> shelvedAt = const Value.absent(),
                Value<DateTime?> lastHoldingRevisitSuggestedAt =
                    const Value.absent(),
                Value<DateTime?> lastHoldingRevisitConfirmedAt =
                    const Value.absent(),
                Value<DateTime?> lastHoldingRevisitDismissedAt =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion.insert(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastInteractedAt: lastInteractedAt,
                resurfaceAt: resurfaceAt,
                closedAt: closedAt,
                consecutiveSnoozeCount: consecutiveSnoozeCount,
                consecutiveNoActionCount: consecutiveNoActionCount,
                lastExposedAt: lastExposedAt,
                shelvedAt: shelvedAt,
                lastHoldingRevisitSuggestedAt: lastHoldingRevisitSuggestedAt,
                lastHoldingRevisitConfirmedAt: lastHoldingRevisitConfirmedAt,
                lastHoldingRevisitDismissedAt: lastHoldingRevisitDismissedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTableTable,
      TasksTableData,
      $$TasksTableTableFilterComposer,
      $$TasksTableTableOrderingComposer,
      $$TasksTableTableAnnotationComposer,
      $$TasksTableTableCreateCompanionBuilder,
      $$TasksTableTableUpdateCompanionBuilder,
      (
        TasksTableData,
        BaseReferences<_$AppDatabase, $TasksTableTable, TasksTableData>,
      ),
      TasksTableData,
      PrefetchHooks Function()
    >;
typedef $$TaskSuggestionEventsTableTableCreateCompanionBuilder =
    TaskSuggestionEventsTableCompanion Function({
      required String id,
      required String taskId,
      required String type,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TaskSuggestionEventsTableTableUpdateCompanionBuilder =
    TaskSuggestionEventsTableCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TaskSuggestionEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSuggestionEventsTableTable> {
  $$TaskSuggestionEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskSuggestionEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSuggestionEventsTableTable> {
  $$TaskSuggestionEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskSuggestionEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSuggestionEventsTableTable> {
  $$TaskSuggestionEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaskSuggestionEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSuggestionEventsTableTable,
          TaskSuggestionEventsTableData,
          $$TaskSuggestionEventsTableTableFilterComposer,
          $$TaskSuggestionEventsTableTableOrderingComposer,
          $$TaskSuggestionEventsTableTableAnnotationComposer,
          $$TaskSuggestionEventsTableTableCreateCompanionBuilder,
          $$TaskSuggestionEventsTableTableUpdateCompanionBuilder,
          (
            TaskSuggestionEventsTableData,
            BaseReferences<
              _$AppDatabase,
              $TaskSuggestionEventsTableTable,
              TaskSuggestionEventsTableData
            >,
          ),
          TaskSuggestionEventsTableData,
          PrefetchHooks Function()
        > {
  $$TaskSuggestionEventsTableTableTableManager(
    _$AppDatabase db,
    $TaskSuggestionEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSuggestionEventsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TaskSuggestionEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaskSuggestionEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSuggestionEventsTableCompanion(
                id: id,
                taskId: taskId,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String type,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskSuggestionEventsTableCompanion.insert(
                id: id,
                taskId: taskId,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskSuggestionEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSuggestionEventsTableTable,
      TaskSuggestionEventsTableData,
      $$TaskSuggestionEventsTableTableFilterComposer,
      $$TaskSuggestionEventsTableTableOrderingComposer,
      $$TaskSuggestionEventsTableTableAnnotationComposer,
      $$TaskSuggestionEventsTableTableCreateCompanionBuilder,
      $$TaskSuggestionEventsTableTableUpdateCompanionBuilder,
      (
        TaskSuggestionEventsTableData,
        BaseReferences<
          _$AppDatabase,
          $TaskSuggestionEventsTableTable,
          TaskSuggestionEventsTableData
        >,
      ),
      TaskSuggestionEventsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$TaskSuggestionEventsTableTableTableManager get taskSuggestionEventsTable =>
      $$TaskSuggestionEventsTableTableTableManager(
        _db,
        _db.taskSuggestionEventsTable,
      );
}
